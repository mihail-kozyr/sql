WITH src as(
 SELECT status, first_change_time,last_change_time,plan_operation,plan_options,
        plan_object_name,plan_object_type,output_rows, plan_parent_id,plan_line_id
   FROM v$sql_plan_monitor
  WHERE sql_id = 'b7pujkgqzxhj9')
SELECT lpad(plan_operation, length(plan_operation)+2*level) AS plan_operation,
        plan_options,
        plan_object_name,
        plan_object_type,
        output_rows,
        first_change_time,
        last_change_time
  FROM src
 START WITH plan_parent_id IS NULL 
 CONNECT BY PRIOR plan_line_id =  plan_parent_id
