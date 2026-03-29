USE be_well;

-- PATIENTS
-- ======================

INSERT INTO patients (id, user_id, cnp, date_of_birth, age, gender, profession, workplace)
VALUES
(1, 2, '1234567890123', '1995-05-10', 29, 'FEMALE', 'Engineer', 'Continental'),
(2, 3, '9876543210987', '1990-03-20', 34, 'MALE', 'Teacher', 'High School');

-- ======================
-- DOCTOR - PATIENT ASSIGNMENT
-- ======================

INSERT INTO doctor_patient_assignments (doctor_id, patient_id)
VALUES
(1, 1),
(1, 2);

-- ======================
-- ADDRESSES
-- ======================

INSERT INTO patient_addresses (
    patient_id, country, county, city, street, street_number, building, apartment, postal_code
)
VALUES
(1, 'Romania', 'Timis', 'Timisoara', 'Str Libertatii', '10', NULL, '5', '300123'),
(2, 'Romania', 'Cluj', 'Cluj-Napoca', 'Str Memorandumului', '25', 'B', '12', '400456');

-- ======================
-- MEDICAL PROFILES
-- ======================

INSERT INTO patient_medical_profiles (
    patient_id,
    medical_history,
    allergies,
    cardiology_consultations,
    normal_ecg_min,
    normal_ecg_max,
    normal_pulse_min,
    normal_pulse_max,
    normal_temperature_min,
    normal_temperature_max,
    normal_humidity_min,
    normal_humidity_max
)
VALUES
(
    1,
    'No major illnesses',
    'Pollen',
    'Routine check OK',
    60, 100,
    60, 100,
    36.5, 37.5,
    30, 60
),
(
    2,
    'Hypertension',
    'None',
    'Mild arrhythmia',
    55, 95,
    65, 110,
    36.0, 37.2,
    35, 65
);