(() => {
    const API_BASE_URL = 'http://localhost:3000/api';

    function debug(...args) {
        console.log('[DEBUG]', ...args);
    }

    const loginForm = document.getElementById('loginForm');
    const registerForm = document.getElementById('registerForm');
    const showLoginBtn = document.getElementById('showLoginBtn');
    const showRegisterBtn = document.getElementById('showRegisterBtn');
    const loginMessage = document.getElementById('loginMessage');
    const registerMessage = document.getElementById('registerMessage');

    showLoginBtn.onclick = () => {
        showLoginBtn.classList.add('active');
        showRegisterBtn.classList.remove('active');
        loginForm.classList.remove('hidden');
        registerForm.classList.add('hidden');
    };
    showRegisterBtn.onclick = () => {
        showRegisterBtn.classList.add('active');
        showLoginBtn.classList.remove('active');
        registerForm.classList.remove('hidden');
        loginForm.classList.add('hidden');
    };

    loginForm.onsubmit = async (event) => {
        event.preventDefault();
        const username = document.getElementById('username').value.trim();
        const password = document.getElementById('password').value.trim();
        loginMessage.textContent = "";
        debug('Login submit', username);

        try {
            const res = await fetch(`${API_BASE_URL}/login`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ username, password })
            });
            const data = await res.json();
            if (res.ok && data.token) {
                localStorage.setItem('token', data.token);
                // Redirect based on user type
                if (data.type === 'Admin') {
                    window.location.href = "admin-dashboard.html";
                } else {
                    window.location.href = "user-dashboard.html";
                }
            } else {
                loginMessage.textContent = data.error || 'Login failed.';
            }
        } catch (err) {
            loginMessage.textContent = 'Login failed. Server error.';
        }
    };

    registerForm.onsubmit = async (e) => {
        e.preventDefault();
        const username = document.getElementById('regUsername').value.trim();
        const password = document.getElementById('regPassword').value.trim();
        registerMessage.textContent = "";
        try {
            const res = await fetch(`${API_BASE_URL}/register`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ username, password, type: "User" })
            });
            const data = await res.json();
            if (res.ok) {
                registerMessage.textContent = 'Registration successful! You can now log in.';
                showLoginBtn.click();
            } else {
                registerMessage.textContent = data.error || 'Registration failed.';
            }
        } catch (err) {
            registerMessage.textContent = 'Registration failed.';
        }
    };

    if (window.location.search) {
        window.history.replaceState({}, document.title, window.location.pathname);
    }
})();