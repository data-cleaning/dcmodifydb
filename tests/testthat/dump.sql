

ALTER TABLE `ds`
ADD `child` TEXT;

ALTER TABLE `ds`
ADD `workstatus` TEXT;

-- M1: maximum age
-- Age is limited.
-- 
-- R expression: if (age > 130) age <- 130
UPDATE `ds` AS T
SET `age` = U.`age`
FROM
(SELECT `id`, 130 AS `age`
FROM `ds`) AS U
WHERE T.`id` = U.`id`
  AND T.`age` > 130.0;

-- M2: Child labor
-- A child should not work.
-- 
-- R expression: if (age < 12) {
--     income <- 0
--     child <- TRUE
-- }
UPDATE `ds` AS T
SET `income` = U.`income`
FROM
(SELECT `id`, 0 AS `income`
FROM `ds`) AS U
WHERE T.`id` = U.`id`
  AND T.`age` < 12.0;

UPDATE `ds` AS T
SET `child` = U.`child`
FROM
(SELECT `id`, 1 AS `child`
FROM `ds`) AS U
WHERE T.`id` = U.`id`
  AND T.`age` < 12.0;

-- M3: has job
-- Income means job.
-- R expression: if (income > 0) {
--     workstatus <- "job"
-- }
UPDATE `ds` AS T
SET `workstatus` = U.`workstatus`
FROM
(SELECT `id`, 'job' AS `workstatus`
FROM `ds`) AS U
WHERE T.`id` = U.`id`
  AND T.`income` > 0.0;
