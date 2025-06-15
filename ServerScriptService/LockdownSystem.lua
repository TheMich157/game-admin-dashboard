-- LockdownSystem.lua
-- Riadenie lockdown stavu a kontroly prístupov

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local LockdownStatusEvent = RemoteEvents:WaitForChild("LockdownStatus") -- Informuje klientov o stave lockdownu
local GlobalMessage = RemoteEvents:WaitForChild("GlobalSystemMessage")

-- Stav lockdownu
local lockdownActive = false

-- Trackovanie, ktorí Commanderi požiadali o lockdown
local lockdownRequests = {}

-- Minimálny rank pre Commanderov na lockdown
local MIN_LOCKDOWN_RANK = 4 -- Major a vyššie, predpokladám ranky od 1 do 6

-- Pomocná funkcia na získanie ranku hráča (musíš prispôsobiť podľa svojho systému)
local function getPlayerRank(player)
	-- Príklad: rank uložený v leaderstats alebo module
	if player:FindFirstChild("leaderstats") and player.leaderstats:FindFirstChild("Rank") then
		return player.leaderstats.Rank.Value
	end
	return 0
end

-- Pomocná funkcia na získanie role hráča (Security, Commander, Scientist)
local function getPlayerRole(player)
	if player:FindFirstChild("leaderstats") and player.leaderstats:FindFirstChild("Role") then
		return player.leaderstats.Role.Value
	end
	return "Unknown"
end

-- Overenie, či môže hráč žiadať lockdown
local function canRequestLockdown(player)
	local role = getPlayerRole(player)
	local rank = getPlayerRank(player)
	return role == "Commander" and rank >= MIN_LOCKDOWN_RANK
end

-- Aktualizuj stav lockdownu na základe žiadostí
local function updateLockdownState()
	local count = 0
	for _, _ in pairs(lockdownRequests) do
		count += 1
	end

	if not lockdownActive and count >= 2 then
		-- Aktivuj lockdown
		lockdownActive = true
		GlobalMessage:FireAllClients("[LOCKDOWN] Lockdown initiated by Commanders.")
		LockdownStatusEvent:FireAllClients(true)
		activateLockdownDoors()
	elseif lockdownActive and count < 2 then
		-- Lockdown sa vypne ak počet žiadostí klesne pod 2
		lockdownActive = false
		GlobalMessage:FireAllClients("[LOCKDOWN] Lockdown lifted.")
		LockdownStatusEvent:FireAllClients(false)
		deactivateLockdownDoors()
	end
end

-- Zamknutie všetkých dverí (nastavenie keycard lock)
function activateLockdownDoors()
	for _, door in pairs(Workspace:GetDescendants()) do
		if door:IsA("BasePart") and door:FindFirstChild("KeycardLevel") then
			door:SetAttribute("Locked", true)
		end
	end
	print("[LockdownSystem] All doors locked.")
end

-- Odomknutie všetkých dverí
function deactivateLockdownDoors()
	for _, door in pairs(Workspace:GetDescendants()) do
		if door:IsA("BasePart") and door:FindFirstChild("KeycardLevel") then
			door:SetAttribute("Locked", false)
		end
	end
	print("[LockdownSystem] All doors unlocked.")
end

-- Hráč žiada lockdown
local function requestLockdown(player)
	if not canRequestLockdown(player) then
		return false, "You do not have permission to request lockdown."
	end

	lockdownRequests[player.UserId] = true
	updateLockdownState()
	return true, "Lockdown request registered."
end

-- Hráč stiahol žiadosť lockdownu (napríklad odvolal)
local function cancelLockdownRequest(player)
	lockdownRequests[player.UserId] = nil
	updateLockdownState()
end

-- Odstránenie hráča z lockdown žiadostí pri odchode
Players.PlayerRemoving:Connect(function(player)
	cancelLockdownRequest(player)
end)

-- Externý API pre iné skripty
local LockdownSystem = {}

LockdownSystem.RequestLockdown = requestLockdown
LockdownSystem.CancelRequest = cancelLockdownRequest
LockdownSystem.ActivateLockdown = function()
	-- Nútená aktivácia lockdownu (napríklad admin)
	lockdownRequests = {}
	lockdownActive = true
	GlobalMessage:FireAllClients("[LOCKDOWN] Lockdown forcibly activated.")
	LockdownStatusEvent:FireAllClients(true)
	activateLockdownDoors()
end
LockdownSystem.DeactivateLockdown = function()
	lockdownRequests = {}
	lockdownActive = false
	GlobalMessage:FireAllClients("[LOCKDOWN] Lockdown forcibly lifted.")
	LockdownStatusEvent:FireAllClients(false)
	deactivateLockdownDoors()
end
LockdownSystem.IsActive = function()
	return lockdownActive
end

return LockdownSystem
