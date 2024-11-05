CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');



--(Total amount spent by each customer)
  select sales.customer_id, Sum(menu.price) from sales
  join menu on sales.product_id=menu.product_id
  group by sales.customer_id
  order by 1;

--(How many days each customer visited the restaurant)

select customer_id,Count(Distinct order_date) from sales
group by 1
order by 1;

--(First item purchased on the menu by each customer)
with cte as(
select sales.customer_id, menu.product_name, sales.order_date,
dense_rank()over(partition by sales.customer_id order by order_date) as dense_R
from sales
inner join menu on sales.product_id=menu.product_id
)
select customer_id, product_name from cte 
where dense_r=1
group by 1,2;

--(Most purchased item)
 select menu.product_name, count(product_name) from sales
 join menu on sales.product_id=menu.product_id
 group by 1
 order by 2 desc;

--(Popular item among each customer)
with my as(
select sales.customer_id, menu.product_name, count(menu.product_id)as num,
dense_rank()over(partition by sales.customer_id order by count(sales.customer_id)desc) as rank
from sales
join menu on sales.product_id=menu.product_id
group by 1,2
order by 1 asc,3 desc,4 desc
)
select * from my
where rank=1

--(which item was purhcased first when they becaome a member)
with my as (
select sales.customer_id, sales.order_date, members.join_date, menu.product_name,
dense_rank()over(partition by sales.customer_id order by sales.order_date asc) as rank
from sales
join members on members.customer_id=sales.customer_id
join menu on menu.product_id=sales.product_id
where order_date >= join_date
group by 1,2,3,4
order by 1 asc,2 asc
)
select * from my 
where rank=1;

--(amount spent by each customer before they became a member)
select sales.customer_id, Sum(menu.price),count(sales.product_id) from sales
join members on members.customer_id=sales.customer_id
join menu on menu.product_id=sales.product_id
where sales.order_date < join_date
group by 1
order by 2 desc;

--(If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?)
with my as(
select *,
case 
	WHEN product_id=1 then menu.price*20
	else menu.price*10 end as points
from menu
group by 1,2,3
order by 1
)
select sales.customer_id, sum(points) from my
join sales on sales.product_id=my.product_id
group by 1
order by 1 Asc;

--(In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - 
--how many points do customer A and B have at the end of January?)
with my as (
select sales.customer_id as name, extract (month from order_date) as months, sales.product_id as P_ID from sales
join members on members.customer_id=sales.customer_id
where order_date >= join_date  
),
points as(
select *,
case 
	WHEN product_id=1 then menu.price*20
	else menu.price*20 end as points
from menu
group by 1,2,3
order by 1
)
select my.name,sum(points.points)
from  my
join points on my.P_ID=points.product_id
where my.months=1
group by 1;




with my as(
select sales.customer_id, sales.product_id as p_id, members.join_date as JD, sales.order_date as OD, join_date+6 as olt
from members
inner join sales on sales.customer_id=members.customer_id
where sales.order_date >= members.join_date
)
select customer_id,
 Sum(case
 	when Menu.product_name='sushi' then menu.price*2*10
	when my.od between my.jd and my.olt then menu.price*2*10
	else menu.price*10 end) as points
from my
join menu on menu.product_id = my.p_id
group by 1
























