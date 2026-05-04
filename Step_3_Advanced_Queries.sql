-- ============================================================
--  CORE BANKING SYSTEM (CBS) — PHASE III: ADVANCED QUERIES
--  Includes Joins, Set Operations, Subqueries, and Aggregates
-- ============================================================

-- ────────────────────────────────────────────────────────────
-- SECTION A: JOINS
-- ────────────────────────────────────────────────────────────

-- A1. INNER JOIN — Customer + Account + Branch details
SELECT c.first_name || ' ' || c.last_name    AS customer_name,
       c.cnic,
       a.account_number,
       at.type_name                           AS account_type,
       a.balance,
       a.status,
       b.branch_name,
       b.city
FROM   customers    c
JOIN   accounts     a  ON a.customer_id      = c.customer_id
JOIN   account_types at ON at.account_type_id = a.account_type_id
JOIN   branches     b  ON b.branch_id        = a.branch_id
WHERE  a.status = 'ACTIVE'
ORDER  BY a.balance DESC;

-- A2. LEFT OUTER JOIN — All customers, show loan info if exists
SELECT c.first_name || ' ' || c.last_name    AS customer_name,
       c.credit_score,
       l.loan_id,
       lt.type_name                           AS loan_type,
       l.principal_amount,
       l.status                               AS loan_status
FROM   customers  c
LEFT JOIN loans      l  ON l.customer_id   = c.customer_id
LEFT JOIN loan_types lt ON lt.loan_type_id = l.loan_type_id
ORDER  BY c.customer_id;

-- A3. RIGHT OUTER JOIN — All branches even if no employees yet
SELECT b.branch_name, b.city,
       e.first_name || ' ' || e.last_name    AS employee_name,
       e.designation,
       e.department
FROM   employees e
RIGHT JOIN branches b ON b.branch_id = e.branch_id
ORDER  BY b.branch_id;

-- A4. FULL OUTER JOIN — Customers vs Loans (see who never borrowed)
-- A4. FULL OUTER JOIN — Customers vs Loans (see who never borrowed)
SELECT c.first_name || ' ' || c.last_name           AS customer_name,
       COALESCE(l.loan_id::TEXT, 'NO LOAN')          AS loan_ref,
       COALESCE(l.principal_amount::TEXT, '—')       AS principal,
       COALESCE(l.status, '—')                       AS loan_status
FROM   customers c
FULL OUTER JOIN loans l ON l.customer_id = c.customer_id
ORDER  BY c.customer_id NULLS LAST;

-- A5. SELF JOIN — Employees and their managers
SELECT e.first_name || ' ' || e.last_name   AS employee,
       e.designation,
       m.first_name || ' ' || m.last_name   AS reports_to,
       m.designation                        AS manager_designation
FROM   employees e
LEFT JOIN employees m ON m.employee_id = e.manager_id
ORDER  BY m.employee_id NULLS LAST, e.employee_id;

-- ────────────────────────────────────────────────────────────
-- SECTION B: SET OPERATIONS
-- ────────────────────────────────────────────────────────────

-- B1. UNION — All cities that have either branches or active customers
SELECT city, 'Branch City' AS source FROM branches
UNION
SELECT city, 'Customer City' AS source FROM customers
ORDER BY city;

-- B2. UNION ALL — Combined deposit + interest transactions
SELECT 'DEPOSIT'  AS txn_category, account_id, amount, txn_date
FROM   transactions WHERE txn_type = 'DEPOSIT'
UNION ALL
SELECT 'INTEREST', account_id, amount, txn_date
FROM   transactions WHERE txn_type = 'INTEREST'
ORDER  BY txn_date DESC;

-- B3. INTERSECT — Customers who have BOTH an active account AND an active loan
SELECT customer_id FROM accounts WHERE status = 'ACTIVE'
INTERSECT
SELECT customer_id FROM loans   WHERE status = 'ACTIVE';

-- B4. EXCEPT — Customers with an account but NO loan of any kind
-- B4. EXCEPT — Customers with an account but NO loan of any kind
SELECT customer_id FROM accounts
EXCEPT
SELECT customer_id FROM loans;

-- B5. EXCEPT — Branch cities with branches but NO customers living there
SELECT city FROM branches
EXCEPT
SELECT city FROM customers;

-- ────────────────────────────────────────────────────────────
-- SECTION C: SUBQUERIES
-- ────────────────────────────────────────────────────────────

-- C1. Non-correlated Subquery — Customers with above-average credit score
SELECT first_name || ' ' || last_name AS customer_name, credit_score, city
FROM   customers
WHERE  credit_score > (SELECT AVG(credit_score) FROM customers)
ORDER  BY credit_score DESC;

-- C2. Non-correlated Subquery — Accounts with the highest balance per type
SELECT a.account_number, at.type_name, a.balance,
       c.first_name || ' ' || c.last_name AS owner
FROM   accounts a
JOIN   account_types at ON at.account_type_id = a.account_type_id
JOIN   customers      c  ON c.customer_id     = a.customer_id
WHERE  (a.account_type_id, a.balance) IN (
           SELECT account_type_id, MAX(balance)
           FROM   accounts
           GROUP  BY account_type_id
       )
