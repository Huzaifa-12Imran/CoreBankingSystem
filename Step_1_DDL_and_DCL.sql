-- ============================================================
--  CORE BANKING SYSTEM (CBS) — DATABASE SCHEMA & DCL
--  Phase I & II: Table Definitions, Constraints, and Permissions
-- ============================================================

-- ── DROP in reverse dependency order ──
DROP TABLE IF EXISTS interest_accruals   CASCADE;
DROP TABLE IF EXISTS collateral         CASCADE;
DROP TABLE IF EXISTS audit_log         CASCADE;
DROP TABLE IF EXISTS loan_payments     CASCADE;
DROP TABLE IF EXISTS loans             CASCADE;
DROP TABLE IF EXISTS transactions      CASCADE;
DROP TABLE IF EXISTS accounts          CASCADE;
DROP TABLE IF EXISTS cards             CASCADE;
DROP TABLE IF EXISTS employees         CASCADE;
DROP TABLE IF EXISTS branches          CASCADE;
DROP TABLE IF EXISTS customers         CASCADE;
DROP TABLE IF EXISTS account_types     CASCADE;
DROP TABLE IF EXISTS loan_types        CASCADE;

-- ============================================================
-- 1. LOOKUP / REFERENCE TABLES
-- ============================================================

CREATE TABLE account_types (
    account_type_id   INTEGER        GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    type_name         VARCHAR(30)    NOT NULL UNIQUE,
    interest_rate     NUMERIC(5,2)   NOT NULL CHECK (interest_rate >= 0),
    min_balance       NUMERIC(12,2)  DEFAULT 0 NOT NULL CHECK (min_balance >= 0),
    description       VARCHAR(200)
);

CREATE TABLE loan_types (
    loan_type_id      INTEGER        GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    type_name         VARCHAR(40)    NOT NULL UNIQUE,
    base_rate         NUMERIC(5,2)   NOT NULL CHECK (base_rate > 0),
    max_amount        NUMERIC(14,2)  NOT NULL,
    max_tenure_months INTEGER        NOT NULL CHECK (max_tenure_months > 0),
    description       VARCHAR(200)
);

-- ============================================================
-- 2. CORE ENTITY TABLES
-- ============================================================

CREATE TABLE branches (
    branch_id         INTEGER        GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    branch_code       VARCHAR(10)    NOT NULL UNIQUE,
    branch_name       VARCHAR(100)   NOT NULL,
    city              VARCHAR(60)    NOT NULL,
    address           VARCHAR(200)   NOT NULL,
    phone             VARCHAR(20),
    ifsc_code         VARCHAR(15)    NOT NULL UNIQUE,
    established_date  DATE           DEFAULT CURRENT_DATE NOT NULL,
    is_active         CHAR(1)        DEFAULT 'Y' NOT NULL CHECK (is_active IN ('Y','N'))
);

CREATE TABLE customers (
    customer_id       INTEGER        GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    cnic              VARCHAR(15)    NOT NULL UNIQUE,
    first_name        VARCHAR(60)    NOT NULL,
    last_name         VARCHAR(60)    NOT NULL,
    date_of_birth     DATE           NOT NULL,
    gender            CHAR(1)        NOT NULL CHECK (gender IN ('M','F','O')),
    email             VARCHAR(120)   UNIQUE,
    phone             VARCHAR(20)    NOT NULL,
    address           VARCHAR(300)   NOT NULL,
    city              VARCHAR(60)    NOT NULL,
    credit_score      INTEGER        DEFAULT 650 CHECK (credit_score BETWEEN 300 AND 850),
    kyc_status        VARCHAR(20)    DEFAULT 'PENDING' CHECK (kyc_status IN ('PENDING','VERIFIED','REJECTED')),
    registration_date DATE           DEFAULT CURRENT_DATE NOT NULL,
    is_active         CHAR(1)        DEFAULT 'Y' NOT NULL CHECK (is_active IN ('Y','N'))
);

CREATE TABLE employees (
    employee_id       INTEGER        GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    branch_id         INTEGER        NOT NULL REFERENCES branches(branch_id),
    first_name        VARCHAR(60)    NOT NULL,
    last_name         VARCHAR(60)    NOT NULL,
    cnic              VARCHAR(15)    NOT NULL UNIQUE,
    designation       VARCHAR(80)    NOT NULL,
    department        VARCHAR(60)    NOT NULL,
    salary            NUMERIC(12,2)  NOT NULL CHECK (salary > 0),
    email             VARCHAR(120)   NOT NULL UNIQUE,
    hire_date         DATE           DEFAULT CURRENT_DATE NOT NULL,
    manager_id        INTEGER        REFERENCES employees(employee_id),
    is_active         CHAR(1)        DEFAULT 'Y' NOT NULL CHECK (is_active IN ('Y','N'))
);

