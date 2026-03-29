USE be_well;

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS sync_queue_logs;
DROP TABLE IF EXISTS alert_notes;
DROP TABLE IF EXISTS alerts;
DROP TABLE IF EXISTS alert_rules;
DROP TABLE IF EXISTS accelerometer_readings;
DROP TABLE IF EXISTS sensor_readings;
DROP TABLE IF EXISTS activity_sessions;
DROP TABLE IF EXISTS recommendation_schedules;
DROP TABLE IF EXISTS recommendations;
DROP TABLE IF EXISTS patient_device_links;
DROP TABLE IF EXISTS wearable_devices;
DROP TABLE IF EXISTS smartphones;
DROP TABLE IF EXISTS doctor_patient_assignments;
DROP TABLE IF EXISTS patient_medical_profiles;
DROP TABLE IF EXISTS patient_addresses;
DROP TABLE IF EXISTS patients;
DROP TABLE IF EXISTS users;

SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE users (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    email VARCHAR(150) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('ADMIN', 'DOCTOR', 'PATIENT') NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(30) NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_users_email (email)
) ENGINE=InnoDB;

CREATE TABLE patients (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    user_id BIGINT UNSIGNED NOT NULL,
    cnp CHAR(13) NOT NULL,
    date_of_birth DATE NULL,
    age INT NULL,
    gender ENUM('FEMALE', 'MALE', 'OTHER', 'UNSPECIFIED') NOT NULL DEFAULT 'UNSPECIFIED',
    profession VARCHAR(120) NULL,
    workplace VARCHAR(150) NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_patients_user_id (user_id),
    UNIQUE KEY uq_patients_cnp (cnp),
    CONSTRAINT fk_patients_user
        FOREIGN KEY (user_id) REFERENCES users(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT chk_patients_age
        CHECK (age IS NULL OR (age >= 0 AND age <= 130))
) ENGINE=InnoDB;

CREATE TABLE patient_addresses (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    patient_id BIGINT UNSIGNED NOT NULL,
    country VARCHAR(100) NULL,
    county VARCHAR(100) NULL,
    city VARCHAR(100) NULL,
    street VARCHAR(150) NULL,
    street_number VARCHAR(20) NULL,
    building VARCHAR(20) NULL,
    apartment VARCHAR(20) NULL,
    postal_code VARCHAR(20) NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_patient_addresses_patient_id (patient_id),
    CONSTRAINT fk_patient_addresses_patient
        FOREIGN KEY (patient_id) REFERENCES patients(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE patient_medical_profiles (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    patient_id BIGINT UNSIGNED NOT NULL,
    medical_history TEXT NULL,
    allergies TEXT NULL,
    cardiology_consultations TEXT NULL,
    normal_ecg_min DECIMAL(10,2) NULL,
    normal_ecg_max DECIMAL(10,2) NULL,
    normal_pulse_min DECIMAL(10,2) NULL,
    normal_pulse_max DECIMAL(10,2) NULL,
    normal_temperature_min DECIMAL(10,2) NULL,
    normal_temperature_max DECIMAL(10,2) NULL,
    normal_humidity_min DECIMAL(10,2) NULL,
    normal_humidity_max DECIMAL(10,2) NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_patient_medical_profiles_patient_id (patient_id),
    CONSTRAINT fk_patient_medical_profiles_patient
        FOREIGN KEY (patient_id) REFERENCES patients(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT chk_patient_medical_profiles_ecg
        CHECK (
            normal_ecg_min IS NULL OR normal_ecg_max IS NULL OR normal_ecg_min <= normal_ecg_max
        ),
    CONSTRAINT chk_patient_medical_profiles_pulse
        CHECK (
            normal_pulse_min IS NULL OR normal_pulse_max IS NULL OR normal_pulse_min <= normal_pulse_max
        ),
    CONSTRAINT chk_patient_medical_profiles_temperature
        CHECK (
            normal_temperature_min IS NULL OR normal_temperature_max IS NULL OR normal_temperature_min <= normal_temperature_max
        ),
    CONSTRAINT chk_patient_medical_profiles_humidity
        CHECK (
            normal_humidity_min IS NULL OR normal_humidity_max IS NULL OR normal_humidity_min <= normal_humidity_max
        )
) ENGINE=InnoDB;

CREATE TABLE doctor_patient_assignments (
    doctor_id BIGINT UNSIGNED NOT NULL,
    patient_id BIGINT UNSIGNED NOT NULL,
    assigned_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (doctor_id, patient_id),
    CONSTRAINT fk_doctor_patient_assignments_doctor
        FOREIGN KEY (doctor_id) REFERENCES users(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_doctor_patient_assignments_patient
        FOREIGN KEY (patient_id) REFERENCES patients(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE smartphones (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    device_uuid VARCHAR(100) NOT NULL,
    patient_id BIGINT UNSIGNED NOT NULL,
    platform ENUM('ANDROID') NOT NULL DEFAULT 'ANDROID',
    device_name VARCHAR(100) NULL,
    app_version VARCHAR(50) NULL,
    last_seen_at DATETIME NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_smartphones_device_uuid (device_uuid),
    UNIQUE KEY uq_smartphones_patient_id (patient_id),
    CONSTRAINT fk_smartphones_patient
        FOREIGN KEY (patient_id) REFERENCES patients(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE wearable_devices (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    device_serial VARCHAR(100) NOT NULL,
    device_type VARCHAR(50) NOT NULL,
    bluetooth_mac VARCHAR(50) NULL,
    firmware_version VARCHAR(50) NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_wearable_devices_device_serial (device_serial),
    UNIQUE KEY uq_wearable_devices_bluetooth_mac (bluetooth_mac)
) ENGINE=InnoDB;

CREATE TABLE patient_device_links (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    patient_id BIGINT UNSIGNED NOT NULL,
    smartphone_id BIGINT UNSIGNED NOT NULL,
    wearable_device_id BIGINT UNSIGNED NOT NULL,
    linked_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    unlinked_at DATETIME NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY (id),
    UNIQUE KEY uq_patient_device_links_patient_id (patient_id),
    UNIQUE KEY uq_patient_device_links_smartphone_id (smartphone_id),
    UNIQUE KEY uq_patient_device_links_wearable_device_id (wearable_device_id),
    CONSTRAINT fk_patient_device_links_patient
        FOREIGN KEY (patient_id) REFERENCES patients(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_patient_device_links_smartphone
        FOREIGN KEY (smartphone_id) REFERENCES smartphones(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_patient_device_links_wearable
        FOREIGN KEY (wearable_device_id) REFERENCES wearable_devices(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE recommendations (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    doctor_id BIGINT UNSIGNED NOT NULL,
    patient_id BIGINT UNSIGNED NOT NULL,
    recommendation_type VARCHAR(100) NOT NULL,
    daily_duration_minutes INT NOT NULL,
    instructions TEXT NULL,
    start_date DATE NULL,
    end_date DATE NULL,
    status ENUM('ACTIVE', 'COMPLETED', 'CANCELLED') NOT NULL DEFAULT 'ACTIVE',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT fk_recommendations_doctor
        FOREIGN KEY (doctor_id) REFERENCES users(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_recommendations_patient
        FOREIGN KEY (patient_id) REFERENCES patients(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT chk_recommendations_daily_duration
        CHECK (daily_duration_minutes > 0),
    CONSTRAINT chk_recommendations_dates
        CHECK (start_date IS NULL OR end_date IS NULL OR start_date <= end_date)
) ENGINE=InnoDB;

CREATE TABLE recommendation_schedules (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    recommendation_id BIGINT UNSIGNED NOT NULL,
    scheduled_date DATE NOT NULL,
    scheduled_time TIME NULL,
    status ENUM('PLANNED', 'DONE', 'MISSED', 'CANCELLED') NOT NULL DEFAULT 'PLANNED',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT fk_recommendation_schedules_recommendation
        FOREIGN KEY (recommendation_id) REFERENCES recommendations(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE activity_sessions (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    patient_id BIGINT UNSIGNED NOT NULL,
    recommendation_id BIGINT UNSIGNED NULL,
    activity_type VARCHAR(100) NOT NULL,
    started_at DATETIME NOT NULL,
    ended_at DATETIME NULL,
    source ENUM('MOBILE', 'MANUAL', 'AUTO') NOT NULL DEFAULT 'MOBILE',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT fk_activity_sessions_patient
        FOREIGN KEY (patient_id) REFERENCES patients(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_activity_sessions_recommendation
        FOREIGN KEY (recommendation_id) REFERENCES recommendations(id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    CONSTRAINT chk_activity_sessions_dates
        CHECK (ended_at IS NULL OR started_at <= ended_at)
) ENGINE=InnoDB;

CREATE TABLE sensor_readings (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    patient_id BIGINT UNSIGNED NOT NULL,
    wearable_device_id BIGINT UNSIGNED NOT NULL,
    recorded_at DATETIME NOT NULL,
    ecg_value DECIMAL(10,2) NULL,
    pulse_value DECIMAL(10,2) NULL,
    temperature_value DECIMAL(10,2) NULL,
    humidity_value DECIMAL(10,2) NULL,
    aggregation_window_seconds INT NOT NULL DEFAULT 30,
    is_alert_triggered BOOLEAN NOT NULL DEFAULT FALSE,
    source ENUM('BATCH', 'ASYNC_ALERT') NOT NULL DEFAULT 'BATCH',
    received_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT fk_sensor_readings_patient
        FOREIGN KEY (patient_id) REFERENCES patients(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_sensor_readings_wearable_device
        FOREIGN KEY (wearable_device_id) REFERENCES wearable_devices(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT chk_sensor_readings_aggregation_window
        CHECK (aggregation_window_seconds > 0)
) ENGINE=InnoDB;


CREATE TABLE accelerometer_readings (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    patient_id BIGINT UNSIGNED NOT NULL,
    smartphone_id BIGINT UNSIGNED NOT NULL,
    recorded_at DATETIME NOT NULL,
    x_value DECIMAL(10,4) NOT NULL,
    y_value DECIMAL(10,4) NOT NULL,
    z_value DECIMAL(10,4) NOT NULL,
    batch_id VARCHAR(100) NULL,
    received_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT fk_accelerometer_readings_patient
        FOREIGN KEY (patient_id) REFERENCES patients(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_accelerometer_readings_smartphone
        FOREIGN KEY (smartphone_id) REFERENCES smartphones(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE alert_rules (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    doctor_id BIGINT UNSIGNED NOT NULL,
    patient_id BIGINT UNSIGNED NOT NULL,
    sensor_type ENUM('ECG', 'PULSE', 'TEMPERATURE', 'HUMIDITY', 'ACTIVITY') NOT NULL,
    rule_name VARCHAR(150) NOT NULL,
    min_value DECIMAL(10,2) NULL,
    max_value DECIMAL(10,2) NULL,
    persistence_seconds INT NULL,
    minutes_since_activity_start INT NULL,
    severity ENUM('WARNING', 'ALARM', 'CRITICAL') NOT NULL DEFAULT 'WARNING',
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT fk_alert_rules_doctor
        FOREIGN KEY (doctor_id) REFERENCES users(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_alert_rules_patient
        FOREIGN KEY (patient_id) REFERENCES patients(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT chk_alert_rules_min_max
        CHECK (min_value IS NULL OR max_value IS NULL OR min_value <= max_value),
    CONSTRAINT chk_alert_rules_persistence
        CHECK (persistence_seconds IS NULL OR persistence_seconds >= 0),
    CONSTRAINT chk_alert_rules_minutes_since_activity_start
        CHECK (minutes_since_activity_start IS NULL OR minutes_since_activity_start >= 0)
) ENGINE=InnoDB;

CREATE TABLE alerts (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    patient_id BIGINT UNSIGNED NOT NULL,
    doctor_id BIGINT UNSIGNED NULL,
    rule_id BIGINT UNSIGNED NULL,
    triggered_at DATETIME NOT NULL,
    resolved_at DATETIME NULL,
    severity ENUM('WARNING', 'ALARM', 'CRITICAL') NOT NULL,
    status ENUM('OPEN', 'ACKNOWLEDGED', 'RESOLVED') NOT NULL DEFAULT 'OPEN',
    message TEXT NOT NULL,
    source ENUM('MOBILE', 'CLOUD', 'DOCTOR_DEFINED') NOT NULL DEFAULT 'CLOUD',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT fk_alerts_patient
        FOREIGN KEY (patient_id) REFERENCES patients(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_alerts_doctor
        FOREIGN KEY (doctor_id) REFERENCES users(id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    CONSTRAINT fk_alerts_rule
        FOREIGN KEY (rule_id) REFERENCES alert_rules(id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    CONSTRAINT chk_alerts_dates
        CHECK (resolved_at IS NULL OR triggered_at <= resolved_at)
) ENGINE=InnoDB;

CREATE TABLE alert_notes (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    alert_id BIGINT UNSIGNED NOT NULL,
    author_user_id BIGINT UNSIGNED NOT NULL,
    note_text TEXT NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT fk_alert_notes_alert
        FOREIGN KEY (alert_id) REFERENCES alerts(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_alert_notes_author
        FOREIGN KEY (author_user_id) REFERENCES users(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE sync_queue_logs (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    patient_id BIGINT UNSIGNED NOT NULL,
    smartphone_id BIGINT UNSIGNED NOT NULL,
    payload_type ENUM('SENSOR_BATCH', 'ACCELEROMETER_BURST', 'ALERT_EVENT', 'NOTE') NOT NULL,
    queued_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    synced_at DATETIME NULL,
    sync_status ENUM('PENDING', 'SYNCED', 'FAILED') NOT NULL DEFAULT 'PENDING',
    retry_count INT NOT NULL DEFAULT 0,
    error_message TEXT NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_sync_queue_logs_patient
        FOREIGN KEY (patient_id) REFERENCES patients(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_sync_queue_logs_smartphone
        FOREIGN KEY (smartphone_id) REFERENCES smartphones(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT chk_sync_queue_logs_retry_count
        CHECK (retry_count >= 0)
) ENGINE=InnoDB;