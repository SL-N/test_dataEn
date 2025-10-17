USE test_db;
-- процедура, которая создает таблицу с премиями сотрудников по указанной дате
create procedure CalculateStaffBonus
    @CalcDate DATE
AS
begin
	-- CTE для расчета процента бонуса
	with p as 
	(select 
		case 
			when DATEDIFF(YEAR, s.StartDate, @CalcDate) < 1 then 0.05
			when DATEDIFF(YEAR, s.StartDate, @CalcDate) < 2 then 0.1
			else 0.15
		end as pers,
		s.Id
		from Staff s 
	)
	
	select
		s.Id as StaffId,
		s.Name as StaffName,
		year(@CalcDate) as YearNum,
		month(@CalcDate) as MonthNum,
		(isnull(sum(rb.RentDuration * b.RentPrice * rb.Paid), 0) * 0.3 + 
			isnull(sum(sb.Price), 0) * 0.8) * p.pers as bonus
	from  Staff s  
	left join RentBook rb on s.Id = rb.StaffId 
		and year(rb.RentDate) = year(@CalcDate)
		and month(rb.RentDate) = month(@CalcDate)
	left join Bicycle b on rb.BicycleId = b.Id
	left join p on p.Id = s.Id
	left join ServiceBook sb on s.Id = sb.StaffId
		and year(sb.ServiceDate) = year(@CalcDate)
		and month(sb.ServiceDate) = month(@CalcDate)
	where s.StartDate <= @CalcDate
	group by s.Name, s.Id, p.pers
end;



	
	