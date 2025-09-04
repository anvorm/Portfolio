-- Kuupäevadega seotud funktsioonid PostgreSQL-is

-- 1.1. Leia müügikogused kuude lõikes -- TO_CHAR funktsionaalsus
select to_char(sale_date, 'YYYY-MM') as yearmonth, sum(quantity)
from salestable as s
group by to_char(sale_date, 'YYYY-MM')
order by to_char(sale_date, 'YYYY-MM') asc;



--  1.2. HARJUTAMISEKS: Leia müügikogused aastate lõikes
select to_char(sale_date, 'YYYY') as year, sum(quantity)
from salestable as s
group by to_char(sale_date, 'YYYY')
order by to_char(sale_date, 'YYYY') asc;

-- 1.3. Kui palju on viimasest müügist möödas?
-- 1.3.1. I võimalus: age funktsioon, annab tekstilise tulemuse

select age(max(sale_date)) from salestable;

-- 1.3.2. II võimalus: current_date ja lahutustehe - annab päevade arvu numbrilise väärtusena

select current_date, max(sale_date), current_date - max(sale_date) as age_in_days
from salestable;

-- 1.4. HARJUTAMISEKS: Kui palju aega on esimesest müügist möödas?
select current_date, min(sale_date), current_date - min(sale_date) as age_in_days
from salestable;

-- keskmine kestvus
select avg(age(sale_date))
from salestable

-- 1.5. Kui palju on tegelikud müügid, eelarve ja nende võrdlus kuude kaupa?
-- Loome eelarvetabeli kuude kaupa
with b as (select TO_CHAR(budget_date, 'YYYY-MM') as yearmonth,
sum(budget_sum) as budget_sum
from budget_monthly_salesrep
group by TO_CHAR(budget_date, 'YYYY-MM')),

-- Loome müügitabeli kuude kaupa
s as (select TO_CHAR(sale_date, 'YYYY-MM') as yearmonth,
sum(quantity*unit_price*(1-discount)) as sales_sum
from salestable
group by TO_CHAR(sale_date, 'YYYY-MM'))

-- Ühendame loodud tabelid
select b.yearmonth, b.budget_sum, s.sales_sum,
s.sales_sum - b.budget_sum as diff_from_budget
from b
left join s on b.yearmonth = s.yearmonth
order by b.yearmonth asc;

ALTER TABLE salestable
ADD sales_sum numeric 
generated always as --- alati arvutab välja teiste tulpade põhjal
(quantity*unit_price*(1-discount)) stored;

select * from salestable;

-- 1.6. HARJUTAMISEKS: Kui palju on tegelikud müügid, eelarve ja nende võrdlus kuude ja müügiesindaja kaupa?
--- eelarvetabel kuude kaupa
with b as (select TO_CHAR(budget_date, 'YYYY-MM') as yearmonth, sales_rep_id,
sum(budget_sum) as budget_sum
from budget_monthly_salesrep
group by TO_CHAR(budget_date, 'YYYY-MM'), sales_rep_id),
-- Loome müügitabeli kuude kaupa
s as (select TO_CHAR(sale_date, 'YYYY-MM') as yearmonth, sales_rep_id,
sum(quantity*unit_price*(1-discount)) as sales_sum
from salestable
group by TO_CHAR(sale_date, 'YYYY-MM'), sales_rep_id)
-- Ühendame loodud tabelid
select b.yearmonth, b.sales_rep_id, b.budget_sum, s.sales_sum, 
s.sales_sum - b.budget_sum as diff_from_budget
from b
left join s on b.yearmonth = s.yearmonth and b.sales_rep_id = s.sales_rep_id
order by b.yearmonth asc;

--- müügisummad toodete kaupa
select product_id, sum(quantity*unit_price*(1-discount)) as sales_sum
from salestable
group by product_id
order by product_id;
---müügisummad klientide kaupa
select customer_id, sum(quantity*unit_price*(1-discount)) as sales_sum
from salestable
group by customer_id;
---müügisummad müügiesindajate kaupa
select sales_rep_id, sum(quantity*unit_price*(1-discount)) as sales_sum
from salestable
group by sales_rep_id;
---müügisummad aastate kaupa
select to_char(sale_date, 'YYYY') as year, sum(quantity*unit_price*(1-discount))
from salestable
group by to_char(sale_date, 'YYYY')
order by to_char(sale_date, 'YYYY') asc;

---II var
SELECT EXTRACT (YEAR FROM sale_date) AS "year", round(sum(sales_sum),0)
from salestable
GROUP BY "year"
ORDER BY "year";

---lisa müükidele müügisummakategooriad


select sum(quantity*unit_price*(1-discount)) as sales_sum,
	case when sales_sum > 500 then 'Large sale'
	when sales_sum < 250 then 'Small sale'
	else 'Medium sale' end as Categories
from salestable
group by sales_sum;

---leia müükide arv ja müügisumma müügisumma kategooriate kaupa
with sales_with_categories as (select sales_sum
from salestable)
select case when sales_sum > 500 then 'Large sale'
when sales_sum >= 250 then 'Medium Sale'
else 'Small sale' end as sales_category,
count(*) as number_of_sales,
round(sum(sales_sum)::numeric,0) as sales_sum
from sales_with_categories
group by sales_category order by sales_category desc;

---II var
select case when sales_sum > 500 then 'Large Sale'
	when sales_sum >= 250 then 'Medium Sale'
	else 'Small Sale' end as sales_category,
	count(*) as number_of_sales,
	round(sum(sales_sum)) as sales_sum
	from salestable
	group by sales_category
	order by sales_category desc;








---müügisumma kategooriate kaupa
---ühenda tabelid












