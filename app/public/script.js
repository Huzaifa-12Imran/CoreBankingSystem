const API_BASE = 'http://localhost:3001/api';
let balanceChart = null;

document.addEventListener('DOMContentLoaded', () => {
    // Navigation logic
    const navItems = document.querySelectorAll('.nav-item');
    const views = document.querySelectorAll('.view');
    const pageTitle = document.getElementById('page-title');

    navItems.forEach(item => {
        item.addEventListener('click', () => {
            const page = item.getAttribute('data-page');
            
            navItems.forEach(i => i.classList.remove('active'));
            item.classList.add('active');
            
            views.forEach(v => v.classList.add('hidden'));
            const activeView = document.getElementById(`${page}-view`);
            activeView.classList.remove('hidden');
            activeView.classList.add('fade-up');
            
            pageTitle.textContent = page.charAt(0).toUpperCase() + page.slice(1);
            loadPageData(page);
        });
    });

    // Command Palette Logic
    const palette = document.getElementById('cmd-palette');
    const paletteInput = document.getElementById('palette-input');
    const paletteBtn = document.getElementById('cmd-palette-btn');

    paletteBtn.onclick = () => {
        palette.style.display = 'block';
        paletteInput.focus();
    };

    // Close on ESC
    document.addEventListener('keydown', (e) => {
        if (e.key === 'Escape') palette.style.display = 'none';
        if ((e.metaKey || e.ctrlKey) && e.key === 'k') {
            e.preventDefault();
            paletteBtn.click();
        }
    });

    // Live Search Logic
    paletteInput.oninput = async (e) => {
        const query = e.target.value.toLowerCase();
        const resultsArea = document.getElementById('palette-results');
        
        if (!query) {
            resultsArea.innerHTML = '<div class="palette-hint">Type to search...</div>';
            return;
        }

        try {
            const res = await fetch(`${API_BASE}/customers`);
            const customers = await res.json();
            const filtered = customers.filter(c => 
                c.first_name.toLowerCase().includes(query) || 
                c.last_name.toLowerCase().includes(query) || 
                c.cnic.includes(query)
            );

            resultsArea.innerHTML = '';
            if (filtered.length === 0) {
                resultsArea.innerHTML = '<div class="palette-hint">No results found.</div>';
            } else {
                filtered.forEach(c => {
                    resultsArea.innerHTML += `
                        <div class="result-item" onclick="viewCustomer(${c.customer_id})">
                            <div>
                                <div class="title">${c.first_name} ${c.last_name}</div>
                                <div class="subtitle">${c.cnic} • ${c.city}</div>
                            </div>
                            <div class="type">CUSTOMER</div>
                        </div>
                    `;
                });
            }
        } catch (err) { console.error(err); }
    };

    // Modal Logic
    const modal = document.getElementById('customer-modal');
    const addBtn = document.getElementById('add-customer-btn');
    const closeBtn = document.querySelector('.close');

    addBtn.onclick = () => {
        const form = document.getElementById('add-customer-form');
        form.reset();
        delete form.dataset.editId;
        form.cnic.disabled = false;
        form.date_of_birth.parentElement.style.display = 'flex';
        form.gender.parentElement.style.display = 'flex';
        form.querySelector('button[type="submit"]').textContent = 'Confirm Enrollment';
        document.querySelectorAll('.error-txt').forEach(el => el.textContent = '');
        document.querySelectorAll('.input-zinc input').forEach(el => el.style.borderColor = '');
        modal.style.display = 'block';
    };
    closeBtn.onclick = () => modal.style.display = 'none';
    window.onclick = (event) => { if (event.target == modal) modal.style.display = 'none'; }

    // Form Submission
    document.getElementById('add-customer-form').onsubmit = async (e) => {
        e.preventDefault();
        const form = e.target;
        document.querySelectorAll('.error-txt').forEach(el => el.textContent = '');
        document.querySelectorAll('.input-zinc input').forEach(el => el.style.borderColor = '');

        const formData = new FormData(form);
        const data = Object.fromEntries(formData.entries());
        const editId = form.dataset.editId;

        try {
            const url = editId ? `${API_BASE}/customers/${editId}` : `${API_BASE}/customers`;
            const method = editId ? 'PUT' : 'POST';

            const res = await fetch(url, {
                method: method,
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(data)
            });
            const result = await res.json();

            if (res.ok) {
                modal.style.display = 'none';
                form.reset();
                delete form.dataset.editId; // Clear edit mode
                form.cnic.disabled = false;
                form.date_of_birth.parentElement.style.display = 'flex';
                form.gender.parentElement.style.display = 'flex';
                form.querySelector('button[type="submit"]').textContent = 'Confirm Enrollment';

                loadPageData('customers');
                loadAuditLogs();
                alert(editId ? 'Profile Updated!' : 'Customer Registered!');
            } else if (result.errors) {
                for (const [field, message] of Object.entries(result.errors)) {
                    const errorSpan = document.getElementById(`err-${field}`);
                    const inputField = document.querySelector(`[name="${field}"]`);
                    if (errorSpan) errorSpan.textContent = message;
                    if (inputField) inputField.style.borderColor = 'var(--danger)';
                }
            }
        } catch (err) { console.error(err); }
    };

    // INITIAL LOAD
    loadPageData('dashboard');
    loadAuditLogs();
});

