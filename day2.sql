
/*
Q2. delivery_id is the primary key of this table.
The table holds information about food delivery to customers that make orders at some date and
specify a preferred delivery date (on the same order date or after it).
If the customer's preferred delivery date is the same as the order date, then the order is called
immediately; otherwise, it is called scheduled.
Write an SQL query to find the percentage of immediate orders in the table, rounded to 2 decimal
places.
*/

CREATE TABLE if not EXISTS delivery(
	delivery_id int,
	customer_id int,
	order_date date,
	customer_pref_delivery_date date,
    constraint pk primary key (delivery_id)
);

INSERT INTO delivery values
	(1,1,'2019-08-01','2019-08-02'),
    (2,5,'2019-08-02','2019-08-02'),
    (3,1,'2019-08-11','2019-08-11'),
    (4,3,'2019-08-24','2019-08-26'),
    (5,4,'2019-08-21','2019-08-22'),
    (6,2,'2019-08-11','2019-08-13');


select * from delivery;

-- Approach 1

WITH order_status AS (
    SELECT *,
           CASE 
               WHEN order_date = customer_pref_delivery_date THEN 'immediately'
               ELSE 'scheduled'
           END AS order_status
    FROM delivery
)
SELECT 
    order_status, 
    COUNT(*) AS order_status_individual_count,
    SUM(COUNT(*)) OVER () AS total_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS order_percentage
FROM order_status
GROUP BY order_status;


-- Approach 2


with order_status as(
	select *,
			case when order_date = customer_pref_delivery_date then 'immediately'
				 when order_date != customer_pref_delivery_date then 'scheduled' 
			end as order_status        
	from delivery
)
select 
	order_status, 
	count(*) order_status_individual_count,
	(select  count(customer_id) as total_count from order_status) as total_count,
	case when order_status = 'immediately' then round(count(*)/(select  count(customer_id) from order_status)*100,2)
		 when order_status = 'scheduled' then round(count(*)/(select  count(customer_id) from order_status)*100,2)
	end as order_percentage
from order_status
group by order_status;