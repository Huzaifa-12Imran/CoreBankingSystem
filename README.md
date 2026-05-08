# 🏦 Core Banking System (CBS) — Enterprise Grade
![License](https://img.shields.io/badge/Academic-Project-blue)
![Database](https://img.shields.io/badge/Database-PostgreSQL%2017-336791?logo=postgresql&logoColor=white)
![Backend](https://img.shields.io/badge/Backend-Node.js-339933?logo=node.js&logoColor=white)
![Design](https://img.shields.io/badge/Design-Zinc%20Bento-09090b)
![Status](https://img.shields.io/badge/Status-Viva--Ready-success)

A robust, full-stack Core Banking System (CBS) designed for academic excellence and production-grade data management. This project demonstrates advanced database architecture, ACID-compliant transaction handling, and a modern, high-performance user interface.

---

## 🌟 Key Features

### 🛠️ Advanced Database Architecture
- **Normalization**: Fully optimized to **3NF/BCNF** to ensure zero data redundancy and maximum integrity.
- **Modular Design**: Implemented using **PostgreSQL Schemas** to emulate Oracle-style packages (`pkg_account_ops`, `pkg_loan_mgmt`), ensuring clean namespace separation.
- **PL/SQL Automation**: 
  - **Triggers**: Automated audit logging, age-based validation (18+), and intelligent account number generation.
  - **Procedures**: Atomic logic for multi-stage transactions (Transfer, Loan Approval, EMI Posting).
  - **Cursors**: Explicit cursors for batch processing of monthly interest and dormant account detection.

### 🖥️ Premium Interface (Zinc Bento Aesthetic)
- **Bento Grid Dashboard**: Real-time visualization of net liquidity, tier-1 capital stability, and customer growth.
- **Interactive Command Palette**: `Ctrl + K` navigation for rapid customer lookup and system navigation.
- **Modern Notifications**: Custom Toast notification system for non-blocking success/error feedback.
- **Full CRUD & Banking Ops**: Perform real-time deposits, withdrawals, profile updates, and record deletions with automated audit trails.

---

## 🚀 Tech Stack

| Layer | Technologies |
| :--- | :--- |
| **Database** | **PostgreSQL 17** (B-Tree Indexing, Schemas, PL/pgSQL) |
| **Backend** | **Node.js** (Express.js), **pg** (Pool Connection Management) |
| **Frontend** | **Vanilla JS**, **CSS3 (Custom Design System)**, **Chart.js**, **FontAwesome** |
| **Security** | **DCL (RBAC)** with fine-grained Roles (Teller, Auditor, Admin) |

---

## 📂 Project Roadmap & Files

The project is structured into logical development steps to ensure a smooth viva demonstration:

1.  **[Step 1: DDL & DCL](Step_1_DDL_and_DCL.sql)**: Schema definition, constraints, and Role-Based Access Control.
2.  **[Step 2: Data Population](Step_2_Data_Population.sql)**: 100+ total records across 12+ tables to simulate a live environment.
3.  **[Step 3: Advanced Queries](Step_3_Advanced_Queries.sql)**: Complex analytical reports using Joins, Set Operations, and Subqueries.
4.  **[Step 4: PL/SQL & Automation](Step_4_PLSQL_and_Automation.sql)**: The "Brain" of the system—Triggers, Functions, and Procedures.
5.  **[Step 5: Final Upgrades](Step_5_Final_Academic_Upgrades.sql)**: High-performance Views and Custom Composite Types.

---

## 🚦 Installation & Setup

### Prerequisites
- PostgreSQL 17+
- Node.js (Latest LTS)

### Setup Instructions
1.  **Clone the Repository**:
    ```bash
    git clone https://github.com/Huzaifa-12Imran/CoreBankingSystem.git
    cd CoreBankingSystem
    ```
2.  **Initialize Database**:
    Execute scripts `Step_1` through `Step_5` in order using your preferred SQL client or `psql`.
3.  **Launch Backend**:
    ```bash
    cd app
    npm install
    node server.js
    ```
4.  **Open Dashboard**: Navigate to `http://localhost:3001`.

---

## 📜 Academic Compliance Dashboard

| Requirement | Implementation Detail | Status |
| :--- | :--- | :---: |
| **Normalization** | Tables optimized to 3NF/BCNF | ✅ |
| **ACID Compliance** | Managed via `BEGIN/COMMIT/ROLLBACK` in banking logic | ✅ |
| **Set Operations** | `UNION`, `EXCEPT`, `INTERSECT` for system reporting | ✅ |
| **Triggers** | 8+ triggers for auditing and business rules | ✅ |
| **Complex Views** | `v_customer_financial_summary` with correlated subqueries | ✅ |
| **DCL** | 4 distinct roles with specific table-level permissions | ✅ |

---
*Developed for the Semester Project — Database Systems (CS-311)*  
**Team**: **Huzaifa Imran** & **Muhammad Arslan**
