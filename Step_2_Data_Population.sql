-- ============================================================
--  CORE BANKING SYSTEM (CBS) — DATA POPULATION
--  DEVELOPED BY: HUZAIFA IMRAN & MUHAMMAD ARSLAN
--  Phase II: Mock Data for Testing and Verification
-- ============================================================

-- CLEANUP OLD DATA (Ensures fresh IDs every time)
TRUNCATE TABLE audit_log, transactions, loan_payments, loans, cards, accounts, employees, customers, loan_types, account_types, branches, collateral, interest_accruals RESTART IDENTITY CASCADE;

-- ── 1. ACCOUNT TYPES ─────────────────────────────────────────
INSERT INTO account_types (type_name, interest_rate, min_balance, description) VALUES 
('Basic Savings',          4.00,  1000, 'Standard savings account'),
('Premium Savings',        8.00,  5000, 'High-yield savings for premium clients'),
('Current Account',         0.00,     0, 'Standard checking account'),
('Fixed Deposit 1Y',      11.50, 10000, '1-year fixed deposit account'),
('Salary Account',         5.00,     0, 'Zero-balance salary account'),
('Student Account',        4.00,     0, 'Zero-balance student account'),
('Senior Citizen Savings', 9.00,  2000, 'Enhanced profit for 60+ customers'),
('Foreign Currency USD',   2.50,   500, 'USD-denominated savings account'),
('Digital Account',        7.00,     0, 'App-only paperless account');

-- ── 2. LOAN TYPES ─────────────────────────────────────────
INSERT INTO loan_types (type_name, base_rate, max_amount, max_tenure_months, description) VALUES 
('Personal Loan',      18.00,  2000000,  60, 'Unsecured personal finance'),
('Home Loan',          14.00, 50000000, 240, 'Secured housing finance'),
('Auto Loan',          16.00,  5000000,  72, 'Vehicle purchase financing'),
('Business Loan',      20.00, 20000000, 120, 'SME / corporate lending'),
('Education Loan',     10.00,  3000000,  84, 'Higher education financing'),
('Agricultural Loan',   9.00,  5000000,  36, 'Crop / farming input loans'),
('Gold Loan',          15.00,  1000000,  24, 'Loan against gold collateral');

-- ── 3. BRANCHES ───────────────────────────────────────────
INSERT INTO branches (branch_code, branch_name, city, address, phone, ifsc_code, established_date) VALUES 
('KHI001','Karachi Main Branch',   'Karachi',   'I.I. Chundrigar Road',  '+92-21-35680001','CBS0KHI001','2005-03-15'),
('KHI002','DHA Branch',            'Karachi',   'Phase VI, Bukhari',     '+92-21-35362002','CBS0KHI002','2008-06-01'),
('LHR001','Lahore Main Branch',    'Lahore',    'Mall Road',             '+92-42-36010004','CBS0LHR001','2005-07-10'),
('ISB001','Islamabad Blue Area',   'Islamabad', 'Blue Area',             '+92-51-28310006','CBS0ISB001','2006-11-30'),
('MUL001','Multan Hussain Agahi',  'Multan',    'Hussain Agahi Road',    '+92-61-45220010','CBS0MUL001','2013-05-22');

