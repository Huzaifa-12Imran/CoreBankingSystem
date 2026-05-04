-- ============================================================
--  CORE BANKING SYSTEM (CBS) — FINAL ACADEMIC UPGRADES
--  Phase III & IV: Performance and Advanced PL/SQL
-- ============================================================

-- 1. PERFORMANCE: Indexing (Phase III)
-- Optimizing retrieval for frequently searched identity columns
CREATE INDEX IF NOT EXISTS idx_customers_cnic ON customers(cnic);
CREATE INDEX IF NOT EXISTS idx_customers_email ON customers(email);
CREATE INDEX IF NOT EXISTS idx_customers_phone ON customers(phone);

-- 2. OBJECT-ORIENTED FEATURES: Custom Types (Phase IV)
-- Demonstrating object-oriented database features
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'contact_info') THEN
        CREATE TYPE contact_info AS (
            email VARCHAR(100),
            phone VARCHAR(20)
        );
    END IF;
END $$;

-- 3. VIEWS: Complex View (Technical Constraints)
-- Simplifies data access for the front-end by joining 3 tables
CREATE OR REPLACE VIEW v_customer_financial_summary AS
SELECT 
    c.customer_id,
    c.first_name, 
    c.last_name,
    c.first_name || ' ' || c.last_name AS full_name,
    c.cnic,
    a.account_number,
    a.balance,
    a.status,
    at.type_name,
    (SELECT COUNT(*) FROM transactions t WHERE t.account_id = a.account_id) as total_txns
FROM 
    customers c
JOIN 
    accounts a ON c.customer_id = a.customer_id
JOIN 
    account_types at ON a.account_type_id = at.account_type_id;

-- 4. PL/SQL: Explicit Cursor & Calculations (Phase IV)
-- This function uses an explicit cursor to calculate total bank risk
CREATE OR REPLACE FUNCTION calculate_bank_risk_metrics() 
RETURNS TABLE(risk_level TEXT, total_exposure NUMERIC) AS $$
DECLARE
    curr_acc CURSOR FOR SELECT balance FROM accounts;
    acc_bal NUMERIC;
    high_risk_sum NUMERIC := 0;
BEGIN
    OPEN curr_acc;
    LOOP
        FETCH curr_acc INTO acc_bal;
        EXIT WHEN NOT FOUND;
        
        -- Business logic: High exposure if balance > 500,000
        IF acc_bal > 500000 THEN
            high_risk_sum := high_risk_sum + acc_bal;
        END IF;
    END LOOP;
    CLOSE curr_acc;
    
    risk_level := 'HIGH EXPOSURE';
    total_exposure := high_risk_sum;
    RETURN NEXT;
END;
$$ LANGUAGE plpgsql;

-- 5. SET OPERATIONS: UNION Example (Phase III)
-- Used for internal reporting of all entities
CREATE OR REPLACE VIEW v_all_system_entities AS
SELECT first_name || ' ' || last_name as entity_name, 'CUSTOMER' as entity_type FROM customers
UNION
SELECT account_number::text, 'ACCOUNT' as entity_type FROM accounts;
