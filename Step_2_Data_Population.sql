-- ============================================================
--  CORE BANKING SYSTEM (CBS) — DATA POPULATION
--  DEVELOPED BY: HUZAIFA IMRAN & MUHAMMAD ARSLAN
--  Phase II: Mock Data for Testing and Verification
-- ============================================================

-- ── 1. ACCOUNT TYPES ──────────────────────────────────────
INSERT INTO account_types (type_name, interest_rate, min_balance, description) VALUES ('Current Account',        0.00, 10000, 'Business / daily-use current account');
INSERT INTO account_types (type_name, interest_rate, min_balance, description) VALUES ('Savings Account',        6.50,  1000, 'Standard savings with monthly profit');
INSERT INTO account_types (type_name, interest_rate, min_balance, description) VALUES ('Premium Savings',        8.00,  5000, 'High-yield savings for premium clients');
INSERT INTO account_types (type_name, interest_rate, min_balance, description) VALUES ('Fixed Deposit 1Y',      11.50, 10000, '1-year fixed deposit account');
INSERT INTO account_types (type_name, interest_rate, min_balance, description) VALUES ('Fixed Deposit 3Y',      12.50, 25000, '3-year fixed deposit account');
INSERT INTO account_types (type_name, interest_rate, min_balance, description) VALUES ('Salary Account',         5.00,     0, 'Zero-balance salary account');
INSERT INTO account_types (type_name, interest_rate, min_balance, description) VALUES ('Student Account',        4.00,     0, 'Zero-balance student account');
INSERT INTO account_types (type_name, interest_rate, min_balance, description) VALUES ('Senior Citizen Savings', 9.00,  2000, 'Enhanced profit for 60+ customers');
INSERT INTO account_types (type_name, interest_rate, min_balance, description) VALUES ('Foreign Currency USD',   2.50,   500, 'USD-denominated savings account');
INSERT INTO account_types (type_name, interest_rate, min_balance, description) VALUES ('Digital Account',        7.00,     0, 'App-only paperless account');

-- ── 2. LOAN TYPES ─────────────────────────────────────────
INSERT INTO loan_types (type_name, base_rate, max_amount, max_tenure_months, description) VALUES ('Personal Loan',      18.00,  2000000,  60, 'Unsecured personal finance');
INSERT INTO loan_types (type_name, base_rate, max_amount, max_tenure_months, description) VALUES ('Home Loan',          14.00, 50000000, 240, 'Secured housing finance');
INSERT INTO loan_types (type_name, base_rate, max_amount, max_tenure_months, description) VALUES ('Auto Loan',          16.00,  5000000,  72, 'Vehicle purchase financing');
INSERT INTO loan_types (type_name, base_rate, max_amount, max_tenure_months, description) VALUES ('Business Loan',      20.00, 20000000, 120, 'SME / corporate lending');
INSERT INTO loan_types (type_name, base_rate, max_amount, max_tenure_months, description) VALUES ('Education Loan',     10.00,  3000000,  84, 'Higher education financing');
INSERT INTO loan_types (type_name, base_rate, max_amount, max_tenure_months, description) VALUES ('Agricultural Loan',   9.00,  5000000,  36, 'Crop / farming input loans');
INSERT INTO loan_types (type_name, base_rate, max_amount, max_tenure_months, description) VALUES ('Gold Loan',          15.00,  1000000,  24, 'Loan against gold collateral');
INSERT INTO loan_types (type_name, base_rate, max_amount, max_tenure_months, description) VALUES ('Overdraft Facility', 22.00,   500000,  12, 'Current account overdraft line');
INSERT INTO loan_types (type_name, base_rate, max_amount, max_tenure_months, description) VALUES ('Renovation Loan',    17.00,  3000000,  60, 'Home improvement financing');
INSERT INTO loan_types (type_name, base_rate, max_amount, max_tenure_months, description) VALUES ('Medical Loan',       13.00,  1500000,  48, 'Healthcare expense financing');

