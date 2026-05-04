-- ============================================================
--  CORE BANKING SYSTEM (CBS) — PHASE IV: PL/pgSQL MODULE
--  Includes Composite Types, Functions, Procedures, and Triggers
-- ============================================================

-- ────────────────────────────────────────────────────────────
-- SECTION 1: COMPOSITE TYPES
--  Oracle Object Types become PostgreSQL composite types.
--  Member functions become standalone functions instead.
-- ────────────────────────────────────────────────────────────

-- 1A. Transaction Receipt composite type
DROP TYPE IF EXISTS txn_receipt_t CASCADE;
CREATE TYPE txn_receipt_t AS (
    reference_no    VARCHAR(30),
    account_number  VARCHAR(20),
    txn_type        VARCHAR(20),
    amount          NUMERIC(14,2),
    balance_after   NUMERIC(14,2),
    txn_timestamp   TIMESTAMP,
    status          VARCHAR(15)
);

-- Equivalent of the Oracle MEMBER FUNCTION to_string()
CREATE OR REPLACE FUNCTION txn_receipt_to_string(r txn_receipt_t)
RETURNS TEXT
LANGUAGE plpgsql AS $$
BEGIN
    RETURN 'Receipt[' || r.reference_no || '] ' ||
           r.txn_type || ' PKR ' || TO_CHAR(r.amount, 'FM9,999,999.00') ||
           ' | Bal: PKR ' || TO_CHAR(r.balance_after, 'FM9,999,999.00') ||
           ' | ' || TO_CHAR(r.txn_timestamp, 'DD-Mon-YYYY HH24:MI:SS');
END;
$$;

-- 1B. EMI Schedule row composite type
DROP TYPE IF EXISTS emi_row_t CASCADE;
CREATE TYPE emi_row_t AS (
    installment_no       INT,
    due_date             DATE,
    emi_amount           NUMERIC(12,2),
    principal_component  NUMERIC(12,2),
    interest_component   NUMERIC(12,2),
    balance_remaining    NUMERIC(14,2)
);
-- emi_schedule_t (a TABLE OF emi_row_t) is expressed via RETURNS TABLE or SETOF emi_row_t


-- ────────────────────────────────────────────────────────────
-- SECTION 2: FUNCTIONS & PROCEDURES
--  Oracle Packages have no direct equivalent in PostgreSQL.
--  We use a dedicated schema per package to group related routines.
-- ────────────────────────────────────────────────────────────

-- Create schemas to mirror Oracle package namespaces
CREATE SCHEMA IF NOT EXISTS pkg_account_ops;
CREATE SCHEMA IF NOT EXISTS pkg_loan_mgmt;
CREATE SCHEMA IF NOT EXISTS pkg_reports;


-- ══════════════════════════════════════════════════════════════
-- SCHEMA pkg_account_ops — Core account operations
-- ══════════════════════════════════════════════════════════════

-- ── next_reference ────────────────────────────────────────────
CREATE OR REPLACE FUNCTION pkg_account_ops.next_reference()
RETURNS TEXT
LANGUAGE plpgsql AS $$
BEGIN
    -- Oracle: 'REF' || TO_CHAR(SYSTIMESTAMP,'YYYYMMDDHH24MISSFF3')
    RETURN 'REF' || TO_CHAR(CURRENT_TIMESTAMP, 'YYYYMMDDHH24MISSMS');
END;
$$;

-- ── get_balance ───────────────────────────────────────────────
CREATE OR REPLACE FUNCTION pkg_account_ops.get_balance(p_account_id INT)
RETURNS NUMERIC
LANGUAGE plpgsql AS $$
DECLARE
    v_bal NUMERIC;
BEGIN
    SELECT balance INTO v_bal FROM accounts WHERE account_id = p_account_id;
    RETURN v_bal;
END;
$$;

-- ── Private helper: validate_account ─────────────────────────
--  Returns a record of accounts for the given id (row-locked).
--  Raises an exception if the account is FROZEN/CLOSED or not found.
CREATE OR REPLACE FUNCTION pkg_account_ops.validate_account(p_account_id INT)
RETURNS accounts   -- returns the full accounts row
LANGUAGE plpgsql AS $$
DECLARE
    v_acc accounts%ROWTYPE;
BEGIN
    SELECT * INTO v_acc FROM accounts WHERE account_id = p_account_id FOR UPDATE;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Account ID % not found.', p_account_id
            USING ERRCODE = 'P0010';
    END IF;
    IF v_acc.status IN ('FROZEN', 'CLOSED') THEN
        RAISE EXCEPTION 'Account % is %.', v_acc.account_number, v_acc.status
            USING ERRCODE = 'P0002';
    END IF;
    RETURN v_acc;
