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
INSERT INTO employees (branch_id,first_name,last_name,cnic,designation,department,salary,email,hire_date,manager_id) VALUES 
(1,'Khalid','Rahman','3520299999901','Branch Manager','Management',250000,'k.rahman@cbs.pk','2010-01-15', NULL),
(1,'Amina','Syed','3520299999902','Senior Teller','Operations',85000,'a.syed@cbs.pk','2015-03-10', 1),
(3,'Imran','Shah','3520299999905','Branch Manager','Management',240000,'i.shah@cbs.pk','2009-04-01', NULL),
(2,'Zoya','Hassan','3520299999906','Relationship Manager','Sales',120000,'z.hassan@cbs.pk','2018-05-20', 1),
(4,'Omar','Farooq','3520299999907','Loan Officer','Credit',110000,'o.farooq@cbs.pk','2017-11-12', 3),
(5,'Sara','Ahmed','3520299999908','Customer Support','Service',65000,'s.ahmed@cbs.pk','2020-02-15', 3),
(1,'Hamza','Ali','3520299999909','Operations Officer','Operations',95000,'h.ali@cbs.pk','2016-08-22', 1),
(2,'Mona','Khan','3520299999910','Accountant','Finance',105000,'m.khan@cbs.pk','2014-12-05', 1),
(3,'Asif','Mehmood','3520299999911','Security Head','Security',75000,'a.mehmood@cbs.pk','2011-06-30', 3),
(4,'Hina','Raza','3520299999912','IT Specialist','Technology',130000,'h.raza@cbs.pk','2019-09-18', 3);

-- ── 6. ACCOUNTS (IDs 1-10) ───────────────────────
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

-- ── 7. CARDS ──────────────────────────────────────────────
INSERT INTO cards (account_id, card_number, card_type, expiry_date, cvv_hash, daily_limit, is_active) VALUES 
(1, '4532-1111-2222-3333', 'DEBIT', '2028-12-31', 'e3b0c442', 50000, 'Y'),
(2, '4532-1111-2222-4444', 'DEBIT', '2027-06-30', 'e3b0c442', 100000, 'Y'),
(3, '4532-1111-2222-5555', 'DEBIT', '2029-01-15', 'e3b0c442', 50000, 'Y'),
(4, '4532-1111-2222-6666', 'DEBIT', '2026-03-20', 'e3b0c442', 50000, 'Y'),
(5, '4532-1111-2222-7777', 'CREDIT', '2028-10-10', 'e3b0c442', 200000, 'Y'),
(6, '4532-1111-2222-8888', 'DEBIT', '2027-11-05', 'e3b0c442', 50000, 'Y'),
(7, '4532-1111-2222-9999', 'DEBIT', '2028-05-22', 'e3b0c442', 75000, 'Y'),
(8, '4532-2222-3333-4444', 'DEBIT', '2026-08-14', 'e3b0c442', 50000, 'Y'),
(9, '4532-3333-4444-5555', 'DEBIT', '2029-02-28', 'e3b0c442', 50000, 'Y'),
(10, '4532-4444-5555-6666', 'CREDIT', '2028-04-12', 'e3b0c442', 300000, 'Y');

-- ── 8. LOANS ──────────────────────────────────────────────
INSERT INTO loans (customer_id,loan_type_id,branch_id,principal_amount,interest_rate,tenure_months,emi_amount,outstanding,status) VALUES 
(1,1,1,500000,18.00,36,18076,450000,'ACTIVE'),
(2,2,1,12000000,14.00,120,186395,11500000,'ACTIVE'),
(3,3,2,1500000,16.00,60,36476,1400000,'ACTIVE'),
(4,4,3,5000000,20.00,84,112500,4800000,'ACTIVE'),
(5,1,4,200000,18.00,24,10000,180000,'ACTIVE'),
(6,2,3,8000000,14.00,180,106500,7800000,'ACTIVE'),
(7,3,1,2000000,16.00,48,56700,1900000,'ACTIVE'),
(8,5,3,1000000,10.00,60,21247,950000,'ACTIVE'),
(9,6,1,500000,9.00,24,22842,450000,'ACTIVE'),
(10,7,4,300000,15.00,12,27083,280000,'ACTIVE');

-- ── 9. LOAN PAYMENTS ──────────────────────────────────────
INSERT INTO loan_payments (loan_id, amount_paid, principal_component, interest_component, balance_remaining) VALUES 
(1, 18076, 12076, 6000, 431924),
(2, 186395, 86395, 100000, 11413605),
(3, 36476, 21476, 15000, 1378524),
(4, 112500, 62500, 50000, 4737500),
(5, 10000, 7000, 3000, 173000),
(6, 106500, 56500, 50000, 7743500),
(7, 56700, 31700, 25000, 1868300),
(8, 21247, 13247, 8000, 936753),
(9, 22842, 18842, 4000, 431158),
(10, 27083, 23083, 4000, 256917);

-- ── 10. COLLATERAL ─────────────────────────────────────────
INSERT INTO collateral (loan_id, asset_type, estimated_value, description) VALUES 
(2, 'PROPERTY', 15000000, 'House in DHA Karachi'),
(3, 'VEHICLE', 2500000, 'Toyota Corolla 2022'),
(4, 'PROPERTY', 8000000, 'Shop in Liberty Market Lahore'),
(6, 'PROPERTY', 12000000, 'Plot in Bahria Town Islamabad'),
(7, 'VEHICLE', 3500000, 'Honda Civic 2023'),
(8, 'DOCUMENT', 1500000, 'Education Degrees'),
(9, 'LAND', 2000000, 'Agricultural land in Multan'),
(10, 'GOLD', 500000, '10 Tolas of Gold'),
(2, 'PROPERTY', 5000000, 'Additional land in Karachi'),
(4, 'STOCKS', 2000000, 'Portfolio in PSX');

-- ── 11. AUDIT LOG (Initial Entry) ─────────────────────────
INSERT INTO audit_log (table_name, operation, record_id, changed_by, remarks) VALUES 
('SYSTEM', 'INSERT', 0, 'SYSTEM', 'Database population completed for Viva demo.');