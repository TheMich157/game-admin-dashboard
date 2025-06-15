const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const path = require('path');

const app = express();
const port = 3000;

app.use(cors());
app.use(bodyParser.json());

// Initialize in-memory storage
let events = [];
let appeals = [];
let adminActions = [];

// Serve static files from current directory
app.use(express.static(path.join(__dirname)));

// Endpoint to receive logs
app.post('/api/logs', (req, res) => {
    const log = req.body;
    if (!log || !log.type) {
        return res.status(400).send('Invalid log format');
    }

    switch (log.type) {
        case 'Event':
            events.unshift(log);
            if (events.length > 100) events.pop();
            break;
        case 'AdminAction':
            adminActions.unshift(log);
            if (adminActions.length > 100) adminActions.pop();
            break;
        case 'BanAppeal':
            appeals.unshift(log);
            if (appeals.length > 100) appeals.pop();
            break;
        default:
            return res.status(400).send('Unknown log type');
    }

    res.status(200).send('Log received');
});

// Endpoint to get events
app.get('/api/events', (req, res) => {
    res.json(events);
});

// Endpoint to get appeals
app.get('/api/appeals', (req, res) => {
    res.json(appeals);
});

// Endpoint to get admin actions
app.get('/api/admin-actions', (req, res) => {
    res.json(adminActions);
});

// Serve index.html at root
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'index.html'));
});

app.listen(port, () => {
    console.log("API server listening at http://localhost:" + port);
});