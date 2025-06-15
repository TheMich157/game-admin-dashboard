// Mock data for testing
const mockEvents = [
    { time: '2024-01-20 10:30:15', event: 'Lockdown', details: 'Manual trigger by admin', status: 'Active' },
    { time: '2024-01-20 10:15:00', event: 'Core Warning', details: 'Temperature exceeding normal levels', status: 'Resolved' },
    { time: '2024-01-20 09:45:30', event: 'Radiation Leak', details: 'Sector B containment breach', status: 'Active' }
];

const mockAppeals = [
    { username: 'Player123', reason: 'Wrongful ban - mistaken identity', date: '2024-01-19', status: 'Pending' },
    { username: 'Gamer456', reason: 'False report by other player', date: '2024-01-18', status: 'Approved' },
    { username: 'User789', reason: 'Accidental violation', date: '2024-01-17', status: 'Rejected' }
];

// Login handling
document.addEventListener('DOMContentLoaded', () => {
    const loginForm = document.getElementById('loginForm');
    
    loginForm.addEventListener('submit', (event) => {
        event.preventDefault();
        const username = document.getElementById('username').value;
        const password = document.getElementById('password').value;

        // Mock authentication - replace with actual authentication
        if (username === 'admin' && password === 'admin') {
            document.getElementById('loginSection').classList.add('hidden');
            document.getElementById('dashboardSection').classList.remove('hidden');
            loadInitialData();
            showPanel('events'); // Show events panel by default
        } else {
            alert('Invalid credentials');
        }
    });
});

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

// Load events into table
function loadEvents() {
    const tbody = document.getElementById('eventsTableBody');
    tbody.innerHTML = '';

    mockEvents.forEach(event => {
        const row = document.createElement('tr');
        row.innerHTML = `
            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">${event.time}</td>
            <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">${event.event}</td>
            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">${event.details}</td>
            <td class="px-6 py-4 whitespace-nowrap">
                <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full 
                    ${event.status === 'Active' ? 'bg-red-100 text-red-800' : 'bg-green-100 text-green-800'}">
                    ${event.status}
                </span>
            </td>
        `;
        tbody.appendChild(row);
    });
}

// Load appeals into table
function loadAppeals() {
    const tbody = document.getElementById('appealsTableBody');
    tbody.innerHTML = '';

    mockAppeals.forEach(appeal => {
        const row = document.createElement('tr');
        row.innerHTML = `
            <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">${appeal.username}</td>
            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">${appeal.reason}</td>
            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">${appeal.date}</td>
            <td class="px-6 py-4 whitespace-nowrap">
                <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full 
                    ${getStatusColor(appeal.status)}">
                    ${appeal.status}
                </span>
            </td>
            <td class="px-6 py-4 whitespace-nowrap text-sm font-medium">
                ${appeal.status === 'Pending' ? `
                    <button onclick="handleAppeal('${appeal.username}', 'approve')" 
                        class="text-green-600 hover:text-green-900 mr-3">
                        Approve
                    </button>
                    <button onclick="handleAppeal('${appeal.username}', 'reject')" 
                        class="text-red-600 hover:text-red-900">
                        Reject
                    </button>
                ` : ''}
            </td>
        `;
        tbody.appendChild(row);
    });
}

// Get status color for appeals
function getStatusColor(status) {
    switch(status) {
        case 'Pending':
            return 'bg-yellow-100 text-yellow-800';
        case 'Approved':
            return 'bg-green-100 text-green-800';
        case 'Rejected':
            return 'bg-red-100 text-red-800';
        default:
            return 'bg-gray-100 text-gray-800';
    }
}

// Handle facility events
function triggerEvent(eventType) {
    const eventDetails = {
        time: new Date().toLocaleString(),
        event: eventType.charAt(0).toUpperCase() + eventType.slice(1),
        details: `Manually triggered by admin`,
        status: 'Active'
    };

    mockEvents.unshift(eventDetails);
    loadEvents();
}

// Handle appeal actions
function handleAppeal(username, action) {
    const appeal = mockAppeals.find(a => a.username === username);
    if (appeal) {
        appeal.status = action === 'approve' ? 'Approved' : 'Rejected';
        loadAppeals();
    }
}

// Show events panel by default after login
document.addEventListener('DOMContentLoaded', () => {
    if (!document.getElementById('loginSection').classList.contains('hidden')) {
        showPanel('events');
    }
});
