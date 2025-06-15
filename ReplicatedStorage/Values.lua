-- Shared values setup here
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folder to organize shared values
local ValuesFolder = Instance.new("Folder")
ValuesFolder.Name = "GameValues"
ValuesFolder.Parent = ReplicatedStorage

local CoreStatus = Instance.new("StringValue")
CoreStatus.Name = "CoreStatus"
CoreStatus.Value = "Offline" -- Initial status
CoreStatus.Parent = ValuesFolder

local LockdownActive = Instance.new("BoolValue")
LockdownActive.Name = "LockdownActive"
LockdownActive.Value = false -- Initial lockdown status
LockdownActive.Parent = ValuesFolder

local GLobalXPMultiplier = Instance.new("NumberValue")
GLobalXPMultiplier.Name = "GlobalXPMultiplier"
GLobalXPMultiplier.Value = 1 -- Initial XP multiplier
GLobalXPMultiplier.Parent = ValuesFolder

local ActiveEvent = Instance.new("StringValue")
ActiveEvent.Name = "ActiveEvent"
ActiveEvent.Value = "None" -- Initial active event
ActiveEvent.Parent = ValuesFolder

local CommandOverride = Instance.new("BoolValue")
CommandOverride.Name = "CommandOverride"
CommandOverride.Value = false -- Initial command override status
CommandOverride.Parent = ValuesFolder

local MapIntegrity = Instance.new("NumberValue")
MapIntegrity.Name = "MapIntegrity"
MapIntegrity.Value = 100 -- Initial map integrity
MapIntegrity.Parent = ValuesFolder

print("[Values] Shared values initialized successfully.")