END;
$$;

-- ── deposit ───────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION pkg_account_ops.deposit(
    p_account_id  INT,
    p_amount      NUMERIC,
    p_description TEXT    DEFAULT NULL,
    p_channel     TEXT    DEFAULT 'BRANCH',
    p_emp_id      INT     DEFAULT NULL
)
RETURNS txn_receipt_t
LANGUAGE plpgsql AS $$
DECLARE
    v_acc     accounts%ROWTYPE;
    v_ref     TEXT;
    v_new_bal NUMERIC(14,2);
    v_receipt txn_receipt_t;
BEGIN
    IF p_amount <= 0 THEN
        RAISE EXCEPTION 'Deposit amount must be positive.'
            USING ERRCODE = 'P0003';
    END IF;

    v_acc     := pkg_account_ops.validate_account(p_account_id);
    v_ref     := pkg_account_ops.next_reference();
    v_new_bal := v_acc.balance + p_amount;

    UPDATE accounts
    SET    balance = v_new_bal, last_txn_date = CURRENT_DATE
    WHERE  account_id = p_account_id;

    INSERT INTO transactions
        (account_id, txn_type, amount, balance_after, reference_no,
         description, channel, txn_date, performed_by, status)
    VALUES
        (p_account_id, 'DEPOSIT', p_amount, v_new_bal, v_ref,
         COALESCE(p_description, 'Cash Deposit'), p_channel,
         CURRENT_DATE, p_emp_id, 'SUCCESS');

    v_receipt := ROW(v_ref, v_acc.account_number, 'DEPOSIT',
                     p_amount, v_new_bal, CURRENT_TIMESTAMP, 'SUCCESS')::txn_receipt_t;
    RETURN v_receipt;
END;
$$;

-- ── withdraw ──────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION pkg_account_ops.withdraw(
    p_account_id  INT,
    p_amount      NUMERIC,
    p_description TEXT  DEFAULT NULL,
    p_channel     TEXT  DEFAULT 'ATM'
)
RETURNS txn_receipt_t
LANGUAGE plpgsql AS $$
DECLARE
    v_acc     accounts%ROWTYPE;
    v_ref     TEXT;
    v_new_bal NUMERIC(14,2);
    v_receipt txn_receipt_t;
BEGIN
    IF p_amount <= 0 THEN
        RAISE EXCEPTION 'Withdrawal amount must be positive.'
            USING ERRCODE = 'P0003';
    END IF;

    v_acc := pkg_account_ops.validate_account(p_account_id);

    IF v_acc.balance < p_amount THEN
        RAISE EXCEPTION 'Insufficient funds. Balance: %, Requested: %',
                        v_acc.balance, p_amount
            USING ERRCODE = 'P0001';
    END IF;

    v_ref     := pkg_account_ops.next_reference();
    v_new_bal := v_acc.balance - p_amount;

    UPDATE accounts
    SET    balance = v_new_bal, last_txn_date = CURRENT_DATE
    WHERE  account_id = p_account_id;

    INSERT INTO transactions
        (account_id, txn_type, amount, balance_after, reference_no,
         description, channel, txn_date, status)
    VALUES
        (p_account_id, 'WITHDRAWAL', p_amount, v_new_bal, v_ref,
         COALESCE(p_description, 'Cash Withdrawal'), p_channel,
         CURRENT_DATE, 'SUCCESS');

    v_receipt := ROW(v_ref, v_acc.account_number, 'WITHDRAWAL',
                     p_amount, v_new_bal, CURRENT_TIMESTAMP, 'SUCCESS')::txn_receipt_t;
    RETURN v_receipt;
END;
$$;

-- ── transfer ──────────────────────────────────────────────────
--  Oracle PROCEDURE with OUT → PostgreSQL PROCEDURE (or FUNCTION returning void/composite)
CREATE OR REPLACE PROCEDURE pkg_account_ops.transfer(
    p_from_account_id INT,
    p_to_account_id   INT,
    p_amount          NUMERIC,
    p_description     TEXT DEFAULT NULL
)
LANGUAGE plpgsql AS $$
DECLARE
    v_from accounts%ROWTYPE;
    v_to   accounts%ROWTYPE;
    v_ref  TEXT;
