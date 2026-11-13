create table zepto_data_analysis(
Category varchar2(100),
name varchar2(255),
mrp	number(10,2),
discountPercent	number(8,2),
availableQuantity number(10),
discountedSellingPrice	number(10,2),
weightInGms	number(10,2),
outOfStock boolean,
quantity number(10)
);

-- drop table zepto_data_analysis;
select * from zepto_data_analysis;

--How many total products are available in the dataset?
select count(name) from zepto_data_analysis;

--How many unique product categories exist?
select distinct(category) from zepto_data_analysis;

--How many products belong to each category?
select category,count(category) from zepto_data_analysis group by category;

--What are the top 5 categories with the highest number of products?
select category,count(name) as product_count from zepto_data_analysis group by category order by product_count desc OFFSET 0 ROWS FETCH NEXT 5 ROWS ONLY; 

--What is the average MRP of all products?
select round(avg(mrp),2) from zepto_data_analysis;

--What is the minimum and maximum product price?
select min(mrp),max(mrp) from zepto_data_analysis;

--How many products are out of stock?
Select count(name) from zepto_data_analysis where OUTOFSTOCK is TRUE;

--How many products are currently available?
select count(name) from zepto_data_analysis where outofstock is False;

--What is the average discount percentage?
select round(avg(DISCOUNTPERCENT),2) from zepto_data_analysis;

--Which products have a discount greater than 20%?
select name,DISCOUNTPERCENT from zepto_data_analysis where DISCOUNTPERCENT>20;

----------
select

count(*) as total_products,

sum(
case when OUTOFSTOCK =0 then 1
else 0
end
) as available_products,

sum(
case when OUTOFSTOCK =1 then 1
else 0
end
) as out_of_stock_products,

round(avg(DISCOUNTPERCENT),2) as avg_discount
FROM zepto_data_analysis;
-----------------------------
--Which category has the highest average discount?
select category,round(avg(DISCOUNTPERCENT),2) as avg_discount  from zepto_data_analysis group by category order by avg_discount desc;

--Which category has the highest average MRP?'
select category,round(avg(MRP),2) as avg_mrp  from zepto_data_analysis group by category order by avg_mrp desc;

--Find the top 10 products with the highest discount percentages.
Select name,max(DISCOUNTPERCENT) as max_discount from zepto_data_analysis group by name order by max_discount desc OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY; 

--Which products have an MRP greater than ₹500?
select distinct name,mrp from zepto_data_analysis where mrp>500;

--Which categories have more than 100 products?
select category,count(category) as cnt from zepto_data_analysis group by category having cnt>100;

--What is the total inventory quantity available in each category?
select category,sum(quantity) as inventory_quantity from zepto_data_analysis WHERE outofstock = 0 group by category;

--Which products have zero available quantity?
select name,quantity from zepto_data_analysis where quantity=0;

--Which products have discounts between 10% and 30%?
select distinct name as product_name,DISCOUNTPERCENT from zepto_data_analysis where DISCOUNTPERCENT between 10 and 30;

--Classify products into High, Medium, and Low discount categories.
select name,DISCOUNTPERCENT,
case when DISCOUNTPERCENT >=30 then 'HIGH'
when DISCOUNTPERCENT >=15 then 'MEDIUM'
else 'LOW'
end as discount_category
from zepto_data_analysis;


--Which products have selling prices higher than their category's average selling price?
select name,DISCOUNTEDSELLINGPRICE as product from zepto_data_analysis p1
where DISCOUNTEDSELLINGPRICE >
(select round(avg(DISCOUNTEDSELLINGPRICE),2) as avg_selling_price from zepto_data_analysis p2
where p2.category=p1.category);


----Find the top 3 most expensive products in each category.
SELECT category, name, mrp, rnk
FROM (
    SELECT 
        category,
        name,
        mrp,
        DENSE_RANK() OVER (PARTITION BY category ORDER BY mrp DESC) AS rnk 
    FROM zepto_data_analysis
)
WHERE rnk < 4;
-----------------------------------------

