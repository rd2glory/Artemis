if not game:IsLoaded() then
	game.Loaded:Wait()
end

local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/iamtryingtofindname/Artemis/main/Venyx2.lua"))()

local Artemis = library.new("Artemis")

-- Services
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local UIS = game:GetService("UserInputService")

-- General Variables
local player = Players.LocalPlayer

local Camera = workspace.CurrentCamera

local HB = RunService.Heartbeat

-- Private Variables
local AllNotifsOverride = false

-- User Input Variables
local AutoRobEnabled = false
local AutoRobNotifs = true
local HideCharacterWhileRobbing = false
local HoldWallet = true
local SelectedAFKSpot = nil -- initialized in ui lib
local FixedCamera = false

local FlyEnabled = false

local FreeFistsEnabled = false

local DoSessionSaving = true

-- Time Keeping Variables
local SecondsSpentRobbing = 0
local CurrentRobbingStart = 0

-- Other Variables
local mouse = player:GetMouse()

local cashiers = Workspace:WaitForChild("Cashiers")
local drops = Workspace:WaitForChild("Ignored"):WaitForChild("Drop")

local AfkSpots = {
	["Lava Base"] = CFrame.new(-798.5,-39.425,-843.75);
}

-- Statistics
local MoneyEarned = 0 -- in session


local fileSeperator = "/"

-- File Saving (Session Saving)
function ReconcileFiles() -- looks through all files to make sure that every file is correct (not edited) and fills in any missing/corrupted required files
	-- Makes a main folder if it doesn't exist
	local sessionTemplate = {
		["Cash Earned"] = 0;
		["TimeSpent"] = 0;
	}

	local mainFolderPath = "Artemis"

	if not isfolder(mainFolderPath) then
		makefolder(mainFolderPath)
	end

	local sessionDataFolderPath = mainFolderPath..fileSeperator.."SessionData"

	if not isfolder(sessionDataFolderPath) then
		makefolder(sessionDataFolderPath)
	end

	local function decode(str)
		local function try()
			return pcall(function()
				return HttpService:JSONDecode(str)
			end)
		end

		local success = false

		while not success do
			local s,r = try()

			if s then
				success = true
				return r
			end
		end

		return
	end

	local sessions = listfiles(sessionDataFolderPath)

	local sessionPath = sessionDataFolderPath.."/"

	local sessionCount = 0

	for i=1,#sessions do
		if isfile(sessionPath..tostring(i)) then
			-- TODO: File source check
		else
			-- TODO: Do something when a missing file is detected
			sessionCount = i
			break
		end
	end
end

-- General Functions
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
		local root = character.PrimaryPart
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		local torso = getTorso(character)

		local motor = torso:FindFirstChildOfClass("Motor6D")

		if humanoid.Health > 0 and motor then
			return character
		end
	end

	return false
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

local function tp(goal,shouldYield)
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
		char.PrimaryPart.CFrame = goal
	end
end

local function formatTime(seconds)
	local SECONDS_IN_MINUTE = 60
	local SECONDS_IN_HOUR = 60*60
	local SECONDS_IN_DAY = 60*60*24

	if seconds < SECONDS_IN_MINUTE then -- less than a minute
		return math.floor(seconds).."s"
	elseif seconds < SECONDS_IN_HOUR then -- less than an hour
		return math.floor(seconds/SECONDS_IN_MINUTE).."m"
	elseif seconds < SECONDS_IN_DAY then -- less than an day
		return math.floor(seconds/SECONDS_IN_HOUR).."h"
	else
		return seconds.."?" -- if it reaches here, they either have been running the script for more than a day (24 hrs) or there was just some type of time formatting bug
	end
end

-- LOG FUNCTION

local prefix = "ARTEMIS: "

local function log(text)
	print(prefix..text)
end

local function error(text)
	warn(prefix,text)
end

-- Pages
local Money = Artemis:addPage("Money")
local Player = Artemis:addPage("Player")
local Combat = Artemis:addPage("Combat")

local Settings = Artemis:addPage("Settings")

-- Sections
local AutoRob = Money:addSection("Auto Rob (BETA)")

