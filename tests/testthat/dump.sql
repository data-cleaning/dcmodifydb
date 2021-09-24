-- -------------------------------------
-- Generated with dcmodifydb, do not edit
-- dcmodify version: 0.1.9
-- dcmodifydb version: 0.1.2
-- from: 'test-sql.yml'
-- -------------------------------------


ALTER TABLE `ds`
ADD COLUMN `child` character;

ALTER TABLE `ds`
ADD COLUMN `workstatus` character;

-- M1: maximum age
-- Age is limited.
-- 
-- R expression: if (age > 130) age <- 130
UPDATE `ds`
SET `age` = 130
WHERE `age` > 130.0;

-- M2: Child labor
-- A child should not work.
-- 
-- R expression: if (age < 12) {
--     income <- 0
--     child <- TRUE
-- }
UPDATE `ds`
SET `income` = 0
WHERE `age` < 12.0;

UPDATE `ds`
SET `child` = 1
WHERE `age` < 12.0;

-- M3: has job
-- Income means job.
-- R expression: if (income > 0) {
--     workstatus <- "job"
-- }
UPDATE `ds`
SET `workstatus` = 'job'
WHERE `income` > 0.0;