BEGIN
    IF p_amount <= 0 THEN
        RAISE EXCEPTION 'Transfer amount must be positive.'
            USING ERRCODE = 'P0003';
    END IF;

    v_from := pkg_account_ops.validate_account(p_from_account_id);
    v_to   := pkg_account_ops.validate_account(p_to_account_id);

    IF v_from.balance < p_amount THEN
        RAISE EXCEPTION 'Insufficient funds for transfer.'
            USING ERRCODE = 'P0001';
    END IF;

    v_ref := pkg_account_ops.next_reference();

    UPDATE accounts SET balance = balance - p_amount, last_txn_date = CURRENT_DATE
    WHERE  account_id = p_from_account_id;

    UPDATE accounts SET balance = balance + p_amount, last_txn_date = CURRENT_DATE
    WHERE  account_id = p_to_account_id;

    INSERT INTO transactions
        (account_id, txn_type, amount, balance_after, reference_no, description, channel, status)
    VALUES
        (p_from_account_id, 'TRANSFER_OUT', p_amount,
         v_from.balance - p_amount, v_ref,
         COALESCE(p_description, 'Transfer to ' || v_to.account_number),
         'INTERNET', 'SUCCESS');

    INSERT INTO transactions
        (account_id, txn_type, amount, balance_after, reference_no, description, channel, status)
    VALUES
        (p_to_account_id, 'TRANSFER_IN', p_amount,
         v_to.balance + p_amount, v_ref,
         COALESCE(p_description, 'Transfer from ' || v_from.account_number),
         'INTERNET', 'SUCCESS');
END;
$$;


-- ══════════════════════════════════════════════════════════════
-- SCHEMA pkg_loan_mgmt — Loan lifecycle & EMI calculations
-- ══════════════════════════════════════════════════════════════

-- ── calc_emi ──────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION pkg_loan_mgmt.calc_emi(
    p_principal   NUMERIC,
    p_annual_rate NUMERIC,
    p_months      INT
)
RETURNS NUMERIC
LANGUAGE plpgsql AS $$
DECLARE
    v_r NUMERIC;
BEGIN
    v_r := p_annual_rate / 12.0 / 100.0;
    RETURN ROUND(
        (p_principal * v_r * POWER(1 + v_r, p_months)
         / (POWER(1 + v_r, p_months) - 1))::NUMERIC,
        2
    );
END;
$$;

-- ── generate_schedule ─────────────────────────────────────────
--  Oracle: PIPELINED FUNCTION returning TABLE type
--  PostgreSQL: RETURNS TABLE with RETURN NEXT
CREATE OR REPLACE FUNCTION pkg_loan_mgmt.generate_schedule(
    p_principal   NUMERIC,
    p_annual_rate NUMERIC,
    p_months      INT,
    p_start_date  DATE DEFAULT CURRENT_DATE
)
RETURNS TABLE (
    installment_no      INT,
    due_date            DATE,
    emi_amount          NUMERIC(12,2),
    principal_component NUMERIC(12,2),
    interest_component  NUMERIC(12,2),
    balance_remaining   NUMERIC(14,2)
)
LANGUAGE plpgsql AS $$
DECLARE
    v_emi       NUMERIC := pkg_loan_mgmt.calc_emi(p_principal, p_annual_rate, p_months);
    v_balance   NUMERIC := p_principal;
    v_r         NUMERIC := p_annual_rate / 12.0 / 100.0;
    v_interest  NUMERIC;
    v_principal NUMERIC;
    v_due       DATE    := p_start_date + INTERVAL '1 month';
    i           INT;
BEGIN
    FOR i IN 1 .. p_months LOOP
        v_interest  := ROUND((v_balance * v_r)::NUMERIC, 2);
        v_principal := v_emi - v_interest;

        IF i = p_months THEN          -- last-instalment rounding fix
            v_principal := v_balance;
            v_emi       := v_balance + v_interest;
        END IF;

        v_balance := v_balance - v_principal;

        installment_no      := i;
        due_date            := v_due;
        emi_amount          := ROUND(v_emi::NUMERIC, 2);
        principal_component := ROUND(v_principal::NUMERIC, 2);
        interest_component  := ROUND(v_interest::NUMERIC, 2);
        balance_remaining   := ROUND(GREATEST(v_balance, 0)::NUMERIC, 2);

        RETURN NEXT;
        -- Oracle ADD_MONTHS(d,1) → d + INTERVAL '1 month'
        v_due := v_due + INTERVAL '1 month';
    END LOOP;
END;
$$;

