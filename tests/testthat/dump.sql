-- -------------------------------------
-- Generated with dcmodifydb, do not edit
-- dcmodify version: 0.1.9
-- dcmodifydb version: 0.1.0.9000
-- from: 'test-sql.yml'
-- -------------------------------------


ALTER TABLE `ds`
ADD COLUMN `child` character;

ALTER TABLE `ds`
ADD COLUMN `workstatus` character;

-- M1: maximum age
-- Age is limited.
-- 
UPDATE `ds`
SET `age` = 130.0
WHERE `age` > 130.0;

-- M2: Child labor
-- A child should not work.
-- 
UPDATE `ds`
SET `income` = 0.0
WHERE `age` < 12.0;

UPDATE `ds`
SET `child` = 1
WHERE `age` < 12.0;

-- M3: has job
-- Income means job.
UPDATE `ds`
SET `workstatus` = 'job'
WHERE `income` > 0.0;
