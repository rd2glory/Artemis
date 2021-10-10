--[[


░█████╗░██████╗░████████╗███████╗███╗░░░███╗██╗░██████╗
██╔══██╗██╔══██╗╚══██╔══╝██╔════╝████╗░████║██║██╔════╝
███████║██████╔╝░░░██║░░░█████╗░░██╔████╔██║██║╚█████╗░
██╔══██║██╔══██╗░░░██║░░░██╔══╝░░██║╚██╔╝██║██║░╚═══██╗
██║░░██║██║░░██║░░░██║░░░███████╗██║░╚═╝░██║██║██████╔╝
╚═╝░░╚═╝╚═╝░░╚═╝░░░╚═╝░░░╚══════╝╚═╝░░░░░╚═╝╚═╝╚═════╝░

Made by: iamtryingtofindname

The best Da Hood script there is.

]]--

-- Identifier Configurations
local VERSION = "2"
local BETA = false

-- Actual Code
if not game:IsLoaded() then
	game.Loaded:Wait()
end

local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/iamtryingtofindname/Artemis/main/Venyx2.lua"))()

local Artemis = library.new("Artemis ("..(BETA and "b" or "v")..VERSION..")")

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MPS = game:GetService("MarketplaceService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local UIS = game:GetService("UserInputService")

-- General Variables
local player = Players.LocalPlayer

local Camera = workspace.CurrentCamera

local MainEvent = ReplicatedStorage.MainEvent

local DataFolder = player:WaitForChild("DataFolder",180)
local Information = DataFolder:WaitForChild("Information",10)
local CrewValue = Information:FindFirstChild("Crew")
local Crew = CrewValue and tonumber(CrewValue.Value) or 0

local HB = RunService.Heartbeat

-- Private Variables
local AllNotifsOverride = false

-- User Input Variables
local AutoRobEnabled = false
local AutoRobNotifs = true
local HoldWallet = true
local SelectedAFKSpot = nil -- initialized in ui lib
local FixedCamera = false
--local HideCharacterWhileRobbing = false -- removed for now

local FlyEnabled = false

local FreeFistsEnabled = false
local EatLettuce = false
local AimlockEnabled = false

local LowerGFX = false

local DoSessionSaving = true

-- Time Keeping Variables
local SecondsSpentRobbing = 0
local CurrentRobbingStart = 0

-- Other Variables
local mouse = player:GetMouse()
local playerGui = player:WaitForChild("PlayerGui",1150)

local cashiers = Workspace:WaitForChild("Cashiers",20)
local ignored = Workspace:WaitForChild("Ignored",20)

local drops = ignored:WaitForChild("Drop",20)
local Shop = ignored:WaitForChild("Shop",20)

local AfkSpots = {
	["Admin Base"] = CFrame.new(-798.5,-39.425,-843.75);
	["Flat Hill"] = CFrame.new(0,11.75,222);
	["Admin Roof"] = CFrame.new(-960.1,-3.64,-1014.876);
	["Under Map"] = CFrame.new(166.6,-40.44,53.3);
}

-- Statistics
local MoneyEarned = 0 -- in session

-- not including active session
local allTimeSpent = 0
local allMoneyEarned = 0

local audioInfo = {} -- audio cache

-- LOG FUNCTION

local prefix = "ARTEMIS: "

local function log(text)
	print(prefix..text)
end

local function error(text)
	warn(prefix,text)
end

-- File Saving
local ReconcileFiles = nil -- defined as function later

local mainFolderPath = "Artemis"

local fileSeperator = "/"
local extension = ".txt"

local configPath = mainFolderPath..fileSeperator.."Configuations"..extension
local metaDataPath = mainFolderPath..fileSeperator.."MetaData"..extension

local sessionDataFolderPath = mainFolderPath..fileSeperator.."SessionData"

local logPath = mainFolderPath..fileSeperator.."Logs"

local thisLogPath = nil -- defined later

local sessionPath = sessionDataFolderPath.."/"

-- all defined as functions later
local encode = nil
local decode = nil
local format = nil

local CashLog = { -- template
	["MoneyEarned"] = 0;
	["TimeSpent"] = 0;
	["Time"] = 0; -- in UTC time (os.time())
}

local DefaultConfigs = {
	["AutoRobNotifs"] = AutoRobNotifs;
	["HoldWallet"] = HoldWallet;
	["FixedCamera"] = FixedCamera;
	["SelectedAFKSpot"] = SelectedAFKSpot;
	["LowerGFX"] = LowerGFX;
}

local defaultMetaData = {
	["LegacyLogVersion"] = false;
}

do
	function decode(str)
		local function try()
			return pcall(function()
				return HttpService:JSONDecode(str)
			end)
		end

		local success = false

		local count = 1

		while not success and count <= 6 do
			local s,r = try()

			if s then
				success = true
				return r
			end

			count = count+1

			task.wait()
		end

		return
	end

	function encode(tbl)
		local function try()
			return pcall(function()
				return HttpService:JSONEncode(tbl)
			end)
		end

		local success = false

		local count = 1

		while not success and count <= 6 do
			local s,r = try()

			if s then
				success = true
				return r
			end

			count = count+1

			task.wait()
		end

		return
	end

	function format(data,template)
		local final = {}

		for i,v in pairs(template) do
			local setValue = data[i]

			if setValue == nil then
				setValue = template[i]
			end

			final[i] = setValue
		end

		return final
	end

	-- File Saving (Session Saving)
	function LoadFiles() -- looks through all files to make sure that every file is correct (not edited) and fills in any missing/corrupted required files
		-- Makes a main folder if it doesn't exist

		if not isfolder(mainFolderPath) then
			makefolder(mainFolderPath)
		end

		if not isfolder(sessionDataFolderPath) then
			makefolder(sessionDataFolderPath)
		end

		if not isfolder(logPath) then
			makefolder(logPath)
		end

		-- Config Loading
		if isfile(configPath) then
			local decoded = decode(readfile(configPath))

			if decoded then
				local formatted = format(decoded,DefaultConfigs)

				if formatted then
					local encoded = encode(formatted)

					if encoded then
						writefile(configPath,encoded)
					end

					AutoRobNotifs = formatted["AutoRobNotifs"]
					HoldWallet = formatted["HoldWallet"]
					FixedCamera = formatted["FixedCamera"]
					SelectedAFKSpot = formatted["SelectedAFKSpot"]
					LowerGFX = formatted["LowerGFX"];
				end
			end
		else
			local encoded = encode(DefaultConfigs)

			writefile(configPath,encoded or "Unable to decode")
		end

		-- Metadata Loading
		local function deleteAllLogs()
			local allLogs = listfiles(logPath)

			for _,v in pairs(allLogs) do
				delfile(v)
			end
		end

		if isfile(metaDataPath) then
			local decoded = decode(readfile(metaDataPath))

			if decoded then
				local formatted = format(decoded,defaultMetaData)

				if formatted then
					if formatted["LegacyLogVersion"] then -- log system changed as of 9/25/21
						deleteAllLogs()

						formatted["LegacyLogVersion"] = false
					end

					local encoded = encode(formatted)

					if encoded then
						writefile(metaDataPath,encoded)
					else
						warn("Failed to encode metadata")
					end
				end
			end
		else
			local encoded = encode(defaultMetaData)

			writefile(metaDataPath,encoded or "Unable to decode")

			deleteAllLogs()
		end

		local sessions = listfiles(sessionDataFolderPath)

		local sessionCount = 0

		for i=1,#sessions do
			local path = sessionPath..tostring(i)..extension

			if isfile(path) then
				local raw = readfile(path)

				local decoded = decode(raw)

				if decoded then
					local formatted = format(decoded,CashLog)

					if formatted and formatted ~= {} and formatted ~= decoded then
						local encoded = encode(formatted)

						if encoded then
							writefile(path,encoded)
						end
					else
						error("Log file ("..path..") has been marked as corrupted/tampered and has been removed")
						delfile(path)
						continue
					end
				else
					-- Write of the file as tampered/corrupted
					error("Log file ("..path..") has been marked as corrupted/tampered and has been removed")
					-- Delete the file
					delfile(path)
					continue
				end
			end
		end

		-- Order them properly
		local indexes = {}
		for i,v in ipairs(sessions) do

			local subbed,_ = string.gsub(v,".txt","",1)
			subbed,_ = string.gsub(subbed,sessionDataFolderPath.."\\","",1)

			v = tonumber(subbed)

			if v then
				table.insert(indexes,v)
			else
				error("Log file ("..v..") has been marked as corrupted/tampered and has been removed")
				delfile(sessionPath..v..extension)
			end
		end

		-- sort it from least to greatest
		table.sort(indexes)
		-- fix order to be incremental
		for i,v in ipairs(indexes) do
			if i ~= v then
				local oldPath = sessionPath..v..extension
				local newPath = sessionPath..i..extension

				local data = readfile(oldPath)

				delfile(oldPath)

				writefile(newPath,data)
			end
		end

		local final = #listfiles(sessionDataFolderPath)

		-- update money earned and time spent variables
		for i=1,final do
			local path = sessionPath..tostring(i)..extension

			-- at this point we don't need to be careful because we are relying on the fact that the previous tests made sure all information is truthy and ordered
			local data = decode(readfile(path))

			allMoneyEarned = allMoneyEarned+data.MoneyEarned
			allTimeSpent = allTimeSpent+data.TimeSpent
		end

		do -- remove current stats from this
			allMoneyEarned = math.floor(allMoneyEarned-MoneyEarned)
			local timeSpent = SecondsSpentRobbing

			if AutoRobEnabled then
				timeSpent = timeSpent+(os.clock()-CurrentRobbingStart)
			end

			allTimeSpent = math.floor(allTimeSpent-timeSpent)
		end

		-- Create log file
		local topSep = "="
		local sideSep = "|"
		local seperateLength = 8
		local logText = ""
		local s = " " -- space
		local indent = string.rep(s,4)

		local logInfo = {
			["Date"] = os.date("%x");
			["Time"] = os.date("%X");
			["Version"] = (BETA and "b" or "")..VERSION;
		}

		local order = {"Date","Time","Version"}

		local longest = ""

		for i,v in pairs(logInfo) do
			v = i..tostring(v)
			if #v >  #longest then
				longest = v
			end
		end

		local totalSeperate = (seperateLength*2)+#longest

		local t = string.rep(topSep,totalSeperate).."\n"

		logText = t

		for i,v in ipairs(order) do
			local concat = sideSep..indent..v..": "..tostring(logInfo[v])

			local spaceAdd = totalSeperate-#concat-1

			concat = concat..string.rep(s,spaceAdd)..sideSep.."\n"

			logText = logText..concat
		end

		logText = logText..t

		thisLogPath = logPath..fileSeperator..os.time()..extension

		writefile(thisLogPath,logText)

		return final
	end
end

local nowIndex = LoadFiles()+1

local function writeLog(data,index)
	index = index or nowIndex

	local path = sessionPath..tostring(index)..extension

	local formatted = format(data,CashLog)

	if formatted then
		local encoded = encode(formatted)

		if encoded then
			writefile(path,encoded)
		end
	end
end


local function logAction(text,toggle,lineBreak)
	local textAdd = nil

	if toggle == nil then
		textAdd = text
	else
		textAdd = text.." "..(toggle and "enabled" or "disabled")
	end

	appendfile(thisLogPath,(lineBreak=="beginning"and"\n"or"").."\n"..os.date("%X")..": "..textAdd..(lineBreak=="end"and"\n"or""))
	log(textAdd)
end

local function getFullName(player)
	return player.Name.." ("..player.DisplayName..")"
end

local lastSave = -1
local saveInterval = 0.5

local function save()
	local now = os.clock()
	-- Cash Log
	local timeSpent = SecondsSpentRobbing

	if AutoRobEnabled then
		timeSpent = timeSpent+(now-CurrentRobbingStart)
	end

	local newLog = {
		["MoneyEarned"] = MoneyEarned;
		["TimeSpent"] = math.floor(timeSpent);
		["Time"] = os.time(); -- in UTC time (os.time())
	}

	writeLog(newLog)

	local newConfigs = {
		["AutoRobNotifs"] = AutoRobNotifs;
		["HoldWallet"] = HoldWallet;
		["FixedCamera"] = FixedCamera;
		["SelectedAFKSpot"] = SelectedAFKSpot;
		["LowerGFX"] = LowerGFX;
	}

	local encoded = encode(newConfigs)

	if encoded then
		writefile(configPath,encoded)
	end

	lastSave = now
end

local function updateCrew()
	Crew = CrewValue and tonumber(CrewValue.Value) or 0
end

do -- Save Loop
	local last = os.clock()

	HB:Connect(function()
		local now = os.clock()
		if now-last >= saveInterval and DoSessionSaving then
			last = now

			save()
		end
	end)
end

do -- Bind to close
	Players.PlayerRemoving:Connect(function(p)
		if p == player then
			coroutine.wrap(save)()
			coroutine.wrap(logAction)("Artemis closed",nil,"beginning")
		end
	end)
end

-- General Functions
local function WaitFor(parent,...)
	local c = {...}
	local l = parent

	for i,v in ipairs(c) do
		l = l:WaitForChild(v)
	end

	return l
end

local function getTorso(character)
	return character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
end

local function validCharacter(character)
	if character.PrimaryPart and character:FindFirstChild("Head") and character:FindFirstChildOfClass("Humanoid") and getTorso(character) then
		return true
	else
		return false
	end
end

local function mobileCharacter(char)
	local character = char or player.Character

	if validCharacter(character) then
		local be = character:WaitForChild("BodyEffects")
		local ko = be:FindFirstChild("K.O")
		if ko and ko.Value == false then
			local grabbed = false
			
			for i,v in pairs(Players:GetPlayers()) do
				local c = v.Character

				if c then
					local oBE = c:FindFirstChild("BodyEffects")
					local oGrabbed = oBE and oBE:FindFirstChild("Grabbed")
					if oGrabbed then
						if oGrabbed.Value == character then
							grabbed = true
							break
						end
					end
				end
			end

			if not grabbed then
				return character
			end
		end
	end

	return false
end

local function isCop()
	return DataFolder:WaitForChild("Officer").Value == 1
end

local function resetCharacter(shouldYield)
	if shouldYield == nil then
		shouldYield = true
	end

	local character = mobileCharacter()

	if character then
		local start = os.clock()

		local humanoid = character:FindFirstChildOfClass("Humanoid")

		humanoid.Health = 0

		local shouldReturn = false

		local addedEvent

		local g = Instance.new("BindableEvent")

		addedEvent = player.CharacterAdded:Connect(function()
			local g = Instance.new("BindableEvent")
			local w = nil
			w = HB:Connect(function()
				if addedEvent then
					g:Fire()
					w:Disconnect()
				end
			end)
			g.Event:Wait()
			g:Destroy()

			addedEvent:Disconnect()
			shouldReturn = true
		end)

		local g = Instance.new("BindableEvent")

		local d = nil
		d = HB:Connect(function()
			if shouldReturn then
				g:Fire()
				d:Disconnect()
			end
		end)

		g.Event:Wait()

		g:Destroy()
	end
end

local function tp(goal,shouldYield,removeVelocity)
	local char = mobileCharacter()

	if not char and shouldYield then
		local b = Instance.new("BindableEvent")
		local c = nil
		c = HB:Connect(function()
			local e = mobileCharacter()
			if e then
				char = e
				c:Disconnect()
				b:Fire()
			end
		end)
		b.Event:Wait()
		b:Destroy()
	end
	if char then
		local root = char.PrimaryPart

		if removeVelocity then
			root.AssemblyLinearVelocity = Vector3.new()
		end
		root.CFrame = goal
	end
end

local function formatTime(seconds)
	local SECONDS_IN_MINUTE = 60
	local SECONDS_IN_HOUR = 60*60
	local SECONDS_IN_DAY = 60*60*24
	local SECONDS_IN_YEAR = SECONDS_IN_DAY*365

	if seconds < SECONDS_IN_MINUTE then -- less than a minute
		return math.floor(seconds).."s"
	elseif seconds < SECONDS_IN_HOUR then -- less than an hour
		return math.floor(seconds/SECONDS_IN_MINUTE).."m"
	elseif seconds < SECONDS_IN_DAY then -- less than an day
		return math.floor(seconds/SECONDS_IN_HOUR).."h"
	elseif seconds < SECONDS_IN_YEAR then
		return math.floor(seconds/SECONDS_IN_DAY).."d"
	else
		return math.floor(seconds/SECONDS_IN_YEAR).."y"
	end
end

do -- Artemis Security v2 (so pro)
    local oldFunc = nil

	oldFunc = hookfunction(MainEvent.FireServer, newcclosure(function(Event, ...)
		local args = {...}

		if args[1] == "CHECKER_1" or args[1] == "TeleportDetect" or args[1] == "OneMoreTime" then
			return nil
		end

		return oldFunc(Event, ...)
	end))

    HB:Connect(function()
        local root = player.Character and player.Character.PrimaryPart

        if root then
            for i,v in pairs(getconnections(root:GetPropertyChangedSignal("CFrame"))) do
                v:Disable()
            end
        end
    end)

	local function added(char)
		while true do
            if not char then return end
			HB:Wait()
			for i,v in pairs(char:GetChildren()) do
				if v:IsA("Script") and v:FindFirstChildOfClass("LocalScript") then
					log("Bypassed Anti-Cheat script")
					v:FindFirstChildOfClass("LocalScript").Source = "-- Cleared by Artemis :)"
					return
				end
			end
		end
	end

	if player.Character then
		added(player.Character)
	end
	player.CharacterAdded:Connect(added)
end

local function fill(text,options)
	for i,v in ipairs(options) do
		local splitString = string.sub(v,1,#text)

		if string.lower(splitString) == string.lower(text) then
			return v
		end
	end
end


local function getPlayerNames(notIncludeSelf,useDisplayName)
	local names = {}

	for i,v in ipairs(Players:GetPlayers()) do
		local value = nil

		if useDisplayName then
			value = v.DisplayName
		else
			value = v.Name
		end

		if not notIncludeSelf or (notIncludeSelf and v ~= player) then
			table.insert(names,value)
		end
	end

	return names
end

-- Pages
local Money = Artemis:addPage("Money")
local Player = Artemis:addPage("Player")
local Combat = Artemis:addPage("Combat")
local TeleportsPage = Artemis:addPage("Teleports")
local Misc = Artemis:addPage("Misc")
local Statistics = Artemis:addPage("Statistics")
local Settings = Artemis:addPage("Settings")

-- Sections
local AutoRob = Money:addSection("Auto Rob (BETA)")

local Movement = Player:addSection("Movement")
local CollectDrop = Player:addSection("Collect Drop")
local Spectate = Player:addSection("Spectate")

local Character = Combat:addSection("Character")
local AutoAttack = Combat:addSection("Auto Attack")
local KillPlayer = Combat:addSection("Kill Player")
local KillAll = Combat:addSection("Kill All")
local Aimlock = Combat:addSection("Aimlock")

local AutoRobStats = Statistics:addSection("AutoRob")

local TeleportToPlayer = TeleportsPage:addSection("Teleport To Player")
local TeleportToLocation = TeleportsPage:addSection("Teleport To Location")
local Teleports = TeleportsPage:addSection("Teleports")

local Audio = Misc:addSection("Audio Player")

local GameSettings = Settings:addSection("Game")
local SessionSaving = Settings:addSection("Session Saving")
local Keybinds = Settings:addSection("Keybinds")
local Cache = Settings:addSection("Cache")

-- Elements
AutoRob:addToggle("Enabled",AutoRobEnabled,function(newValue)

	AutoRobEnabled = newValue

	logAction("AutoRob",AutoRobEnabled)

	-- Update Time Variables
	local now = os.clock()

	if newValue then
		CurrentRobbingStart = now
	else
		local timeSpent = now-CurrentRobbingStart

		SecondsSpentRobbing = SecondsSpentRobbing+timeSpent
	end

	for i,v in pairs(cashiers:GetDescendants()) do
		if v:IsA("BasePart") then
			v.CanCollide = not AutoRobEnabled
		end
	end
end)

AutoRob:addToggle("Notifications",AutoRobNotifs,function(newValue)
	AutoRobNotifs = newValue
end)

AutoRob:addToggle("Fixed Camera",FixedCamera,function(newValue)
	FixedCamera = newValue
end)

AutoRob:addToggle("Hold Wallet",HoldWallet,function(newValue)
	HoldWallet = newValue
end)

local spotsDropdown do
	spotsDropdown = {}

	for i,v in pairs(AfkSpots) do
		table.insert(spotsDropdown,i)
	end
end

AutoRob:addDropdown("AFK Spot",spotsDropdown,1,function(newSpot)
	SelectedAFKSpot = newSpot
end)

-- Auto Rob Status
local Status = AutoRob:addBody("Loading...")

-- Player

local flying = false

Movement:addToggle("Fly (X)",FlyEnabled,function(newValue)
	FlyEnabled = newValue
	logAction("Fly",FlyEnabled)

	if not FlyEnabled then
		flying = false
	end
end)

do
	local ItemDrop = ignored:WaitForChild("ItemsDrop")

	local db = false

	local function collect(name)
		local char = mobileCharacter()
		if char and not db then
			db = true

			local oldCF = char.PrimaryPart.CFrame

			local toolFound = nil

			for i,v in pairs(ItemDrop:GetChildren()) do
				local children = v:GetChildren()
				if #children == 1 then
					local tool = children[1]

					if tool.Name == "["..name.."]" then
						toolFound = v
						break
					end
				end
			end

			if toolFound then
				tp(CFrame.new(toolFound.Position)*CFrame.new(0,1,0))
				task.wait(0.5)
				tp(oldCF)
			else
				Artemis:Notify("Collect Error","Tool not found!")
			end

			db = false
		end
	end

	CollectDrop:addButton("Find Knife",function()
		collect("Knife")
	end)

	CollectDrop:addButton("Find Lockpick",function()
		collect("LockPicker")
	end)
end

local useDisplayName1 = false
local useDisplayName2 = false
local useDisplayName3 = false

-- player: spectate
local selectedSpectatePlayer = nil

Spectate:addSuggestionBox("Chosen Player","",function(text,focusLost)
	if focusLost then
		local filtered = fill(text,getPlayerNames(true,useDisplayName3)) or ""

		local found = false

		for _,v in pairs(Players:GetPlayers()) do
			local name = nil
			if useDisplayName3 then
				name = v.DisplayName
			else
				name = v.Name
			end

			if name == filtered then
				selectedSpectatePlayer = v
				found = true
				break
			end
		end

		if not found then
			selectedSpectatePlayer = nil
		end
	end
end,function(text)
	return fill(text,getPlayerNames(true,useDisplayName3))
end)

Spectate:addToggle("Use Display Name",useDisplayName3,function(newValue)
	useDisplayName3 = newValue
end)

Spectate:addButton("Spectate Player",function()
	if selectedSpectatePlayer and selectedSpectatePlayer.Character then
		Camera.CameraSubject = selectedSpectatePlayer.Character:FindFirstChildOfClass("Humanoid")
	end
end)

Spectate:addButton("Stop Spectating",function()
	if player.Character then
		Camera.CameraSubject = player.Character:FindFirstChildOfClass("Humanoid")
	end
end)

-- AutoRobStats:

local AutoRobStatsBody = AutoRobStats:addBody("Loading...")

local SelectedTeleportPlayer = nil

TeleportToPlayer:addSuggestionBox("Chosen Player","",function(text,focusLost)
	if focusLost then
		local filtered = fill(text,getPlayerNames(true,useDisplayName1)) or ""

		local found = false

		for _,v in pairs(Players:GetPlayers()) do
			local name = nil
			if useDisplayName1 then
				name = v.DisplayName
			else
				name = v.Name
			end

			if name == filtered then
				SelectedTeleportPlayer = v
				found = true
				break
			end
		end

		if not found then
			SelectedTeleportPlayer = nil
		end
	end
end,function(text)
	return fill(text,getPlayerNames(true,useDisplayName1))
end)

TeleportToPlayer:addToggle("Use Display Name",useDisplayName1,function(newValue)
	useDisplayName1 = newValue
end)

TeleportToPlayer:addButton("Teleport",function()
	if SelectedTeleportPlayer and SelectedTeleportPlayer.Character then
		logAction("Teleported to "..getFullName(SelectedTeleportPlayer))

		local targetChar = SelectedTeleportPlayer.Character

		if targetChar and targetChar.PrimaryPart then
			local cframe = targetChar.PrimaryPart.CFrame
			tp(cframe,false)
		end
	else
		local b = "Player does not have a character!"
		if not SelectedTeleportPlayer then
			b = "Player does not exist!"
		end

		Artemis:Notify("Teleport Error",b)
	end
end)

-- Combat

-- for kill player
local selectedKillPlayer = nil

AutoAttack:addSuggestionBox("Chosen Player","",function(text,focusLost)
	if focusLost then
		local filtered = fill(text,getPlayerNames(true,useDisplayName2)) or ""

		local found = false

		for _,v in pairs(Players:GetPlayers()) do
			local name = nil
			if useDisplayName2 then
				name = v.DisplayName
			else
				name = v.Name
			end

			if name == filtered then
				selectedKillPlayer = v
				found = true
				break
			end
		end

		if not found then
			selectedKillPlayer = nil
		end
	end
end,function(text)
	return fill(text,getPlayerNames(true,useDisplayName2))
end)

AutoAttack:addToggle("Use Display Name",useDisplayName2,function(newValue)
	useDisplayName2 = newValue
end)

local killPlayer = nil
local loopKill = false
local stomp = false
local arrest = false

do
	local wasChanged = false

	local RightWrist = nil
	local LeftWrist = nil

	local db = false

	local lastFramePlayer = nil

	local event = nil
	local killAllHook = nil
	local killAllPlayerHook = nil
	
	local selectedLoopKill = false

	local savedPos = nil
	local oldPos = nil

	local target = nil -- for kill all

	local function disconnectLoop()
		pcall(function()
			killAllHook:Disconnect()
		end)
		pcall(function()
			killAllPlayerHook:Disconnect()
		end)
		killAllHook = nil
		killAllPlayerHook = nil
	end

	local function reset()
		pcall(function()
			RightWrist:Destroy()
		end)
		pcall(function()
			LeftWrist:Destroy()
		end)
		RightWrist = nil
		LeftWrist = nil
	end

	player.CharacterRemoving:Connect(reset)

	local lastArrest = 0

	HB:Connect(function()

		do
			if killPlayer ~= lastFramePlayer then
				pcall(function()
					event:Disconnect()
				end)
				savedPos = nil
				
				if killPlayer and stomp then
					event = killPlayer.CharacterRemoving:Connect(function()
						if not loopKill then
							killPlayer = nil
						end
						if savedPos then
							tp(savedPos,nil,true)
						end
					end)
				end				
			end
		end

		local char = mobileCharacter()

		if not db and char and killPlayer and killPlayer.Character then
			db = true

			local s,r = pcall(function()
				local RH = char:FindFirstChild("RightHand")
				local LH = char:FindFirstChild("LeftHand")

				RightWrist = RightWrist or RH:FindFirstChild("RightWrist")
				LeftWrist = LeftWrist or LH:FindFirstChild("LeftWrist")
				local bp = player.Backpack

				local weapon = (bp:FindFirstChild("[Knife]") or char:FindFirstChild("[Knife]")) or (bp:FindFirstChild("Combat") or char:FindFirstChild("Combat"))
				local cuffs = isCop and (bp:FindFirstChild("Cuff") or char:FindFirstChild("Cuff"))

				if not (RightWrist and LeftWrist and RH and LH and weapon and (not isCop() or cuffs))  then
					db = false
					return
				else
					local otherChar = mobileCharacter(killPlayer.Character)
					wasChanged = false

					if otherChar then
						Camera.CameraSubject = otherChar:FindFirstChildOfClass("Humanoid")

						LeftWrist.Parent = nil
						RightWrist.Parent = nil

						local goal = otherChar.PrimaryPart.CFrame
						local goal2 = otherChar.Head.CFrame
						
						tp(goal*CFrame.new(0,-15,0))

						weapon.Parent = char
						weapon:Activate()

						if killPlayer.DataFolder.Officer.Value ~= 0 and isCop() then
							target = nil
							killPlayer = nil
						end

						if cuffs then
							cuffs.Parent = bp
						end

						RH.CFrame = goal2
						LH.CFrame = goal2
					else
						LeftWrist.Parent = LH
						RightWrist.Parent = RH
						if stomp then
							if not savedPos then
								savedPos = killPlayer.Character.PrimaryPart.CFrame
							end
							if killPlayer.Character then
								local torso = killPlayer.Character:FindFirstChild("UpperTorso") or killPlayer.Character:FindFirstChild("Torso")
								if torso then
									tp(CFrame.new(torso.Position)*CFrame.new(0,2.5,0))
								end
							end
							if arrest and isCop() then
								cuffs.Parent = char
								if os.clock()-lastArrest > 0.25 then
									task.delay(0.75,function()
										cuffs:Activate()
									end)
									lastArrest = os.clock()
									if killPlayer.leaderstats.Wanted.Value <= 0 or killPlayer.DataFolder.Officer.Value ~= 0 then
										tp(killPlayer.Character.PrimaryPart.CFrame*CFrame.new(0,2,0))
										target = nil
										killPlayer = nil
									end
								end
							else
								MainEvent:FireServer("Stomp")
							end
						else
							if not loopKill then
								tp(killPlayer.Character.PrimaryPart.CFrame*CFrame.new(0,2,0))
								killPlayer = nil
							end
						end
					end
				end
			end)

			if not s then warn(r) end

			db = false
		elseif not wasChanged and char then
			wasChanged = true
			Camera.CameraSubject = char:FindFirstChildOfClass("Humanoid")
		end
	end)

	AutoAttack:addToggle("Loop Action",selectedLoopKill,function(value)
		selectedLoopKill = value
	end)

	KillPlayer:addButton("Knock Selected",function()
		if selectedKillPlayer and mobileCharacter(selectedKillPlayer.Character) and not killAllHook then
			killPlayer = selectedKillPlayer
			loopKill = selectedLoopKill
			stomp = false
			arrest = false
			logAction("Started knocking "..getFullName(killPlayer))
			if not killPlayer and mobileCharacter() then
				oldPos = mobileCharacter().PrimaryPart.CFrame
			end
		else
			Artemis:Notify("Knock Error","Failed to select player!")
		end
	end)
	
	KillPlayer:addButton("Stomp Selected",function()
		if selectedKillPlayer and mobileCharacter(selectedKillPlayer.Character) and not killAllHook then
			killPlayer = selectedKillPlayer
			loopKill = selectedLoopKill
			stomp = true
			arrest = false
			logAction("Started stomping "..getFullName(killPlayer))
			if not killPlayer and mobileCharacter() then
				oldPos = mobileCharacter().PrimaryPart.CFrame
			end
		else
			Artemis:Notify("Stomp Error","Failed to select player!")
		end
	end)

	KillPlayer:addButton("Arrest Selected",function()
		if not isCop() then
			Artemis:Notify("You must be a cop to be able to arrest!")
			return
		end

		if selectedKillPlayer and mobileCharacter(selectedKillPlayer.Character) and not killAllHook then
			killPlayer = selectedKillPlayer
			loopKill = selectedLoopKill
			stomp = true
			arrest = true
			logAction("Started arresting "..getFullName(killPlayer))
			if not killPlayer and mobileCharacter() then
				oldPos = mobileCharacter().PrimaryPart.CFrame
			end
		else
			Artemis:Notify("Stomp Error","Failed to select player!")
		end
	end)

	KillAll:addButton("Knock All",function()
		if killAllHook then return end

		local targets = Players:GetPlayers()

		for i,v in pairs(targets) do
			local otherCrewValue = player:WaitForChild("DataFolder",180):WaitForChild("Information",10):FindFirstChild("Crew")
			local otherCrew = CrewValue and tonumber(CrewValue.Value) or 0
			updateCrew()
			local df = v:FindFirstChild("DataFolder")
			if v == player or Crew == otherCrew or (not df) then
				table.remove(targets,i)
			end
		end

		if #targets <= 0 then
			Artemis:Notify("Nobody is in the server!")
		end

		stomp = false
		arrest = false

		local loop = loopKill and true or false

		logAction("Started knocking all")

		killAllHook = HB:Connect(function()
			if #targets == 0 then
				if loop then
					targets = Players:GetPlayers()
				else
					disconnectLoop()
					return
				end
			end
			if not (target and target.Character) then
				pcall(function()
					killAllPlayerHook:Disconnect()
				end)
				local index = math.random(1,#targets)
				target = targets[index]
				table.remove(targets,index)
				if target and target.Character then
					killAllPlayerHook = target.Character.BodyEffects:FindFirstChild("K.O").Changed:Connect(function()
						target = nil
						killAllPlayerHook:Disconnect()
					end)
				end
			end
			killPlayer = target
		end)
	end)

	KillAll:addButton("Stomp All",function()
		if killAllHook then return end

		local targets = Players:GetPlayers()

		for i,v in pairs(targets) do
			local otherCrewValue = player:WaitForChild("DataFolder",180):WaitForChild("Information",10):FindFirstChild("Crew")
			local otherCrew = CrewValue and tonumber(CrewValue.Value) or 0
			updateCrew()
			local df = v:FindFirstChild("DataFolder")
			if v == player or Crew == otherCrew or (not df) then
				table.remove(targets,i)
			end
		end

		if #targets <= 0 then
			Artemis:Notify("Nobody is in the server!")
		end

		stomp = true
		arrest = false

		local loop = loopKill and true or false

		logAction("Started stomping all")

		killAllHook = HB:Connect(function()
			if #targets == 0 then
				if loop then
					targets = Players:GetPlayers()
				else
					disconnectLoop()
					return
				end
			end
			if not (target and target.Character) then
				pcall(function()
					killAllPlayerHook:Disconnect()
				end)
				local index = math.random(1,#targets)
				target = targets[index]
				table.remove(targets,index)
				if target and target.Character then
					killAllPlayerHook = target.CharacterRemoving:Connect(function()
						target = nil
						killAllPlayerHook:Disconnect()
					end)
				end
			end
			killPlayer = target
		end)
	end)

	KillAll:addButton("Arrest All",function()
		if killAllHook then return end

		if not isCop() then
			Artemis:Notify("You must be a cop to be able to arrest!")
			return
		end

		local targets = Players:GetPlayers()

		for i,v in pairs(targets) do
			local otherCrewValue = player:WaitForChild("DataFolder",180):WaitForChild("Information",10):FindFirstChild("Crew")
			local otherCrew = CrewValue and tonumber(CrewValue.Value) or 0
			local ls = v:FindFirstChild("leaderstats")
			local df = v:FindFirstChild("DataFolder")
			updateCrew()
			if v == player or Crew == otherCrew or (not df) or (not ls) or df.Officer.Value ~= 0 or ls.Wanted.Value <= 0 then
				table.remove(targets,i)
			end
		end

		if #targets <= 0 then
			Artemis:Notify("Nobody is in the server!")
		end

		stomp = true
		arrest = true

		local loop = loopKill and true or false

		logAction("Started arresting all")

		killAllHook = HB:Connect(function()
			if #targets == 0 then
				if loop then
					targets = Players:GetPlayers()
				else
					disconnectLoop()
					return
				end
			end
			if not (target and target.Character) then
				pcall(function()
					killAllPlayerHook:Disconnect()
				end)
				local index = math.random(1,#targets)
				target = targets[index]
				table.remove(targets,index)
				if target and target.Character then
					killAllPlayerHook = target.CharacterRemoving:Connect(function()
						target = nil
						killAllPlayerHook:Disconnect()
					end)
				end
			end
			killPlayer = target
		end)
	end)

	
	AutoAttack:addButton("Stop Kill",function()
		disconnectLoop()
		logAction("Stopped killing process")
		killPlayer = nil
		pcall(function()
			event:Disconnect()
		end)
		event = nil
		if oldPos then
			HB:Wait()
			tp(oldPos,nil,true)
		else
			warn("No CFrame found when teleporting player back to old position")
		end
	end)
end

-- other

local FreeFistsToggle = Character:addToggle("Free Fists (R)",FreeFistsEnabled,function(newValue)
	FreeFistsEnabled = newValue
	logAction("Free fists",FreeFistsEnabled)

	if AimlockEnabled then
		Artemis:Notify("Warning","Aimlock and free fists don't work well together! It is reccomended you disable one of them.")
	end
end)

--[[ Removed for now (never finished it)
local EatLettuceToggle = Character:addToggle("Eat Lettuce",EatLettuce,function(newValue)
	EatLettuce = newValue
	logAction("Lettuce eat",EatLettuce)
end)
]]--

local AimlockToggle = Aimlock:addToggle("Aimlock (Z)",AimlockEnabled,function(newValue)
	AimlockEnabled = newValue
	logAction("Aimlock",AimlockEnabled)

	if FreeFistsEnabled then
		Artemis:Notify("Warning","Aimlock and free fists don't work well together! It is reccomended you disable one of them.")
	end
end)

-- Audio Player
local success,ownsBoombox = pcall(MPS.UserOwnsGamePassAsync,MPS,player.UserId,6207330)

if success and ownsBoombox then	-- load audios
	loadstring(game:HttpGet("https://raw.githubusercontent.com/iamtryingtofindname/Artemis/main/audios.lua"))()

	local audios = shared.audios

	local audioDropdown = {}

	if shared.audios then
		for i,v in ipairs(audios) do
			table.insert(audioDropdown,v.Name)
			audioInfo[tostring(v.ID)] = v.Name
		end
	else
		warn("Audios failed to load!")
	end

	local playing = false
	local currentAudioId = "None"

	local function play(id)
		local boomboxName = "[Boombox]"

		local character = player.Character
		local backpack = player:FindFirstChild("Backpack")

		if character and backpack then
			local b = character:FindFirstChild(boomboxName) or backpack:FindFirstChild(boomboxName)

			if b then
				b.Parent = character

				if tonumber(id) then
					MainEvent:FireServer("Boombox",id)

					
					playing = true
				end

				currentAudioId = id

				b.Parent = backpack
			end
		end
	end

	local function stop()
		MainEvent:FireServer("BoomboxStop")
		playing = false
	end
	
	local audioId = Audio:addTextbox("Audio ID","Enter ID here")
	local songPresets = Audio:addChoiceDropdown("Audios",audioDropdown,function(choice)
		local id = nil

		for _,v in ipairs(audios) do
			if v.Name == choice then
				id = v.ID
				break
			end
		end

		audioId.Button.Textbox.Text = tostring(id)
	end)
	local audioStatus = Audio:addBody("Loading...")
	Audio:addButton("Play Audio",function()
		play(audioId.Button.Textbox.Text)
	end)
	local stopAudio = Audio:addButton("Stop Audio",stop)

	local function makecall(id)
		local function red(text)
			return '<font color="rgb(255,0,0)">'..text..'</font>'
		end

		local success,response = pcall(function()
			return MPS:GetProductInfo(tonumber(id),Enum.InfoType.Asset)
		end)

		local foundName = false

		if success then
			if response.AssetTypeId == 3 then -- 3 means audio
				if response.IsPublicDomain and response.Name ~= "(Removed for copyright)" then
					audioInfo[id] = '"'..response.Name..'"'
					foundName = true
				else
					audioInfo[id] = red("Not playable")
				end
			else
				audioInfo[id] = red("Invalid asset type")
			end
		else
			audioInfo[id] = red("Invalid ID")
		end

		if not foundName then
			stop()
		end
	end

	local function getAudioInfo(id)
		audioInfo[id] = os.clock()

		coroutine.wrap(makecall)(id)
	end

	local lastChange = os.clock()
	local lastFrame = nil

	HB:Connect(function()
		local now = os.clock()

		if currentAudioId ~= lastFrame then
			lastChange = now
		end

		lastFrame = currentAudioId

		local songInfo = audioInfo[currentAudioId]

		if tonumber(songInfo) then
			local e = tonumber(songInfo)

			if now-e > 30 then
				audioInfo[currentAudioId] = nil
				songInfo = nil
			end
		end

		if now - lastChange >= 0.8 then
			if not songInfo and tonumber(currentAudioId) then
				getAudioInfo(currentAudioId)
			end
		end

		songInfo = audioInfo[currentAudioId]

		if not songInfo then
			songInfo = "Typing..."
		elseif typeof(songInfo) == "number" then
			songInfo = "Retrieving..."
		end

		local audioId = tonumber(currentAudioId) and currentAudioId or "nil"
		if #audioId > 16 then
			audioId = "Long..."
		end

		if audioId == "nil" then
			songInfo = "Nothing"
		end

		local text = "Playing: "..songInfo.." ("..audioId..")".."\nStatus: "..(playing and '<font color="rgb(0,255,0)">Playing</font>' or '<font color="rgb(255,0,0)">Stopped</font>')

		audioStatus.Body.Text = text
	end)

	stop()

	local function onAdded()
		stop()

		local boomboxFrame = WaitFor(player,"PlayerGui","MainScreenGui","BoomboxFrame")
	
		boomboxFrame.TextButton.Visible = false
		boomboxFrame.TextButton2.Visible = false
		boomboxFrame.TextBox.Visible = false
	end

	if player.Character then
		onAdded()
	end

	player.CharacterAdded:Connect(onAdded)
else
	local function red(text)
		return '<font color="rgb(255,0,0)">'..text..'</font>'
	end
	Audio:addBody(success and red("You do not own the boombox gamepass! If you purchase it while in game, you will have to rejoin for Audio Player to work.") or red("Failed to check if user own the boombox gamepass! Please rejoin. If this error persists, there may be something internally wrong.\n\n").."Error message: "..red(ownsBoombox))
end

-- Game Settings
local Hidden = Instance.new("Folder")
Hidden.Name = "Hidden"

local hiddenItems = {}
local hiddenItemData = {} -- holds materials and old parents

local function updateGFX(setting)
	logAction("Lower graphics",setting)
	if setting == true then
		Color3.fromRGB(253, 136, 136)
		for i,v in pairs(workspace:GetDescendants()) do
			if v:IsA("Texture") or v:IsA("SurfaceAppearance") then
				table.insert(hiddenItems,v)
				hiddenItemData[v] = v.Parent
				v.Parent = Hidden
			elseif v:IsA("BasePart") and v.Material ~= Enum.Material.Glass and v.Material ~= Enum.Material.ForceField then
				table.insert(hiddenItems,v)
				hiddenItemData[v] = v.Material
				v.Material = Enum.Material.SmoothPlastic
			end
		end
	elseif setting == false then
		for i,v in pairs(hiddenItems) do
			local data = hiddenItemData[v]

			if typeof(data) == "EnumItem" then
				v.Material = data
			else
				v.Parent = data
			end
		end

		hiddenItems = {}
		hiddenItemData = {}
	end
end

	GameSettings:addToggle("Lower GFX",LowerGFX,updateGFX)

local AntiAfkNotice = GameSettings:addBody("Loading...")

local lastAfkAction = nil

RunService.Heartbeat:Connect(function()
	local newText = "<b>Anti-Afk:</b> \n \nStatus: "..'<font color="rgb(0,255,0)">Active</font> \nLast Action: '..(lastAfkAction and formatTime(os.clock()-lastAfkAction) or '<font color="rgb(255,0,0)">Never</font>')

	AntiAfkNotice.Body.Text = newText
end)

-- SessionSaving
	SessionSaving:addToggle("Session Saving Enabled",DoSessionSaving,function(newValue)
	DoSessionSaving = newValue

	logAction("Session saving",DoSessionSaving)

	if DoSessionSaving then
		Artemis:Notify("Session Saving Enabled","All session data will be saved for statistics")
	else
		Artemis:Notify("Session Saving Disabled","Any future data will not be saved")
	end
end)

local SessionSavingText = SessionSaving:addBody("Session saving occurs every ~"..tostring(saveInterval).." seconds \n \nLast Save: Never")
do -- updater
	HB:Connect(function()
		local newText = "Session saving occurs every ~"..tostring(saveInterval).." seconds \n \nLast Save: "

		if lastSave == -1 then
			newText = newText.."Never"
		else
			newText = newText..tostring(formatTime(os.clock()-lastSave)).." ago"
		end

		SessionSavingText.Body.Text = newText
	end)
end

SessionSaving:addButton("Clear All Data",function()
	AllNotifsOverride = true

	local notifLength = 5

	logAction("Cleared all session data")

	local allLogs = listfiles(sessionDataFolderPath)

	for _,v in pairs(allLogs) do
		delfile(v)
	end

	nowIndex = 1

	Artemis:Notify("All Session Data Removed","You may have to rejoin for everything to look normal",nil,notifLength)

	task.wait(notifLength)

	AllNotifsOverride = false
end)

-- Keybinds
Keybinds:addKeybind("Toggle Gui",Enum.KeyCode.RightControl,function()
	Artemis:toggle()
end)

-- Cache
Cache:addButton("Clear Audio Cache",function()
	audioInfo = {}
end)

-- Anti-Idle Kick
local VU = game:GetService("VirtualUser")

local clickLocation = Vector2.new()

local saveCount = 0

player.Idled:Connect(function()
	VU:CaptureController()
	VU:ClickButton2(clickLocation)

	saveCount = saveCount+1
	lastAfkAction = os.clock()

	logAction("Anti-AFK prevented user from being disconnected (#"..saveCount..")")
end)

-- Auto Rob Code
local AutoRobPause = false
local autoRobThread = nil

do
	-- Config
	local registerOffset = CFrame.new(0, -2, 1)
	local camOffset = CFrame.new(-5, -2, 7) * CFrame.Angles(0,-math.pi/5,0)

	local pickupCooldown = 0.08

	local currentlyRobbing = "Nothing"

	local RegisterNames = { -- in specific order
		"Bank (1)";
		"Bank (2)";
		"Bank (3)";

		"Hood Kicks";

		"Klips";

		"Gas Station";

		"Jeff's (2)";

		"Bank ATM";

		"Hospital ATM";

		"Neighborhood ATM";

		"Gas Station ATM";

		"Park ATM";

		"Jeff's (1)";

		"Da Furniture";

		"Jewelry (1)";
		"Jewelry (2)";

		"Pool ATM";

		"Casino ATM (1)";
		"Casino ATM (2)";

		"Casino (2)";
		"Casino (1)";

		"High School (1)";
		"High School (2)";
	}

	-- Items
	local key = Shop:WaitForChild("[Key] - $125")

	-- Functions

	local function updateStatusText()
		local now = os.clock()

		local timeSpent = SecondsSpentRobbing

		if AutoRobEnabled then
			timeSpent = timeSpent+(now-CurrentRobbingStart)
		end

		local autoRobStatsText = ' \n<b>This session:</b>\n \nMoney Earned: <font color="rgb(0,255,0)">$'..MoneyEarned..'</font>\nTime Spent: '..formatTime(timeSpent)..'\n \n'..'<b>All sessions:</b>\n \nMoney Earned: <font color="rgb(0,255,0)">$'..(allMoneyEarned+MoneyEarned)..'</font>\nTime Spent: '..formatTime(allTimeSpent+timeSpent)..'\n '
		local newText = ' \n<b>Currently Robbing: </b>'..currentlyRobbing.."\n \n<b>Register List:</b> \n "

		local registerOrder = { -- Display order
			1,
			2,
			3,
			15,
			16,
			21,
			20,
			13,
			7,
			22,
			23,
			4,
			14,
			5,
			6,
			18,
			19,
			12,
			17,
			8,
			9,
			10,
			11,
		}

		local registers = cashiers:GetChildren()

		for i,v in ipairs(registerOrder) do
			local register = registers[v]
			local name = RegisterNames[v]

			local errorEncountered = false
			local open = false

			local head = register:FindFirstChild("Head")
			local humanoid = register:FindFirstChildOfClass("Humanoid")

			if head and humanoid then
				open = humanoid.Health > 0
			else
				errorEncountered = true
			end

			local addText = "\n"..name..": "

			if open then -- open
				addText = addText..'<font color="rgb(0,255,0)">Open</font>'
			elseif not open then -- closed
				addText = addText..'<font color="rgb(255,0,0)">Closed</font>'
			elseif errorEncountered then -- unknown
				addText = addText..'<font color="rgb(255,165,0)">Unknown</font>'
			end
			newText = newText..addText
		end

		newText = newText.."\n "

		AutoRobStatsBody.Body.Text = autoRobStatsText
		Status.Body.Text = newText
	end

	local function getRegister()
		local character = mobileCharacter()

		if character then
			local root = character.PrimaryPart

			local rootPos = root.Position

			local registerFound = nil
			local maxDistance = math.huge

			for _,register in pairs(cashiers:GetChildren()) do
				if register:FindFirstChild("Head") and register:FindFirstChild("Humanoid") and register.Humanoid.Health > 0 then
					local distance = (rootPos-register.Head.Position).Magnitude
					if distance < maxDistance then
						registerFound = register
						maxDistance = distance
					end
				end
			end

			return registerFound
		end
	end

	local boundary do
		boundary = Instance.new("Model")

		local head = Instance.new("Part")
		local p1 = Instance.new("Part")
		local p2 = Instance.new("Part")
		local p3 = Instance.new("Part")
		local p4 = Instance.new("Part")
		local p5 = Instance.new("Part")

		boundary.Name = "Boundary"
		boundary.PrimaryPart = head
		boundary.Archivable = false

		head.Name = "Head"
		head.Anchored = true
		head.CanCollide = false
		head.CanTouch = false
		head.Massless = true
		head.Size = Vector3.new(1.4,0.4,0.2)
		head.CFrame = CFrame.new()

		p1.Size = Vector3.new(0.5,10,5)
		p1.Position = Vector3.new(0.588, 4.467, 2.325)
		p1.Orientation = Vector3.new(0,90,90)
		p1.Transparency = 1
		p1.CanCollide = true
		p1.CanTouch = false
		p1.Anchored = true

		p2.Size = Vector3.new(0.5, 11, 5)
		p2.Position = Vector3.new(0.588, -1.283, -2.425)
		p2.Orientation = Vector3.new(0,90,0)
		p2.Transparency = 1
		p2.CanCollide = true
		p2.CanTouch = false
		p2.Anchored = true

		p3.Size = Vector3.new(0.5, 11, 9)
		p3.Position = Vector3.new(-1.662, -1.283, 2.325)
		p3.Orientation = Vector3.new(0,0,0)
		p3.Transparency = 1
		p3.CanCollide = true
		p3.CanTouch = false
		p3.Anchored = true

		p4.Size = Vector3.new(0.5, 11.05, 5)
		p4.Position = Vector3.new(0.588, -1.258, 7.075)
		p4.Orientation = Vector3.new(0,90,0)
		p4.Transparency = 1
		p4.CanCollide = true
		p4.CanTouch = false
		p4.Anchored = true

		p5.Size = Vector3.new(0.5, 11, 9)
		p5.Position = Vector3.new(2.838, -1.283, 2.325)
		p5.Orientation = Vector3.new(0,0,0)
		p5.Transparency = 1
		p5.CanCollide = true
		p5.CanTouch = false
		p5.Anchored = true

		head.Parent = boundary

		p1.Parent = boundary
		p2.Parent = boundary
		p3.Parent = boundary
		p4.Parent = boundary
		p5.Parent = boundary
	end

	-- Auto Rob Loop

	local function autoRobLoop()
		local repeatSub = Instance.new("BindableEvent")

		local function getNameFromRegister(register)
			local Registers = cashiers:GetChildren()

			local index = -1

			for i,v in ipairs(Registers) do
				if v == register then
					index = i
					break
				end
			end

			if index ~= -1 and index <= #RegisterNames then
				return RegisterNames[index]
			else
				error("Name not found for register")
				return "Unknown"
			end
		end

		local function updateStatus(text,callback)
			if AutoRobNotifs and not AllNotifsOverride then
				Artemis:Notify("Auto Rob",text,callback)
			end
		end

		local inAfkSpot = false

		local goal = nil
		local CamGoal = nil

		local wasEnabled = not AutoRobEnabled

		local updateConnection = HB:Connect(function()
			updateStatusText()

			local character = mobileCharacter()

			if (not AutoRobEnabled) and wasEnabled then
				currentlyRobbing = "Nothing"
				Camera.CameraType = Enum.CameraType.Custom
			end


			if AutoRobEnabled then
				if FixedCamera and CamGoal then
					Camera.CameraType = Enum.CameraType.Scriptable
					Camera.CFrame = CamGoal
				elseif not FixedCamera then
					Camera.CameraType = Enum.CameraType.Custom
				end
			end

			if character and AutoRobEnabled and not AutoRobPause and not killPlayer and goal then

				local root = character.PrimaryPart

				root.CFrame = goal

				local Backpack = player.Backpack

				local Wallet = Backpack:FindFirstChild("Wallet") or character:FindFirstChild("Wallet")
				local Combat = Backpack:FindFirstChild("Combat") or character:FindFirstChild("Combat")

				if Wallet then
					if HoldWallet then
						Wallet.Parent = character
					else
						Wallet.Parent = Backpack
					end
				end

				if Combat then
					Combat.Parent = character
				end
			end

			wasEnabled = AutoRobEnabled
		end)

		-- Loop
		local db = false
		local mainLoop = HB:Connect(function()
			if not AutoRobEnabled then
				task.wait(0.1)
				db = false
			end

			if db then return else db = true end

			pcall(function()
				if not player:FindFirstChild("DataFolder") then return end

				local character = mobileCharacter()

				local function updateCharacterVar()
					character = mobileCharacter()
				end

				if AutoRobEnabled and character then
					-- Check if they are arrested or banned
					local jail = player.DataFolder.Information:FindFirstChild("Jail")


					if jail then
						local jailTime = tonumber(jail.Value)

						if jailTime > 50000000 then
							-- Assume they are banned
							return
						elseif jailTime > 0 then
							-- Unjail them!
							character.PrimaryPart.CFrame = key.Head.CFrame + Vector3.new(0,1,0) -- Teleport them a bit above it because why not
							task.wait(0.25)
							-- Purchase it
							fireclickdetector(key:FindFirstChildOfClass("ClickDetector"))
							task.wait(0.75)
							local key = player.Backpack:FindFirstChild("[Key]")

							if key then
								task.wait(0.5)
								key.Parent = character
							else
								error("No key found after purchasing!")
							end
						end

					end

					local register = getRegister()

					if register then
						local name = getNameFromRegister(register)

						local start = os.clock()
						local lastSawCombat = start
						local noCombatWait = 3

						local headCFrame = register.Head.CFrame

						goal = headCFrame * registerOffset
						CamGoal = headCFrame * camOffset


						currentlyRobbing = name
						updateStatus("Now Robbing: "..name)

						local startTime = os.clock()

						-- Put the boundary around it so cash doesn't go everywhere
						boundary.Parent = workspace
						boundary:SetPrimaryPartCFrame(headCFrame)

						-- Open up the register
						local openRegister = nil
						openRegister = HB:Connect(function()

							pcall(function()

								updateCharacterVar()

								local now = os.clock()

								local function resetTimeVars()
									now = os.clock()
									lastSawCombat,start = now,now
								end

								if character then

									updateCharacterVar()

									while not character do
										task.wait()
										updateCharacterVar()
									end

									local Combat = player.Backpack:FindFirstChild("Combat") or character:FindFirstChild("Combat")

									if not Combat then
										if not AutoRobEnabled then
											return
										end

										if now-lastSawCombat >= noCombatWait then
											resetCharacter(true)
											resetTimeVars()
										end
									else
										lastSawCombat = now

										if now-start >= 8 then
											resetCharacter(true)
											resetTimeVars()
										else
											Combat.Parent = character
											Combat:Activate()
										end
									end
								else
									resetTimeVars()
									task.wait()
								end
							end)

							if not AutoRobEnabled or (not register or register.Humanoid.Health <= 0) then
								openRegister:Disconnect()
								repeatSub:Fire()
								return
							end
						end)

						repeatSub.Event:Wait()

						-- Collect the cash
						if AutoRobEnabled then

							inAfkSpot = false

							local moneyFoundNear = 0

							local function collect()
								moneyFoundNear = 0

								for i, v in pairs(drops:GetDescendants()) do
									if not AutoRobEnabled then
										return
									end
									if v:IsA("ClickDetector") and v.Parent and v.Parent.Name:find("Money") then
										updateCharacterVar()

										if not character then
											local b = nil
											b = HB:Connect(function()
												updateCharacterVar()
												if character then
													b:Disconnect()
													repeatSub:Fire()
													return
												end
											end)
											repeatSub.Event:Wait()
										end

										local root = character.PrimaryPart

										if not root then
											local b = nil
											b = HB:Connect(function()
												updateCharacterVar()
												if character and character.PrimaryPart then
													b:Disconnect()
													repeatSub:Fire()
													return
												end
											end)
											repeatSub.Event:Wait()

											root = character.PrimaryPart
										end

										-- add it to MoneyEarned (statistics)
										if v and v.Parent and (v.Parent.Position - root.Position).Magnitude <= 18 then
											local worth = nil

											local billboardGui = v.Parent:FindFirstChildOfClass("BillboardGui")

											if billboardGui then
												local moneyLabel = billboardGui:FindFirstChildOfClass("TextLabel")

												if moneyLabel then
													worth = tonumber(string.sub(moneyLabel.Text,2))
												end
											end

											local e = nil
											local l = false
											e = HB:Connect(function()
												if l then return else l = true end
												updateCharacterVar()
												if character then
													root = character.PrimaryPart
												else
													e:Disconnect()
													repeatSub:Fire()
													return
												end

												if not AutoRobEnabled or (v.Parent.Position - root.Position).Magnitude >= 18 then
													return
												end
												task.wait(pickupCooldown)

												if v then
													fireclickdetector(v)
													task.wait()
												end

												if not v or not v.Parent or not v.Parent.Parent or (v.Parent.Position - root.Position).Magnitude > 18 then
													e:Disconnect()
													repeatSub:Fire()
													return
												end
												l = false
											end)
											repeatSub.Event:Wait()

											if worth then
												MoneyEarned = MoneyEarned+worth
												moneyFoundNear = moneyFoundNear+1
											end
										end
									end
								end
							end
							local v = nil
							local q = false
							local temp = Instance.new("BindableEvent")
							v = HB:Connect(function()
								if q then return else q = true end
								pcall(collect)
								if moneyFoundNear == 0 then
									v:Disconnect()
									temp:Fire()
									return
								end
								q = false
							end)
							temp.Event:Wait()
							temp:Destroy()
							task.wait(1.5)
						end
					else
						--TODO: Afk spot code
						if not inAfkSpot then
							currentlyRobbing = "Nothing"
							updateStatus("Moved to AFK spot")

							local afkSpotCFrame = AfkSpots[SelectedAFKSpot or 1]

							inAfkSpot = true

							CamGoal = afkSpotCFrame * registerOffset:Inverse() * camOffset
							goal = afkSpotCFrame

							boundary.Parent = nil
						end
					end
				else
					boundary.Parent = nil
				end
			end)

			db = false
		end)
	end

	autoRobThread = coroutine.create(autoRobLoop)

	coroutine.resume(autoRobThread)
end

-- Fly

do
	local plr = game.Players.LocalPlayer
	local mouse = plr:GetMouse()

	local localplayer = plr

	if workspace:FindFirstChild("Core") then
		workspace.Core:Destroy()
	end

	local Core = Instance.new("Part")
	Core.Name = "Core"
	Core.Size = Vector3.new(0.05, 0.05, 0.05)
	Core.Transparency = 1

	Core.Parent = workspace
	local Weld = Instance.new("Weld", Core)
	Weld.Part0 = Core
	Weld.Part1 = localplayer.Character:FindFirstChild("LowerTorso") or localplayer.Character:FindFirstChild("Torso")
	Weld.C0 = CFrame.new(0, 0, 0)

	local torso = workspace.Core
	local speed = 20
	local keys = {
		a = false,
		d = false,
		w = false,
		s = false
	}

	local b = Instance.new("BindableEvent")

	local function start()


		local pos = Instance.new("BodyPosition", torso)
		local gyro = Instance.new("BodyGyro", torso)
		pos.Name = "EPIXPOS"
		pos.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
		pos.Position = torso.Position
		gyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
		gyro.CFrame = torso.CFrame

		local speedModifier = 0.4

		local c = nil
		local db = false
		c = HB:Connect(function(dt)
			if db then return else db = true end

			local speedMod = speedModifier*60*dt

			if not flying then
				c:Disconnect()
				b:Fire()
				return
			end
			localplayer.Character.Humanoid.PlatformStand = true
			local new = gyro.cframe - gyro.cframe.p + pos.position
			if not keys.w and not keys.s and not keys.a and not keys.d then
				speed = 20
			end
			if keys.w then
				new = new + workspace.CurrentCamera.CFrame.LookVector * (speed*speedMod)
				speed = speed + 0
			end
			if keys.s then
				new = new - workspace.CurrentCamera.CFrame.LookVector * (speed*speedMod)
				speed = speed + 0
			end
			if keys.d then
				new = new * CFrame.new(speed*speedMod, 0, 0)
				speed = speed + 0
			end
			if keys.a then
				new = new * CFrame.new(-speed*speedMod, 0, 0)
				speed = speed + 0
			end
			if speed > 10 then
				speed = 20
			end
			pos.position = new.p
			if keys.w then
				gyro.CFrame = workspace.CurrentCamera.CFrame * CFrame.Angles(-math.rad(speed * 0), 0, 0)
			elseif keys.s then
				gyro.CFrame = workspace.CurrentCamera.CFrame * CFrame.Angles(math.rad(speed * 0), 0, 0)
			else
				gyro.CFrame = workspace.CurrentCamera.CFrame
			end

			db = false
		end)

		b.Event:Wait()
		task.wait()

		if gyro then
			gyro:Destroy()
		end
		if pos then
			pos:Destroy()
		end
		flying = false
		localplayer.Character.Humanoid.PlatformStand = false
		speed = 20
	end

	e1 = mouse.KeyDown:connect(function(key)
		if not torso or not torso.Parent then
			flying = false
			e1:disconnect()
			e2:disconnect()
			return
		end
		if key == "w" then
			keys.w = true
		elseif key == "s" then
			keys.s = true
		elseif key == "a" then
			keys.a = true
		elseif key == "d" then
			keys.d = true
		elseif key == "x" then
			if FlyEnabled then
				if flying == true then
					flying = false
				else
					flying = true
					start()
				end
			end
		end
	end)
	e2 = mouse.KeyUp:connect(function(key)
		if key == "w" then
			keys.w = false
		elseif key == "s" then
			keys.s = false
		elseif key == "a" then
			keys.a = false
		elseif key == "d" then
			keys.d = false
		end
	end)

	HB:Connect(function()
		local char = mobileCharacter()

		if not Weld or Weld.Parent ~= Core then
			local old = Weld or Core:FindFirstAncestorOfClass("Weld")

			if old then
				old:Destroy()
			end

			Weld = Instance.new("Weld", Core)
			Weld.Part0 = Core
			Weld.C0 = CFrame.new(0, 0, 0)
		end
		if char then
			Weld.Part1 = char:FindFirstChild("LowerTorso") or char:FindFirstChild("Torso")
		else
			flying = false
		end
	end)
end

-- Free Fists
do
	local rDown = false

	local RightWrist = nil
	local LeftWrist = nil

	local db = false

	local key = "R"

	local input = UIS.InputBegan:Connect(function(input,gpe)
		if not gpe and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode[key] and FreeFistsEnabled then
			rDown = not rDown
		end
	end)

	local function reset()
		pcall(function()
			RightWrist:Destroy()
		end)
		pcall(function()
			LeftWrist:Destroy()
		end)
		RightWrist = nil
		LeftWrist = nil
	end

	player.CharacterRemoving:Connect(reset)

	HB:Connect(function()

		if not db and not killPlayer then
			db = true

			local s,r = pcall(function()
				local char = mobileCharacter()
				local goal = mouse.Hit

				if char and goal then
					local RH = char:FindFirstChild("RightHand")
					local LH = char:FindFirstChild("LeftHand")

					RightWrist = RightWrist or RH:FindFirstChild("RightWrist")
					LeftWrist = LeftWrist or LH:FindFirstChild("LeftWrist")

					if not (RightWrist and LeftWrist and RH and LH)  then
						db = false
						return
					else
						if FreeFistsEnabled and rDown then
							LeftWrist.Parent = nil
							RightWrist.Parent = nil

							--temp
							--[[
							local closestPlr = nil
							local closestDistance = math.huge

							for i,v in pairs(Players:GetPlayers()) do
								if v == player then continue end

								local u = v.Character and mobileCharacter(v.Character)

								if u then
									local dist = (u.PrimaryPart.Position-char.PrimaryPart.Position).Magnitude

									if dist < closestDistance then
										closestDistance = dist
										closestPlr = v
									end
								end
							end

							if closestPlr then
								RH.CFrame = closestPlr.Character.PrimaryPart.CFrame
								LH.CFrame = closestPlr.Character.PrimaryPart.CFrame
							else
								RH.CFrame = goal
								LH.CFrame = goal
							end
							]]--
							RH.CFrame = goal
							LH.CFrame = goal
						else
							LeftWrist.Parent = LH
							RightWrist.Parent = RH
						end

						if not FreeFistsEnabled then
							rDown = false
						end
					end
				end
			end)

			if not s then warn(r) end

			db = false
		end
	end)
end

-- Teleports
do
	-- Thanks to @Speedbird13 for writing these coords down for me :)
	local TeleportLocations = {
		-- Robberies
		["Bank"] = CFrame.new(-443.5,23.5,-284.25);
		["Jewelry Store"] = CFrame.new(-626.5,23.5,-268.5);
		["Casino"] = CFrame.new(-865.75,22,-147.5);
		["Jeff's"] = CFrame.new(557.25,51.025,-492.5);
		["High School"] = CFrame.new(-653,22,255);
		["Hood Kicks"] = CFrame.new(-223,22,-410.25);
		["Klips"] = CFrame.new(3.5,22,-89.5);
		["Da Furniture"] = CFrame.new(-491,22,-95);
		["Hood Fitness"] = CFrame.new(-75.75,22.75,-639);
		["Gas Station"] = CFrame.new(595.5,49,-258.25);
		-- Gear
		["Medium Armor (1)"] = CFrame.new(-594,10.5,-793.75);
		["Medium Armor (2)"] = CFrame.new(544.5,50.5,-626.5);
		["High-Medium Armor"] = CFrame.new(-938,-28.25,560);
		["Tyrone's (1)"] = CFrame.new(-559,8.25,-736.75);
		["Tyrone's (2)"] = CFrame.new(481.5,48.25,-600);
		-- Guns
		["Revolver"] = CFrame.new(-633.25,22,-133.75);
		["Double Barrel"] = CFrame.new(-1038,22,-275.25);
		["Grenade Launcher"] = CFrame.new(-959,-1,469);
		["RPG"] = CFrame.new(111.5,-27,-277);
		["Flamethrower"] = CFrame.new(-150,54,-94.75);
		["Silencer/Bat"] = CFrame.new(-83.25,22,-286.25);
		["Drum Gun"] = CFrame.new(-74.25,22.75,-86);
		["AUG"] = CFrame.new(-273.5,52.5,-222.5);
		["LMG"] = CFrame.new(-619.25,23.5,-299.5);
		["Bag"] = CFrame.new(-308,51.25,-725.5);
		-- Other Locations
		["Pool"] = CFrame.new(-847.75,22,-279);
		["Bike"] = CFrame.new(-826,22.25,-541.25);
		["Subway Station"] = CFrame.new(-422,-21,36.5);
		["Alley"] = CFrame.new(-270,22,-254.5);
		["Police Station"] = CFrame.new(-262.25,22,-114.5);
		["Jail"] = CFrame.new(-331.25,22,-83.25);
		["Hospital"] = CFrame.new(102.5,23,-484.5);
		["Church"] = CFrame.new(206.5,22,-90.5);
		["Park"] = CFrame.new(365.75,50,-404.25);
		["Playground"] = CFrame.new(-269.5,22.25,-759);
		["Apartment"] = CFrame.new(450,54.75,-733);
		["Food Store (1)"] = CFrame.new(-329.25,23.75,-297.5);
		["Food Store (2)"] = CFrame.new(299,49.5,-618.5);
		["Phone Store"] = CFrame.new(-104.25,22,-870.75);
		["Movie Theater"] = CFrame.new(-1006.25,25.25,-117.75);
		-- Admin
		["Admin Base"] = CFrame.new(-735.3,-39.5,-886.25);
		["Admin Gear (1)"] = CFrame.new(-798.5,-39.5,-904.25);
		["Admin Gear (2)"] = CFrame.new(-870.25,-38.25,-551.5);
		["Admin Jail"] = CFrame.new(-798.5,-39.5,-841);
	}

	local order = { -- added as of v1.0
		"Bank";
		"Jewelry Store";
		"Casino";
		"Jeff's";
		"High School";
		"Hood Kicks";
		"Klips";
		"Da Furniture";
		"Hood Fitness";
		"Gas Station";
		"Medium Armor (1)";
		"Medium Armor (2)";
		"High-Medium Armor";
		"Tyrone's (1)";
		"Tyrone's (2)";
		"Revolver";
		"Double Barrel";
		"Grenade Launcher";
		"RPG";
		"Flamethrower";
		"Silencer/Bat";
		"Drum Gun";
		"AUG";
		"LMG";
		"Bag";
		"Pool";
		"Bike";
		"Subway Station";
		"Alley";
		"Police Station";
		"Jail";
		"Hospital";
		"Church";
		"Park";
		"Playground";
		"Apartment";
		"Food Store (1)";
		"Food Store (2)";
		"Phone Store";
		"Movie Theater";
		"Admin Base";
		"Admin Gear (1)";
		"Admin Gear (2)";
		"Admin Jail";
	}

	local selectedLocation = nil

	TeleportToLocation:addSuggestionBox("Chosen Location","",function(text,focusLost)
		if focusLost then
			local filtered = fill(text,order) or ""
	
			selectedLocation = TeleportLocations[filtered]
		end
	end,function(text)
		return fill(text,order)
	end)

	TeleportToLocation:addButton("Teleport To Location",function()
		if selectedLocation then
			tp(selectedLocation)
		end
	end)

	do -- Actually turns them into buttons
		for i,j in ipairs(order) do
			local v = TeleportLocations[j]
			Teleports:addButton(j,function()
				tp(v)
			end)
		end
	end
end

do -- Aimlock
	local key = "Z"

	local target = nil
	local holding = false

	UIS.InputBegan:Connect(function(input,gpe)
		if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode[key] and not gpe and #Players:GetPlayers() > 0 then
			if not holding then
				local me = mobileCharacter()

				if me then
					local mr = me.PrimaryPart

					local selected = nil

					local params = RaycastParams.new()
					local filter = {}

					for i,v in pairs(Players:GetPlayers()) do
						if v ~= player and mobileCharacter(v.Character) then
							table.insert(filter,v.Character)
						end
					end

					params.FilterDescendantsInstances = filter
					params.FilterType = Enum.RaycastFilterType.Whitelist
					params.IgnoreWater = false

					local mousePos = UIS:GetMouseLocation()

					local unitRay = Camera:ScreenPointToRay(mousePos.X,mousePos.Y)

					local ray = workspace:Raycast(unitRay.Origin,unitRay.Direction*100,params)

					if ray then
						selected = Players:GetPlayerFromCharacter(ray.Instance:FindFirstAncestorOfClass("Model"))

						if selected then
							local dataFolder = selected:FindFirstChild("DataFolder")
							local information = dataFolder and dataFolder:FindFirstChild("Information")
							local crew = information and information:FindFirstChild("Crew")

							local otherCrewId = crew and tonumber(crew.Value)

							if (Crew == 0 and otherCrewId == 0) or (Crew ~= otherCrewId) then
								target = selected
								holding = true
							else
								selected = nil
							end
						end
					end

					local idealScreenX = mouse.X--Camera.ViewportSize.X/2
					local idealScreenY = mouse.Y--Camera.ViewportSize.Y/2

					local idealDistance = 12

					if not selected then

						local best = nil
						local bestScore = math.huge

						updateCrew()

						for i,v in pairs(Players:GetPlayers()) do
							if v ~= player then
								local c = v.Character

								if mobileCharacter(c) then
									local r = c.PrimaryPart

									local screenPos,onScreen = Camera:WorldToScreenPoint(r.Position)

									if onScreen then
										local distance = math.abs((r.Position-mr.Position).Magnitude-idealDistance)
										local screenX = math.abs(screenPos.X-idealScreenX)/idealScreenX
										local screenY = math.abs(screenPos.X-idealScreenY)/idealScreenY

										local ScreenXMultiplier = 8 -- higher = more important
										local ScreenYMultiplier = 0.25 -- higher = more important

										local score = distance*(1+(screenX*ScreenXMultiplier))*(1+(screenY*ScreenYMultiplier))

                                        local dataFolder = v:FindFirstChild("DataFolder")
                                        local information = dataFolder and dataFolder:FindFirstChild("Information")
                                        local crew = information and information:FindFirstChild("Crew")

                                        local otherCrewId = crew and tonumber(crew.Value)

										if ((Crew == 0 and otherCrewId == 0) or (Crew ~= otherCrewId)) and score < bestScore then
											bestScore = distance
											best = v
										end
									end
								end
							end
						end

						if best then
							target = best
							holding = true
						end

						if target then
							logAction("Starting locking on "..getFullName(target))
						end
					end
				end
			else
				holding = false
			end
		end
	end)

	local guess = 2
	local alpha = 1

	HB:Connect(function()
		if AimlockEnabled then
			if holding then
				local them = target.Character

				if them then
					them = mobileCharacter(them)

					if them then
						local root = them.PrimaryPart
						local humanoid = them:FindFirstChildOfClass("Humanoid")
						local goal = root.CFrame + (humanoid.MoveDirection*guess) + (root.Velocity/50)*guess

						local zoom = (Camera.CFrame.Position-Camera.Focus.Position).Magnitude
						local point,onScreen = Camera:WorldToScreenPoint(goal.Position)

						if UIS.MouseBehavior ~= Enum.MouseBehavior.LockCurrentPosition then
							if UIS.MouseBehavior == Enum.MouseBehavior.LockCenter or not onScreen then
								Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.Focus.Position,goal.Position),alpha)
							else
								mousemoveabs(point.X,point.Y+36)
							end
						end

						return
					end
				end
				-- If code reaches this point then one of the if statements failed
				holding = false
			end
		else
			holding = false
		end
	end)
end

logAction("Artemis fully loaded",nil,"end")