-- ── 3. BRANCHES ───────────────────────────────────────────
INSERT INTO branches (branch_code, branch_name, city, address, phone, ifsc_code, established_date) VALUES ('KHI001','Karachi Main Branch',   'Karachi',   'I.I. Chundrigar Road, PIDC House',  '+92-21-35680001','CBS0KHI001','2005-03-15');
INSERT INTO branches (branch_code, branch_name, city, address, phone, ifsc_code, established_date) VALUES ('KHI002','DHA Branch',            'Karachi',   'Phase VI, Bukhari Commercial',      '+92-21-35362002','CBS0KHI002','2008-06-01');
INSERT INTO branches (branch_code, branch_name, city, address, phone, ifsc_code, established_date) VALUES ('KHI003','PECHS Branch',          'Karachi',   'Block-6, PECHS, Shahrah-e-Faisal',  '+92-21-34543003','CBS0KHI003','2010-09-20');
INSERT INTO branches (branch_code, branch_name, city, address, phone, ifsc_code, established_date) VALUES ('LHR001','Lahore Main Branch',    'Lahore',    'Mall Road, Aiwan-e-Iqbal Complex',  '+92-42-36010004','CBS0LHR001','2005-07-10');
INSERT INTO branches (branch_code, branch_name, city, address, phone, ifsc_code, established_date) VALUES ('LHR002','Gulberg Branch',        'Lahore',    'Main Boulevard, Gulberg III',       '+92-42-35771005','CBS0LHR002','2012-01-05');
INSERT INTO branches (branch_code, branch_name, city, address, phone, ifsc_code, established_date) VALUES ('ISB001','Islamabad Blue Area',   'Islamabad', 'Blue Area, Jinnah Avenue',          '+92-51-28310006','CBS0ISB001','2006-11-30');
INSERT INTO branches (branch_code, branch_name, city, address, phone, ifsc_code, established_date) VALUES ('ISB002','F-10 Markaz Branch',    'Islamabad', 'F-10 Markaz, Block-A',             '+92-51-22310007','CBS0ISB002','2015-04-18');
INSERT INTO branches (branch_code, branch_name, city, address, phone, ifsc_code, established_date) VALUES ('PES001','Peshawar Saddar Branch','Peshawar',  'Saddar Road, Cantt Area',           '+92-91-52730008','CBS0PES001','2009-02-14');
INSERT INTO branches (branch_code, branch_name, city, address, phone, ifsc_code, established_date) VALUES ('QTA001','Quetta Main Branch',    'Quetta',    'Jinnah Road, City Centre',          '+92-81-28050009','CBS0QTA001','2011-08-05');
INSERT INTO branches (branch_code, branch_name, city, address, phone, ifsc_code, established_date) VALUES ('MUL001','Multan Hussain Agahi',  'Multan',    'Hussain Agahi Road',                '+92-61-45220010','CBS0MUL001','2013-05-22');
INSERT INTO branches (branch_code, branch_name, city, address, phone, ifsc_code, established_date) VALUES ('FSB001','Faisalabad D Ground',   'Faisalabad','D Ground, Karkhana Bazar',          '+92-41-26500011','CBS0FSB001','2014-10-11');

