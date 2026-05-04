# 🏦 Core Banking System (CBS) — Production Ready

![License](https://img.shields.io/badge/Academic-Project-blue)
![Database](https://img.shields.io/badge/Database-PostgreSQL%2017-336791?logo=postgresql&logoColor=white)
![Backend](https://img.shields.io/badge/Backend-Node.js-339933?logo=node.js&logoColor=white)
![Frontend](https://img.shields.io/badge/Frontend-Vanilla%20JS-F7DF1E?logo=javascript&logoColor=black)
![Design](https://img.shields.io/badge/Design-Zinc%20Bento-09090b)

A robust, full-stack Core Banking System designed for academic excellence and production-grade data management. This system manages everything from customer enrollment to automated interest accruals and loan lifecycles.

---

## 🌟 Key Features

### 🛠️ Advanced Database Logic
- **Normalization**: Fully normalized to 3NF/BCNF to ensure zero data redundancy.
- **PL/SQL Automation**: 
  - Automated **EMI Calculations** for loans.
  - Real-time **Audit Logging** via database triggers.
  - **Dormant Account Detection** using explicit cursors.
  - **Interest Accrual Posting** as a dedicated financial entity.
- **Complex Views**: Unified reporting via `v_customer_financial_summary` for high-performance dashboarding.

### 🖥️ Premium Interface (Zinc Aesthetic)
- **Bento Grid Dashboard**: Visualizes net liquidity, system stability, and recent activity.
- **Interactive Command Palette**: `Ctrl + K` navigation for rapid customer lookup.
- **Live Audit Feed**: Real-time visualization of database events.
- **Full CRUD & Transactions**: Perform deposits, withdrawals, and profile updates with a single click.

---

## 🚀 Tech Stack

| Layer | Technologies |
| :--- | :--- |
| **Database** | ![Postgres](https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white) |
| **Backend** | ![NodeJS](https://img.shields.io/badge/Node.js-43853D?style=for-the-badge&logo=node.js&logoColor=white) ![Express](https://img.shields.io/badge/Express.js-000000?style=for-the-badge&logo=express&logoColor=white) |
| **Frontend** | ![HTML5](https://img.shields.io/badge/HTML5-E34F26?style=for-the-badge&logo=html5&logoColor=white) ![CSS3](https://img.shields.io/badge/CSS3-1572B6?style=for-the-badge&logo=css3&logoColor=white) ![JS](https://img.shields.io/badge/JavaScript-F7DF1E?style=for-the-badge&logo=javascript&logoColor=black) |
| **Tools** | ![Git](https://img.shields.io/badge/Git-F05032?style=for-the-badge&logo=git&logoColor=white) ![Postman](https://img.shields.io/badge/Postman-FF6C37?style=for-the-badge&logo=Postman&logoColor=white) |

---

## 📂 Project Structure

```bash
├── app/                  # Full-stack application source
│   ├── server.js         # Node.js Express backend
│   └── public/           # Frontend (HTML, Zinc CSS, JS)
├── Step_1_DDL_and_DCL.sql # Schema & Permissions
├── Step_2_Data_Population.sql # Mock Data (15+ Records)
├── Step_3_Advanced_Queries.sql # Analytical Reports
├── Step_4_PLSQL_and_Automation.sql # Triggers & Procedures
├── Step_5_Final_Upgrades.sql # Views & Performance
├── SRS_Document.txt      # Software Requirements Specification
└── Code_Appendix.txt     # Consolidated Submission Script
```

---

## 🚦 Getting Started

1.  **Database Setup**:
    -   Run the `Step_1` through `Step_5` SQL scripts in sequence on a PostgreSQL 17 instance.
2.  **Server Startup**:
    -   Navigate to `/app`.
    -   Run `npm install` and `npm start`.
3.  **Access**:
    -   Open `http://localhost:3001` in your browser.

---

## 📜 Academic Compliance
This project satisfies all requirements for the **Database Systems Final Project**, including:
- EERD Specialization (Savings vs Current Accounts).
- ACID-compliant transactions.
- Multi-join complex views.
- Correlated subqueries and Set operations (UNION/EXCEPT).
- Role-based Access Control (GRANT/REVOKE).

---
*Developed for academic evaluation by Huzaifa Imran.*