-- ── approve_loan ──────────────────────────────────────────────
CREATE OR REPLACE PROCEDURE pkg_loan_mgmt.approve_loan(
    p_loan_id    INT,
    p_officer_id INT,
    p_rate       NUMERIC DEFAULT NULL
)
LANGUAGE plpgsql AS $$
DECLARE
    v_loan  loans%ROWTYPE;
    v_ltype loan_types%ROWTYPE;
    v_rate  NUMERIC;
BEGIN
    SELECT * INTO v_loan  FROM loans      WHERE loan_id      = p_loan_id      FOR UPDATE;
    SELECT * INTO v_ltype FROM loan_types WHERE loan_type_id = v_loan.loan_type_id;

    IF v_loan.status <> 'PENDING' THEN
        RAISE EXCEPTION 'Loan % is not in PENDING status.', p_loan_id
            USING ERRCODE = 'P0020';
    END IF;

    v_rate := COALESCE(p_rate, v_ltype.base_rate);

    UPDATE loans SET
        status            = 'APPROVED',
        approved_by       = p_officer_id,
        interest_rate     = v_rate,
        emi_amount        = pkg_loan_mgmt.calc_emi(v_loan.principal_amount, v_rate, v_loan.tenure_months),
        disbursement_date = CURRENT_DATE,
        -- Oracle ADD_MONTHS → interval arithmetic
        maturity_date     = CURRENT_DATE + (v_loan.tenure_months || ' months')::INTERVAL,
        outstanding       = v_loan.principal_amount
    WHERE loan_id = p_loan_id;

    RAISE NOTICE 'Loan % approved at %%% by officer %', p_loan_id, v_rate, p_officer_id;
END;
$$;

-- ── record_payment ────────────────────────────────────────────
CREATE OR REPLACE PROCEDURE pkg_loan_mgmt.record_payment(
    p_loan_id INT,
    p_amount  NUMERIC,
    p_mode    TEXT DEFAULT 'ACCOUNT_DEBIT'
)
LANGUAGE plpgsql AS $$
DECLARE
    v_loan      loans%ROWTYPE;
    v_monthly_r NUMERIC;
    v_interest  NUMERIC;
    v_principal NUMERIC;
BEGIN
    SELECT * INTO v_loan FROM loans WHERE loan_id = p_loan_id FOR UPDATE;

    IF v_loan.status NOT IN ('ACTIVE', 'APPROVED') THEN
        RAISE EXCEPTION 'Loan % is not active.', p_loan_id
            USING ERRCODE = 'P0021';
    END IF;

    v_monthly_r := v_loan.interest_rate / 12.0 / 100.0;
    v_interest  := ROUND((v_loan.outstanding * v_monthly_r)::NUMERIC, 2);
    v_principal := LEAST(p_amount - v_interest, v_loan.outstanding);

    INSERT INTO loan_payments
        (loan_id, payment_date, amount_paid, principal_component,
         interest_component, balance_remaining, payment_mode, status)
    VALUES
        (p_loan_id, CURRENT_DATE, p_amount, v_principal, v_interest,
         GREATEST(v_loan.outstanding - v_principal, 0), p_mode, 'SUCCESS');

    UPDATE loans SET
        outstanding = GREATEST(outstanding - v_principal, 0),
        status      = CASE WHEN outstanding - v_principal <= 0 THEN 'CLOSED' ELSE status END
    WHERE loan_id = p_loan_id;
END;
$$;


-- ══════════════════════════════════════════════════════════════
-- SCHEMA pkg_reports — Branch/customer analytics
--  Oracle used DBMS_OUTPUT.PUT_LINE for printing.
--  In PostgreSQL we use RAISE NOTICE (visible in psql with \set VERBOSITY verbose
--  or captured server-side). For real apps, return result sets instead.
-- ══════════════════════════════════════════════════════════════

-- ── rpt_overdue_loans ─────────────────────────────────────────
CREATE OR REPLACE PROCEDURE pkg_reports.rpt_overdue_loans()
LANGUAGE plpgsql AS $$
DECLARE
    v_count INT := 0;
    r RECORD;
BEGIN
    RAISE NOTICE '=== OVERDUE LOAN REPORT (%) ===', TO_CHAR(CURRENT_DATE, 'DD-Mon-YYYY');

    FOR r IN
        SELECT l.loan_id,
               c.first_name || ' ' || c.last_name  AS borrower,
               c.phone,
               lt.type_name                        AS loan_type,
               l.emi_amount,
               l.outstanding,
               l.maturity_date
        FROM   loans l
        JOIN   customers  c  ON c.customer_id  = l.customer_id
        JOIN   loan_types lt ON lt.loan_type_id = l.loan_type_id
        WHERE  l.status = 'ACTIVE'
        AND    l.maturity_date < CURRENT_DATE
        ORDER  BY l.outstanding DESC
    LOOP
        v_count := v_count + 1;
        RAISE NOTICE '% | % | % | %',
            r.loan_id, r.borrower, r.loan_type, r.outstanding;
    END LOOP;

    RAISE NOTICE 'Total records: %', v_count;
