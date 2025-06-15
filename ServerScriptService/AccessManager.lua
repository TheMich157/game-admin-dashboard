-- AccessManager.lua
-- Server-side handler for verifying keycard access levels

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local remoteFolder = ReplicatedStorage:WaitForChild("RemoteEvents")
local accessRequest = remoteFolder:WaitForChild("AccessRequest")

local GameLogManager = require(script.Parent:WaitForChild("GameLogManager"))

-- Dvere majú priradenú hodnotu: RequiredAccessLevel (IntValue)
-- Hráči majú: IntValue "KeycardLevel" v leaderstats alebo Humanoid

-- Príklad:
-- player.leaderstats.KeycardLevel.Value

local function getPlayerAccessLevel(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats and leaderstats:FindFirstChild("KeycardLevel") then
		return leaderstats.KeycardLevel.Value
	end
	return 0
end

local function logAdminAction(adminPlayer, action, details)
	GameLogManager:logAdminAction(adminPlayer, action, details)
end

-- Handler pre AccessRequest RemoteFunction
accessRequest.OnServerInvoke = function(player, door)
	if not player or not door or not door:IsA("Model") then return false end

	local requiredLevel = door:FindFirstChild("RequiredAccessLevel")
	if not requiredLevel or not requiredLevel:IsA("IntValue") then return false end

	local playerAccess = getPlayerAccessLevel(player)

	if playerAccess >= requiredLevel.Value then
		-- Access granted
		print("[AccessManager] Access granted to", player.Name, "for door:", door.Name)
		-- Log access granted
		logAdminAction(player, "AccessGranted", {door = door.Name})
		return true
	else
		-- Access denied
		print("[AccessManager] Access denied to", player.Name, "for door:", door.Name)
		-- Log access denied
		logAdminAction(player, "AccessDenied", {door = door.Name})
		return false
	end
end
