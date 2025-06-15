-- RemoteEvents.lua

-- This script should be placed in ReplicatedStorage

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folder to organize remote events
local RemoteFolder = Instance.new("Folder")
RemoteFolder.Name = "RemoteEvents"
RemoteFolder.Parent = ReplicatedStorage

-- Lockdown System
local LockdownRequest = Instance.new("RemoteEvent")
LockdownRequest.Name = "LockdownRequest"
LockdownRequest.Parent = RemoteFolder

local LockdownStatus = Instance.new("RemoteEvent")
LockdownStatus.Name = "LockdownStatus"
LockdownStatus.Parent = RemoteFolder

-- XP System
local XPChanged = Instance.new("RemoteEvent")
XPChanged.Name = "XPChanged"
XPChanged.Parent = RemoteFolder

-- Achievements
local AchievementUnlocked = Instance.new("RemoteEvent")
AchievementUnlocked.Name = "AchievementUnlocked"
AchievementUnlocked.Parent = RemoteFolder

-- Core Reactor System
local CoreStatusChanged = Instance.new("RemoteEvent")
CoreStatusChanged.Name = "CoreStatusChanged"
CoreStatusChanged.Parent = RemoteFolder

-- Admin Panel
local AdminCommand = Instance.new("RemoteEvent")
AdminCommand.Name = "AdminCommand"
AdminCommand.Parent = RemoteFolder

-- Suit System
local EquipSuit = Instance.new("RemoteEvent")
EquipSuit.Name = "EquipSuit"
EquipSuit.Parent = RemoteFolder

local RemoveSuit = Instance.new("RemoteEvent")
RemoveSuit.Name = "RemoveSuit"
RemoveSuit.Parent = RemoteFolder

-- Access / Keycard
local AccessRequest = Instance.new("RemoteFunction")
AccessRequest.Name = "AccessRequest"
AccessRequest.Parent = RemoteFolder

-- Event Triggers (e.g. map destruction, system warnings)
local TriggerEvent = Instance.new("RemoteEvent")
TriggerEvent.Name = "TriggerEvent"
TriggerEvent.Parent = RemoteFolder

print("[RemoteEvents] All remote events initialized successfully.")