-- ── 4. CUSTOMERS ──────────────────────────────────────────
INSERT INTO customers (cnic,first_name,last_name,date_of_birth,gender,email,phone,address,city,credit_score,kyc_status) VALUES ('3520212345671','Ahmed',  'Khan',     '1985-04-12','M','ahmed.khan@email.com',   '+92-300-1234567','House 12, Block B, Gulshan-e-Iqbal','Karachi',  720,'VERIFIED');
INSERT INTO customers (cnic,first_name,last_name,date_of_birth,gender,email,phone,address,city,credit_score,kyc_status) VALUES ('3520212345672','Fatima', 'Ali',      '1990-08-25','F','fatima.ali@email.com',   '+92-321-2345678','Flat 5A, Defence View Apts',         'Karachi',  685,'VERIFIED');
INSERT INTO customers (cnic,first_name,last_name,date_of_birth,gender,email,phone,address,city,credit_score,kyc_status) VALUES ('3520212345673','Bilal',  'Sheikh',   '1978-11-03','M','bilal.sheikh@email.com', '+92-333-3456789','Plot 22, North Nazimabad',            'Karachi',  760,'VERIFIED');
INSERT INTO customers (cnic,first_name,last_name,date_of_birth,gender,email,phone,address,city,credit_score,kyc_status) VALUES ('3520212345674','Ayesha', 'Siddiqui', '1995-02-17','F','ayesha.s@email.com',     '+92-345-4567890','House 7, Johar Town',                 'Lahore',   640,'VERIFIED');
INSERT INTO customers (cnic,first_name,last_name,date_of_birth,gender,email,phone,address,city,credit_score,kyc_status) VALUES ('3520212345675','Usman',  'Malik',    '1982-06-30','M','usman.malik@email.com',  '+92-311-5678901','Street 4, F-7/2',                     'Islamabad',800,'VERIFIED');
INSERT INTO customers (cnic,first_name,last_name,date_of_birth,gender,email,phone,address,city,credit_score,kyc_status) VALUES ('3520212345684','Usman',  'Malik',    '1990-11-22','M','usman.malik.alt@gmail.com','+92-300-1122334','DHA Phase 6',                       'Karachi',  700,'VERIFIED');
INSERT INTO customers (cnic,first_name,last_name,date_of_birth,gender,email,phone,address,city,credit_score,kyc_status) VALUES ('3520212345699','Sung',   'Hua',      '1995-05-15','M','sung.hua@demo.com',      '+92-333-9998887','Model Town',                        'Lahore',   750,'VERIFIED');
INSERT INTO customers (cnic,first_name,last_name,date_of_birth,gender,email,phone,address,city,credit_score,kyc_status) VALUES ('3520212345600','Pending','User',     '1998-01-01','O','pending@test.com',       '+92-300-0000000','F-7 Markaz',                        'Islamabad',500,'PENDING');
INSERT INTO customers (cnic,first_name,last_name,date_of_birth,gender,email,phone,address,city,credit_score,kyc_status) VALUES ('3520212345611','Test',   'Entry',    '1992-12-12','F','test@example.com',       '+92-321-1234567','People Colony',                     'Faisalabad',650,'VERIFIED');
INSERT INTO customers (cnic,first_name,last_name,date_of_birth,gender,email,phone,address,city,credit_score,kyc_status) VALUES ('3520212345676','Sana',   'Qureshi',  '1993-09-14','F','sana.q@email.com',       '+92-300-6789012','House 3, Model Town',                 'Lahore',   700,'VERIFIED');
INSERT INTO customers (cnic,first_name,last_name,date_of_birth,gender,email,phone,address,city,credit_score,kyc_status) VALUES ('3520212345677','Tariq',  'Hussain',  '1970-01-22','M','tariq.h@email.com',      '+92-321-7890123','Plot 9, Cantt Area',                  'Peshawar', 715,'VERIFIED');
INSERT INTO customers (cnic,first_name,last_name,date_of_birth,gender,email,phone,address,city,credit_score,kyc_status) VALUES ('3520212345678','Zara',   'Baig',     '1998-12-05','F','zara.baig@email.com',    '+92-333-8901234','Hostel Block C, UET',                 'Lahore',   580,'VERIFIED');
INSERT INTO customers (cnic,first_name,last_name,date_of_birth,gender,email,phone,address,city,credit_score,kyc_status) VALUES ('3520212345679','Kamran', 'Iqbal',    '1975-07-19','M','kamran.i@email.com',     '+92-345-9012345','House 45, Satellite Town',             'Quetta',   690,'VERIFIED');
INSERT INTO customers (cnic,first_name,last_name,date_of_birth,gender,email,phone,address,city,credit_score,kyc_status) VALUES ('3520212345680','Nadia',  'Farooq',   '1988-03-28','F','nadia.f@email.com',      '+92-311-0123456','Flat 12, Bahria Enclave',              'Islamabad',730,'VERIFIED');
INSERT INTO customers (cnic,first_name,last_name,date_of_birth,gender,email,phone,address,city,credit_score,kyc_status) VALUES ('3520212345681','Hassan', 'Raza',     '1965-10-10','M','hassan.r@email.com',     '+92-300-1122334','House 88, Hussain Agahi',              'Multan',   750,'VERIFIED');
INSERT INTO customers (cnic,first_name,last_name,date_of_birth,gender,email,phone,address,city,credit_score,kyc_status) VALUES ('3520212345682','Mariam', 'Javed',    '2001-05-03','F','mariam.j@email.com',     '+92-321-2233445','Dorm 3, BZU Campus',                  'Multan',   560,'PENDING');
INSERT INTO customers (cnic,first_name,last_name,date_of_birth,gender,email,phone,address,city,credit_score,kyc_status) VALUES ('3520212345683','Faisal', 'Nawaz',    '1991-08-15','M','faisal.n@email.com',     '+92-333-3344556','Plot 55, D-Ground Area',              'Faisalabad',670,'VERIFIED');

