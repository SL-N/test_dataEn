from faker import Faker
from sqlalchemy import create_engine
import random
from datetime import timedelta, date

fake = Faker()

engine = create_engine("mssql+pymssql://sa:MyStrongPass123!@localhost:1433/test_db")



with engine.begin() as conn: 

    bicycle_ids = []
    for _ in range(10):
        brand = fake.company()
        rent_price = round(random.uniform(5, 50), 2)
        result = conn.execute(
            "INSERT INTO Bicycle (Brand, RentPrice) VALUES (%s, %s); SELECT SCOPE_IDENTITY();",
            brand, rent_price
        )
        bicycle_ids.append(result.scalar()) 
    
    used_pass = set()
    used_phone = set()
    client_ids = []
    # Client
    for _ in range(10):
        name = fake.first_name()
        passport = fake.bothify(text='??######')

        # проверка на уникальность passport
        while passport in used_pass:
            passport = fake.bothify(text='??######')
        used_pass.add(passport)

        phone = fake.phone_number()
         # проверка на уникальность phone
        while phone in used_phone:
            phone = fake.phone_number()
        used_phone.add(passport)

        country = fake.country()
        result = conn.execute(
            "INSERT INTO Client (Name, Passport, PhoneNumber, Country) VALUES (%s, %s, %s, %s); SELECT SCOPE_IDENTITY();",
            name, passport, phone, country
        )
        client_ids.append(result.scalar())

    # Staff
    used_pass.clear()
    staff_ids = []
    for _ in range(5):
        name = fake.name()
        passport = fake.bothify(text='ST######')

        while passport in used_pass:
            passport = fake.bothify(text='??######')
        used_pass.add(passport)
        
        hire_date = fake.date_between(start_date='-5y', end_date='today')
        result = conn.execute(
            "INSERT INTO Staff (Name, Passport, StartDate) VALUES (%s, %s, %s); SELECT SCOPE_IDENTITY();",
            name, passport, hire_date
        )
        staff_ids.append(result.scalar())

    # Detail
    detail_ids = []

    detail_types = [
    "Chain",      # Цепь
    "Sprocket",   # Звезда
    "Brake",      # Тормоз
    "Tire",       # Шина
    "Frame"       # Рама
    ]

    detail_names = [
        "Shimano CN-HG53",       # Цепь
        "SRAM X01 Eagle",        # Звезда
        "Tektro Auriga",         # Тормоз
        "Continental Grand Prix 5000",  # Шина
        "Giant Aluxx SL"         # Рама
    ]
    for _ in range(10):
        brand = fake.company()
        type_ = random.choice(detail_types)
        name = random.choice(detail_names)
        price = round(random.uniform(10, 100), 2)
        result = conn.execute(
            "INSERT INTO Detail (Brand, Type, Name, Price) VALUES (%s, %s, %s, %s); SELECT SCOPE_IDENTITY();",
            brand, type_, name, price
        )
        detail_ids.append(result.scalar())

    # DetailForBicycle
    for b_id in bicycle_ids:
        for d_id in random.sample(detail_ids, k=3):  # случайные 3 детали на велосипед
            conn.execute(
                "INSERT INTO DetailForBicycle (BicycleId, DetailId) VALUES (%s, %s)",
                b_id, d_id
            )

    # RentBook
    for _ in range(15):
        rent_date = fake.date_between(start_date='-1y', end_date='today')
        rent_duration = random.randint(1, 8)
        paid = random.randint(0, 1)
        bicycle_id = random.choice(bicycle_ids)
        client_id = random.choice(client_ids)
        staff_id = random.choice(staff_ids)
        conn.execute(
            "INSERT INTO RentBook (RentDate, RentDuration, Paid, BicycleId, ClientId, StaffId) "
            "VALUES (%s, %s, %s, %s, %s, %s)",
            rent_date, rent_duration, paid, bicycle_id, client_id, staff_id
        )

    # ServiceBook
    for _ in range(15):
        bicycle_id = random.choice(bicycle_ids)
        detail_id = random.choice(detail_ids)
        service_date = fake.date_between(start_date='-1y', end_date='today')
        price = round(random.uniform(10, 100), 2)
        staff_id = random.choice(staff_ids)
        conn.execute(
            "INSERT INTO ServiceBook (BicycleId, DetailId, ServiceDate, Price, StaffId) "
            "VALUES (%s, %s, %s, %s, %s)",
            bicycle_id, detail_id, service_date, price, staff_id
        )
