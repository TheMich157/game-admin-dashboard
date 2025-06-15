-- GameLogManager.lua
-- Centralized logging for game events and admin actions

local HttpService = game:GetService("HttpService")
local LOG_URL = "http://localhost:3000/api/logs" -- Replace with actual dashboard URL

local GameLogManager = {}

function GameLogManager:logEvent(eventName, details)
    local payload = HttpService:JSONEncode({
        type = "Event",
        eventName = eventName,
        details = details,
        timestamp = os.time()
    })

    local success, response = pcall(function()
        return HttpService:PostAsync(LOG_URL, payload, Enum.HttpContentType.ApplicationJson)
    end)
    if not success then
        warn("[GameLogManager] Failed to log event:", eventName, response)
    end
end

function GameLogManager:logAdminAction(adminPlayer, action, details)
    local payload = HttpService:JSONEncode({
        type = "AdminAction",
        admin = adminPlayer.Name,
        action = action,
        details = details,
        timestamp = os.time()
    })

    local success, response = pcall(function()
        return HttpService:PostAsync(LOG_URL, payload, Enum.HttpContentType.ApplicationJson)
    end)
    if not success then
        warn("[GameLogManager] Failed to log admin action:", action, response)
    end
end

function GameLogManager:logBanAppeal(player, appealData)
    local payload = HttpService:JSONEncode({
        type = "BanAppeal",
        player = player.Name,
        appeal = appealData,
        timestamp = os.time()
    })

    local success, response = pcall(function()
        return HttpService:PostAsync(LOG_URL, payload, Enum.HttpContentType.ApplicationJson)
    end)
    if not success then
        warn("[GameLogManager] Failed to log ban appeal from player:", player.Name, response)
    end
end

return GameLogManager