-- ── 5. EMPLOYEES ──────────────────────────────────────────
INSERT INTO employees (branch_id,first_name,last_name,cnic,designation,department,salary,email,hire_date) VALUES
  (1,'Khalid','Rahman','3520299999901','Branch Manager','Management',250000,'k.rahman@cbs.pk','2010-01-15');
INSERT INTO employees (branch_id,first_name,last_name,cnic,designation,department,salary,email,hire_date,manager_id) VALUES
  (1,'Amina','Syed','3520299999902','Senior Teller','Operations',80000,'a.syed@cbs.pk','2015-03-10',1);
INSERT INTO employees (branch_id,first_name,last_name,cnic,designation,department,salary,email,hire_date,manager_id) VALUES
  (1,'Rizwan','Butt','3520299999903','Teller','Operations',60000,'r.butt@cbs.pk','2019-06-01',1);
INSERT INTO employees (branch_id,first_name,last_name,cnic,designation,department,salary,email,hire_date,manager_id) VALUES
  (1,'Saima','Naz','3520299999904','Loan Officer','Credit',90000,'s.naz@cbs.pk','2016-09-20',1);
INSERT INTO employees (branch_id,first_name,last_name,cnic,designation,department,salary,email,hire_date) VALUES
  (4,'Imran','Shah','3520299999905','Branch Manager','Management',240000,'i.shah@cbs.pk','2009-04-01');
INSERT INTO employees (branch_id,first_name,last_name,cnic,designation,department,salary,email,hire_date,manager_id) VALUES
  (4,'Mehwish','Chaudhry','3520299999906','Senior Teller','Operations',78000,'m.chaudhry@cbs.pk','2017-11-15',5);
INSERT INTO employees (branch_id,first_name,last_name,cnic,designation,department,salary,email,hire_date,manager_id) VALUES
  (4,'Omar','Farhan','3520299999907','Relationship Manager','Retail',110000,'o.farhan@cbs.pk','2014-02-28',5);
INSERT INTO employees (branch_id,first_name,last_name,cnic,designation,department,salary,email,hire_date) VALUES
  (6,'Rabia','Tahir','3520299999908','Branch Manager','Management',260000,'r.tahir@cbs.pk','2008-07-15');
INSERT INTO employees (branch_id,first_name,last_name,cnic,designation,department,salary,email,hire_date,manager_id) VALUES
  (6,'Shahid','Mir','3520299999909','IT Officer','Technology',120000,'s.mir@cbs.pk','2020-01-10',8);
INSERT INTO employees (branch_id,first_name,last_name,cnic,designation,department,salary,email,hire_date,manager_id) VALUES
  (6,'Hina','Lodhi','3520299999910','Compliance Officer','Compliance',130000,'h.lodhi@cbs.pk','2013-05-05',8);
INSERT INTO employees (branch_id,first_name,last_name,cnic,designation,department,salary,email,hire_date,manager_id) VALUES
  (1,'Ali','Raza','3520299999911','Customer Service Rep','Operations',55000,'ali.raza@cbs.pk','2022-03-01',1);
INSERT INTO employees (branch_id,first_name,last_name,cnic,designation,department,salary,email,hire_date,manager_id) VALUES
  (2,'Sara','Khan','3520299999912','Teller','Operations',58000,'sara.khan@cbs.pk','2021-08-15',1);

