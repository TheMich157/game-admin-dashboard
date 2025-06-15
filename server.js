require('dotenv').config();
const express = require('express');
const cors = require('cors');
const rateLimit = require('express-rate-limit');
const validator = require('validator');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const Database = require('better-sqlite3');
const fetch = require('node-fetch');
const path = require('path');
const fs = require('fs');

const app = express();
const db = new Database('gameadmin.sqlite');
const JWT_SECRET = process.env.JWT_SECRET || 'supersecretjwtkey';
const PORT = process.env.PORT || 3000;

// Debug helper
function debug(...args) { console.log('[DEBUG]', ...args); }

// Middleware
app.use(express.json());
app.use(cors({
    origin: ['http://localhost:3000'],
    credentials: true
}));
app.use('/api/', rateLimit({
    windowMs: 15 * 60 * 1000,
    max: 100,
    standardHeaders: true,
    legacyHeaders: false,
}));

// JWT middleware
function requireJwtAuth(req, res, next) {
    const auth = req.headers.authorization;
    if (!auth) return res.status(401).json({ error: 'No token' });
    try {
        req.user = jwt.verify(auth.split(' ')[1], JWT_SECRET);
        next();
    } catch {
        res.status(401).json({ error: 'Invalid token' });
    }
}
function requireJwtAdmin(req, res, next) {
    if (req.user.type !== 'Admin') return res.status(403).json({ error: 'Admins only' });
    next();
}

// --- DB INIT (run once if needed) ---
db.prepare(`
CREATE TABLE IF NOT EXISTS users (
    username TEXT PRIMARY KEY,
    password TEXT NOT NULL,
    type TEXT NOT NULL
)`).run();
db.prepare(`
CREATE TABLE IF NOT EXISTS bans (
    robloxUsername TEXT PRIMARY KEY
)`).run();
db.prepare(`
CREATE TABLE IF NOT EXISTS appeals (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    player TEXT NOT NULL,
    robloxUsername TEXT NOT NULL,
    q1 TEXT NOT NULL,
    q2 TEXT NOT NULL,
    timestamp INTEGER NOT NULL,
    status TEXT NOT NULL
)`).run();
// Ensure at least one admin exists
const adminExists = db.prepare('SELECT 1 FROM users WHERE type = ?').get('Admin');
if (!adminExists) {
    db.prepare('INSERT INTO users (username, password, type) VALUES (?, ?, ?)').run(
        'admin', bcrypt.hashSync('AdminPass123!', 10), 'Admin'
    );
    debug('Default admin created: admin/AdminPass123!');
}

// --- API ROUTES ---

// Health check
app.get('/api/health', (req, res) => res.json({ ok: true }));

// Registration
app.post('/api/register', (req, res) => {
    debug('Register attempt:', req.body);
    const { username, password, type } = req.body;
    if (!username || !password || type !== 'User') {
        return res.status(400).json({ error: 'Invalid registration' });
    }
    if (!validator.isAlphanumeric(username) || username.length < 3 || username.length > 20) {
        return res.status(400).json({ error: 'Invalid username' });
    }
    if (!validator.isStrongPassword(password, { minLength: 8 })) {
        return res.status(400).json({ error: 'Password too weak' });
    }
    const exists = db.prepare('SELECT 1 FROM users WHERE username = ?').get(username);
    if (exists) return res.status(400).json({ error: 'Username taken' });
    db.prepare('INSERT INTO users (username, password, type) VALUES (?, ?, ?)').run(
        username, bcrypt.hashSync(password, 10), 'User'
    );
    res.status(201).json({ message: 'Registered' });
});

// Login
app.post('/api/login', (req, res) => {
    const { username, password } = req.body;
    if (!username || !password) return res.status(400).json({ error: 'Missing credentials' });
    const user = db.prepare('SELECT * FROM users WHERE username = ?').get(username);
    if (!user) return res.status(401).json({ error: 'Invalid username or password' });
    if (!bcrypt.compareSync(password, user.password)) {
        return res.status(401).json({ error: 'Invalid username or password' });
    }
    const token = jwt.sign({ username: user.username, type: user.type }, JWT_SECRET, { expiresIn: '12h' });
    res.json({ token, type: user.type });
});

