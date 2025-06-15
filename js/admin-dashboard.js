const API_BASE_URL = 'http://localhost:3000/api';
const token = localStorage.getItem('token');
if (!token) window.location.href = "index.html";

let username = "";

function debug(...args) { console.log('[DEBUG]', ...args); }

// Tabs logic
document.querySelectorAll('.tab').forEach(tab => {
    tab.onclick = function() {
        document.querySelectorAll('.tab').forEach(t => t.classList.remove('active'));
        document.querySelectorAll('.section').forEach(s => s.classList.remove('active'));
        tab.classList.add('active');
        document.getElementById(tab.dataset.tab + "Section").classList.add('active');
    };
});

// Fetch user info
fetch(`${API_BASE_URL}/me`, { headers: { Authorization: `Bearer ${token}` } })
    .then(r => r.json())
    .then(user => {
        username = user.username;
        document.getElementById('userInfo').innerHTML = `<b>Logged in as:</b> ${user.username} <span class="admin-badge">Admin</span>`;
        loadAllAppeals();
    });

// Load all appeals
async function loadAllAppeals() {
    const res = await fetch(`${API_BASE_URL}/appeals`, { headers: { Authorization: `Bearer ${token}` } });
    const appeals = await res.json();
    const list = document.getElementById('allAppealsList');
    list.innerHTML = '';
    if (!appeals.length) {
        list.innerHTML = '<li>No appeals submitted yet.</li>';
        return;
    }
    for (const appeal of appeals) {
        const row = document.createElement('tr');
        row.innerHTML = `
            <td class="px-6 py-4 text-sm font-medium text-gray-900">${appeal.player}</td>
            <td class="px-6 py-4 text-sm text-gray-500">${appeal.q1 || ''} / ${appeal.q2 || ''}</td>
            <td class="px-6 py-4 text-sm text-gray-500">${new Date(appeal.timestamp * 1000).toLocaleDateString()}</td>
            <td class="px-6 py-4">
                <span class="px-2 inline-flex text-xs font-semibold rounded-full bg-yellow-100 text-yellow-800">${appeal.status}</span>
            </td>
            <td class="px-6 py-4 text-sm font-medium">
                ${appeal.status === 'Pending' ? `
                    <button onclick="handleAppeal(${appeal.id}, 'approve')" class="text-green-600 hover:text-green-900 mr-3">Approve</button>
                    <button onclick="handleAppeal(${appeal.id}, 'reject')" class="text-red-600 hover:text-red-900">Reject</button>
                ` : ''}
            </td>`;
        list.appendChild(row);
    }
}

// Handle admin appeal actions
window.handleAppeal = async (appealId, action) => {
    const res = await fetch(`${API_BASE_URL}/appeals/update`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${token}` },
        body: JSON.stringify({ id: appealId, action })
    });
    if (res.ok) {
        loadAllAppeals();
    }
};

// Admin actions
window.triggerAdminAction = async (action) => {
    const res = await fetch(`${API_BASE_URL}/admin-actions`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${token}` },
        body: JSON.stringify({ action })
    });
    if (res.ok) alert('Action triggered: ' + action);
};

document.getElementById('logoutBtn').onclick = () => {
    localStorage.removeItem('token');
    window.location.href = "index.html";
};