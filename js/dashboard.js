const API_BASE_URL = 'http://localhost:3000/api';

// Login handling
const initializeLogin = () => {
    const loginForm = document.getElementById('loginForm');
    const loginSection = document.getElementById('loginSection');
    const dashboardSection = document.getElementById('dashboardSection');

    if (!loginForm || !loginSection || !dashboardSection) {
        console.error('Required elements not found');
        return;
    }

    const handleLogin = (event) => {
        event.preventDefault();
        
        const username = document.getElementById('username').value.trim();
        const password = document.getElementById('password').value.trim();

        console.log('Login attempt:', { username });

        if (username === 'admin' && password === 'admin') {
            console.log('Login successful');
            loginSection.classList.add('hidden');
            dashboardSection.classList.remove('hidden');
            loadInitialData();
            showPanel('events');
        } else {
            console.log('Login failed');
            alert('Invalid credentials. Please try again.');
        }
    };

    // Attach submit event listener
    loginForm.addEventListener('submit', handleLogin);
};

// Initialize when DOM is ready
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initializeLogin);
} else {
    initializeLogin();
}

// Panel navigation
function showPanel(panelName) {
    // Hide all panels
    document.getElementById('eventsPanel').classList.add('hidden');
    document.getElementById('adminPanel').classList.add('hidden');
    document.getElementById('appealsPanel').classList.add('hidden');

    // Show selected panel
    document.getElementById(panelName + 'Panel').classList.remove('hidden');
}

// Load initial data
function loadInitialData() {
    loadEvents();
    loadAppeals();
}

// Load events from API
async function loadEvents() {
    const tbody = document.getElementById('eventsTableBody');
    tbody.innerHTML = '';

    try {
        const response = await fetch(\`\${API_BASE_URL}/events\`);
        const events = await response.json();

        events.forEach(event => {
            const row = document.createElement('tr');
            row.innerHTML = \`
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">\${new Date(event.timestamp * 1000).toLocaleString()}</td>
                <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">\${event.eventName}</td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">\${event.details.initiator || ''}</td>
                <td class="px-6 py-4 whitespace-nowrap">
                    <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-red-100 text-red-800">
                        Active
                    </span>
                </td>
            \`;
            tbody.appendChild(row);
        });
    } catch (error) {
        console.error('Failed to load events:', error);
    }
}

// Load appeals from API
async function loadAppeals() {
    const tbody = document.getElementById('appealsTableBody');
    tbody.innerHTML = '';

    try {
        const response = await fetch(\`\${API_BASE_URL}/appeals\`);
        const appeals = await response.json();

        appeals.forEach(appeal => {
            const row = document.createElement('tr');
            row.innerHTML = \`
                <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">\${appeal.player}</td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">\${appeal.appeal.reason || ''}</td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">\${new Date(appeal.timestamp * 1000).toLocaleDateString()}</td>
                <td class="px-6 py-4 whitespace-nowrap">
                    <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-yellow-100 text-yellow-800">
                        \${appeal.status}
                    </span>
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm font-medium">
                    \${appeal.status === 'Pending' ? \`
                        <button onclick="handleAppeal('\${appeal.player}', 'approve')" class="text-green-600 hover:text-green-900 mr-3">Approve</button>
                        <button onclick="handleAppeal('\${appeal.player}', 'reject')" class="text-red-600 hover:text-red-900">Reject</button>
                    \` : ''}
                </td>
            \`;
            tbody.appendChild(row);
        });
    } catch (error) {
        console.error('Failed to load appeals:', error);
    }
}

// Handle facility events
function triggerEvent(eventType) {
    fetch(\`\${API_BASE_URL}/admin-actions\`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: eventType, admin: 'admin', timestamp: Date.now() })
    }).then(() => {
        loadEvents();
    }).catch(console.error);
}

// Handle appeal actions
function handleAppeal(username, action) {
    // Implement API call to update appeal status here
    console.log(\`Appeal \${action} for user: \${username}\`);
    // For demo, just reload appeals
    loadAppeals();
}

// Show events panel by default after login
document.addEventListener('DOMContentLoaded', () => {
    if (!document.getElementById('loginSection').classList.contains('hidden')) {
        showPanel('events');
    }
});
