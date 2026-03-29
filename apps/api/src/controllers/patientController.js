import pool from '../config/db.js';

/* ===================== GET ALL ===================== */
export async function getAllPatients(req, res) {
    try {
        const [rows] = await pool.query(`
      SELECT
        p.id,
        p.user_id,
        u.first_name,
        u.last_name,
        u.email,
        u.phone,
        p.cnp,
        p.date_of_birth,
        p.age,
        p.gender,
        p.profession,
        p.workplace,
        pa.country,
        pa.county,
        pa.city,
        pa.street,
        pa.street_number,
        pa.building,
        pa.apartment,
        pa.postal_code,
        pmp.medical_history,
        pmp.allergies,
        pmp.cardiology_consultations,
        pmp.normal_ecg_min,
        pmp.normal_ecg_max,
        pmp.normal_pulse_min,
        pmp.normal_pulse_max,
        pmp.normal_temperature_min,
        pmp.normal_temperature_max,
        pmp.normal_humidity_min,
        pmp.normal_humidity_max
      FROM patients p
      JOIN users u ON p.user_id = u.id
      LEFT JOIN patient_addresses pa ON pa.patient_id = p.id
      LEFT JOIN patient_medical_profiles pmp ON pmp.patient_id = p.id
      ORDER BY p.id
    `);

        res.json(rows);
    } catch (error) {
        console.error('GET /api/patients error:', error);
        res.status(500).json({ error: 'Failed to fetch patients' });
    }
}

/* ===================== GET BY ID ===================== */
export async function getPatientById(req, res) {
    const id = req.params.id;

    try {
        const [rows] = await pool.query(`
      SELECT
        p.id,
        p.user_id,
        u.first_name,
        u.last_name,
        u.email,
        u.phone,
        p.cnp,
        p.date_of_birth,
        p.age,
        p.gender,
        p.profession,
        p.workplace,
        pa.country,
        pa.county,
        pa.city,
        pa.street,
        pa.street_number,
        pa.building,
        pa.apartment,
        pa.postal_code,
        pmp.medical_history,
        pmp.allergies,
        pmp.cardiology_consultations,
        pmp.normal_ecg_min,
        pmp.normal_ecg_max,
        pmp.normal_pulse_min,
        pmp.normal_pulse_max,
        pmp.normal_temperature_min,
        pmp.normal_temperature_max,
        pmp.normal_humidity_min,
        pmp.normal_humidity_max
      FROM patients p
      JOIN users u ON p.user_id = u.id
      LEFT JOIN patient_addresses pa ON pa.patient_id = p.id
      LEFT JOIN patient_medical_profiles pmp ON pmp.patient_id = p.id
      WHERE p.id = ?
      LIMIT 1
    `, [id]);

        if (rows.length === 0) {
            return res.status(404).json({ error: 'Patient not found' });
        }

        res.json(rows[0]);
    } catch (error) {
        console.error('GET patient error:', error);
        res.status(500).json({ error: 'Failed to fetch patient' });
    }
}