local Movement = Player:addSection("Movement")
local TeleportToPlayer = Player:addSection("Teleport To Player")
local Teleports = Player:addSection("Teleports")

local Character = Combat:addSection("Character")

local SessionSaving = Settings:addSection("Session Saving")
local Keybinds = Settings:addSection("Keybinds")

-- Elements
local EnableAutoRob = AutoRob:addToggle("Enabled",AutoRobEnabled,function(newValue)

	AutoRobEnabled = newValue

	-- Update Time Variables
	local now = os.clock()

	if newValue then
		CurrentRobbingStart = now
	else
		local timeSpent = now-CurrentRobbingStart

		SecondsSpentRobbing = SecondsSpentRobbing+timeSpent
	end

	log("Auto Rob Enabled State Changed: "..tostring(newValue))

	for i,v in pairs(cashiers:GetDescendants()) do
		if v:IsA("BasePart") then
			v.CanCollide = not AutoRobEnabled
		end
	end
end)

local NotificationsEnabled = AutoRob:addToggle("Notifications",AutoRobNotifs,function(newValue)
	AutoRobNotifs = newValue
end)

local FixedCameraEnabled = AutoRob:addToggle("Fixed Camera",FixedCamera,function(newValue)
	FixedCamera = newValue
end)

local ShouldHoldWallet = AutoRob:addToggle("Hold Wallet",HoldWallet,function(newValue)
	HoldWallet = newValue
end)


local spotsDropdown do
	spotsDropdown = {}

	for i,v in pairs(AfkSpots) do
		table.insert(spotsDropdown,i)
	end
end

local AFKSpot = AutoRob:addDropdown("AFK Spot",spotsDropdown,1,function(newSpot)
	SelectedAFKSpot = newSpot
end)

-- Auto Rob Status
local Status = AutoRob:addBody("Loading...")

-- Player

local flying = false

local FlyToggle = Movement:addToggle("Fly (X)",FlyEnabled,function(newValue)
	FlyEnabled = newValue

	if not FlyEnabled then
		flying = false
	end
end)

local SelectedTeleportPlayer = nil
local useDisplayName = false

