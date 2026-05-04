const express = require('express');
const { Pool } = require('pg');
const cors = require('cors');
require('dotenv').config();

const path = require('path');
const app = express();
const port = 3001;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

// DB Connection
const pool = new Pool({
  user: 'postgres',
  host: 'localhost',
  database: 'postgres',
  password: 'huzaifa123',
  port: 5432,
});

// API Routes
app.get('/api/stats', async (req, res) => {
  try {
    const stats = {};
    const cCount = await pool.query('SELECT COUNT(*) FROM customers');
    stats.totalCustomers = cCount.rows[0].count;
    const tDep = await pool.query('SELECT SUM(balance) FROM accounts');
    stats.totalDeposits = tDep.rows[0].sum || 0;
    const aLoans = await pool.query("SELECT COUNT(*) FROM loans WHERE status = 'ACTIVE'");
    stats.activeLoans = aLoans.rows[0].count;
    const mTxns = await pool.query('SELECT COUNT(*) FROM transactions WHERE txn_date >= CURRENT_DATE - INTERVAL \'30 days\'');
    stats.monthlyTxns = mTxns.rows[0].count;
    res.json(stats);
  } catch (err) { res.status(500).json({ error: err.message }); }
});

app.get('/api/customers', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM customers ORDER BY registration_date DESC LIMIT 50');
    res.json(result.rows);
  } catch (err) { res.status(500).json({ error: err.message }); }
});

app.get('/api/accounts', async (req, res) => {
  try {
    // Phase V Academic Requirement: Fetching data via a complex Multi-Table View
    const result = await pool.query('SELECT * FROM v_customer_financial_summary ORDER BY balance DESC');
    res.json(result.rows);
  } catch (err) { res.status(500).json({ error: err.message }); }
});

