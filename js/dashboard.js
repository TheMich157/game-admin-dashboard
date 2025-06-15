const API_BASE_URL = 'http://localhost:3000/api';

// Debugging
const DEBUG = true;
function debug(...args) {
    if (DEBUG) console.log('[DEBUG]', ...args);
}

// Login handling
const initializeLogin = () => {
    const loginForm = document.getElementById('loginForm');
    const loginSection = document.getElementById('loginSection');
    const dashboardSection = document.getElementById('dashboardSection');

    if (!loginForm || !loginSection || !dashboardSection) {
        console.error('Required elements not found');
        return;
    }

    const urlParams = new URLSearchParams(window.location.search);
    const offlineMode = urlParams.get('offline') === '1';

    // Replace login endpoint and token handling
    async function handleLogin(event) {
        event.preventDefault();
        const username = document.getElementById('username').value.trim();
        const password = document.getElementById('password').value.trim();
        debug('Login attempt:', username);

        if (offlineMode) {
            debug('Offline mode login for:', username);
            if (username.toLowerCase() !== "admin") {
                debug('Offline login denied for non-admin:', username);
                alert("Offline: Only admins can log in.");
                return;
            }
            localStorage.setItem('offlineAdmin', username);
            debug('Offline admin login success:', username);
            window.location.href = "dashboard.html?offline=1";
            return;
        }
        try {
            const response = await fetch(`${API_BASE_URL}/login`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ username, password }),
            });
            debug('Login API response:', response.status);
            if (!response.ok) throw new Error('Invalid credentials');
            const data = await response.json();
            localStorage.setItem('token', data.token);
            debug('Login success, token stored');
            // Redirect based on role
            if (data.type === "Admin") {
                window.location.href = "admin-dashboard.html";
            } else {
                window.location.href = "user-dashboard.html";
            }
        } catch (err) {
            debug('Login error:', err);
            alert('Invalid credentials. Please try again.');
        }
    };

    loginForm.addEventListener('submit', handleLogin);
};

// Panel navigation
function showPanel(panelName) {
    ['eventsPanel', 'adminPanel', 'appealsPanel'].forEach(panel =>
        document.getElementById(panel).classList.add('hidden')
    );
    document.getElementById(`${panelName}Panel`).classList.remove('hidden');
}

// Load initial data
function loadInitialData() {
    loadEvents();
    loadAppeals();
}