END;
$$;

-- ── rpt_account_statement ─────────────────────────────────────
CREATE OR REPLACE PROCEDURE pkg_reports.rpt_account_statement(
    p_account_id INT,
    p_from_date  DATE DEFAULT (CURRENT_DATE - INTERVAL '1 month')::DATE,
    p_to_date    DATE DEFAULT CURRENT_DATE
)
LANGUAGE plpgsql AS $$
DECLARE
    v_acc       accounts%ROWTYPE;
    v_cust      customers%ROWTYPE;
    v_total_cr  NUMERIC := 0;
    v_total_dr  NUMERIC := 0;
    r           RECORD;
BEGIN
    SELECT * INTO v_acc  FROM accounts  WHERE account_id = p_account_id;
    SELECT * INTO v_cust FROM customers WHERE customer_id = v_acc.customer_id;

    RAISE NOTICE '=== ACCOUNT STATEMENT ===';
    RAISE NOTICE 'Account : %', v_acc.account_number;
    RAISE NOTICE 'Customer: % %', v_cust.first_name, v_cust.last_name;
    RAISE NOTICE 'Period  : % to %',
        TO_CHAR(p_from_date,'DD-Mon-YYYY'), TO_CHAR(p_to_date,'DD-Mon-YYYY');

    FOR r IN
        SELECT txn_date, reference_no, txn_type, description, amount, balance_after, channel
        FROM   transactions
        WHERE  account_id = p_account_id
        AND    txn_date BETWEEN p_from_date AND p_to_date
        ORDER  BY txn_date
    LOOP
        IF r.txn_type IN ('DEPOSIT','TRANSFER_IN','INTEREST') THEN
            v_total_cr := v_total_cr + r.amount;
        ELSE
            v_total_dr := v_total_dr + r.amount;
        END IF;
        RAISE NOTICE '% | % | % | % | % | %',
            TO_CHAR(r.txn_date,'DD/MM/YY'), r.reference_no, r.txn_type,
            r.amount, r.balance_after, r.channel;
    END LOOP;

    RAISE NOTICE 'Total Credits: PKR %', TO_CHAR(v_total_cr,'FM9,999,999.00');
    RAISE NOTICE 'Total Debits : PKR %', TO_CHAR(v_total_dr,'FM9,999,999.00');
    RAISE NOTICE 'Closing Bal  : PKR %', TO_CHAR(v_acc.balance,'FM9,999,999.00');
END;
$$;

-- ── rpt_branch_summary ────────────────────────────────────────
CREATE OR REPLACE PROCEDURE pkg_reports.rpt_branch_summary()
LANGUAGE plpgsql AS $$
DECLARE
    r RECORD;
BEGIN
    RAISE NOTICE '=== BRANCH PERFORMANCE SUMMARY ===';
    FOR r IN
        SELECT branch_name, city, total_accounts, total_deposits,
               total_loans, total_loan_amount, staff_count
        FROM   vw_branch_performance
        ORDER  BY total_deposits DESC NULLS LAST
    LOOP
        RAISE NOTICE '% | % | % accounts | %M deposits | % loans | % staff',
            r.branch_name, r.city, COALESCE(r.total_accounts,0),
            TO_CHAR(COALESCE(r.total_deposits,0)/1000000.0,'FM999.99'),
            COALESCE(r.total_loans,0), COALESCE(r.staff_count,0);
    END LOOP;
END;
$$;

-- ── rpt_high_value_customers ──────────────────────────────────
CREATE OR REPLACE PROCEDURE pkg_reports.rpt_high_value_customers(
    p_threshold NUMERIC DEFAULT 500000
)
LANGUAGE plpgsql AS $$
DECLARE
    v_count INT := 0;
    r       RECORD;
BEGIN
    RAISE NOTICE '=== HIGH VALUE CUSTOMERS (Balance >= PKR %) ===',
        TO_CHAR(p_threshold,'FM9,999,999');

    FOR r IN
        SELECT customer_name, cnic, credit_score, account_type, balance, branch_name
        FROM   vw_customer_portfolio
        WHERE  balance >= p_threshold
        ORDER  BY balance DESC
    LOOP
        v_count := v_count + 1;
        RAISE NOTICE '%. % | % | PKR % | Score: %',
            v_count, r.customer_name, r.account_type,
            TO_CHAR(r.balance,'FM9,999,999'), r.credit_score;
    END LOOP;

    RAISE NOTICE 'Total: % customer(s).', v_count;