app.get('/api/transactions', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT t.*, a.account_number FROM transactions t
      JOIN accounts a ON t.account_id = a.account_id
      ORDER BY t.txn_date DESC, t.transaction_id DESC LIMIT 20
    `);
    res.json(result.rows);
  } catch (err) { res.status(500).json({ error: err.message }); }
});

// Phase III Requirement: Set Operations (UNION)
app.get('/api/system-entities', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM v_all_system_entities LIMIT 10');
    res.json(result.rows);
  } catch (err) { res.status(500).json({ error: err.message }); }
});

// Advanced POST with Multiple Error Checking
app.post('/api/customers', async (req, res) => {
  const { cnic, first_name, last_name, date_of_birth, gender, email, phone, address, city } = req.body;
  const errors = {};

  // 1. Manual Validation (Checks multiple things at once)
  if (!/^[0-9]{5}-[0-9]{7}-[0-9]{1}$/.test(cnic)) {
    errors.cnic = 'Format: 00000-0000000-0';
  }
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
    errors.email = 'Invalid email address';
  }
  
  const birthYear = new Date(date_of_birth).getFullYear();
  const currentYear = new Date().getFullYear();
  if (currentYear - birthYear < 18) {
    errors.date_of_birth = 'Must be 18+ years old';
  }

  // 2. Database Pre-Checks (Check for existing records)
  try {
    const cnicCheck = await pool.query('SELECT customer_id FROM customers WHERE cnic = $1', [cnic]);
    if (cnicCheck.rows.length > 0) errors.cnic = 'Already registered';

    const emailCheck = await pool.query('SELECT customer_id FROM customers WHERE email = $1', [email]);
    if (emailCheck.rows.length > 0) errors.email = 'Already registered';

    const phoneCheck = await pool.query('SELECT customer_id FROM customers WHERE phone = $1', [phone]);
    if (phoneCheck.rows.length > 0) errors.phone = 'Already registered';

    // If any errors (regex, age, or existence), return them all at once
    if (Object.keys(errors).length > 0) {
      return res.status(400).json({ errors });
    }

    const result = await pool.query(
      'INSERT INTO customers (cnic, first_name, last_name, date_of_birth, gender, email, phone, address, city) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9) RETURNING *',
      [cnic, first_name, last_name, date_of_birth, gender, email, phone, address, city]
    );

    // LOG ACTION (Matching your DB schema)
    await pool.query(
        'INSERT INTO audit_log (table_name, operation, record_id, changed_by, remarks) VALUES ($1, $2, $3, $4, $5)',
        ['customers', 'INSERT', result.rows[0].customer_id, 'SYSTEM', `New customer enrolled: ${first_name} ${last_name}`]
    );

    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

app.put('/api/customers/:id', async (req, res) => {
  const { first_name, last_name, email, phone, city, address } = req.body;
  try {
    const result = await pool.query(
      'UPDATE customers SET first_name = $1, last_name = $2, email = $3, phone = $4, city = $5, address = $6 WHERE customer_id = $7 RETURNING *',
      [first_name, last_name, email, phone, city, address, req.params.id]
    );
    
    // LOG ACTION
    await pool.query(
        'INSERT INTO audit_log (table_name, operation, record_id, changed_by, remarks) VALUES ($1, $2, $3, $4, $5)',
        ['customers', 'UPDATE', req.params.id, 'SYSTEM', `Updated profile for: ${first_name} ${last_name}`]
    );

    res.json(result.rows[0]);
  } catch (err) { res.status(500).json({ error: err.message }); }
});

app.delete('/api/customers/:id', async (req, res) => {
    try {
        const cust = await pool.query('SELECT first_name, last_name FROM customers WHERE customer_id = $1', [req.params.id]);
        const name = cust.rows[0] ? `${cust.rows[0].first_name} ${cust.rows[0].last_name}` : 'Unknown';
        
        await pool.query('DELETE FROM customers WHERE customer_id = $1', [req.params.id]);
        
        await pool.query(
            'INSERT INTO audit_log (table_name, operation, record_id, changed_by, remarks) VALUES ($1, $2, $3, $4, $5)',
            ['customers', 'DELETE', req.params.id, 'SYSTEM', `Customer record deleted: ${name}`]
        );
        
        res.status(200).json({ success: true, message: 'Customer deleted successfully' });
    } catch (err) {
        console.error('Delete error:', err);
        res.status(500).json({ error: err.message });
    }
});

app.get('/api/audit-logs', async (req, res) => {
  try {
    const result = await pool.query('SELECT remarks as action, change_timestamp as action_date FROM audit_log ORDER BY change_timestamp DESC LIMIT 10');
    res.json(result.rows);
  } catch (err) { res.status(500).json({ error: err.message }); }
});

// ── TRANSACTIONS (CRUD for Balances) ───────────────────
app.post('/api/transactions', async (req, res) => {
    const { account_id, type, amount, description } = req.body;
    
    if (!account_id || !amount || amount <= 0) {
        return res.status(400).json({ error: 'Invalid transaction data' });
    }

    try {
        const client = await pool.connect();
        try {
            await client.query('BEGIN');
            
            // 1. Get current balance
            const accRes = await client.query('SELECT balance FROM accounts WHERE account_id = $1', [account_id]);
            if (accRes.rows.length === 0) throw new Error('Account not found');
            
            const currentBal = parseFloat(accRes.rows[0].balance);
            const newBal = type === 'DEPOSIT' ? currentBal + parseFloat(amount) : currentBal - parseFloat(amount);

            if (newBal < 0) {
                return res.status(400).json({ error: 'Insufficient funds' });
            }

            // 2. Update balance
            await client.query('UPDATE accounts SET balance = $1, last_txn_date = CURRENT_DATE WHERE account_id = $2', [newBal, account_id]);

            // 3. Log transaction
            await client.query(
                `INSERT INTO transactions (account_id, txn_type, amount, balance_after, description, status) 
                 VALUES ($1, $2, $3, $4, $5, 'SUCCESS')`,
                [account_id, type, amount, newBal, description || `${type} via Dashboard`]
            );

            await client.query('COMMIT');
            res.json({ success: true, newBalance: newBal });
        } catch (e) {
            await client.query('ROLLBACK');
            throw e;
        } finally {
            client.release();
        }
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Database transaction failed' });
    }
});

app.listen(port, () => {
  console.log(`CBS Backend running at http://localhost:${port}`);
});
