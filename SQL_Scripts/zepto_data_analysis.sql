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
