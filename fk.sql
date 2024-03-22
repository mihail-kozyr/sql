COL DIS FOR A100

SELECT f.table_name, f.constraint_name, f.status, 'ALTER TABLE ' || f.table_name || ' DISABLE CONSTRAINT ' || f.constraint_name ||';' DIS
FROM user_constraints p, user_constraints f
WHERE p.constraint_name = f.r_constraint_name
AND p.table_name = UPPER('&1');