// Get current user
app.get('/api/me', requireJwtAuth, (req, res) => {
    res.json({ username: req.user.username, type: req.user.type });
});

// Ban status (for web and Roblox)
app.get('/api/banstatus/:username', (req, res) => {
    const username = req.params.username.toLowerCase();
    const banned = !!db.prepare('SELECT 1 FROM bans WHERE robloxUsername = ?').get(username);
    res.json({ banned });
});

app.post('/api/game/ban', (req, res) => {
    const { robloxUsername } = req.body;
    debug('Ban request from game:', robloxUsername);
    if (!robloxUsername) return res.status(400).json({ error: 'Missing username' });
    db.prepare('INSERT OR IGNORE INTO bans (robloxUsername) VALUES (?)').run(robloxUsername.toLowerCase());
    res.json({ success: true });
});
app.post('/api/game/unban', (req, res) => {
    const { robloxUsername } = req.body;
    debug('Unban request from game:', robloxUsername);
    if (!robloxUsername) return res.status(400).json({ error: 'Missing username' });
    db.prepare('DELETE FROM bans WHERE robloxUsername = ?').run(robloxUsername.toLowerCase());
    res.json({ success: true });
});

// Appeals
app.post('/api/appeals', requireJwtAuth, (req, res) => {
    if (req.user.type !== 'User') return res.status(403).json({ error: 'Only users can appeal' });
    const { robloxUsername, q1, q2 } = req.body;
    if (!robloxUsername || !q1 || !q2) {
        return res.status(400).json({ error: 'All fields required' });
    }
    const banned = !!db.prepare('SELECT 1 FROM bans WHERE robloxUsername = ?').get(robloxUsername.toLowerCase());
    if (!banned) return res.status(400).json({ error: 'User is not banned' });
    db.prepare(`
        INSERT INTO appeals (player, robloxUsername, q1, q2, timestamp, status)
        VALUES (?, ?, ?, ?, ?, ?)
    `).run(req.user.username, robloxUsername, q1, q2, Math.floor(Date.now() / 1000), 'Pending');
    res.status(201).json({ message: 'Appeal submitted' });
});
app.get('/api/appeals', requireJwtAuth, (req, res) => {
    if (req.user.type === 'Admin') {
        const all = db.prepare('SELECT * FROM appeals ORDER BY timestamp DESC').all();
        return res.json(all);
    }
    const userAppeals = db.prepare('SELECT * FROM appeals WHERE player = ? ORDER BY timestamp DESC').all(req.user.username);
    res.json(userAppeals);
});
app.post('/api/appeals/update', requireJwtAuth, requireJwtAdmin, async (req, res) => {
    const { id, action } = req.body;
    const appeal = db.prepare('SELECT * FROM appeals WHERE id = ? AND status = ?').get(id, 'Pending');
    if (!appeal) return res.status(404).json({ error: 'Appeal not found or already processed.' });

    if (action === 'approve') {
        db.prepare('UPDATE appeals SET status = ? WHERE id = ?').run('Approved', appeal.id);
        // Unban the user in the game
        try {
            await fetch('http://localhost:3000/api/game/unban', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ robloxUsername: appeal.robloxUsername })
            });
            debug('Unban triggered for', appeal.robloxUsername);
        } catch (e) {
            debug('Failed to unban in game:', e);
        }
    } else if (action === 'reject') {
        db.prepare('UPDATE appeals SET status = ? WHERE id = ?').run('Rejected', appeal.id);
    }
    res.json({ success: true });
});

// Admin actions (stub)
app.post('/api/admin-actions', requireJwtAuth, requireJwtAdmin, (req, res) => {
    // Implement your admin actions here (e.g., trigger events, lockdown, etc.)
    debug('Admin action:', req.body);
    // For now, just return success
    res.json({ success: true });
});

// Serve static files (frontend)
app.use(express.static(path.join(__dirname)));

// Fallback: serve index.html for unknown routes (SPA support)
app.get('*', (req, res) => {
    res.sendFile(path.resolve(__dirname, 'index.html'));
});

// Start server
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