-- ── 6. ACCOUNTS ───────────────────────────────────────────
INSERT INTO accounts (account_number,customer_id,branch_id,account_type_id,balance,opened_date,status,currency) VALUES ('PK36CBS0KHI001000001',1,1,2,125000,'2020-01-10','ACTIVE','PKR');
INSERT INTO accounts (account_number,customer_id,branch_id,account_type_id,balance,opened_date,status,currency) VALUES ('PK36CBS0KHI001000002',1,1,1,500000,'2020-01-10','ACTIVE','PKR');
INSERT INTO accounts (account_number,customer_id,branch_id,account_type_id,balance,opened_date,status,currency) VALUES ('PK36CBS0KHI002000003',2,2,6,85000,'2021-03-15','ACTIVE','PKR');
INSERT INTO accounts (account_number,customer_id,branch_id,account_type_id,balance,opened_date,status,currency) VALUES ('PK36CBS0KHI001000004',3,1,3,950000,'2019-06-20','ACTIVE','PKR');
INSERT INTO accounts (account_number,customer_id,branch_id,account_type_id,balance,opened_date,status,currency) VALUES ('PK36CBS0LHR001000005',4,4,2,42000,'2022-05-01','ACTIVE','PKR');
INSERT INTO accounts (account_number,customer_id,branch_id,account_type_id,balance,opened_date,status,currency) VALUES ('PK36CBS0ISB001000006',5,6,3,2500000,'2018-11-12','ACTIVE','PKR');
INSERT INTO accounts (account_number,customer_id,branch_id,account_type_id,balance,opened_date,status,currency) VALUES ('PK36CBS0LHR001000007',6,4,6,120000,'2023-02-28','ACTIVE','PKR');
INSERT INTO accounts (account_number,customer_id,branch_id,account_type_id,balance,opened_date,status,currency) VALUES ('PK36CBS0PES001000008',7,8,1,750000,'2017-08-19','ACTIVE','PKR');
INSERT INTO accounts (account_number,customer_id,branch_id,account_type_id,balance,opened_date,status,currency) VALUES ('PK36CBS0LHR002000009',8,5,7,5000,'2023-09-01','ACTIVE','PKR');
INSERT INTO accounts (account_number,customer_id,branch_id,account_type_id,balance,opened_date,status,currency) VALUES ('PK36CBS0QTA001000010',9,9,2,98000,'2020-12-10','ACTIVE','PKR');
INSERT INTO accounts (account_number,customer_id,branch_id,account_type_id,balance,opened_date,status,currency) VALUES ('PK36CBS0ISB001000011',10,6,3,1800000,'2016-03-22','ACTIVE','PKR');
INSERT INTO accounts (account_number,customer_id,branch_id,account_type_id,balance,opened_date,status,currency) VALUES ('PK36CBS0MUL001000012',11,10,8,350000,'2014-07-05','ACTIVE','PKR');
INSERT INTO accounts (account_number,customer_id,branch_id,account_type_id,balance,opened_date,status,currency) VALUES ('PK36CBS0MUL001000013',12,10,7,2500,'2024-01-20','ACTIVE','PKR');
INSERT INTO accounts (account_number,customer_id,branch_id,account_type_id,balance,opened_date,status,currency) VALUES ('PK36CBS0FSB001000014',13,11,2,67000,'2022-11-11','ACTIVE','PKR');
INSERT INTO accounts (account_number,customer_id,branch_id,account_type_id,balance,opened_date,status,currency) VALUES ('PK36CBS0KHI001000015',5,1,9,15000,'2021-04-01','ACTIVE','USD');

-- ── 7. CARDS ──────────────────────────────────────────────
INSERT INTO cards (account_id,card_number,card_type,expiry_date,cvv_hash,daily_limit) VALUES (1,'4111111111110001','DEBIT', '2027-12-31','abc123hash',50000);
INSERT INTO cards (account_id,card_number,card_type,expiry_date,cvv_hash,daily_limit) VALUES (2,'4111111111110002','DEBIT', '2027-06-30','abc124hash',200000);
INSERT INTO cards (account_id,card_number,card_type,expiry_date,cvv_hash,daily_limit) VALUES (3,'4111111111110003','DEBIT', '2026-09-30','abc125hash',50000);
INSERT INTO cards (account_id,card_number,card_type,expiry_date,cvv_hash,daily_limit) VALUES (4,'4111111111110004','CREDIT','2028-03-31','abc126hash',500000);
INSERT INTO cards (account_id,card_number,card_type,expiry_date,cvv_hash,daily_limit) VALUES (5,'4111111111110005','DEBIT', '2027-12-31','abc127hash',50000);
INSERT INTO cards (account_id,card_number,card_type,expiry_date,cvv_hash,daily_limit) VALUES (6,'4111111111110006','CREDIT','2028-06-30','abc128hash',1000000);
INSERT INTO cards (account_id,card_number,card_type,expiry_date,cvv_hash,daily_limit) VALUES (7,'4111111111110007','DEBIT', '2026-12-31','abc129hash',100000);
INSERT INTO cards (account_id,card_number,card_type,expiry_date,cvv_hash,daily_limit) VALUES (8,'4111111111110008','DEBIT', '2027-09-30','abc130hash',150000);
INSERT INTO cards (account_id,card_number,card_type,expiry_date,cvv_hash,daily_limit) VALUES (9,'4111111111110009','DEBIT', '2026-03-31','abc131hash',20000);
INSERT INTO cards (account_id,card_number,card_type,expiry_date,cvv_hash,daily_limit) VALUES (10,'4111111111110010','DEBIT','2027-12-31','abc132hash',50000);
INSERT INTO cards (account_id,card_number,card_type,expiry_date,cvv_hash,daily_limit) VALUES (11,'4111111111110011','CREDIT','2028-12-31','abc133hash',750000);
INSERT INTO cards (account_id,card_number,card_type,expiry_date,cvv_hash,daily_limit) VALUES (12,'4111111111110012','DEBIT','2027-06-30','abc134hash',100000);