-- ── 4. CUSTOMERS ──────────────────────────────────────────
-- IDs 1 to 10 will have Accounts.
-- IDs 11 to 15 will be EMPTY for your Demo.
INSERT INTO customers (cnic,first_name,last_name,date_of_birth,gender,email,phone,address,city,credit_score,kyc_status) VALUES 
('3520212345671','Ahmed',  'Khan',     '1985-04-12','M','ahmed@email.com',   '+92-300-1234567','Gulshan','Karachi',720,'VERIFIED'),
('3520212345672','Fatima', 'Ali',      '1990-08-25','F','fatima@email.com',  '+92-321-2345678','Defence','Karachi',685,'VERIFIED'),
('3520212345673','Bilal',  'Sheikh',   '1978-11-03','M','bilal@email.com',   '+92-333-3456789','Nazimabad','Karachi',760,'VERIFIED'),
('3520212345674','Ayesha', 'Siddiqui', '1995-02-17','F','ayesha@email.com',  '+92-345-4567890','Johar Town','Lahore',640,'VERIFIED'),
('3520212345675','Usman',  'Malik',    '1982-06-30','M','usman@email.com',   '+92-311-5678901','F-7/2','Islamabad',800,'VERIFIED'),
('3520212345676','Sana',   'Qureshi',  '1993-09-14','F','sana@email.com',    '+92-300-6789012','Model Town','Lahore',700,'VERIFIED'),
('3520212345677','Tariq',  'Hussain',  '1970-01-22','M','tariq@email.com',   '+92-321-7890123','Cantt Area','Peshawar',715,'VERIFIED'),
('3520212345678','Zara',   'Baig',     '1998-12-05','F','zara@email.com',    '+92-333-8901234','UET','Lahore',580,'VERIFIED'),
('3520212345679','Kamran', 'Iqbal',    '1975-07-19','M','kamran@email.com',  '+92-345-9012345','Satellite','Quetta',690,'VERIFIED'),
('3520212345680','Nadia',  'Farooq',   '1988-03-28','F','nadia@email.com',   '+92-311-0123456','Bahria','Islamabad',730,'VERIFIED'),
-- TEST USERS (NO ACCOUNTS - DELETABLE)
('3520212345684','Faisal', 'Nawaz',    '1990-11-22','M','faisal@email.com',  '+92-300-1122334','DHA 6','Karachi',700,'VERIFIED'),
('3520212345699','Sung',   'Hua',      '1995-05-15','M','sung@demo.com',    '+92-333-9998887','Model Town','Lahore',750,'VERIFIED'),
('3520212345600','Pending','User',     '1998-01-01','O','pending@test.com',  '+92-300-0000000','F-7','Islamabad',500,'PENDING');

-- ── 5. EMPLOYEES ──────────────────────────────────────────
INSERT INTO employees (branch_id,first_name,last_name,cnic,designation,department,salary,email,hire_date) VALUES 
(1,'Khalid','Rahman','3520299999901','Manager','Management',250000,'k.rahman@cbs.pk','2010-01-15'),
(1,'Amina','Syed','3520299999902','Teller','Operations',80000,'a.syed@cbs.pk','2015-03-10'),
(3,'Imran','Shah','3520299999905','Manager','Management',240000,'i.shah@cbs.pk','2009-04-01');

-- ── 6. ACCOUNTS (Only for IDs 1-10) ───────────────────────
INSERT INTO accounts (account_number,customer_id,branch_id,account_type_id,balance,opened_date,status) VALUES 
('PK36CBS0KHI001000001',1,1,1,125000,'2020-01-10','ACTIVE'),
('PK36CBS0KHI001000002',2,1,2,500000,'2020-01-10','ACTIVE'),
('PK36CBS0KHI002000003',3,2,3,85000,'2021-03-15','ACTIVE'),
('PK36CBS0LHR001000004',4,3,1,42000,'2022-05-01','ACTIVE'),
('PK36CBS0ISB001000005',5,4,2,2500000,'2018-11-12','ACTIVE'),
('PK36CBS0LHR001000006',6,3,1,120000,'2023-02-28','ACTIVE'),
('PK36CBS0KHI001000007',7,1,1,750000,'2017-08-19','ACTIVE'),
('PK36CBS0LHR001000008',8,3,2,5000,'2023-09-01','ACTIVE'),
('PK36CBS0KHI001000009',9,1,1,98000,'2020-12-10','ACTIVE'),
('PK36CBS0ISB001000010',10,4,2,1800000,'2016-03-22','ACTIVE');

-- ── 7. LOANS ──────────────────────────────────────────────
INSERT INTO loans (customer_id,loan_type_id,branch_id,principal_amount,interest_rate,tenure_months,emi_amount,outstanding,status) VALUES 
(1,1,1,500000,18.00,36,18076,450000,'ACTIVE'),
(2,2,1,12000000,14.00,120,186395,11500000,'ACTIVE');

-- ── 8. AUDIT LOG (Initial Entry) ─────────────────────────
INSERT INTO audit_log (table_name, operation, record_id, changed_by, remarks) VALUES 
('SYSTEM', 'INIT', 0, 'SYSTEM', 'Database population completed for Viva demo.');