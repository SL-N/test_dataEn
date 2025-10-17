-- Задание 1.1
USE test_db;
create table [Bicycle]
(
   [Id] int IDENTITY(1,1) not null,
   [Brand] varchar(50)  not null,
   [RentPrice] int not null, -- цена аренды
   primary key(Id)
);

create table [Client]
(
   [Id] int IDENTITY(1,1) not null,
   [Name] varchar(10) not null,
   [Passport] varchar(50) not null,
   [Phone number] varchar(50) not null,
   [Country] varchar(50) not null,
   primary key(Id)
);

create table [Staff]
(
   [Id] int IDENTITY(1,1) not null,
   [Name] varchar(10) not null, -- имя сотрудника
   [Passport] varchar(50) not null,
   [Date] date not null, -- дата начала работы
   primary key(Id)
);

create table [Detail] -- запчасти велосипеда
(
   [Id] int IDENTITY(1,1) not null,
   [Brand] varchar(50)  not null,
   [Type] varchar(50) not null, -- тип детали (цепь, звезда, etc.)
   [Name] varchar(50) not null, -- название детали
   [Price] int not null,
   primary key(Id) 

);
create table [DetailForBicycle] -- список деталей подходящих к велосипедам
(
   [BicycleId] int not null,
   [DetailId] int not null,
   FOREIGN KEY ([BicycleId]) REFERENCES [Bicycle] ([Id]),
   FOREIGN KEY ([DetailId]) REFERENCES [Detail] ([Id])
);
create table [ServiceBook] -- сервисное обслуживание велосипедов
(
   [BicycleId] int not null,
   [DetailId] int not null,
   [Date] date not null,
   [Price] int not null, -- цена работы
   [StaffId] int not null,
   FOREIGN KEY ([BicycleId]) REFERENCES [Bicycle] ([Id]),
   FOREIGN KEY ([StaffId]) REFERENCES [Staff] ([Id]),
   FOREIGN KEY ([DetailId]) REFERENCES [Detail] ([Id])
);
create table [RentBook] -- аренда велосипеда клиентом
(
   [Id] int IDENTITY(1,1) not null,
   [Date] date not null, -- дата аренды
   [Time] int not null, -- время аренды в часах
   [Paid] bit not null, -- 1 оплатил; 0 не оплатил 
   [BicycleId] int not null,
   [ClientId] int not null,
   [StaffId] int not null,
   FOREIGN KEY ([BicycleId]) REFERENCES [Bicycle] ([Id]),
   FOREIGN KEY ([StaffId]) REFERENCES [Staff] ([Id]),
   FOREIGN KEY ([ClientId]) REFERENCES [Client] ([Id])
   );

-- Задание 1.2


-- Изменить тип данных для колонок, которые хранят цены на DECIMAL
-- для корректных вычислений

alter table Bicycle
alter column RentPrice decimal(10,2) not null;

alter table Detail
alter column Price decimal(10,2) not null;

alter table ServiceBook
alter column Price decimal(10,2) not null;

-- Добавить проверку на положительную сумму
alter table Bicycle
add constraint Positiv_RentPrice check (RentPrice > 0);

alter table Detail
add constraint Positiv_DPrice check (Price > 0);

alter table ServiceBook
add constraint Positiv_SPrice check (Price > 0);

-- корректнее использовать название колонок без пробелов
EXEC sys.sp_rename 'Client.[Phone number]', 'PhoneNumber', 'COLUMN';
-- Переименовываю колонку Date, чтобы не возникало конфликотов из-за используемых имен
EXEC sys.sp_rename 'ServiceBook.[Date]', 'ServiceDate', 'COLUMN';
EXEC sys.sp_rename 'Staff.[Date]', 'StartDate', 'COLUMN';
EXEC sys.sp_rename 'RentBook.[Date]', 'RentDate', 'COLUMN';
EXEC sys.sp_rename 'RentBook.[Time]', 'RentDuration', 'COLUMN';

-- Увеличить количество символов для имени клиента и сотрудника
alter table Client
alter column Name varchar(50) not null;

alter table Staff 
alter column Name varchar(50) not null;

-- Пасспорт и телефон клиента должен быть уникальным, добавляю проверку
alter table Client
add constraint UQ_Client_Passport UNIQUE (Passport);

alter table Client
add constraint UQ_Phone_number UNIQUE ([PhoneNumber]);

-- Аналогично с паспортом сотрудника
alter table Staff 
add constraint UQ_Staff_Passport UNIQUE (Passport);

-- Добавляю PK, чтобы исключить повторения и ускорить поиск
alter table DetailForBicycle 
add constraint PK_Bicycle_Detail PRIMARY KEY (BicycleId, DetailId);

alter table ServiceBook 
add constraint PK_ServiceBook PRIMARY KEY (BicycleId, ServiceDate);

alter table RentBook 
add constraint PK_RentBook PRIMARY KEY (Id);

-- По умолчанию аренда не оплачена
alter table RentBook
add constraint DF_RentBook_Paid DEFAULT 0 FOR Paid;