-- ── 8. TRANSACTIONS ───────────────────────────────────────
INSERT INTO transactions (account_id,txn_type,amount,balance_after,reference_no,description,channel,txn_date,performed_by,status) VALUES (1,'DEPOSIT',50000,125000,'REF20240115001','Initial cash deposit','BRANCH','2024-01-15',2,'SUCCESS');
INSERT INTO transactions (account_id,txn_type,amount,balance_after,reference_no,description,channel,txn_date,status) VALUES (1,'WITHDRAWAL',15000,110000,'REF20240118002','ATM cash withdrawal','ATM','2024-01-18','SUCCESS');
INSERT INTO transactions (account_id,txn_type,amount,balance_after,reference_no,description,channel,txn_date,status) VALUES (1,'TRANSFER_OUT',20000,90000,'REF20240201003','Online bill payment - KESC','INTERNET','2024-02-01','SUCCESS');
INSERT INTO transactions (account_id,txn_type,amount,balance_after,reference_no,description,channel,txn_date,performed_by,status) VALUES (2,'DEPOSIT',500000,500000,'REF20200110004','Account opening deposit','BRANCH','2020-01-10',2,'SUCCESS');
INSERT INTO transactions (account_id,txn_type,amount,balance_after,reference_no,description,channel,txn_date,status) VALUES (3,'DEPOSIT',85000,85000,'REF20210315005','Salary credit March 2021','INTERNET','2021-03-15','SUCCESS');
INSERT INTO transactions (account_id,txn_type,amount,balance_after,reference_no,description,channel,txn_date,status) VALUES (3,'FEE',500,84500,'REF20210401006','Monthly maintenance fee','BRANCH','2021-04-01','SUCCESS');
INSERT INTO transactions (account_id,txn_type,amount,balance_after,reference_no,description,channel,txn_date,status) VALUES (4,'DEPOSIT',1000000,950000,'REF20190620007','Business proceeds deposit','BRANCH','2019-06-20','SUCCESS');
INSERT INTO transactions (account_id,txn_type,amount,balance_after,reference_no,description,channel,txn_date,status) VALUES (5,'DEPOSIT',42000,42000,'REF20220501008','Initial deposit','BRANCH','2022-05-01','SUCCESS');
INSERT INTO transactions (account_id,txn_type,amount,balance_after,reference_no,description,channel,txn_date,status) VALUES (6,'DEPOSIT',2500000,2500000,'REF20181112009','Investment transfer','INTERNET','2018-11-12','SUCCESS');
INSERT INTO transactions (account_id,txn_type,amount,balance_after,reference_no,description,channel,txn_date,status) VALUES (6,'INTEREST',15000,2515000,'REF20240131010','Monthly profit credit Jan','BRANCH','2024-01-31','SUCCESS');
INSERT INTO transactions (account_id,txn_type,amount,balance_after,reference_no,description,channel,txn_date,status) VALUES (7,'DEPOSIT',120000,120000,'REF20230228011','Salary credit Feb 2023','INTERNET','2023-02-28','SUCCESS');
INSERT INTO transactions (account_id,txn_type,amount,balance_after,reference_no,description,channel,txn_date,status) VALUES (7,'WITHDRAWAL',30000,90000,'REF20230315012','POS purchase - Hyperstar','POS','2023-03-15','SUCCESS');
INSERT INTO transactions (account_id,txn_type,amount,balance_after,reference_no,description,channel,txn_date,status) VALUES (8,'DEPOSIT',750000,750000,'REF20170819013','Business account funding','BRANCH','2017-08-19','SUCCESS');
INSERT INTO transactions (account_id,txn_type,amount,balance_after,reference_no,description,channel,txn_date,status) VALUES (10,'DEPOSIT',98000,98000,'REF20201210014','Salary transfer','INTERNET','2020-12-10','SUCCESS');
INSERT INTO transactions (account_id,txn_type,amount,balance_after,reference_no,description,channel,txn_date,status) VALUES (1,'TRANSFER_IN',35000,160000,'REF20240310015','Transfer from family','MOBILE','2024-03-10','SUCCESS');

