-- -------------------------------------
-- Generated with dcmodifydb, do not edit
-- dcmodify version: 0.1.9
-- dcmodifydb version: 0.1.0.9000
-- from: 'test-sql.yml'
-- -------------------------------------



-- M1: simple rule
-- Description of this modification rule.
-- Can span multiple lines.
-- 
UPDATE `ds`
SET 'x' = 1.0
WHERE `x` > 1.0;

-- M2: multiple rules
-- Description of this modification rule.
UPDATE `ds`
SET 'x' = 1.0
WHERE `x` > 1.0;

UPDATE `ds`
SET 'y' = 2.0
WHERE `x` > 1.0;
