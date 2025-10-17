-- Процедура, которая обновляет значения в таблице
create procedure UpdateStaffBonus
	as begin
		-- проверяю существует ли таблица, если нет, создаю ее
		if object_id('dbo.DataMart_StaffBonus', 'U') is null
			begin
				create table dbo.DataMart_StaffBonus(
				StaffId INT,
		        StaffName NVARCHAR(100),
		        YearNum INT,
		        MonthNum INT,
		        Bonus DECIMAL(18,2),
		        primary key (StaffId, YearNum, MonthNum)
    );
			end
			
	-- первая дата в таблице - когда устроился первый сотрудник 
	declare @StartDate Date;
	select @StartDate = min(StartDate) from Staff;
	
	-- последняя дата в сводной таблице
	declare @LastDate Date;
	select @LastDate = max(datefromparts([YearNum],[MonthNum],1)) 
		from dbo.DataMart_StaffBonus;
	
	-- дата с которой начнем добавлять записи
	declare @Month Date;
	
	-- если записей в таблицу нет, @Month - месяц первого сотрудника,
	-- иначе следующий месяц после последнего в таблице
	if @LastDate is null
		set @Month = datefromparts(year(@StartDate), month(@StartDate), 1);
	else
		set @Month = dateadd(month, 1, @LastDate)
		
	--  текущая дата
	declare @CurrentMonth date = datefromparts(year(getdate()), month(getdate()), 1);
	
	-- прохожусь в цикле, пока дата не соответствует актуальной
	while @Month <= @CurrentMonth
	begin 
		insert into dbo.DataMart_StaffBonus (StaffId, StaffName, YearNum, MonthNum, Bonus)
		EXEC CalculateStaffBonus @CalcDate = @Month;
		SET @Month = dateadd(month, 1, @Month);
	end
		
	end;