-- ── 9. LOANS ──────────────────────────────────────────────
INSERT INTO loans (customer_id,loan_type_id,branch_id,approved_by,principal_amount,interest_rate,tenure_months,emi_amount,disbursement_date,maturity_date,outstanding,status,application_date) VALUES (1,1,1,4,500000,18.00,24,24939,'2023-02-01','2025-01-31',250000,'ACTIVE','2023-01-15');
INSERT INTO loans (customer_id,loan_type_id,branch_id,approved_by,principal_amount,interest_rate,tenure_months,emi_amount,disbursement_date,maturity_date,outstanding,status,application_date) VALUES (3,2,1,4,8000000,14.50,180,113500,'2021-09-01','2036-08-31',6800000,'ACTIVE','2021-08-10');
INSERT INTO loans (customer_id,loan_type_id,branch_id,approved_by,principal_amount,interest_rate,tenure_months,emi_amount,disbursement_date,maturity_date,outstanding,status,application_date) VALUES (5,3,6,8,1500000,16.00,60,36392,'2022-06-15','2027-05-31',900000,'ACTIVE','2022-06-01');
INSERT INTO loans (customer_id,loan_type_id,branch_id,approved_by,principal_amount,interest_rate,tenure_months,emi_amount,disbursement_date,maturity_date,outstanding,status,application_date) VALUES (7,4,8,8,5000000,20.00,84,109167,'2020-03-01','2027-02-28',3000000,'ACTIVE','2020-02-15');
INSERT INTO loans (customer_id,loan_type_id,branch_id,approved_by,principal_amount,interest_rate,tenure_months,emi_amount,disbursement_date,maturity_date,outstanding,status,application_date) VALUES (8,5,5,5,300000,10.00,36,9676,'2023-10-01','2026-09-30',210000,'ACTIVE','2023-09-15');
INSERT INTO loans (customer_id,loan_type_id,branch_id,approved_by,principal_amount,interest_rate,tenure_months,emi_amount,disbursement_date,maturity_date,outstanding,status,application_date) VALUES (2,1,2,4,200000,19.00,12,18408,'2022-01-01','2022-12-31',0,'CLOSED','2021-12-10');
INSERT INTO loans (customer_id,loan_type_id,branch_id,approved_by,principal_amount,interest_rate,tenure_months,emi_amount,disbursement_date,maturity_date,outstanding,status,application_date) VALUES (11,2,10,8,12000000,14.00,240,152000,'2019-05-01','2039-04-30',10800000,'ACTIVE','2019-04-15');
INSERT INTO loans (customer_id,loan_type_id,branch_id,approved_by,principal_amount,interest_rate,tenure_months,emi_amount,disbursement_date,maturity_date,outstanding,status,application_date) VALUES (13,6,11,NULL,400000,9.00,24,18318,NULL,NULL,400000,'PENDING','2024-03-20');
INSERT INTO loans (customer_id,loan_type_id,branch_id,approved_by,principal_amount,interest_rate,tenure_months,emi_amount,disbursement_date,maturity_date,outstanding,status,application_date) VALUES (6,9,4,7,1000000,17.00,48,28956,'2024-01-15','2028-01-14',950000,'ACTIVE','2024-01-01');
INSERT INTO loans (customer_id,loan_type_id,branch_id,approved_by,principal_amount,interest_rate,tenure_months,emi_amount,disbursement_date,maturity_date,outstanding,status,application_date) VALUES (9,7,9,8,150000,15.00,12,13563,'2023-06-01','2024-05-31',0,'CLOSED','2023-05-20');
INSERT INTO loans (customer_id,loan_type_id,branch_id,approved_by,principal_amount,interest_rate,tenure_months,emi_amount,disbursement_date,maturity_date,outstanding,status,application_date) VALUES (4,10,4,7,80000,13.00,24,3798,'2023-11-01','2025-10-31',60000,'ACTIVE','2023-10-25');

