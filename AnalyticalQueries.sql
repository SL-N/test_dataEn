-- Задание 1.3
USE test_db;

-- 1.топ 5 наиболее рентабельных 
-- (минимальные траты на ремонт и максимальная выручка за аренду) велосипедов
 
with rev_sum as (
	select 
		b.Id,
		sum(r.RentDuration * b.RentPrice * r.Paid) as Revenue
	from Bicycle b
	left join RentBook r on b.Id = r.BicycleId
	group by b.Id
),
repair_sum as (
	select 
		b.Id,
		isnull(sum(s.Price + d.Price), 0) as RepairCosts
	from Bicycle b
	left join ServiceBook s on b.Id = s.BicycleId
	left join Detail d on d.Id = s.DetailId
	group by b.Id
)
select top 5
    b.Id,
    rev.Revenue,
    rep.RepairCosts,
    rev.Revenue - rep.RepairCosts AS Profit
from Bicycle b
left join rev_sum rev on b.Id = rev.Id
left join repair_sum rep on b.Id = rep.Id
order by Profit DESC;

-- 2.средняя цена ремонта детали 

select 
	d.[Type],
	avg(d.Price) as avg_price 
from Detail d 
group by d.[Type]
order by avg_price DESC;

-- 3.Сколько раз клиент арендовал велосипед и общая прибыль с клиента

select 
	c.id,
	sum(r.RentDuration * b.RentPrice * r.Paid) as Spent,
	count(r.Id) as Rent_count
from Client c 
left join RentBook r on c.Id = r.ClientId
left join  Bicycle b on r.BicycleId = b.Id
group by c.Id 
order by Spent DESC ; 

-- 4. Сколько велосипедов сотрудник выдал, сколько починил,
-- какая прибыль по аренде от сотрудника
select 
	s.Id,
	count(r.Id) as Rent_count,
	count(sb.BicycleId) as Service_count,
	isnull(sum(r.RentDuration * b.RentPrice * r.Paid), 0) as Profit
from Staff s 
left join RentBook r on s.Id = r.StaffId 
left join ServiceBook sb on s.Id = sb.StaffId 
left join Bicycle b on r.BicycleId = b.Id
group by s.Id 
order by Profit DESC ;

-- 5. Прибыль и затраты по месяцам
with rev_sum as (
	select 
	    year(r.RentDate) as Year,
	    month(r.RentDate) as Month,
	    isnull(sum(r.RentDuration * b.RentPrice * r.Paid), 0) as Revenue
   	from Bicycle b
   	left join RentBook r on b.Id = r.BicycleId
   	group by year(r.RentDate), month(r.RentDate)
),
costs_sum as (
	select 
	    year(s.ServiceDate) as Year,
	    month(s.ServiceDate) as Month,
	    isnull(sum(s.Price + d.Price), 0) as Repair_costs
   	from Bicycle b
   	left join ServiceBook s on b.Id = s.BicycleId
   	left join Detail d on d.Id = s.DetailId
   	group by year(s.ServiceDate), month(s.ServiceDate)
)
select 
    isnull(r.Year, c.Year) as year,
    isnull(r.Month, c.Month) as month,
    isnull(r.Revenue, 0) as Revenue,
    isnull(c.Repair_costs, 0) as Repair_costs,
    isnull(r.Revenue, 0) - isnull(c.Repair_costs, 0) as Profit
from rev_sum r
full outer join costs_sum c on r.Year = c.Year and r.Month = c.Month
where isnull(r.Year, c.Year) is not null
order by year, month;
 
