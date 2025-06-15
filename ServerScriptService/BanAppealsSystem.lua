-- BanAppealsSystem.lua
-- Handles player ban appeals and admin review

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local GameLogManager = require(script.Parent:WaitForChild("GameLogManager"))

local BanAppealsSystem = {}

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local SubmitAppealEvent = RemoteEvents:WaitForChild("SubmitBanAppeal")
local AppealStatusUpdateEvent = RemoteEvents:WaitForChild("UpdateAppealStatus")

local appeals = {}

-- Player submits a ban appeal
SubmitAppealEvent.OnServerEvent:Connect(function(player, reason)
    if not reason or reason == "" then return end
    local appealId = tostring(player.UserId) .. "-" .. tostring(os.time())
    appeals[appealId] = {
        player = player.Name,
        userId = player.UserId,
        reason = reason,
        status = "Pending",
        submittedAt = os.time()
    }
    GameLogManager:logBanAppeal(player, {appealId = appealId, reason = reason})
    print("[BanAppealsSystem] New ban appeal submitted by", player.Name, "ID:", appealId)
end)

-- Admin updates appeal status
AppealStatusUpdateEvent.OnServerEvent:Connect(function(adminPlayer, appealId, newStatus)
    if not appeals[appealId] then
        warn("[BanAppealsSystem] Invalid appeal ID:", appealId)
        return
    end

    appeals[appealId].status = newStatus
    GameLogManager:logAdminAction(adminPlayer, "BanAppealStatusUpdate", {appealId = appealId, newStatus = newStatus})

    print("[BanAppealsSystem] Appeal", appealId, "status updated to", newStatus, "by", adminPlayer.Name)
end)

-- Public API to get appeals (for admin UI)
function BanAppealsSystem:GetAppeals()
    return appeals
end

return BanAppealsSystem