-- ── 10. LOAN PAYMENTS ─────────────────────────────────────
INSERT INTO loan_payments (loan_id,payment_date,amount_paid,principal_component,interest_component,balance_remaining,payment_mode) VALUES (1,'2023-03-01',24939,17439,7500,482561,'ACCOUNT_DEBIT');
INSERT INTO loan_payments (loan_id,payment_date,amount_paid,principal_component,interest_component,balance_remaining,payment_mode) VALUES (1,'2023-04-01',24939,17700,7239,464861,'ACCOUNT_DEBIT');
INSERT INTO loan_payments (loan_id,payment_date,amount_paid,principal_component,interest_component,balance_remaining,payment_mode) VALUES (1,'2023-05-01',24939,17966,6973,446895,'ACCOUNT_DEBIT');
INSERT INTO loan_payments (loan_id,payment_date,amount_paid,principal_component,interest_component,balance_remaining,payment_mode) VALUES (2,'2021-10-01',113500,75167,38333,7924833,'ACCOUNT_DEBIT');
INSERT INTO loan_payments (loan_id,payment_date,amount_paid,principal_component,interest_component,balance_remaining,payment_mode) VALUES (2,'2021-11-01',113500,76076,37424,7848757,'ACCOUNT_DEBIT');
INSERT INTO loan_payments (loan_id,payment_date,amount_paid,principal_component,interest_component,balance_remaining,payment_mode) VALUES (3,'2022-07-15',36392,18392,18000,1481608,'ACCOUNT_DEBIT');
INSERT INTO loan_payments (loan_id,payment_date,amount_paid,principal_component,interest_component,balance_remaining,payment_mode) VALUES (3,'2022-08-15',36392,18613,17779,1462995,'ACCOUNT_DEBIT');
INSERT INTO loan_payments (loan_id,payment_date,amount_paid,principal_component,interest_component,balance_remaining,payment_mode) VALUES (5,'2023-11-01',9676,7176,2500,292824,'ACCOUNT_DEBIT');
INSERT INTO loan_payments (loan_id,payment_date,amount_paid,principal_component,interest_component,balance_remaining,payment_mode) VALUES (5,'2023-12-01',9676,7236,2440,285588,'ACCOUNT_DEBIT');
INSERT INTO loan_payments (loan_id,payment_date,amount_paid,principal_component,interest_component,balance_remaining,payment_mode) VALUES (6,'2022-02-01',18408,15241,3167,184759,'ACCOUNT_DEBIT');
INSERT INTO loan_payments (loan_id,payment_date,amount_paid,principal_component,interest_component,balance_remaining,payment_mode) VALUES (6,'2022-03-01',18408,15482,2926,169277,'ACCOUNT_DEBIT');
INSERT INTO loan_payments (loan_id,payment_date,amount_paid,principal_component,interest_component,balance_remaining,payment_mode) VALUES (7,'2019-06-01',152000,12000,140000,11988000,'ONLINE');
INSERT INTO loan_payments (loan_id,payment_date,amount_paid,principal_component,interest_component,balance_remaining,payment_mode) VALUES (9,'2024-02-15',28956,22456,6500,927544,'ACCOUNT_DEBIT');
INSERT INTO loan_payments (loan_id,payment_date,amount_paid,principal_component,interest_component,balance_remaining,payment_mode) VALUES (11,'2023-12-01',3798,2931,867,77069,'ACCOUNT_DEBIT');
INSERT INTO loan_payments (loan_id,payment_date,amount_paid,principal_component,interest_component,balance_remaining,payment_mode) VALUES (11,'2024-01-01',3798,2963,835,74106,'ACCOUNT_DEBIT');