async function loadPageData(page) {
    if (page === 'dashboard') {
        loadStats();
        loadRecentTransactions();
    } else if (page === 'customers') {
        loadCustomers();
    } else if (page === 'accounts') {
        loadAccounts();
    } else if (page === 'transactions') {
        loadFullTransactions();
    }
}

async function loadStats() {
    try {
        const res = await fetch(`${API_BASE}/stats`);
        const data = await res.json();
        document.getElementById('stat-customers').textContent = data.totalCustomers;
        document.getElementById('stat-deposits').textContent = 'PKR ' + (parseFloat(data.totalDeposits) / 1000000).toFixed(1) + 'M';
        updateChart(data.totalDeposits);
    } catch (err) { console.error(err); }
}

function updateChart(totalDeposits) {
    const canvas = document.getElementById('balanceChart');
    if (!canvas) return;
    const ctx = canvas.getContext('2d');
    if (balanceChart) balanceChart.destroy();

    balanceChart = new Chart(ctx, {
        type: 'line',
        data: {
            labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
            datasets: [{
                label: 'Deposits',
                data: [totalDeposits * 0.8, totalDeposits * 0.85, totalDeposits * 0.9, totalDeposits * 0.95, totalDeposits * 0.98, totalDeposits],
                borderColor: '#3b82f6',
                borderWidth: 4,
                tension: 0.4,
                pointRadius: 4,
                pointBackgroundColor: '#3b82f6',
                fill: true,
                backgroundColor: 'rgba(59, 130, 246, 0.1)'
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: { legend: { display: false } },
            scales: {
                y: { display: false },
                x: {
                    grid: { display: false },
                    ticks: { color: '#71717a', font: { size: 10 } }
                }
            }
        }
    });
}

async function loadRecentTransactions() {
    const tableBody = document.querySelector('#recent-txns-table tbody');
    if (!tableBody) return;
    try {
        const res = await fetch(`${API_BASE}/transactions`);
        const data = await res.json();
        tableBody.innerHTML = '';
        data.slice(0, 5).forEach(txn => {
            tableBody.innerHTML += `
                <tr>
                    <td>${txn.account_number}</td>
                    <td style="font-weight: 600;">${parseFloat(txn.amount).toLocaleString()}</td>
                    <td><span style="color: var(--success)">Success</span></td>
                </tr>
            `;
        });
    } catch (err) { console.error(err); }
}

async function loadCustomers() {
    const tableBody = document.querySelector('#customers-table tbody');
    if (!tableBody) return;
    try {
        const res = await fetch(`${API_BASE}/customers`);
        const data = await res.json();
        tableBody.innerHTML = '';
        data.forEach(c => {
            tableBody.innerHTML += `
                <tr>
                    <td>${c.first_name} ${c.last_name}</td>
                    <td>${c.cnic}</td>
                    <td>${c.phone}</td>
                    <td>${c.city}</td>
                    <td>
                        <button onclick='openEditModal(${JSON.stringify(c)})' style="background: none; border: none; color: var(--accent); cursor: pointer; margin-right: 10px;"><i class="fa-solid fa-pen"></i></button>
                        <button onclick="deleteCustomer(${c.customer_id})" style="background: none; border: none; color: var(--muted); cursor: pointer;"><i class="fa-solid fa-trash"></i></button>
                    </td>
                </tr>
            `;
        });
    } catch (err) { console.error(err); }
}

function openEditModal(customer) {
    const modal = document.getElementById('customer-modal');
    const form = document.getElementById('add-customer-form');
    
    // Fill the form
    form.first_name.value = customer.first_name;
    form.last_name.value = customer.last_name;
    form.cnic.value = customer.cnic;
    form.cnic.disabled = true; // Identity shouldn't be edited easily
    form.email.value = customer.email;
    form.phone.value = customer.phone;
    form.city.value = customer.city;
    form.address.value = customer.address;
    
    // Hide fields that aren't editable for simplicity in academic demo
    form.date_of_birth.parentElement.style.display = 'none';
    form.gender.parentElement.style.display = 'none';

    // Change button text
    form.querySelector('button[type="submit"]').textContent = 'Update Profile';
    
    // Store ID
    form.dataset.editId = customer.customer_id;
    
    modal.style.display = 'block';
}

async function loadAccounts() {
    const tableBody = document.querySelector('#accounts-table tbody');
    if (!tableBody) return;
    try {
        const res = await fetch(`${API_BASE}/accounts`);
        const data = await res.json();
        tableBody.innerHTML = '';
        data.forEach(a => {
            tableBody.innerHTML += `
                <tr>
                    <td style="font-family: monospace;">${a.account_number}</td>
                    <td>${a.first_name} ${a.last_name}</td>
                    <td>${a.type_name}</td>
                    <td style="font-weight: 600;">${parseFloat(a.balance).toLocaleString()}</td>
                    <td><span style="color: var(--success)">${a.status}</span></td>
                    <td>
                        <button onclick="performTransaction(${a.account_id}, '${a.account_number}')" style="background: var(--accent); border: none; color: white; cursor: pointer; padding: 4px 8px; border-radius: 4px; font-size: 11px;">TRANSACT</button>
                    </td>
                </tr>
            `;
        });
    } catch (err) { console.error(err); }
}

async function performTransaction(accountId, accNum) {
    const type = confirm(`Post a DEPOSIT for ${accNum}?\n(Cancel for WITHDRAWAL)`) ? 'DEPOSIT' : 'WITHDRAWAL';
    const amount = prompt(`Enter ${type} amount for ${accNum}:`);
    
    if (!amount || isNaN(amount) || amount <= 0) return;

    try {
        const res = await fetch(`${API_BASE}/transactions`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ account_id: accountId, type, amount, description: `${type} via Dashboard` })
        });
        const result = await res.json();
        
        if (res.ok) {
            alert(`${type} Successful! New Balance: PKR ${parseFloat(result.newBalance).toLocaleString()}`);
            loadPageData('accounts');
            loadStats();
            loadAuditLogs();
        } else {
            alert('Error: ' + result.error);
        }
    } catch (err) { console.error(err); }
}