/* ===================== CREATE ===================== */
export async function createPatient(req, res) {
    const connection = await pool.getConnection();

    try {
        await connection.beginTransaction();

        const body = req.body;

        if (!body.doctor_id || !body.email || !body.password_hash || !body.first_name || !body.last_name || !body.cnp) {
            await connection.rollback();
            return res.status(400).json({ error: 'Missing required fields' });
        }

        /* USER */
        const [userResult] = await connection.query(`
      INSERT INTO users (
        email, password_hash, role, first_name, last_name, phone
      ) VALUES (?, ?, 'PATIENT', ?, ?, ?)
    `, [
            body.email,
            body.password_hash,
            body.first_name,
            body.last_name,
            body.phone ? body.phone : null
        ]);

        const userId = userResult.insertId;

        /* PATIENT */
        const [patientResult] = await connection.query(`
      INSERT INTO patients (
        user_id, cnp, date_of_birth, age, gender, profession, workplace
      ) VALUES (?, ?, ?, ?, ?, ?, ?)
    `, [
            userId,
            body.cnp,
            body.date_of_birth ? body.date_of_birth : null,
            body.age !== undefined ? body.age : null,
            body.gender ? body.gender : 'UNSPECIFIED',
            body.profession ? body.profession : null,
            body.workplace ? body.workplace : null
        ]);

        const patientId = patientResult.insertId;

        /* ASSIGNMENT */
        await connection.query(`
      INSERT INTO doctor_patient_assignments (doctor_id, patient_id)
      VALUES (?, ?)
    `, [body.doctor_id, patientId]);

        /* ADDRESS */
        const address = body.address;

        await connection.query(`
      INSERT INTO patient_addresses (
        patient_id, country, county, city, street, street_number, building, apartment, postal_code
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    `, [
            patientId,
            address && address.country ? address.country : null,
            address && address.county ? address.county : null,
            address && address.city ? address.city : null,
            address && address.street ? address.street : null,
            address && address.street_number ? address.street_number : null,
            address && address.building ? address.building : null,
            address && address.apartment ? address.apartment : null,
            address && address.postal_code ? address.postal_code : null
        ]);

        /* MEDICAL PROFILE */
        const mp = body.medical_profile;

        await connection.query(`
      INSERT INTO patient_medical_profiles (
        patient_id, medical_history, allergies, cardiology_consultations,
        normal_ecg_min, normal_ecg_max,
        normal_pulse_min, normal_pulse_max,
        normal_temperature_min, normal_temperature_max,
        normal_humidity_min, normal_humidity_max
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `, [
            patientId,
            mp && mp.medical_history ? mp.medical_history : null,
            mp && mp.allergies ? mp.allergies : null,
            mp && mp.cardiology_consultations ? mp.cardiology_consultations : null,
            mp && mp.normal_ecg_min !== undefined ? mp.normal_ecg_min : null,
            mp && mp.normal_ecg_max !== undefined ? mp.normal_ecg_max : null,
            mp && mp.normal_pulse_min !== undefined ? mp.normal_pulse_min : null,
            mp && mp.normal_pulse_max !== undefined ? mp.normal_pulse_max : null,
            mp && mp.normal_temperature_min !== undefined ? mp.normal_temperature_min : null,
            mp && mp.normal_temperature_max !== undefined ? mp.normal_temperature_max : null,
            mp && mp.normal_humidity_min !== undefined ? mp.normal_humidity_min : null,
            mp && mp.normal_humidity_max !== undefined ? mp.normal_humidity_max : null
        ]);

        await connection.commit();

        res.status(201).json({
            message: 'Patient created',
            patient_id: patientId
        });

    } catch (error) {
        await connection.rollback();
        console.error('CREATE error:', error);
        res.status(500).json({ error: 'Failed to create patient' });
    } finally {
        connection.release();
    }
}

/* ===================== UPDATE ===================== */
export async function updatePatient(req, res) {
    const id = req.params.id;
    const connection = await pool.getConnection();

    try {
        await connection.beginTransaction();

        const [rows] = await connection.query(
            `SELECT user_id FROM patients WHERE id = ?`, [id]
        );

        if (rows.length === 0) {
            await connection.rollback();
            return res.status(404).json({ error: 'Patient not found' });
        }

        const userId = rows[0].user_id;
        const body = req.body;

        if (!body.email || !body.first_name || !body.last_name || !body.cnp) {
            await connection.rollback();
            return res.status(400).json({
                error: 'email, first_name, last_name and cnp are required'
            });
        }

        await connection.query(`
        UPDATE users
        SET email=?, first_name=?, last_name=?, phone=?
        WHERE id=?
      `, [
            body.email,
            body.first_name,
            body.last_name,
            body.phone ? body.phone : null,
            userId
        ]);

        await connection.query(`
        UPDATE patients
        SET cnp=?, date_of_birth=?, age=?, gender=?, profession=?, workplace=?
        WHERE id=?
      `, [
            body.cnp,
            body.date_of_birth ? body.date_of_birth : null,
            body.age !== undefined ? body.age : null,
            body.gender ? body.gender : 'UNSPECIFIED',
            body.profession ? body.profession : null,
            body.workplace ? body.workplace : null,
            id
        ]);

        await connection.commit();

        res.json({ message: 'Updated successfully' });
    } catch (error) {
        await connection.rollback();
        console.error('UPDATE error:', error);
        res.status(500).json({ error: 'Failed to update patient' });
    } finally {
        connection.release();
    }
}

/* ===================== DELETE ===================== */
export async function deletePatient(req, res) {
    const id = req.params.id;

    try {
        await pool.query(`DELETE FROM users WHERE id = (SELECT user_id FROM patients WHERE id = ?)`, [id]);

        res.json({ message: 'Deleted successfully' });
    } catch (error) {
        console.error('DELETE error:', error);
        res.status(500).json({ error: 'Failed to delete patient' });
    }
}