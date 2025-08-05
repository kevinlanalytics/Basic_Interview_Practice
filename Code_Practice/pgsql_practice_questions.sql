-- Q1: Show all patient names and the trials they are enrolled in (include patients not enrolled).

select p.name, e.trial_id, e.status, t.phase from patients p 
left join enrollment e on p.patient_id = e.patient_id                                                    
left join trials t on e.trial_id = t.trial_id;


-- Q2: Count how many patients enrolled in each trial.

-- Q3: Show patients who are not enrolled in any trials.
-- Q4: For each region, rank patients by birth_date (oldest = 1).
-- Q5: Find the trial(s) with the highest number of enrolled patients.
-- Q6: List only the most recent enrollment for each patient.
-- Bonus
--   Calculate average age of patients per region.
--   List trials that have not enrolled any patients.
--   For each trial, calculate the percentage of patients from each region.