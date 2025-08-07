-- Create the 'patients' table
CREATE TABLE patients (
    patient_id INT PRIMARY KEY,
    name VARCHAR(255),
    gender VARCHAR(1),
    birth_date DATE,
    region VARCHAR(255)
);

-- Import data into the 'patients' table
COPY patients (patient_id, name, gender, birth_date, region)
FROM 'patients.csv'
WITH (FORMAT CSV, HEADER, DELIMITER ',');

-- Create the 'trials' table
CREATE TABLE trials (
    trial_id VARCHAR(255) PRIMARY KEY,
    condition VARCHAR(255),
    phase VARCHAR(255),
    sponsor VARCHAR(255)
);

-- Import data into the 'trials' table
COPY trials (trial_id, condition, phase, sponsor)
FROM 'trials.csv'
WITH (FORMAT CSV, HEADER, DELIMITER ',');

-- Create the 'enrollment' table
CREATE TABLE enrollment (
    enroll_id INT PRIMARY KEY,
    patient_id INT REFERENCES patients(patient_id),
    trial_id VARCHAR(255) REFERENCES trials(trial_id),
    enroll_date DATE,
    status VARCHAR(255)
);

-- Import data into the 'enrollment' table
COPY enrollment (enroll_id, patient_id, trial_id, enroll_date, status)
FROM 'enrollment.csv'
WITH (FORMAT CSV, HEADER, DELIMITER ',');



-- Q1: Show all patient names and the trials they are enrolled in (include patients not enrolled). (join function)
select p.name, e.trial_id, e.status, t.phase from patients p
left join enrollment e on p.patient_id = e.patient_id
left join trials t on e.trial_id = t.trial_id;


-- Q2: Count how many patients enrolled in each trial. (count function)
select count(e.patient_id) as patient_count, e.trial_id, e.status from enrollment e
group by e.trial_id, e.status
order by patient_count desc;


-- Q3: Show patients who are not enrolled in any trials. (not in and subquery function)
select patient_id, name from patients p
where patient_id not in (select patient_id from enrollment) or 
order by name;


-- Q4: For each region, rank patients by birth_date (oldest = 1). (rank() over, partition by aggregation function)
select 
    p.region, 
    p.name, 
    p.birth_date,
    rank() over (partition by p.region order by p.birth_date) as rank
from patients p
order by p.region, rank;


-- Q5: Find the trial(s) with the highest number of enrolled patients. (order by desc function)
select e.trial_id, count(e.patient_id) as patient_count
from enrollment e
group by e.trial_id
order by patient_count desc;


-- Q6: List only the most recent enrollment for each patient. (desc function)
select * from enrollment order by enroll_date desc;


-- Q7: Write a query that returns each patient's name and a column trial_status where: (Case when function)
    -- "Active" if the enrollment status is ''Active''
    -- "Finished" if status is 'Completed'
    -- "Other" for anything else or null
select p.name,
    case 
        when e.status = 'Active' then 'Active'
        when e.status = 'Completed' then 'Finished'
        else 'Other'
    end as trial_status
from patients p
left join enrollment e on p.patient_id = e.patient_id;


-- Q8: Write a query to list all enrolled patients and the trial condition, using 'Unknown Trial' if the trial condition is null. (COALESCE function on simple NULL handling)
    -- COALESCE returns the first non-null value in the list.
select 
    trial_id, 
    coalesce(condition, 'unknown condition') as condition 
from trials;


-- Q9: How many distinct trials has each patient participated in? (distinct and count function)
    -- with highest patient count first. 
select distinct(e.trial_id), count(patient_id) as patient_count
from enrollment e
group by e.trial_id
order by patient_count desc; -- use limit 1 to get the highest count only


-- Q10 alter tables foreign key data type. to remove constraints, alter the two tables, add constraints back 
begin; -- use begin to start a transaction and wrap it, it is similar to CTE in SQL Server, it creates a temporary transaction block until commit or rollback.
alter table enrollment drop constraint enrollment_patient_id_fkey;
alter table enrollment alter patient_id type integer using patient_id :: integer;
alter table patients alter patient_id type integer using patient_id :: integer;
alter table enrollment add constraint enrollment_patient_id_fkey foreign key (patient_id) references patients(patient_id);
select * from patients where patient_id = 4;-- check the data type of patient_id in patients table
commit; -- or rollback; 

-- Q11: update data in specific columns and rows. e.g. update patient name.
update patients 
set name = NULL 
where patient_id = 3; -- when patient_id is varchar you will need to do patient_id = '3' instead of patient_id = 3


-- Q12: finding NULL value in the columns 
select trial_id, condition 
from trials 
where condition is NULL; -- or column_name is null; 
-- you can + AND or OR to combine multiple conditions


-- Q13: Insert and delete a patient from the patients table.
    -- insert 
insert into patients (patient_id, name, gender, birth_date, region)
values (9, 'john john', 'M', '1990-12-11', 'Southwest');
    -- delete
delete from patients
where patient_id = 9;


--- Bonus ---
-- Calculate average age of patients per region. when today is the 2025-08-06
        -- calculate the age 
select patient_id, age('2025-08-06', birth_date) from patients 
        -- calculate the average age per region 
select
    coalesce(region, 'Unknown Region') as region,
    avg(age('2025-08-06', birth_date)) as average_age
from patients
group by region
order by average_age desc;


-- calculate the date of birth and split the age years and months to another column
select
    patient_id,
    birth_date,
    age('2025-08-06', birth_date) as age,
    extract(year from age('2025-08-06', birth_date)) as age_years,
    extract(month from age('2025-08-06', birth_date)) as age_months
from patients
order by age_years desc, age_months desc;


-- now subtract the age years with the average age years
with average_age as (
    select
        coalesce(region, 'Unknown Region') as region,
        avg(extract(year from age('2025-08-06', birth_date))) as average_age_years
    from patients
    group by region
)
select
    p.patient_id,
    p.birth_date,
    age('2025-08-06', p.birth_date) as age,
    extract(year from age('2025-08-06', p.birth_date)) as age_years,
    extract(month from age('2025-08-06', p.birth_date)) as age_months,
    extract(year from age('2025-08-06', p.birth_date)) - aa.average_age_years as age_difference
from patients p
left join average_age aa on p.region = aa.region
order by age_years desc, age_months desc;