---Find products whose discount is greater than their category's average discount.
select name,DISCOUNTPERCENT from zepto_data_analysis P1 where DISCOUNTPERCENT >
(select round(avg(DISCOUNTPERCENT),2) from zepto_data_analysis p2
where p2.category=p1.category);

--------------------------------
--Identify products with the highest difference between MRP and selling price.
select distinct name,mrp,discountedsellingprice,(mrp-discountedsellingprice) as diff from zepto_data_analysis
order by diff desc
offset 0 rows fetch next 10 rows only;
-------------------------------------------
--Calculate the percentage of out-of-stock products in each category.

select out_of_stock_count,total_cnt,category,round((out_of_stock_count)/(total_cnt),2)*100 as outofstock_per from
(select category,count(name)as out_of_stock_count,outofstock,(select count(name) from zepto_data_analysis p2 where p2.category=p1.category) as total_cnt from zepto_data_analysis p1
group by category,outofstock
having outofstock is TRUE)


-----Find categories where the out-of-stock percentage exceeds 10%.

select out_of_stock_count,total_cnt,category,round((out_of_stock_count)/(total_cnt),2)*100 as outofstock_per from
(select category,count(name)as out_of_stock_count,outofstock,(select count(name) from zepto_data_analysis p2 where p2.category=p1.category) as total_cnt from zepto_data_analysis p1
group by category,outofstock
having outofstock is TRUE)
where (round((out_of_stock_count)/(total_cnt),2)*100) > 10;

---- Calculate the average discount for each product category and rank them.
select category,dc,dense_rank() over(order by dc desc) as rank from(
select category,avg(DISCOUNTPERCENT) as dc from zepto_data_analysis
group by category
order by dc);

-----Find the top 5 products by potential savings (MRP minus selling price).
select distinct name,mrp,DISCOUNTEDSELLINGPRICE,(mrp-DISCOUNTEDSELLINGPRICE) as Potential_saving from zepto_data_analysis
order by Potential_saving desc
offset 0 rows fetch next 5 rows only;

---Which categories have the highest out-of-stock rates?

select category, sum(
case when outofstock is true then 1
else 0
end) as outofstock_count,count(*) as total from zepto_data_analysis
group by category
order by outofstock_count desc;

----Which categories offer the highest average discounts?
select category,round(avg(DISCOUNTPERCENT),2) as avg_discount from zepto_data_analysis
group by category
order by avg_discount desc;

----Which products have high MRP but low discounts?
select distinct name,mrp,DISCOUNTPERCENT from zepto_data_analysis
order by DISCOUNTPERCENT asc,mrp desc;

-----Which products have high discounts but are out of stock?
select distinct name,DISCOUNTPERCENT,outofstock from zepto_data_analysis
where outofstock = 1
order by DISCOUNTPERCENT desc;

---Which categories have both high average prices and high out-of-stock rates?
select category,avg(DISCOUNTEDSELLINGPRICE) as avg_sp,count(
case
when outofstock=1 then 1
else 0
end) as cnt from zepto_data_analysis
group by category
order by cnt desc,avg_sp desc;

--Which products have unusually low or zero prices?
SELECT name, DISCOUNTEDSELLINGPRICE
FROM zepto_data_analysis
WHERE DISCOUNTEDSELLINGPRICE <
(
    SELECT AVG(DISCOUNTEDSELLINGPRICE) * 0.5
    FROM zepto_data_analysis
);

---Which categories have the greatest potential savings(MRP minus selling price) for customers?
select category,sum(mrp) as sum_mrp,sum(DISCOUNTEDSELLINGPRICE) as sum_sp,sum(mrp-DISCOUNTEDSELLINGPRICE) as sp from zepto_data_analysis
group by category
order by sp desc

 