-- ============================================================
-- 3. ACCOUNTS
-- ============================================================

CREATE TABLE accounts (
    account_id        INTEGER        GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    account_number    VARCHAR(20)    NOT NULL UNIQUE,
    customer_id       INTEGER        NOT NULL REFERENCES customers(customer_id),
    branch_id         INTEGER        NOT NULL REFERENCES branches(branch_id),
    account_type_id   INTEGER        NOT NULL REFERENCES account_types(account_type_id),
    balance           NUMERIC(14,2)  DEFAULT 0 NOT NULL,
    opened_date       DATE           DEFAULT CURRENT_DATE NOT NULL,
    status            VARCHAR(15)    DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE','DORMANT','CLOSED','FROZEN')),
    currency          CHAR(3)        DEFAULT 'PKR' NOT NULL,
    last_txn_date     DATE
);

CREATE TABLE cards (
    card_id           INTEGER        GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    account_id        INTEGER        NOT NULL REFERENCES accounts(account_id),
    card_number       VARCHAR(19)    NOT NULL UNIQUE,
    card_type         VARCHAR(15)    NOT NULL CHECK (card_type IN ('DEBIT','CREDIT','PREPAID')),
    expiry_date       DATE           NOT NULL,
    cvv_hash          VARCHAR(64)    NOT NULL,
    daily_limit       NUMERIC(10,2)  DEFAULT 50000 NOT NULL,
    is_active         CHAR(1)        DEFAULT 'Y' NOT NULL CHECK (is_active IN ('Y','N')),
    issued_date       DATE           DEFAULT CURRENT_DATE NOT NULL
);

-- ============================================================
-- 4. TRANSACTIONS
-- ============================================================

CREATE TABLE transactions (
    transaction_id    INTEGER        GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    account_id        INTEGER        NOT NULL REFERENCES accounts(account_id),
    txn_type          VARCHAR(20)    NOT NULL CHECK (txn_type IN ('DEPOSIT','WITHDRAWAL','TRANSFER_IN','TRANSFER_OUT','FEE','INTEREST')),
    amount            NUMERIC(14,2)  NOT NULL CHECK (amount > 0),
    balance_after     NUMERIC(14,2)  NOT NULL,
    reference_no      VARCHAR(30)    NOT NULL UNIQUE,
    description       VARCHAR(300),
    channel           VARCHAR(20)    DEFAULT 'BRANCH' CHECK (channel IN ('BRANCH','ATM','MOBILE','INTERNET','POS')),
    txn_date          DATE           DEFAULT CURRENT_DATE NOT NULL,
    performed_by      INTEGER        REFERENCES employees(employee_id),
    status            VARCHAR(15)    DEFAULT 'SUCCESS' CHECK (status IN ('SUCCESS','FAILED','REVERSED','PENDING'))
);

-- ============================================================
-- 5. LOANS
-- ============================================================

CREATE TABLE loans (
    loan_id           INTEGER        GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id       INTEGER        NOT NULL REFERENCES customers(customer_id),
    loan_type_id      INTEGER        NOT NULL REFERENCES loan_types(loan_type_id),
    branch_id         INTEGER        NOT NULL REFERENCES branches(branch_id),
    approved_by       INTEGER        REFERENCES employees(employee_id),
    principal_amount  NUMERIC(14,2)  NOT NULL CHECK (principal_amount > 0),
    interest_rate     NUMERIC(5,2)   NOT NULL CHECK (interest_rate > 0),
    tenure_months     INTEGER        NOT NULL CHECK (tenure_months > 0),
    emi_amount        NUMERIC(12,2)  NOT NULL,
    disbursement_date DATE,
    maturity_date     DATE,
    outstanding       NUMERIC(14,2),
    status            VARCHAR(15)    DEFAULT 'PENDING' CHECK (status IN ('PENDING','APPROVED','ACTIVE','CLOSED','DEFAULTED','REJECTED')),
    application_date  DATE           DEFAULT CURRENT_DATE NOT NULL
);

