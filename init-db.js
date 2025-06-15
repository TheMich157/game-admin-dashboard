const Database = require('better-sqlite3');
const db = new Database('gameadmin.sqlite');

// Users table
db.prepare(`
CREATE TABLE IF NOT EXISTS users (
    username TEXT PRIMARY KEY,
    password TEXT NOT NULL,
    type TEXT NOT NULL
)`).run();

// Bans table
db.prepare(`
CREATE TABLE IF NOT EXISTS bans (
    robloxUsername TEXT PRIMARY KEY
)`).run();

// Appeals table
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

console.log('Database initialized.');