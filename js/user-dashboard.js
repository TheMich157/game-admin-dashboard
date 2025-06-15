const API_BASE_URL = 'http://localhost:3000/api';
const token = localStorage.getItem('token');
if (!token) window.location.href = "index.html";

// Tabs logic
document.querySelectorAll('.tab').forEach(tab => {
    tab.onclick = function() {
        document.querySelectorAll('.tab').forEach(t => t.classList.remove('active'));
        document.querySelectorAll('.section').forEach(s => s.classList.remove('active'));
        tab.classList.add('active');
        document.getElementById(tab.dataset.tab + "Section").classList.add('active');
    };
});

// Logout button
document.getElementById('logoutBtn').onclick = () => {
    localStorage.removeItem('token');
    window.location.href = "index.html";
};

// Fetch user info
fetch(`${API_BASE_URL}/me`, { headers: { Authorization: `Bearer ${token}` } })
    .then(r => r.json())
    .then(user => {
        document.getElementById('userInfo').innerHTML = `<b>Logged in as:</b> ${user.username}`;
        loadAppeals();
        loadProfile();
    });

// Profile info
function loadProfile() {
    fetch(`${API_BASE_URL}/me`, { headers: { Authorization: `Bearer ${token}` } })
        .then(r => r.json())
        .then(user => {
            document.getElementById('profileInfo').innerHTML = `<b>Username:</b> ${user.username}`;
        });
}

// Appeal form logic
const robloxUsernameInput = document.getElementById('robloxUsername');
const banStatus = document.getElementById('banStatus');
const appealNotification = document.getElementById('appealNotification');
let isBanned = false;

robloxUsernameInput.oninput = async function() {
    const username = robloxUsernameInput.value.trim();
    banStatus.textContent = '';
    isBanned = false;
    if (username.length < 3) return;
    // Check ban status via API
    try {
        const res = await fetch(`${API_BASE_URL}/banstatus/${encodeURIComponent(username)}`);
        const data = await res.json();
        if (!data.banned) {
            banStatus.textContent = "User is not banned.";
            isBanned = false;
        } else {
            banStatus.textContent = "";
            isBanned = true;
        }
    } catch {
        banStatus.textContent = "";
        isBanned = false;
    }
};

document.getElementById('appealForm').onsubmit = async (e) => {
    e.preventDefault();
    appealNotification.style.display = "none";
    const robloxUsername = robloxUsernameInput.value.trim();
    const q1 = document.getElementById('appealQ1').value.trim();
    const q2 = document.getElementById('appealQ2').value.trim();
    if (!isBanned) {
        appealNotification.textContent = "You can only appeal if you are banned.";
        appealNotification.className = "notification error";
        appealNotification.style.display = "block";
        return;
    }
    const res = await fetch(`${API_BASE_URL}/appeals`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${token}` },
        body: JSON.stringify({
            robloxUsername,
            q1,
            q2
        })
    });
    const data = await res.json();
    if (res.ok) {
        appealNotification.textContent = "Appeal submitted!";
        appealNotification.className = "notification";
        appealNotification.style.display = "block";
        document.getElementById('appealForm').reset();
        loadAppeals();
    } else {
        appealNotification.textContent = data.error || "Failed to submit appeal.";
        appealNotification.className = "notification error";
        appealNotification.style.display = "block";
    }
};

// Load user's appeals
async function loadAppeals() {
    const res = await fetch(`${API_BASE_URL}/appeals`, { headers: { Authorization: `Bearer ${token}` } });
    const appeals = await res.json();
    const list = document.getElementById('appealsList');
    list.innerHTML = '';
    if (!appeals.length) {
        list.innerHTML = '<li>No appeals submitted yet.</li>';
        return;
    }
    for (const appeal of appeals) {
        const li = document.createElement('li');
        li.textContent = `[${new Date(appeal.timestamp * 1000).toLocaleString()}] ${appeal.robloxUsername}: ${appeal.q1} / ${appeal.q2} - Status: ${appeal.status}`;
        list.appendChild(li);
    }
}