local function fill(text,options)
	for i,v in ipairs(options) do
		local splitString = string.sub(v,1,#text)

		if string.lower(splitString) == string.lower(text) then
			return v
		end
	end
end


local function getPlayerNames(notIncludeSelf)
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

local TeleportPlayerInput = TeleportToPlayer:addSuggestionBox("Chosen Player","",function(text,focusLost)
	if focusLost then
		local filtered = fill(text,getPlayerNames(true))

		SelectedTeleportPlayer = Players:FindFirstChild(filtered or "")
	end
end,function(text)
	return fill(text,getPlayerNames())
end)

local TeleportPlayerButton = TeleportToPlayer:addButton("Teleport",function()
	if SelectedTeleportPlayer and SelectedTeleportPlayer.Character then		
		local targetChar = mobileCharacter(SelectedTeleportPlayer.Character)

		if targetChar then
			local cframe = targetChar.PrimaryPart.CFrame
			tp(cframe,false)
		end
	end
end)

-- Combat

local FreeFistsToggle = Character:addToggle("Free Fists (R)",FreeFistsEnabled,function(newValue)
	FreeFistsEnabled = newValue
end)

-- SessionSaving
local ToggleSessionSaving = SessionSaving:addToggle("Session Saving Enabled",DoSessionSaving,function(newValue)
	DoSessionSaving = newValue

	if DoSessionSaving then
		Artemis:Notify("Session Saving Enabled","All session data will be saved for statistics")
	else
		Artemis:Notify("Session Saving Disabled","Any future data will not be saved")
	end
end)

local SessionSavingText = SessionSaving:addBody("Session saving occurs every ~30 seconds \n \nLast Save: Never")

local ClearAllDataButton = SessionSaving:addButton("Clear All Data",function()
	AllNotifsOverride = true

	local notifLength = 5

	Artemis:Notify("All Session Data Removed","This action cannot be undone",nil,notifLength)

	wait(5)

	AllNotifsOverride = false
end)

-- Keybinds
local ToggleGui = Keybinds:addKeybind("Toggle Gui",Enum.KeyCode.RightControl,function()
	Artemis:toggle()
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

	-- Functions

	local function updateStatusText()
		local now = os.clock()

		local timeSpent = SecondsSpentRobbing

		if AutoRobEnabled then
			timeSpent = timeSpent+(now-CurrentRobbingStart)
		end

		local newText = '<b>Currently Robbing: </b>'..currentlyRobbing..'\n \n'..'<b>This session:</b>\n \nMoney Earned: <font color="rgb(0,255,0)">$'..MoneyEarned..'</font>\nTime Spent: '..formatTime(timeSpent).."\n \n<b>Register List:</b> \n "

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

		-- Add a final line break
		newText = newText.."\n "

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
				--print("Robbery Status Updated: "..text)
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
				else
					error("CRITICAL ERROR: No valid camera state found")
				end
			end

			if character and AutoRobEnabled and not AutoRobPause and goal then

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
			if db then return else db = true end
			--print("bruh 1")

			local character = mobileCharacter()

			--print("bruh 2")

			local function updateCharacterVar()
				character = mobileCharacter()
			end

			--print("bruh 3")			

			if AutoRobEnabled and character then

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

					-- Open up the register
					local openRegister = nil
					openRegister = HB:Connect(function()
						HB:Wait()

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
									HB:Wait()
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
								HB:Wait()
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
											wait(pickupCooldown)

											if v then
												fireclickdetector(v)
												HB:Wait()
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
						wait(0.5) -- updated to 1 because of anti-cheat
					end
				else
					--TODO: Afk spot code
					if not inAfkSpot then
						currentlyRobbing = "Nothing"
						updateStatus("Moved to AFK spot")

						local afkSpotCFrame = AfkSpots[SelectedAFKSpot]

						inAfkSpot = true

						CamGoal = afkSpotCFrame * registerOffset:Inverse() * camOffset
						goal = afkSpotCFrame
					end
				end
			end

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
		pos.maxForce = Vector3.new(math.huge, math.huge, math.huge)
		pos.position = torso.Position
		gyro.maxTorque = Vector3.new(9e9, 9e9, 9e9)
		gyro.cframe = torso.CFrame

		local speedMod = 0.4

		local c = nil
		local db = false
		c = HB:Connect(function()
			if db then return else db = true end

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
				new = new + workspace.CurrentCamera.CFrame.lookVector * (speed*speedMod)
				speed = speed + 0
			end
			if keys.s then
				new = new - workspace.CurrentCamera.CFrame.lookVector * (speed*speedMod)
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
				gyro.cframe = workspace.CurrentCamera.CFrame * CFrame.Angles(-math.rad(speed * 0), 0, 0)
			elseif keys.s then
				gyro.cframe = workspace.CurrentCamera.CFrame * CFrame.Angles(math.rad(speed * 0), 0, 0)
			else
				gyro.cframe = workspace.CurrentCamera.CFrame
			end

			db = false
		end)

		b.Event:Wait()
		HB:Wait()

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

	player.CharacterRemoving:Connect(function()
		pcall(function()
			RightWrist:Destroy()
		end)
		pcall(function()
			LeftWrist:Destroy()
		end)
		RightWrist,LeftWrist = nil,nil
	end)

	local updateEvent = HB:Connect(function()

		if not db then
			db = true

			pcall(function()
				local char = mobileCharacter()
				local goal = mouse.Hit

				if char and goal then
					local RH = char:FindFirstChild("RightHand")
					local LH = char:FindFirstChild("LeftHand")

					RightWrist = RightWrist or RH:FindFirstChild("RightWrist")
					LeftWrist = LeftWrist or LH:FindFirstChild("LeftWrist")

					if not (RightWrist and LeftWrist and RH and LH)  then
						resetCharacter()
						db = false
						return
					else
						if FreeFistsEnabled and rDown then
							LeftWrist.Parent = nil
							RightWrist.Parent = nil

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
		["DrumGun"] = CFrame.new(-74.25,22.75,-86);
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

	do -- Actually turns them into buttons
		for i,v in pairs(TeleportLocations) do
			Teleports:addButton(i,function()
				tp(v)
			end)
		end
	end
end