CREATE TABLE loan_payments (
    payment_id          INTEGER        GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    loan_id             INTEGER        NOT NULL REFERENCES loans(loan_id),
    payment_date        DATE           DEFAULT CURRENT_DATE NOT NULL,
    amount_paid         NUMERIC(12,2)  NOT NULL CHECK (amount_paid > 0),
    principal_component NUMERIC(12,2)  NOT NULL,
    interest_component  NUMERIC(12,2)  NOT NULL,
    balance_remaining   NUMERIC(14,2)  NOT NULL,
    payment_mode        VARCHAR(20)    DEFAULT 'ACCOUNT_DEBIT' CHECK (payment_mode IN ('ACCOUNT_DEBIT','CASH','CHEQUE','ONLINE')),
    status              VARCHAR(15)    DEFAULT 'SUCCESS' CHECK (status IN ('SUCCESS','FAILED','BOUNCED'))
);

CREATE TABLE collateral (
    collateral_id       INTEGER        GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    loan_id             INTEGER        NOT NULL REFERENCES loans(loan_id),
    asset_type          VARCHAR(30)    NOT NULL, -- e.g. PROPERTY, VEHICLE, GOLD
    estimated_value     NUMERIC(14,2)  NOT NULL,
    valuation_date      DATE           DEFAULT CURRENT_DATE,
    description         VARCHAR(500),
    status              VARCHAR(20)    DEFAULT 'HELD' CHECK (status IN ('HELD','RELEASED','LIQUIDATED'))
);

CREATE TABLE interest_accruals (
    accrual_id          INTEGER        GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    account_id          INTEGER        NOT NULL REFERENCES accounts(account_id),
    accrual_date        DATE           DEFAULT CURRENT_DATE NOT NULL,
    interest_amount     NUMERIC(12,2)  NOT NULL,
    rate_applied        NUMERIC(5,2)   NOT NULL,
    remarks             VARCHAR(100)
);

-- ============================================================
-- 6. AUDIT LOG
-- ============================================================

CREATE TABLE audit_log (
    log_id            INTEGER        GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    table_name        VARCHAR(50)    NOT NULL,
    operation         VARCHAR(10)    NOT NULL CHECK (operation IN ('INSERT','UPDATE','DELETE')),
    record_id         INTEGER        NOT NULL,
    changed_by        VARCHAR(80)    DEFAULT CURRENT_USER NOT NULL,
    change_timestamp  TIMESTAMPTZ    DEFAULT NOW() NOT NULL,
    old_value         TEXT,
    new_value         TEXT,
    remarks           VARCHAR(500)
);

-- ============================================================
-- 7. SEQUENCES
-- ============================================================

--  Required by the account-number auto-generation trigger in 04_plsql_module.sql
CREATE SEQUENCE IF NOT EXISTS acc_seq START 1;

-- ============================================================
-- 8. INDEXES
-- ============================================================

CREATE INDEX idx_accounts_customer   ON accounts(customer_id);
CREATE INDEX idx_accounts_branch     ON accounts(branch_id);
CREATE INDEX idx_txn_account_date    ON transactions(account_id, txn_date DESC);
CREATE INDEX idx_txn_date            ON transactions(txn_date DESC);
CREATE INDEX idx_loans_customer      ON loans(customer_id);
CREATE INDEX idx_loans_status        ON loans(status);
CREATE INDEX idx_customers_cnic      ON customers(cnic);
CREATE INDEX idx_customers_city      ON customers(city);
CREATE INDEX idx_lp_loan             ON loan_payments(loan_id);
CREATE INDEX idx_audit_table_op      ON audit_log(table_name, operation);

-- ============================================================
-- 9. VIEWS
-- ============================================================

-- Customer portfolio
CREATE OR REPLACE VIEW vw_customer_portfolio AS
    SELECT c.customer_id,
           c.first_name || ' ' || c.last_name AS customer_name,
           c.cnic, c.credit_score, c.kyc_status,
           a.account_number, at.type_name AS account_type,
           a.balance, a.status AS account_status, a.currency,
           b.branch_name, b.city AS branch_city
    FROM   customers     c
    JOIN   accounts      a  ON a.customer_id    = c.customer_id
    JOIN   account_types at ON at.account_type_id = a.account_type_id
    JOIN   branches      b  ON b.branch_id      = a.branch_id;

-- Active loan summary
CREATE OR REPLACE VIEW vw_active_loans AS
    SELECT l.loan_id,
           c.first_name || ' ' || c.last_name AS customer_name,
           c.cnic, lt.type_name AS loan_type,
           l.principal_amount, l.outstanding, l.interest_rate,
           l.tenure_months, l.emi_amount, l.maturity_date, l.status,
           b.branch_name,
           e.first_name || ' ' || e.last_name AS approved_by
    FROM   loans      l
    JOIN   customers  c  ON c.customer_id  = l.customer_id
    JOIN   loan_types lt ON lt.loan_type_id = l.loan_type_id
    JOIN   branches   b  ON b.branch_id    = l.branch_id
    LEFT JOIN employees e ON e.employee_id = l.approved_by
    WHERE  l.status IN ('ACTIVE','APPROVED');

