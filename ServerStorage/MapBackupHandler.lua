local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")

local MapBackupHandler = {}

-- Názov priečinka v ServerStorage pre zálohu
local BACKUP_FOLDER_NAME = "MapBackup"

-- Uloží aktuálny stav mapy
function MapBackupHandler:BackupMap()
	local backupFolder = ServerStorage:FindFirstChild(BACKUP_FOLDER_NAME)
	if backupFolder then
		backupFolder:Destroy()
	end

	backupFolder = Instance.new("Folder")
	backupFolder.Name = BACKUP_FOLDER_NAME
	backupFolder.Parent = ServerStorage

	for _, item in ipairs(Workspace:GetChildren()) do
		if item:IsA("Model") or item:IsA("BasePart") then
			local clone = item:Clone()
			clone.Parent = backupFolder
		end
	end

	print("[MapBackupHandler] Map backup created.")
end

-- Zničí mapu (napr. meltdown)
function MapBackupHandler:DestroyMap()
	for _, item in ipairs(Workspace:GetChildren()) do
		if item:IsA("Model") or item:IsA("BasePart") then
			item:Destroy()
		end
	end

	print("[MapBackupHandler] Map destroyed.")
end

-- Obnoví mapu zo zálohy
function MapBackupHandler:RestoreMap()
	local backupFolder = ServerStorage:FindFirstChild(BACKUP_FOLDER_NAME)
	if not backupFolder then
		warn("[MapBackupHandler] No backup found!")
		return
	end

	self:DestroyMap()

	for _, item in ipairs(backupFolder:GetChildren()) do
		local clone = item:Clone()
		clone.Parent = Workspace
	end

	print("[MapBackupHandler] Map restored from backup.")
end

return MapBackupHandler
