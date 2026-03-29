USE be_well;

-- ======================
-- USERS (doctor + patients)
-- ======================

INSERT INTO users (id, email, password_hash, role, first_name, last_name, phone)
VALUES
(1, 'doctor@bewell.com', 'hashed_pass', 'DOCTOR', 'Andrei', 'Popescu', '0711111111'),
(2, 'patient1@bewell.com', 'hashed_pass', 'PATIENT', 'Maria', 'Ionescu', '0722222222'),
(3, 'patient2@bewell.com', 'hashed_pass', 'PATIENT', 'Ion', 'Georgescu', '0733333333');