END;
$$;


-- ────────────────────────────────────────────────────────────
-- SECTION 3: TRIGGERS
--  Oracle: CREATE OR REPLACE TRIGGER ... :NEW / :OLD
--  PostgreSQL: Triggers need a TRIGGER FUNCTION returning TRIGGER,
--              then CREATE TRIGGER separately. Use NEW/OLD (no colon).
-- ────────────────────────────────────────────────────────────

-- T1. BEFORE INSERT on transactions — Validate amount & auto-set reference/date
CREATE OR REPLACE FUNCTION trg_fn_txn_before_insert()
RETURNS TRIGGER
LANGUAGE plpgsql AS $$
BEGIN
    IF NEW.reference_no IS NULL THEN
        NEW.reference_no := 'REF' || TO_CHAR(CURRENT_TIMESTAMP, 'YYYYMMDDHH24MISSMS');
    END IF;

    IF NEW.amount <= 0 THEN
        RAISE EXCEPTION 'Transaction amount must be > 0. Got: %', NEW.amount
            USING ERRCODE = 'P0030';
    END IF;

    IF NEW.txn_date IS NULL THEN
        NEW.txn_date := CURRENT_DATE;
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_txn_before_insert ON transactions;
CREATE TRIGGER trg_txn_before_insert
BEFORE INSERT ON transactions
FOR EACH ROW EXECUTE FUNCTION trg_fn_txn_before_insert();


-- T2. AFTER INSERT on transactions — Sync account balance and last_txn_date
CREATE OR REPLACE FUNCTION trg_fn_txn_after_insert()
RETURNS TRIGGER
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE accounts
    SET    balance       = NEW.balance_after,
           last_txn_date = NEW.txn_date
    WHERE  account_id   = NEW.account_id;
    RETURN NULL;   -- AFTER triggers on row-level should return NULL
END;
$$;

DROP TRIGGER IF EXISTS trg_txn_after_insert ON transactions;
CREATE TRIGGER trg_txn_after_insert
AFTER INSERT ON transactions
FOR EACH ROW EXECUTE FUNCTION trg_fn_txn_after_insert();


-- T3. AFTER UPDATE on accounts — Write to audit_log
CREATE OR REPLACE FUNCTION trg_fn_accounts_audit()
RETURNS TRIGGER
LANGUAGE plpgsql AS $$
BEGIN
    IF OLD.balance <> NEW.balance OR OLD.status <> NEW.status THEN
        INSERT INTO audit_log
            (table_name, operation, record_id, changed_by,
             change_timestamp, old_value, new_value, remarks)
        VALUES
            ('ACCOUNTS', 'UPDATE', OLD.account_id, CURRENT_USER,
             CURRENT_TIMESTAMP,
             'Balance=' || OLD.balance || '; Status=' || OLD.status,
             'Balance=' || NEW.balance || '; Status=' || NEW.status,
             'Balance delta: ' || (NEW.balance - OLD.balance));
    END IF;
    RETURN NULL;
END;
$$;

DROP TRIGGER IF EXISTS trg_accounts_audit ON accounts;
CREATE TRIGGER trg_accounts_audit
AFTER UPDATE ON accounts
FOR EACH ROW EXECUTE FUNCTION trg_fn_accounts_audit();


-- T4. BEFORE DELETE on customers — Prevent deletion if active accounts exist
CREATE OR REPLACE FUNCTION trg_fn_customers_no_delete()
RETURNS TRIGGER
LANGUAGE plpgsql AS $$
DECLARE
    v_count INT;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM   accounts
    WHERE  customer_id = OLD.customer_id
    AND    status      = 'ACTIVE';

    IF v_count > 0 THEN
        RAISE EXCEPTION 'Cannot delete customer % % — % active account(s) exist.',
                        OLD.first_name, OLD.last_name, v_count
            USING ERRCODE = 'P0040';
    END IF;

    RETURN OLD;
END;
$$;

DROP TRIGGER IF EXISTS trg_customers_no_delete ON customers;
CREATE TRIGGER trg_customers_no_delete
BEFORE DELETE ON customers
FOR EACH ROW EXECUTE FUNCTION trg_fn_customers_no_delete();