ORDER  BY a.balance DESC;

-- C3. Correlated Subquery — Customers whose total loan outstanding > account balance
-- C3. Correlated Subquery — Customers whose total loan outstanding > account balance
SELECT c.first_name || ' ' || c.last_name AS customer_name,
       c.credit_score,
       (SELECT SUM(l.outstanding) FROM loans l
        WHERE  l.customer_id = c.customer_id AND l.status = 'ACTIVE') AS total_outstanding,
       (SELECT SUM(a.balance)    FROM accounts a
        WHERE  a.customer_id = c.customer_id) AS total_balance
FROM   customers c
WHERE  COALESCE((SELECT SUM(l.outstanding) FROM loans l
                 WHERE  l.customer_id = c.customer_id AND l.status = 'ACTIVE'), 0)
     > COALESCE((SELECT SUM(a.balance)    FROM accounts a
                 WHERE  a.customer_id = c.customer_id), 0);

-- C4. Correlated Subquery — Accounts with NO transactions in last 90 days (dormancy check)
-- C4. Correlated Subquery — Accounts with NO transactions in last 90 days (dormancy check)
SELECT a.account_number, c.first_name || ' ' || c.last_name AS owner,
       a.balance, a.last_txn_date
FROM   accounts a
JOIN   customers c ON c.customer_id = a.customer_id
WHERE  NOT EXISTS (
           SELECT 1 FROM transactions t
           WHERE  t.account_id = a.account_id
           AND    t.txn_date  >= CURRENT_DATE - INTERVAL '90 days'
       )
AND    a.status = 'ACTIVE';

-- C5. Subquery in FROM — Branch loan-to-deposit ratio
-- C5. Subquery in FROM — Branch loan-to-deposit ratio
SELECT bp.branch_name, bp.city,
       bp.total_deposits,
       bp.total_loan_amount,
       ROUND((bp.total_loan_amount / NULLIF(bp.total_deposits,0) * 100)::NUMERIC, 2) AS ldr_pct
FROM   vw_branch_performance bp
ORDER  BY ldr_pct DESC NULLS LAST;

-- C6. Non-correlated — Top 3 transaction amounts ever recorded
-- C6. Non-correlated — Top 3 transaction amounts ever recorded
SELECT * FROM (
    SELECT t.reference_no, t.txn_type, t.amount,
           a.account_number, t.txn_date,
           RANK() OVER (ORDER BY t.amount DESC) AS amount_rank
    FROM   transactions t
    JOIN   accounts a ON a.account_id = t.account_id
) ranked
WHERE amount_rank <= 3;

-- ────────────────────────────────────────────────────────────
-- SECTION D: AGGREGATE / ANALYTICAL QUERIES
-- ────────────────────────────────────────────────────────────

-- D1. Branch-wise total deposits, loans, and customer count
-- C3. Correlated Subquery — Customers whose total loan outstanding > account balance
SELECT b.branch_name, b.city,
       COUNT(DISTINCT a.customer_id) AS customers,
       COUNT(DISTINCT a.account_id)  AS accounts,
       COALESCE(SUM(a.balance), 0)   AS total_deposits,
       COUNT(DISTINCT l.loan_id)     AS loan_count,
       COALESCE(SUM(l.outstanding), 0) AS loan_book
FROM   branches b
LEFT JOIN accounts a ON a.branch_id = b.branch_id AND a.status = 'ACTIVE'
LEFT JOIN loans    l ON l.branch_id = b.branch_id AND l.status = 'ACTIVE'
GROUP  BY b.branch_name, b.city
ORDER  BY total_deposits DESC;

-- D2. Monthly transaction volume and value for current year
-- D2. Monthly transaction volume and value for current year
SELECT EXTRACT(MONTH FROM txn_date)::INT AS month,
       txn_type,
       COUNT(*)                           AS txn_count,
       SUM(amount)                        AS total_value,
       AVG(amount)                        AS avg_value,
       MAX(amount)                        AS max_single_txn
FROM   transactions
WHERE  EXTRACT(YEAR FROM txn_date) = EXTRACT(YEAR FROM CURRENT_DATE)
GROUP  BY EXTRACT(MONTH FROM txn_date), txn_type
ORDER  BY month, txn_type;

-- D3. Loan repayment health — paid vs outstanding per loan
SELECT l.loan_id,
       c.first_name || ' ' || c.last_name  AS borrower,
       lt.type_name                        AS loan_type,
       l.principal_amount,
       l.outstanding,
       l.principal_amount - l.outstanding  AS amount_repaid,
       ROUND(((l.principal_amount - l.outstanding) / l.principal_amount * 100)::NUMERIC, 1)
           AS repaid_pct
FROM   loans     l
JOIN   customers  c  ON c.customer_id  = l.customer_id
JOIN   loan_types lt ON lt.loan_type_id = l.loan_type_id
WHERE  l.status IN ('ACTIVE','CLOSED')
ORDER  BY repaid_pct DESC;