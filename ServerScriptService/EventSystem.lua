-- EventSystem.lua
-- Central manager for triggered facility-wide events

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local TriggerEvent = RemoteEvents:WaitForChild("TriggerEvent")
local MessageEvent = RemoteEvents:WaitForChild("GlobalSystemMessage")

-- Aktívne eventy
local ActiveEvents = {}

-- Funkcia na aktiváciu eventu
local function activateEvent(eventName, initiator)
	if ActiveEvents[eventName] then
		warn("[EventSystem] Event už aktívny:", eventName)
		return
	end

	ActiveEvents[eventName] = true
	print("[EventSystem] Aktivovaný event:", eventName)

	-- Klientské vizuály
	TriggerEvent:FireAllClients(eventName)

	-- Serverová logika podľa typu eventu
	if eventName == "Lockdown" then
		-- Lockdown: uzamkne všetky dvere
		local LockdownSystem = require(script.Parent.LockdownSystem)
		LockdownSystem.ActivateLockdown()

		MessageEvent:FireAllClients("[SECURITY] Facility is now under LOCKDOWN.")
		
	elseif eventName == "RadiationLeak" then
		MessageEvent:FireAllClients("[EMERGENCY] Radiation leak detected in Core Sector!")
		-- Môžeš tu spustiť Damage Loop

	elseif eventName == "OverrideCore" then
		local CoreControl = _G.CoreControl
		CoreControl.SetState("Overheat")

		MessageEvent:FireAllClients("[CORE] Manual override issued by Command authority.")
		
	elseif eventName == "EmergencySuits" then
		MessageEvent:FireAllClients("[ACCESS] Emergency Suit Lockers are now available.")
		-- Otvorenie skríň s ochranným vybavením

	elseif eventName == "Blackout" then
		MessageEvent:FireAllClients("[SYSTEM] Power failure across the facility.")
		-- Zhasnú svetlá, aktivuj záložné systémy
	end

	-- Voliteľné: časovaný reset
	task.delay(60, function()
		ActiveEvents[eventName] = nil
	end)
end

-- Prístup z iných skriptov
_G.EventSystem = {
	Activate = activateEvent,
	IsActive = function(eventName)
		return ActiveEvents[eventName] or false
	end
}
_G.EventSystem.Activate("Lockdown")
_G.EventSystem.Activate("Blackout")
_G.EventSystem.Activate("RadiationLeak")
_G.EventSystem.Activate("EmergencySuits")
_G.EventSystem.Activate("OverrideCore")
_G.EventSystem.Activate("CoreMeltdown")
_G.EventSystem.Activate("CoreDestruction")
-- Debug: vypíš všetky aktívne eventy
print("[EventSystem] Aktívne eventy:", table.concat(table.keys(ActiveEvents), ", "))