-- T5. AFTER INSERT on loans — Log new loan application to audit
CREATE OR REPLACE FUNCTION trg_fn_loans_audit_insert()
RETURNS TRIGGER
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO audit_log
        (table_name, operation, record_id, changed_by,
         change_timestamp, new_value, remarks)
    VALUES
        ('LOANS', 'INSERT', NEW.loan_id, CURRENT_USER,
         CURRENT_TIMESTAMP,
         'Amount=' || NEW.principal_amount ||
         '; Type=' || NEW.loan_type_id ||
         '; Status=' || NEW.status,
         'New loan application submitted');
    RETURN NULL;
END;
$$;

DROP TRIGGER IF EXISTS trg_loans_audit_insert ON loans;
CREATE TRIGGER trg_loans_audit_insert
AFTER INSERT ON loans
FOR EACH ROW EXECUTE FUNCTION trg_fn_loans_audit_insert();


-- T6. AFTER UPDATE OF status on loans — Alert on status change + audit
CREATE OR REPLACE FUNCTION trg_fn_loans_status_change()
RETURNS TRIGGER
LANGUAGE plpgsql AS $$
BEGIN
    IF OLD.status <> NEW.status THEN
        INSERT INTO audit_log
            (table_name, operation, record_id, changed_by,
             change_timestamp, old_value, new_value, remarks)
        VALUES
            ('LOANS', 'UPDATE', OLD.loan_id, CURRENT_USER,
             CURRENT_TIMESTAMP,
             'Status=' || OLD.status,
             'Status=' || NEW.status,
             'Loan status changed from ' || OLD.status || ' to ' || NEW.status);

        IF NEW.status = 'CLOSED' THEN
            RAISE NOTICE 'LOAN CLOSED: ID=% | Customer=%', OLD.loan_id, OLD.customer_id;
        END IF;
    END IF;
    RETURN NULL;
END;
$$;

DROP TRIGGER IF EXISTS trg_loans_status_change ON loans;
CREATE TRIGGER trg_loans_status_change
AFTER UPDATE OF status ON loans
FOR EACH ROW EXECUTE FUNCTION trg_fn_loans_status_change();


-- T7. BEFORE INSERT on customers — Enforce minimum age (18+)
CREATE OR REPLACE FUNCTION trg_fn_customers_age_check()
RETURNS TRIGGER
LANGUAGE plpgsql AS $$
DECLARE
    -- Oracle MONTHS_BETWEEN(SYSDATE, dob)/12 → AGE() in PostgreSQL
    v_age NUMERIC;
BEGIN
    v_age := EXTRACT(YEAR FROM AGE(CURRENT_DATE, NEW.date_of_birth))
           + EXTRACT(MONTH FROM AGE(CURRENT_DATE, NEW.date_of_birth)) / 12.0;

    IF v_age < 18 THEN
        RAISE EXCEPTION 'Customer must be at least 18 years old. Calculated age: % years.',
                        FLOOR(v_age)
            USING ERRCODE = 'P0050';
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_customers_age_check ON customers;
CREATE TRIGGER trg_customers_age_check
BEFORE INSERT ON customers
FOR EACH ROW EXECUTE FUNCTION trg_fn_customers_age_check();


-- T8. BEFORE INSERT on accounts — Auto-generate account number if NULL
--  Oracle: :NEW.account_number := 'PK36CBS0' || branch_code || LPAD(acc_seq.NEXTVAL,6,'0')
--  PostgreSQL: acc_seq must be created with CREATE SEQUENCE acc_seq; beforehand
CREATE OR REPLACE FUNCTION trg_fn_accounts_acc_number()
RETURNS TRIGGER
LANGUAGE plpgsql AS $$
DECLARE
    v_branch_code TEXT;
BEGIN
    IF NEW.account_number IS NULL THEN
        SELECT branch_code INTO v_branch_code
        FROM   branches WHERE branch_id = NEW.branch_id;

        NEW.account_number := 'PK36CBS0' || v_branch_code ||
                              LPAD(NEXTVAL('acc_seq')::TEXT, 6, '0');
    END IF;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_accounts_acc_number ON accounts;
CREATE TRIGGER trg_accounts_acc_number
BEFORE INSERT ON accounts
FOR EACH ROW EXECUTE FUNCTION trg_fn_accounts_acc_number();


-- ────────────────────────────────────────────────────────────
-- SECTION 4: CURSOR DEMOS (as standalone DO blocks)
--  Oracle anonymous blocks with DECLARE...BEGIN...END are
--  written as DO $$ ... $$ in PostgreSQL.
-- ────────────────────────────────────────────────────────────

