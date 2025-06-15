-- Roblox: When banning a user
local HttpService = game:GetService("HttpService")
local url = "http://localhost:3000/api/game/ban"
local function banUser(username)
    local data = { robloxUsername = username }
    HttpService:PostAsync(url, HttpService:JSONEncode(data), Enum.HttpContentType.ApplicationJson)
end

-- Roblox: When unbanning a user
local urlUnban = "http://localhost:3000/api/game/unban"
local function unbanUser(username)
    local data = { robloxUsername = username }
    HttpService:PostAsync(urlUnban, HttpService:JSONEncode(data), Enum.HttpContentType.ApplicationJson)
end