-- GameLogManager.lua
-- Centralized logging for game events and admin actions

local HttpService = game:GetService("HttpService")
local LOG_URL = "http://localhost:3000/api/logs"
local HEALTH_URL = "http://localhost:3000/api/health"

local GameLogManager = {}
local logQueue = {}

local function isApiOnline()
    local ok, res = pcall(function()
        return HttpService:GetAsync(HEALTH_URL)
    end)
    return ok and res == "OK"
end

local function sendLog(payload)
    if not isApiOnline() then
        table.insert(logQueue, payload)
        warn("[GameLogManager] API offline, log queued.")
        return
    end
    local success, response = pcall(function()
        return HttpService:PostAsync(LOG_URL, payload, Enum.HttpContentType.ApplicationJson)
    end)
    if not success then
        warn("[GameLogManager] Failed to log, queuing:", response)
        table.insert(logQueue, payload)
    end
end

function GameLogManager:logEvent(eventName, details)
    local payload = HttpService:JSONEncode({
        type = "Event",
        eventName = eventName,
        details = details,
        timestamp = os.time()
    })
    sendLog(payload)
end

function GameLogManager:logAdminAction(adminPlayer, action, details)
    local payload = HttpService:JSONEncode({
        type = "AdminAction",
        admin = adminPlayer.Name,
        action = action,
        details = details,
        timestamp = os.time()
    })
    sendLog(payload)
end

function GameLogManager:logBanAppeal(player, appealData)
    local payload = HttpService:JSONEncode({
        type = "BanAppeal",
        player = player.Name,
        appeal = appealData,
        timestamp = os.time()
    })
    sendLog(payload)
end

-- Retry queued logs every 30 seconds
task.spawn(function()
    while true do
        if #logQueue > 0 and isApiOnline() then
            for i = #logQueue, 1, -1 do
                sendLog(logQueue[i])
                table.remove(logQueue, i)
            end
        end
        task.wait(30)
    end
end)

return GameLogManager