-- Demo 1: FOR loop — identify and mark dormant accounts
DO $$
DECLARE
    v_dormancy_days CONSTANT INT := 90;
    v_count INT := 0;
    r RECORD;
BEGIN
    RAISE NOTICE '=== DORMANT ACCOUNT CHECK ===';

    FOR r IN
        SELECT a.account_number, a.balance, a.last_txn_date,
               c.first_name || ' ' || c.last_name AS customer
        FROM   accounts  a
        JOIN   customers c ON c.customer_id = a.customer_id
        WHERE  a.status = 'ACTIVE'
        AND    (a.last_txn_date IS NULL
                OR a.last_txn_date < CURRENT_DATE - (v_dormancy_days || ' days')::INTERVAL)
        ORDER  BY a.last_txn_date NULLS FIRST
    LOOP
        v_count := v_count + 1;
        RAISE NOTICE '%. % | % | Last txn: % | Bal: %',
            v_count, r.account_number, r.customer,
            COALESCE(TO_CHAR(r.last_txn_date,'DD-Mon-YYYY'),'NEVER'),
            r.balance;

        UPDATE accounts SET status = 'DORMANT'
        WHERE  account_number = r.account_number;
    END LOOP;

    RAISE NOTICE 'Dormant accounts found: %', v_count;
END;
$$;


-- Demo 2: Explicit cursor — Monthly interest posting
--  Oracle: CURSOR ... FOR UPDATE OF col; WHERE CURRENT OF cursor
--  PostgreSQL: No CURRENT OF with named cursors (use PK-based UPDATE instead)
DO $$
DECLARE
    c_savings CURSOR FOR
        SELECT a.account_id, a.balance, at.interest_rate
        FROM   accounts      a
        JOIN   account_types at ON at.account_type_id = a.account_type_id
        WHERE  a.status       = 'ACTIVE'
        AND    at.interest_rate > 0;

    v_row   RECORD;
    v_intr  NUMERIC(12,2);
    v_ref   TEXT;
    v_total NUMERIC := 0;
BEGIN
    RAISE NOTICE '=== MONTHLY INTEREST POSTING — % ===',
        TO_CHAR(CURRENT_DATE,'Mon YYYY');

    OPEN c_savings;
    LOOP
        FETCH c_savings INTO v_row;
        EXIT WHEN NOT FOUND;

        v_intr := ROUND((v_row.balance * (v_row.interest_rate / 12.0 / 100.0))::NUMERIC, 2);
        v_ref  := 'INT' || TO_CHAR(CURRENT_DATE,'YYYYMM') ||
                  LPAD(v_row.account_id::TEXT, 6, '0');

        -- Oracle WHERE CURRENT OF → explicit PK-based update
        UPDATE accounts
        SET    balance       = balance + v_intr,
               last_txn_date = CURRENT_DATE
        WHERE  account_id   = v_row.account_id;

        INSERT INTO transactions
            (account_id, txn_type, amount, balance_after, reference_no,
             description, channel, status)
        VALUES
            (v_row.account_id, 'INTEREST', v_intr,
             v_row.balance + v_intr, v_ref,
             'Monthly profit credit ' || TO_CHAR(CURRENT_DATE,'Mon YYYY'),
             'BRANCH', 'SUCCESS');

        v_total := v_total + v_intr;
        RAISE NOTICE 'Account % | Interest: PKR %', v_row.account_id, v_intr;
    END LOOP;
    CLOSE c_savings;

    RAISE NOTICE 'Total interest posted: PKR %', TO_CHAR(v_total,'FM9,999,999.00');
END;
$$;


-- ────────────────────────────────────────────────────────────
-- SECTION 5: USAGE EXAMPLES
-- ────────────────────────────────────────────────────────────

-- Example: Deposit into account 1
DO $$
DECLARE
    v_r txn_receipt_t;
BEGIN
    v_r := pkg_account_ops.deposit(1, 25000, 'Test deposit', 'MOBILE', NULL);
    RAISE NOTICE '%', txn_receipt_to_string(v_r);
END;
$$;

-- Example: Run branch summary report
CALL pkg_reports.rpt_branch_summary();

-- Example: Generate EMI schedule for PKR 1,000,000 at 15% for 24 months
SELECT installment_no,
       TO_CHAR(due_date,'DD-Mon-YYYY') AS due_date,
       emi_amount, principal_component, interest_component, balance_remaining
FROM   pkg_loan_mgmt.generate_schedule(1000000, 15, 24, CURRENT_DATE);

-- Example: High-value customer report
CALL pkg_reports.rpt_high_value_customers(100000);