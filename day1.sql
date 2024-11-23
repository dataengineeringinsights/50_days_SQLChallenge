
/*
Q1. Write an SQL query that reports the products that were only sold in the first quarter of 2019. That is,
between '2019-01-01' and '2019-03-31' inclusive.

Explanation:
The product with id 1 was only sold in the spring of 2019.
The product with id 2 was sold in the spring of 2019 but was also sold after the spring of 2019.
The product with id 3 was sold after spring 2019.
We return only product 1 as it is the product that was only sold in the spring of 2019.
*/

create schema dataeng;
use dataeng;

CREATE TABLE if not EXISTS product(
    product_id int,
    product_name varchar(20),
    unit_price int,
    constraint pk  primary key (product_id)    
);
   
CREATE TABLE if not EXISTS sales(
	seller_id int,
    product_id int,
    buyer_id int,
    sale_date date,
    quantity int,
    price int,
    constraint fk foreign key (product_id) references product(product_id)
);

INSERT INTO product values
	(1,'s8',1000),
    (2,'G4',800),
    (3,'iPhone',1400);

INSERT INTO sales values
	(1,1,1,'2019-01-21',2,2000),
    (1,2,2,'2019-02-17',1,800),
    (2,2,3,'2019-06-02',1,800),
    (3,3,4,'2019-05-13',2,2800);
    
select * from sales;
select * from product;


-- Approach 1

select product_id, product_name
from (
		select p.product_id, product_name,
			max(case when s.sale_date between '2019-01-01' AND '2019-03-31' then 1 else 0 end) as sold_in_q1,
			max(case when s.sale_date not between '2019-01-01' AND '2019-03-31' then 1 else 0 end) as sold_outside_q1
		from product p
		join sales s on p.product_id=s.product_id
		group by product_id, product_name
	  ) as subquery
where sold_in_q1=1 and sold_outside_q1=0;

-- Approach 2

with cte as (
		select p.product_id, product_name,
			max(case when s.sale_date between '2019-01-01' AND '2019-03-31' then 1 else 0 end) as sold_in_q1,
			max(case when s.sale_date not between '2019-01-01' AND '2019-03-31' then 1 else 0 end) as sold_outside_q1
		from product p
		join sales s on p.product_id=s.product_id
		group by product_id, product_name
)
select product_id, product_name
from cte 
where sold_in_q1=1 and sold_outside_q1=0;

-- Approach 3
        
SELECT p.product_id, p.product_name
FROM product p
JOIN sales s ON p.product_id = s.product_id
GROUP BY p.product_id, p.product_name
HAVING MAX(CASE WHEN s.sale_date BETWEEN '2019-01-01' AND '2019-03-31' THEN 1 ELSE 0 END) = 1
   AND MAX(CASE WHEN s.sale_date NOT BETWEEN '2019-01-01' AND '2019-03-31' THEN 1 ELSE 0 END) = 0;

-- Approach 4:

SELECT p.product_id, p.product_name
FROM product p
WHERE EXISTS (
    SELECT 1
    FROM sales s
    WHERE s.product_id = p.product_id
      AND s.sale_date BETWEEN '2019-01-01' AND '2019-03-31'
)
AND NOT EXISTS (
    SELECT 1
    FROM sales s
    WHERE s.product_id = p.product_id
      AND s.sale_date NOT BETWEEN '2019-01-01' AND '2019-03-31'
);