-- Monthly transaction summary
CREATE OR REPLACE VIEW vw_monthly_txn_summary AS
    SELECT a.account_number,
           c.first_name || ' ' || c.last_name AS customer_name,
           EXTRACT(YEAR  FROM t.txn_date)::INT AS txn_year,
           EXTRACT(MONTH FROM t.txn_date)::INT AS txn_month,
           t.txn_type,
           COUNT(*)        AS txn_count,
           SUM(t.amount)   AS total_amount,
           AVG(t.amount)   AS avg_amount
    FROM   transactions t
    JOIN   accounts     a ON a.account_id  = t.account_id
    JOIN   customers    c ON c.customer_id = a.customer_id
    GROUP  BY a.account_number, c.first_name, c.last_name,
              EXTRACT(YEAR FROM t.txn_date), EXTRACT(MONTH FROM t.txn_date), t.txn_type;

-- Branch performance
CREATE OR REPLACE VIEW vw_branch_performance AS
    SELECT b.branch_id, b.branch_name, b.city,
           COUNT(DISTINCT a.account_id)  AS total_accounts,
           SUM(a.balance)                AS total_deposits,
           COUNT(DISTINCT l.loan_id)     AS total_loans,
           SUM(l.principal_amount)       AS total_loan_amount,
           COUNT(DISTINCT e.employee_id) AS staff_count
    FROM   branches  b
    LEFT JOIN accounts   a ON a.branch_id = b.branch_id AND a.status = 'ACTIVE'
    LEFT JOIN loans      l ON l.branch_id = b.branch_id AND l.status IN ('ACTIVE','APPROVED')
    LEFT JOIN employees  e ON e.branch_id = b.branch_id AND e.is_active = 'Y'
    GROUP  BY b.branch_id, b.branch_name, b.city;

-- ============================================================
-- 10. DCL — ROLES & PERMISSIONS (PostgreSQL style)
--    Run these as superuser / owner of the database.
-- ============================================================

-- Create roles (idempotent pattern)
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'cbs_app')    THEN CREATE ROLE cbs_app    LOGIN PASSWORD 'App@2024#'; END IF;
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'cbs_report') THEN CREATE ROLE cbs_report LOGIN PASSWORD 'Rep@2024#'; END IF;
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'cbs_teller') THEN CREATE ROLE cbs_teller LOGIN PASSWORD 'Tel@2024#'; END IF;
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'cbs_audit')  THEN CREATE ROLE cbs_audit  LOGIN PASSWORD 'Aud@2024#'; END IF;
END $$;

-- Application user
GRANT SELECT, INSERT, UPDATE ON customers     TO cbs_app;
GRANT SELECT, INSERT, UPDATE ON accounts      TO cbs_app;
GRANT SELECT, INSERT         ON transactions  TO cbs_app;
GRANT SELECT, INSERT, UPDATE ON loans         TO cbs_app;
GRANT SELECT, INSERT         ON loan_payments TO cbs_app;
GRANT SELECT, INSERT         ON audit_log     TO cbs_app;
GRANT SELECT                 ON account_types TO cbs_app;
GRANT SELECT                 ON loan_types    TO cbs_app;
GRANT SELECT                 ON branches      TO cbs_app;
-- Grant usage on all identity sequences so cbs_app can INSERT
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO cbs_app;

-- Teller
GRANT SELECT, INSERT ON transactions TO cbs_teller;
GRANT SELECT, UPDATE ON accounts     TO cbs_teller;
GRANT SELECT         ON customers    TO cbs_teller;

-- Report user
GRANT SELECT ON vw_customer_portfolio  TO cbs_report;
GRANT SELECT ON vw_active_loans        TO cbs_report;
GRANT SELECT ON vw_monthly_txn_summary TO cbs_report;
GRANT SELECT ON vw_branch_performance  TO cbs_report;

-- Audit user
GRANT SELECT ON audit_log    TO cbs_audit;
GRANT SELECT ON transactions TO cbs_audit;

-- Revoke from PUBLIC (PostgreSQL grants CONNECT to PUBLIC by default; tighten here)
REVOKE ALL ON customers    FROM PUBLIC;
REVOKE ALL ON accounts     FROM PUBLIC;
REVOKE ALL ON transactions FROM PUBLIC;
REVOKE ALL ON loans        FROM PUBLIC;