async function loadFullTransactions() {
    const tableBody = document.querySelector('#full-txns-table tbody');
    if (!tableBody) return;
    try {
        const res = await fetch(`${API_BASE}/transactions`);
        const data = await res.json();
        tableBody.innerHTML = '';
        data.forEach(t => {
            tableBody.innerHTML += `
                <tr>
                    <td>${t.reference_no}</td>
                    <td>${new Date(t.txn_date).toLocaleDateString()}</td>
                    <td>${t.txn_type}</td>
                    <td style="font-weight: 600;">${parseFloat(t.amount).toLocaleString()}</td>
                    <td><span style="color: var(--success)">SUCCESS</span></td>
                </tr>
            `;
        });
    } catch (err) { console.error(err); }
}

function viewCustomer(id) {
    document.getElementById('cmd-palette').style.display = 'none';
    document.querySelector('[data-page="customers"]').click();
}

async function loadAuditLogs() {
    const feed = document.getElementById('audit-feed');
    if (!feed) return;
    try {
        const res = await fetch(`${API_BASE}/audit-logs`);
        const logs = await res.json();
        feed.innerHTML = '';
        if (!logs || logs.length === 0) {
            feed.innerHTML = `
                <div class="audit-item">
                    <div class="audit-dot" style="background: var(--success); box-shadow: 0 0 10px var(--success);"></div>
                    <div class="audit-info">
                        <div class="action">System online. Monitoring ready.</div>
                        <div class="time">Just now</div>
                    </div>
                </div>
            `;
            return;
        }
        logs.forEach(log => {
            feed.innerHTML += `
                <div class="audit-item">
                    <div class="audit-dot"></div>
                    <div class="audit-info">
                        <div class="action">${log.action}</div>
                        <div class="time">${new Date(log.action_date).toLocaleTimeString()}</div>
                    </div>
                </div>
            `;
        });
    } catch (err) { console.error(err); }
}

async function deleteCustomer(id) {
    if (confirm('Are you sure you want to permanently delete this record?')) {
        try {
            const res = await fetch(`${API_BASE}/customers/${id}`, { method: 'DELETE' });
            const result = await res.json();
            
            if (res.ok) {
                alert('Record deleted successfully.');
                loadCustomers();
                loadStats();
                loadAuditLogs();
            } else {
                alert('ACCESS DENIED: ' + (result.error || 'Check database constraints.'));
            }
        } catch (err) { 
            console.error(err);
            alert('Network error or server is offline.');
        }
    }
}
