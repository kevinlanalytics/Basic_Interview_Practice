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

-- Q4: For each region, rank patients by birth_date (oldest = 1).
-- Q5: Find the trial(s) with the highest number of enrolled patients.
-- Q6: List only the most recent enrollment for each patient.
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

-- Q8: Write a query to list all enrolled patients and the trial name, using 'Unknown Trial' if the trial condition is null.
-- Q9: How many distinct trials has each patient participated in?

-- Q10 alter tables foreign key data type. - remove constraints, alter the two tables, add constraints back 
begin; -- use begin to start a transaction and wrap it, it is similar to CTE in SQL Server, it creates a temporary transaction block until commit or rollback.
 alter table enrollment drop constraint enrollment_patient_id_fkey;
alter table enrollment alter patient_id type integer using patient_id :: integer;
alter table patients alter patient_id type integer using patient_id :: integer;                          
alter table enrollment add constraint enrollment_patient_id_fkey foreign key (patient_id) references patients(patient_id);
select * from patients where patient_id = 4;
commit; -- or rollback; 

-- Q11: update data in specific columns and rows. e.g. update patient name.
update patients 
set name = NULL 
where patient_id = 3; -- when patient_id is varchar you will need to do patient_id = '3' instead of patient_id = 3


    
-- Bonus
--   Calculate average age of patients per region.
--   List trials that have not enrolled any patients.
--   For each trial, calculate the percentage of patients from each region.