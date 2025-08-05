CREATE TABLE patients (
    patient_id TEXT PRIMARY KEY,
    name TEXT,
    gender CHAR(1),
    birth_date DATE,
    region TEXT
);


CREATE TABLE trials (
    trial_id TEXT PRIMARY KEY,
    condition TEXT,
    phase TEXT,
    sponsor TEXT
);


CREATE TABLE enrollment (
    enroll_id TEXT PRIMARY KEY,
    patient_id TEXT REFERENCES patients(patient_id),
    trial_id TEXT REFERENCES trials(trial_id),
    enroll_date DATE,
    status TEXT
);


COPY patients FROM '/Users/sonicboy66/Documents/Code_Practice/patients.csv' CSV HEADER;
COPY trials FROM '/Users/sonicboy66/Documents/Code_Practice/trials.csv' CSV HEADER;
COPY enrollment FROM '/Users/sonicboy66/Documents/Code_Practice/enrollment.csv' CSV HEADER;