// Get auth headers
function getAuthHeaders() {
    const token = localStorage.getItem('token');
    return {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${token}`
    };
}

// Load events
async function loadEvents() {
    const tbody = document.getElementById('eventsTableBody');
    tbody.innerHTML = '';

    try {
        const response = await fetch(`${API_BASE_URL}/events`, {
            headers: getAuthHeaders()
        });

        if (response.status === 401) return handleUnauthorized();

        const events = await response.json();

        events.forEach(event => {
            const row = document.createElement('tr');
            row.innerHTML = `
                <td class="px-6 py-4 text-sm text-gray-500">${new Date(event.timestamp * 1000).toLocaleString()}</td>
                <td class="px-6 py-4 text-sm font-medium text-gray-900">${event.eventName}</td>
                <td class="px-6 py-4 text-sm text-gray-500">${event.details.initiator || ''}</td>
                <td class="px-6 py-4">
                    <span class="px-2 inline-flex text-xs font-semibold rounded-full bg-red-100 text-red-800">Active</span>
                </td>`;
            tbody.appendChild(row);
        });
    } catch (error) {
        console.error('Failed to load events:', error);
    }
}

// Load appeals
async function loadAppeals() {
    const tbody = document.getElementById('appealsTableBody');
    tbody.innerHTML = '';

    try {
        const response = await fetch(`${API_BASE_URL}/appeals`, {
            headers: getAuthHeaders()
        });

        if (response.status === 401) return handleUnauthorized();

        const appeals = await response.json();

        appeals.forEach(appeal => {
            const row = document.createElement('tr');
            row.innerHTML = `
                <td class="px-6 py-4 text-sm font-medium text-gray-900">${appeal.player}</td>
                <td class="px-6 py-4 text-sm text-gray-500">${appeal.appeal.reason || ''}</td>
                <td class="px-6 py-4 text-sm text-gray-500">${new Date(appeal.timestamp * 1000).toLocaleDateString()}</td>
                <td class="px-6 py-4">
                    <span class="px-2 inline-flex text-xs font-semibold rounded-full bg-yellow-100 text-yellow-800">${appeal.status}</span>
                </td>
                <td class="px-6 py-4 text-sm text-gray-500">${appeal.q1 || ''} / ${appeal.q2 || ''}</td>
                <td class="px-6 py-4 text-sm font-medium">
                    ${appeal.status === 'Pending' ? `
                        <button onclick="handleAppeal('${appeal.player}', 'approve')" class="text-green-600 hover:text-green-900 mr-3">Approve</button>
                        <button onclick="handleAppeal('${appeal.player}', 'reject')" class="text-red-600 hover:text-red-900">Reject</button>
                    ` : ''}
                </td>`;
            tbody.appendChild(row);
        });
    } catch (error) {
        console.error('Failed to load appeals:', error);
    }
}

// Handle facility event trigger
let isOfflineMode = false;
let queuedAdminActions = JSON.parse(localStorage.getItem('queuedAdminActions') || '[]');

// Example: API health check
async function checkApiHealth() {
    debug('Checking API health...');
    try {
        const res = await fetch(`${API_BASE_URL}/health`, { cache: "no-store" });
        debug('API health response:', res.status);
        if (!res.ok) throw new Error();
        if (isOfflineMode) {
            isOfflineMode = false;
            debug('API back online, syncing queued admin actions');
            await syncQueuedAdminActions();
        }
    } catch (e) {
        debug('API offline:', e);
        isOfflineMode = true;
        window.location.href = "offline.html";
    }
}

async function syncQueuedAdminActions() {
    if (queuedAdminActions.length === 0) return;
    for (const action of queuedAdminActions) {
        try {
            await fetch(`${API_BASE_URL}/admin-actions`, {
                method: 'POST',
                headers: getAuthHeaders(),
                body: JSON.stringify(action)
            });
        } catch {}
    }
    queuedAdminActions = [];
    localStorage.removeItem('queuedAdminActions');
}

function triggerEvent(eventType) {
    const eventMap = {
        'lockdown': 'Lockdown',
        'radiation': 'RadiationLeak',
        'blackout': 'Blackout',
        'core-warning': 'CoreWarning',
        'core-critical': 'CoreCritical',
        'core-meltdown': 'CoreMeltdown'
    };
    const mappedEvent = eventMap[eventType] || eventType;
    const action = {
        action: mappedEvent,
        timestamp: Date.now()
    };

    if (isOfflineMode) {
        // Only allow admins
        const token = localStorage.getItem('token');
        if (!token) {
            alert('Offline: Only admins can use controls.');
            return;
        }
        const payload = JSON.parse(atob(token.split('.')[1]));
        if (payload.type !== 'Admin') {
            alert('Offline: Only admins can use controls.');
            return;
        }
        queuedAdminActions.push(action);
        localStorage.setItem('queuedAdminActions', JSON.stringify(queuedAdminActions));
        alert('Server offline. Action queued and will be applied when online.');
        return;
    }

    fetch(`${API_BASE_URL}/admin-actions`, {
        method: 'POST',
        headers: getAuthHeaders(),
        body: JSON.stringify(action)
    }).then(loadEvents).catch(console.error);
}

// Handle appeal action
function handleAppeal(id, action) {
    fetch(`${API_BASE_URL}/appeals/update`, {
        method: 'POST',
        headers: getAuthHeaders(),
        body: JSON.stringify({ id, action })
    }).then(loadAppeals).catch(console.error);
}

// Redirect to login if unauthorized
function handleUnauthorized() {
    alert('Session expired. Please log in again.');
    localStorage.removeItem('token');
    location.reload();
}

// DOM ready init
document.addEventListener('DOMContentLoaded', () => {
    if (!localStorage.getItem('token')) {
        document.getElementById('loginSection').classList.remove('hidden');
    } else {
        document.getElementById('loginSection').classList.add('hidden');
        document.getElementById('dashboardSection').classList.remove('hidden');
        loadInitialData();
        showPanel('events');
    }

    // Registration/Login toggle
    const loginForm = document.getElementById('loginForm');
    const registerForm = document.getElementById('registerForm');
    const showLoginBtn = document.getElementById('showLoginBtn');
    const showRegisterBtn = document.getElementById('showRegisterBtn');

    showLoginBtn.onclick = () => {
        registerForm.classList.add('animate__fadeOut');
        setTimeout(() => {
            registerForm.classList.add('hidden');
            loginForm.classList.remove('hidden');
            loginForm.classList.remove('animate__fadeOut');
            loginForm.classList.add('animate__fadeIn');
        }, 300);
    };
    showRegisterBtn.onclick = () => {
        loginForm.classList.add('animate__fadeOut');
        setTimeout(() => {
            loginForm.classList.add('hidden');
            registerForm.classList.remove('hidden');
            registerForm.classList.remove('animate__fadeOut');
            registerForm.classList.add('animate__fadeIn');
        }, 300);
    };

    // Registration handler
    registerForm.onsubmit = async (e) => {
        e.preventDefault();
        const username = document.getElementById('regUsername').value.trim();
        const password = document.getElementById('regPassword').value.trim();
        try {
            const res = await fetch(`${API_BASE_URL}/register`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ username, password, type: "User" })
            });
            const data = await res.json();
            if (res.ok) {
                alert('Registration successful! You can now log in.');
                showLoginBtn.click();
            } else {
                alert(data.error || 'Registration failed.');
            }
        } catch {
            alert('Registration failed.');
        }
    };
});

// Periodic health check
setInterval(checkApiHealth, 10000);
checkApiHealth();

// Add registration (for demo, you can add a registration form and call this)
async function registerUser(username, password, type) {
    const response = await fetch(`${API_BASE_URL}/register`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ username, password, type })
    });
    return response.json();
}

// Admin: create user (call from admin panel)
async function adminCreateUser(username, type) {
    const response = await fetch(`${API_BASE_URL}/users/create`, {
        method: 'POST',
        headers: getAuthHeaders(),
        body: JSON.stringify({ username, type })
    });
    return response.json();
}
