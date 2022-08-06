--[[


██╗░░██╗██████╗░░█████╗░████████╗░█████╗░░██████╗
██║░██╔╝██╔══██╗██╔══██╗╚══██╔══╝██╔══██╗██╔════╝
█████═╝░██████╔╝███████║░░░██║░░░██║░░██║╚█████╗░
██╔═██╗░██╔══██╗██╔══██║░░░██║░░░██║░░██║░╚═══██╗
██║░╚██╗██║░░██║██║░░██║░░░██║░░░╚█████╔╝██████╔╝
╚═╝░░╚═╝╚═╝░░╚═╝╚═╝░░╚═╝░░░╚═╝░░░░╚════╝░╚═════╝░

Private exploit hub made by TrojanHorse#9879
Uses Artemis UI Library made by TrojanHorse#9879
Uses Helios file saving system made by TrojanHorse#9879

]]--

local VERSION = "2.3.4"

print("Loading Kratos v"..VERSION.."...")

if not LPH_OBFUSCATED then
    local function r(f)
        return f
    end
    LPH_JIT_MAX = r
    LPH_JIT_ULTRA = r
    LPH_JIT = r
end

do -- Wait until game is loaded
    if not game:IsLoaded() then
        game.Loaded:Wait()
    end
    local plrs = game:GetService("Players")
    local rs = game:GetService("RunService").RenderStepped
    local Loaded = Instance.new("BindableEvent")
    local loadEvent
    LPH_JIT(function()
        loadEvent = rs:Connect(function()
            if not (plrs.LocalPlayer==nil or not plrs.LocalPlayer:IsDescendantOf(plrs)) and (plrs.LocalPlayer and plrs.LocalPlayer.Character) then
                loadEvent:Disconnect()
                Loaded:Fire()
            end
        end)
    end)()
    Loaded.Event:Wait()
    Loaded:Destroy()
end

-- KRATOS SYSTEMS
local Artemis = loadstring(game:HttpGet("https://raw.githubusercontent.com/iamtryingtofindname/Kratos/main/Artemis/main.lua"))()
local Helios = loadstring(game:HttpGet("https://raw.githubusercontent.com/iamtryingtofindname/Kratos/main/Helios/main.lua"))()

if not (Artemis and Helios) then
    error("Failed to load Kratos systems")
end

-- SERVICES
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local workspace = game:GetService("Workspace")
local Run = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TeleportService")
local VU = game:GetService("VirtualUser")
local Core = game:GetService("CoreGui")
local CS = game:GetService("CollectionService")

-- GENERAL VARIABLES
local player = Players.LocalPlayer

-- CONSTANTS
local RANKS = {
    ["Developer"] = {
        ["Color"] = Color3.fromRGB(174, 93, 255);
        ["Users"] = {
            [2755663001] = true;
            [2754911135] = true;
            [82370367] = true;
            [2063482249] = true;
        }
    };
    ["Admin"] = {
        ["Color"] = Color3.fromRGB(196, 40, 28);
        ["Users"] = {
            [1350477738] = true;
            [1530054675] = true;
            [2801170807] = true;
            [224744418] = true;
        }
    };
    ["Friends"] = {
        ["Color"] = Color3.fromRGB(0, 0, 255);
        ["Users"] = {
            [3088427999] = true;
        }
    };
}
local DEFAULT_RANK = "User"
local DEFAULT_RANK_COLOR = Color3.new(0,1,0)
local IS_PREMIUM = LTH_IsUserPremium and true
local DISCORD = "https://discord.gg/xu5dDS3Pb9"

if not LPH_OBFUSCATED then
    IS_PREMIUM = true
end

-- ARTEMIS INIT
local Rank = DEFAULT_RANK
local RankColor = DEFAULT_RANK_COLOR
do
    if IS_PREMIUM then
        Rank = "Premium User"
        RankColor = Color3.new(1,0,0)
    end
    for rankName,rank in pairs(RANKS) do
        if rank.Users[player.UserId] then
            Rank = rankName
            RankColor = rank.Color
            break
        end
    end
end

do -- raw mod
    local old_rawget = rawget
    rawget = function(tbl,...)
        local returnValue = tbl
        for _,v in ipairs({...}) do
            returnValue = old_rawget(returnValue,v)
        end
        return returnValue
    end
    local old_rawset = rawset
    rawset = function(tbl,index,value)
        if tbl and index and value then
            old_rawset(tbl,index,value)
        end
    end
end

-- HELIOS VARIABLES
local data,oldMetadata,key

-- SYSTEMS INIT
local UI = Artemis.new("Kratos",{
    ["Version"] = VERSION;
})

local Kratos = {}

-- GENERAL KRATOS FUNCTIONS
do
    function Kratos:Wait()
        return Run.RenderStepped:Wait()
    end

    function Kratos:Print(...)
        print("KRATOS:", ...)
    end

    function Kratos:Warn(...)
        warn("KRATOS:", ...)
    end
end

local places = {
    --[[

    ░░░░░██╗░█████╗░██╗██╗░░░░░██████╗░██████╗░███████╗░█████╗░██╗░░██╗
    ░░░░░██║██╔══██╗██║██║░░░░░██╔══██╗██╔══██╗██╔════╝██╔══██╗██║░██╔╝
    ░░░░░██║███████║██║██║░░░░░██████╦╝██████╔╝█████╗░░███████║█████═╝░
    ██╗░░██║██╔══██║██║██║░░░░░██╔══██╗██╔══██╗██╔══╝░░██╔══██║██╔═██╗░
    ╚█████╔╝██║░░██║██║███████╗██████╦╝██║░░██║███████╗██║░░██║██║░╚██╗
    ░╚════╝░╚═╝░░╚═╝╚═╝╚══════╝╚═════╝░╚═╝░░╚═╝╚══════╝╚═╝░░╚═╝╚═╝░░╚═╝

    ]]--
    [606849621] = function()
        -- HELIOS VARS
        local configs = {
            ["NoPromptWait"] = false;
            ["KeycardDoorBypass"] = false;
            ["OpenAllDoorsLoop"] = false;
            ["CarEngineSpeed"] = 0;
            ["CarSuspensionHeight"] = 0;
            ["TirePopBypass"] = false;
            ["InfNitro"] = false;
            ["CarTurnSpeed"] = 0;
            ["CarBrakesSpeed"] = 0;
            ["NoCellTime"] = false;
            ["AntiTaze"] = false;
            ["ToggleUI"] = "LeftControl";
            ["CharacterFlyEnabled"] = false;
            ["CharacterFlyBind"] = "X";
            ["CarFlyEnabled"] = false;
            ["CarFlyBind"] = "Z";
            ["CharacterFlySpeed"] = 35;
            ["CarFlySpeed"] = 350;
            ["LaserRemove"] = false;
            ["DoorNoClip"] = false;
            ["DoorNoClipTransparent"] = false;
            ["NoParachute"] = false;
            ["NoFallDamage"] = false;
            ["NoRagdoll"] = false;
            ["WalkSpeed"] = 16;
            ["JumpPower"] = 50;
            ["NoDelayTeamChange"] = false;
            ["NoReloadTime"] = false;
            ["NoBulletSpread"] = false;
            ["NoRecoil"] = false;
            ["NoShotDelay"] = false;
            ["FullAuto"] = false;
            ["ForwardBind"] = "KeypadPlus";
        }

        local FILE_TREE = {
            ["configs.json"] = {}
        }

        local metadata = {
            ["inBeta"] = false;
            ["keybindUpdate_7/21/22_12:05AM"] = true;
            ["keybindUpdate_7/21/22_1:09PM"] = true;
        }

        -- START LOADING
        UI:StartLoading({
            ["Title"] = Rank;
            ["ThumbnailId"] = 10395551459;--old: 10196274249
            ["GameName"] = "Jailbreak";
            ["TitleTextColor"] = RankColor;
        })

        -- GENERAL VARIABLES
        local VehiclesFolder = workspace:WaitForChild("Vehicles")
        local SettingsModule = require(RS.Resource.Settings)

        -- SCRIPT VARIABLES
        local setCharacterFlyEnabled
        local setCarFlyEnabled

        -- HELIOS INIT
        data,oldMetadata,key = Helios:Init(game.PlaceId,FILE_TREE,metadata)
        if typeof(data["configs.json"])=="table" then
            configs = Helios:reconcile(data["configs.json"],configs)
        end

        -- METADATA INIT
        do
            local function wipe()
                delfolder(Helios._place_directory)
            end
            if oldMetadata["keybindUpdate_7/21/22_12:05AM"] ~= true then
                wipe()
            end
            if oldMetadata["keybindUpdate_7/21/22_1:09PM"] ~= true then
                wipe()
            end
            if oldMetadata["inBeta"] then
                print("Kratos now out of beta")
            end
        end

        task.wait(0.5)

        -- KRATOS FUNCTIONS
        do
            function Kratos:GetLocalCharacter()
                local c = player.Character

                if c and c:IsDescendantOf(workspace) and c:FindFirstChild("Head") and c.PrimaryPart and c:FindFirstChild("Humanoid") then
                    if c:FindFirstChild("Humanoid") and c:FindFirstChild("Humanoid").Health > 0 then
                        return c
                    else
                        return false
                    end
                end
            end
        
            function Kratos:GetLocalPlayerVehicle()
                for _,v in pairs(VehiclesFolder:GetChildren()) do
                    if v:FindFirstChild("Seat") and v.Seat:FindFirstChild("PlayerName") and v:FindFirstChild("Make") and v:FindFirstChild("Engine") then
                        if v.Seat.PlayerName.Value == player.Name then
                            return v
                        end
                    end
                end
            end
        
            function Kratos:Init()
                Kratos.MainScript = player:WaitForChild("PlayerScripts",60):WaitForChild("LocalScript",60)
                Kratos.Doors = {}
                Kratos.Backups = {}
                LPH_JIT_ULTRA(function()
                    for _, v in pairs(getgc(true)) do
                        if type(v) == "table" then
                            if rawget(v, "Event") and rawget(v, "Fireworks") then
                                Kratos.em = v.em
                                Kratos.GetVehiclePacket = v.GetVehiclePacket
                                Kratos.Fireworks = v.Fireworks
                                Kratos.Network = v.Event
                            elseif rawget(v, "State") and rawget(v, "OpenFun") then
                                table.insert(Kratos.Doors, v)
                            elseif rawget(v, "Ragdoll") then
                                Kratos.Backups.Ragdoll = v.Ragdoll
                            end
                        elseif type(v) == "function" then
                            if getfenv(v).script == Kratos.MainScript then
                                local con = getconstants(v)
                                if table.find(con, "SequenceRequireState") then
                                    Kratos.OpenDoor = v
                                end
                                    --[[
                                elseif table.find(con, "Play") and table.find(con, "Source") and table.find(con, "FireServer") then
                                    Kratos.PlaySound = v
                                elseif table.find(con, "PlusCash") then
                                    Kratos.PlusCash = v
                                elseif table.find(con, "Punch") then
                                    Kratos.GuiFunc = v
                                end
                                ]]--
                            end
                        end
                    end
                end)()
        --[[
                local oldFireServer
                oldFireServer = hookfunction(Instance.new('RemoteEvent').FireServer, newcclosure(function(Event, ...)
                    if not checkcaller() then
                        local Args = {...}
        
                    end
        
                    return oldFireServer(Event, ...)
                end))
        ]]--
                local lastSave = os.clock()
                LPH_JIT_MAX(function()
                    Run.RenderStepped:Connect(function()
                        local now = os.clock()
                        if now-lastSave>=1 then
                            lastSave = now
                            data["configs.json"] = Helios:encode(configs)
                            Helios:updateWithDirectory(data)
                        end
                    end)
                end)()
            end
        end
        
        Kratos:Init()
        
        -- NOTIFICATION
        local notify do
            local Notification = {}
            do -- notif module
                -- Decompiled with the Synapse X Luau decompiler.
                local u1 = {};
                local u2 = false;
                local v2 = {};
                v2.__index = v2;
                local u4 = require(RS:WaitForChild("Game"):WaitForChild("GameUtil"));
                local u5 = require(RS:WaitForChild("Resource"):WaitForChild("Settings"));
                local original = nil
                function v2.Init()
                    --local l__em__3 = p1.em;
                    original = player:WaitForChild("PlayerGui",45):WaitForChild("NotificationGui",45)
                    local l__NotificationGui__4 = original:Clone();
                    l__NotificationGui__4.Parent = Core;
                    l__NotificationGui__4.DisplayOrder = 1;
                    v2.Gui = l__NotificationGui__4;
                    local v5 = Instance.new("Sound");
                    v5.SoundId = ("rbxassetid://%d"):format(215658476);
                    v5.Parent = l__NotificationGui__4;
                    v2.TypeWriterSound = v5;
                    u4.OnTeamChanged:Connect(function(p2)
                        v2.SetColor(u5.TeamColor[p2]);
                    end);
                    v2.SetColor(u5.TeamColor[u4.Team]);
                end;
                function v2.SetColor(p3)
                    v2.Gui.ContainerNotification.ImageColor3 = p3;
                end;
                local u6 = nil;
                local u7 = require(RS:WaitForChild("Std"):WaitForChild("Maid"));
                local function u8()
                    if not (#u1 > 0) then
                        u2 = false;
                        return;
                    end;
                    u2 = true;
                    table.remove(u1, 1):Hook();
                end;
                function v2.new(p4)
                    assert(p4 ~= nil);
                    assert(p4.Text ~= nil);
                    if p4.Text == u6 then
                        return;
                    end;
                    local v6 = u1[1];
                    if v6 and v6.Text == p4.Text then
                        return;
                    end;
                    if p4.Duration == nil then
                        p4.Duration = math.min(5, 4 * utf8.len(p4.Text) / 50);
                    end;
                    assert(p4.Duration ~= nil);
                    local v7 = {};
                    setmetatable(v7, v2);
                    v7.Maid = u7.new();
                    v7.Text = p4.Text;
                    v7.Duration = p4.Duration;
                    table.insert(u1, v7);
                    if u2 == false then
                        u8();
                    end;
                    return v7;
                end;
                local u9 = require(RS.Game.TypeWrite);
                local u10 = require(RS.Std.Audio);
                function v2.Hook(p5)
                    pcall(function()
                        local l__Gui__8 = v2.Gui;
                        l__Gui__8.Enabled = true;
                        u6 = p5.Text;
                        original.ContainerNotification.Visible = false
                        local u11 = 1;
                        p5.Maid:GiveTask(u9(p5.Text, function(p6)
                            if p5.Maid == nil then
                                return false;
                            end;
                            if u11 == 1 then
                                v2.TypeWriterSound:Play();
                            end;
                            u11 = u11 % 3 + 1;
                            l__Gui__8.ContainerNotification.Message.Text = p6;
                        end, 50));
                        u10.ObjectLocal(l__Gui__8, 700153902, {
                            Volume = 0.25
                        });
                        task.delay(p5.Duration, function()
                            p5:Destroy();
                            original.ContainerNotification.Visible = true
                        end);
                    end)
                end;
                function v2.Destroy(p7)
                    if p7.Maid ~= nil then
                        v2.Gui.Enabled = false;
                        p7.Maid:Destroy();
                        p7.Maid = nil;
                        u6 = nil;
                        u8();
                    end;
                end;
        
                pcall(v2.Init)
        
                Notification = v2
            end
        
            function notify(text,duration)
                text = text or "nil"
                duration = duration or math.min(5, 4 * utf8.len(text) / 50);
        
                pcall(function()
                    local e = Notification.new({
                        ["Text"] = text;
                        ["Duration"] = duration;
                    })
                    
                    Notification.Hook(e)
                end)
            end
        end

        task.wait(0.5)
        
        -- NO E WAIT
        do
            local db = false
            local cache = {}
            LPH_JIT_MAX(function()
                Run.RenderStepped:Connect(function()
                    if db then return else db = true end
                    for _,v in pairs(rawget(require(RS.Module.UI),"CircleAction","Specs")) do
                        local part = rawget(v,"Part")
                        if part then
                            if configs["NoPromptWait"] then
                                --cache[part] = cache[part] or v.Duration
                                cache[part]=cache[part] or rawget(v,"Duration")
                                rawset(v,"Duration",0)
                            else
                                rawset(v,"Duration",cache[part] or rawget(v,"Duration"))
                                --rawset(v,"Timed",true)--cache[part] or v.Duration)
                            end
                        end
                    end
                    db = false
                end)
            end)()
        end
        
        -- PLAYER UTIL BYPASS
        do
            local playerUtils = require(RS.Game.PlayerUtils)
        
            -- Keycard Door Bypass
            local old_func_1 = rawget(playerUtils,"hasKey")
            rawset(playerUtils,"hasKey",function(...)
                if configs["KeycardDoorBypass"] then
                    return true
                else
                    return old_func_1(...)
                end
            end)
        
            -- Skydive bypass
            local old_func_2 = rawget(playerUtils,"isPointInTag")
            rawset(playerUtils,"isPointInTag",function(...)
                local args = {...}
                if args[2] == "NoParachute" and configs["NoParachute"] then
                    return true
                elseif args[2] == "NoFallDamage" and configs["NoFallDamage"] then
                    return true
                elseif args[2] == "NoRagdoll" and configs["NoRagdoll"] then
                    return true
                end
                return old_func_2(...)
            end)
        end

        -- OPEN ALL DOORS (ONCE)
        local openAllDoors do
            function openAllDoors()
                for _,v in next, Kratos.Doors do 
                    Kratos.OpenDoor(v)
                end
            end
        end

        -- OPEN ALL DOORS (LOOP)
        do
            local OPEN_ALL_DOORS_LOOP = 1
            local lastOpen = 0
            LPH_JIT_ULTRA(function()
                Run.RenderStepped:Connect(function()
                    if configs["OpenAllDoorsLoop"] then
                        local now = os.clock()
                        if now-lastOpen >= OPEN_ALL_DOORS_LOOP then
                            lastOpen = now
                            openAllDoors()
                        end
                    end
                end)
            end)()
        end
        
        do -- INF NITRO
            LPH_JIT_ULTRA(function()
                for _,v in pairs(getgc(true)) do
                    if type(v) == "table" and rawget(v, "Nitro") then
                        LPH_JIT_MAX(function()
                            Run.RenderStepped:Connect(function()
                                if configs["InfNitro"] then
                                    rawset(v,"Nitro",250)
                                end
                            end)
                        end)()
                    end
                end
            end)()
        end
        
        -- VEHICLE MODS & CHARACTER MODS
        do
            --[[
            local aChassis = require(game:GetService("ReplicatedStorage").Module.AlexChassis)
        
            local old_update = rawget(aChassis,"Update")
        
            rawset(aChassis,"Update",function(...)
                local args = {...}
                local vehicleData = args[1]
        
                rawset(vehicleData,"GarageEngineSpeed",configs["CarEngineSpeed"])
                rawset(vehicleData,"Height",configs["CarSuspensionHeight"]+4)
                rawset(vehicleData,"TurnSpeed",configs["CarTurnSpeed"]+1.4)
                rawset(vehicleData,"GarageBrakes",configs["CarBrakesSpeed"])
        
                if configs["TirePopBypass"] then
                    rawset(vehicleData,"AreTiresPopped",false)
                    rawset(vehicleData,"TirePopProportion",0)
                    rawset(vehicleData,"TirePopDuration",0)
                    rawset(vehicleData,"TireHealth",1)
                end
        
                args[1] = vehicleData
        
                return old_update(unpack(args))
            end)
            ]]--

            LPH_JIT_ULTRA(function()
                local OldIndex
                OldIndex = hookmetamethod(game, "__index", function(self, b)
                    if b == "WalkSpeed" then
                        return 16
                    end
                    if b == "JumpPower" then
                        return 50
                    end 
                    return OldIndex(self,b)
                end)
            end)()

            LPH_JIT_MAX(function()
                Run.RenderStepped:Connect(function()
                    local char = Kratos:GetLocalCharacter()
    
                    if char then
                        char.Humanoid.WalkSpeed = configs["WalkSpeed"]
                        char.Humanoid.JumpPower = configs["JumpPower"]
                    end
    
                    if typeof(Kratos.GetVehiclePacket()) then
                        rawset(Kratos.GetVehiclePacket(),"GarageEngineSpeed",configs["CarEngineSpeed"])
                        rawset(Kratos.GetVehiclePacket(),"Height",configs["CarSuspensionHeight"]+3)
                        rawset(Kratos.GetVehiclePacket(),"TurnSpeed",configs["CarTurnSpeed"]+1.4)
                        rawset(Kratos.GetVehiclePacket(),"GarageBrakes",configs["CarBrakesSpeed"])
    
                        if configs["TirePopBypass"] then
                            rawset(Kratos.GetVehiclePacket(),"AreTiresPopped",false)
                            rawset(Kratos.GetVehiclePacket(),"TirePopProportion",0)
                            rawset(Kratos.GetVehiclePacket(),"TirePopDuration",0)
                            rawset(Kratos.GetVehiclePacket(),"TireHealth",1)
                        end
                    end
                end)
            end)()
        end
        
        -- NO CELL TIME/ANTI TAZE/NO TEAM SWITCH DELAY
        do
            LPH_JIT_MAX(function()
                Run.RenderStepped:Connect(function()
                    local timeTable = rawget(SettingsModule,"Time")
                    rawset(timeTable,"Cell",configs["NoCellTime"] and 0 or 20)
                    rawset(timeTable,"Stunned",configs["AntiTaze"] and 0 or 2.5)
                    rawset(timeTable,"BetweenTeamChange",configs["NoDelayTeamChange"] and 0 or 24)
                end)
            end)()
        end
        
        -- CHARACTER FLY
        do
            local _fly = false

            function setCharacterFlyEnabled(toggle)
                if toggle == nil then
                    toggle = not _fly
                end
                _fly = toggle
            end

            local core
        
            local function repairCore(char)
                if core == nil then
                    core = Instance.new("Part")
                    Instance.new("Weld").Parent = core
                    Instance.new("BodyPosition").Parent = core
                    Instance.new("BodyForce").Parent = core
                end
                core.Size = Vector3.new(2,5.6,2)
                core.Anchored = false
                core.CanCollide = true
                core.Transparency = 1
                core.CanTouch = false
                core.CanQuery = false
                core.Massless = true
            
                core.Weld.Part0 = core
                core.Weld.Part1 = char.PrimaryPart
            
                core.BodyPosition.MaxForce = Vector3.new(400000,400000,400000)
                core.BodyPosition.D = 4000
                core.BodyPosition.P = 70000
            
                core.BodyForce.Force = Vector3.new(0, char.PrimaryPart.AssemblyMass * workspace.Gravity, 0);
            
                core.Parent = workspace
            end
        
            local keysDown = {}

            LPH_JIT_ULTRA(function()
                Run.RenderStepped:Connect(function()
                    local char = Kratos:GetLocalCharacter()
                    if char and char.Humanoid.Sit == false and _fly and configs["CharacterFlyEnabled"] and workspace.CurrentCamera then
                        local direction = Vector3.new()
                
                        if keysDown[Enum.KeyCode.W] then
                            direction = direction+Vector3.new(0,0,-1)
                        end
                        if keysDown[Enum.KeyCode.S] then
                            direction = direction+Vector3.new(0,0,1)
                        end
                        if keysDown[Enum.KeyCode.A] then
                            direction = direction+Vector3.new(-1,0,0)
                        end
                        if keysDown[Enum.KeyCode.D] then
                            direction = direction+Vector3.new(1,0,0)
                        end
                        if keysDown[Enum.KeyCode.Space] then
                            direction = direction+Vector3.new(0,1,0)
                        end
                
                        if math.abs(direction.X)+math.abs(direction.Y)+math.abs(direction.Z)>1 then
                            local sq2 = math.sqrt(2)/2
                            direction = direction*sq2
                        end
                
                        direction = Vector3.new(direction.X,direction.Y*0.75,direction.Z)
                
                        repairCore(char)
                        local current = char.PrimaryPart.Position
                        local body = core.BodyPosition
                        local lv = workspace.CurrentCamera.CFrame.LookVector
                        local goal = CFrame.lookAt(Vector3.zero,lv)+current
                        goal = goal*CFrame.new(direction*configs["CharacterFlySpeed"])
                        char.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false)
                        body.Position = goal.Position
                    else
                        --print(char,char.Humanoid.Sit == false, _fly, configs["CharacterFlyEnabled"], workspace.CurrentCamera)
                        if core then
                            pcall(function()
                                core:Destroy()
                            end)
                        end
                        pcall(function()
                            char.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown,true)
                        end)
                        core = nil
                    end
                end)
            end)()
        
            UIS.InputBegan:Connect(function(input,gpe)
                if input.UserInputType == Enum.UserInputType.Keyboard and not gpe then
                    keysDown[input.KeyCode] = true
                end
            end)
        
            UIS.InputEnded:Connect(function(input,gpe)
                if input.UserInputType == Enum.UserInputType.Keyboard and not gpe then
                    keysDown[input.KeyCode] = false
                end
            end)
        
            player.CharacterRemoving:Connect(function()
                pcall(function()
                    core:Destroy()
                end)
                core = nil
            end)
        end

        -- temp
        Run.RenderStepped:Connect(function()
            local vehicle = Kratos.GetVehiclePacket()
            if vehicle then
                for i,v in pairs(vehicle) do print(i,v) end
            end
        end)

        task.wait(0.5)
        
        -- CAR FLY
        do
            local _fly = false

            function setCarFlyEnabled(toggle)
                if toggle == nil then
                    toggle = not _fly
                end
                _fly = toggle
            end

            local velocity = "velocity"
            local gyro = "gyro"
        
            local function repairCore(car)
                if car.Engine:FindFirstChild(velocity)==nil then
                    Instance.new("BodyVelocity").Parent = car.Engine
                    car.Engine.BodyVelocity.Name = velocity
                end
                if car.Engine:FindFirstChild(gyro)==nil then
                    Instance.new("BodyGyro").Parent = car.Engine
                    car.Engine.BodyGyro.Name = gyro
                end
        
                car.Engine:FindFirstChild(velocity).MaxForce = Vector3.new(9e9,9e9,9e9)
                car.Engine:FindFirstChild(velocity).P = 1250
        
                car.Engine:FindFirstChild(gyro).MaxTorque = Vector3.new(9e9,9e9,9e9)
                car.Engine:FindFirstChild(gyro).D = 500
                car.Engine:FindFirstChild(gyro).P = 90000
            end
        
            local keysDown = {}

            LPH_JIT_ULTRA(function()
                Run.RenderStepped:Connect(function()
                    local char = Kratos:GetLocalCharacter()
                    local car = Kratos:GetLocalPlayerVehicle()
                    if char and car and _fly and configs["CarFlyEnabled"] and workspace.CurrentCamera then
                        local direction = Vector3.new()
            
                        if keysDown[Enum.KeyCode.W] then
                            direction = direction+Vector3.new(0,0,-1)
                        end
                        if keysDown[Enum.KeyCode.S] then
                            direction = direction+Vector3.new(0,0,1)
                        end
                        if keysDown[Enum.KeyCode.A] then
                            direction = direction+Vector3.new(-1,0,0)
                        end
                        if keysDown[Enum.KeyCode.D] then
                            direction = direction+Vector3.new(1,0,0)
                        end
            
                        if math.abs(direction.X)+math.abs(direction.Z)>1 then
                            local sq2 = math.sqrt(2)/2
                            direction = direction*sq2
                        end
            
                        repairCore(car)
            
                        local camCFrame = workspace.CurrentCamera.CFrame
                        local goal = CFrame.new(Vector3.zero,camCFrame.LookVector.Unit)*(direction*configs["CarFlySpeed"])
                        car.Engine:FindFirstChild(velocity).Velocity = goal
                        car.Engine:FindFirstChild(gyro).CFrame = CFrame.lookAt(Vector3.zero,camCFrame.LookVector)
                    else
                        pcall(function()
                            car.Engine:FindFirstChild(velocity):Destroy()
                        end)
                        pcall(function()
                            car.Engine:FindFirstChild(gyro):Destroy()
                        end)
                    end
                end)
            end)()
        
            UIS.InputBegan:Connect(function(input,gpe)
                if input.UserInputType == Enum.UserInputType.Keyboard and not gpe then
                    keysDown[input.KeyCode] = true
                end
            end)
        
            UIS.InputEnded:Connect(function(input,gpe)
                if input.UserInputType == Enum.UserInputType.Keyboard and not gpe then
                    keysDown[input.KeyCode] = false
                end
            end)
        
            player.CharacterRemoving:Connect(function()
                local car = Kratos:GetLocalPlayerVehicle()
                pcall(function()
                    car.Engine:FindFirstChild(velocity):Destroy()
                end)
                pcall(function()
                    car.Engine:FindFirstChild(gyro):Destroy()
                end)
            end)
        end
        
        -- LASER REMOVER
        do
            local lasers = {}
            local num = 0
            local function processLaser(v)
                --num = num + 1
                do--==0 then
                    Run.RenderStepped:Wait()
                end
                lasers[v] = v.Parent
                v.Parent = nil
            end
            local db = false
            local ppModel = nil

            LPH_JIT_ULTRA(function()
                Run.RenderStepped:Connect(function()
                    if db then return else db = true end
                    if configs["LaserRemove"] then
                        pcall(function()
                            local jewStore = workspace.Jewelrys:GetChildren()[1]
                            for _,j in pairs(jewStore.Floors:GetChildren()) do
                                for _,v in pairs(j:GetChildren()) do
                                    if not (v.Name == "Model" and v:IsA("Model")) then
                                        processLaser(v)
                                    end
                                end
                            end
                            for _,v in pairs(jewStore:GetChildren()) do
                                if v:IsA("BasePart") and v.Name == "BarbedWire" then
                                    processLaser(v)
                                end
                            end
                        end)
                        pcall(function()
            
                            local bank = workspace.Banks:GetChildren()[1]
                            local floor = bank.Layout:GetChildren()[1]
            
                            if floor:FindFirstChild("Lasers") then
                                for _,v in pairs(floor.Lasers:GetChildren()) do
                                    processLaser(v)
                                end
                            end
            
                            for _,v in pairs(bank:GetDescendants()) do
                                if v.Name == "BarbedWire" and v:IsA("BasePart") then
                                    processLaser(v)
                                end
                            end
                        end)
                        pcall(function()
                            Run.RenderStepped:Wait()
            
                            local light = workspace.Museum:FindFirstChild("Lights")
            
                            if light then
                                for _,v in pairs(light:GetChildren()) do
                                    processLaser(v)
                                end
                            end

                            if not ppModel then
                                ppModel = {}
                                for _,v in pairs(workspace:GetChildren()) do
                                    if v:IsA("Model") and v.Name == "Model" then
                                        if v:FindFirstChild("BarbedWire",true) then
                                            table.insert(ppModel,v)
                                        end
                                    end
                                end
                            end
            
                            for _,v in pairs(ppModel) do
                                for _,j in pairs(v:GetDescendants()) do
                                    if j:IsA("BasePart") and j.Name == "BarbedWire" and j.Color ~= Color3.fromRGB(202, 203, 209) then
                                        processLaser(j)
                                    end
                                end
                            end
            
                            Run.RenderStepped:Wait()
            
                            for _,v in pairs(workspace.Casino.Lasers:GetChildren()) do
                                processLaser(v)
                            end
                            for _,v in pairs(workspace.Casino.LasersMoving:GetChildren()) do
                                processLaser(v)
                            end
                            for _,v in pairs(workspace.Casino.CamerasMoving:GetChildren()) do
                                processLaser(v)
                            end
            
                            Run.RenderStepped:Wait()
            
                            for _,v in pairs(workspace.Casino.LaserCarousel.InnerModel:GetChildren()) do
                                if v.Name == "Part" then
                                    processLaser(v)
                                end
                            end
                        end)
                    else
                        for i,v in pairs(lasers) do
                            if i then
                                if v==nil then
                                    if i then
                                        i:Destroy()
                                    end
                                else
                                    i.Parent = v
                                    lasers[i] = nil
                                end
                            end
                        end
                    end
    
                    db = false
                end)
            end)()
        end
        
        -- DOOR NO CLIP
        do
            local originalTransparencies = {}
            local originalCollisions = {}
            --local changeEvents = {}
            local mult = 0.5
        
            local function handle(v)
                if v:IsA("BasePart") then
                    originalTransparencies[v] = originalTransparencies[v] or v.Transparency
                    if originalCollisions[v]==nil then
                        originalCollisions[v]=v.CanCollide
                    end
                    if configs["DoorNoClip"] then
                        v.Transparency = 1-((1-originalTransparencies[v])*(configs["DoorNoClipTransparent"] and mult or 1))
                        v.CanCollide = false
                    else
                        v.Transparency = originalTransparencies[v]
                        v.CanCollide = originalCollisions[v]
                    end
                    --[[ removed
                    if changeEvents[v]==nil then
                        changeEvents[v] = v:GetPropertyChangedSignal("Transparency"):Connect(function()
                            local t = v.Transparency
                            if t ~= originalTransparencies[v] and t ~= 1-((1-originalTransparencies[v])*mult) then
                                originalTransparencies[v] = t
                            end
                        end)
                    end
                    ]]--
                end
            end
        
            local db = false
            LPH_JIT_ULTRA(function()
                Run.RenderStepped:Connect(function()
                    if db then return else db = true end
    
                    local doors = CS:GetTagged("Door")
            
                    for _,v in pairs(doors) do
                        for _,j in pairs(v:GetDescendants()) do
                            handle(j)
                        end
                        handle(v)
                    end
        
                    for _=1,8 do
                        Run.RenderStepped:Wait()
                    end
    
                    db = false
                end)
            end)()
        end

        -- GUN MODS
        local updateNoReloadTime,updateNoBulletSpread,updateNoRecoil,updateFullAuto,updateNoShotDelay do
            function updateNoReloadTime()
                for _,v in pairs(RS.Game.ItemConfig:GetChildren()) do
                    local gun = require(v)
                    gun.ReloadTime = configs["NoReloadTime"] and 0 or 1
                end
            end
            function updateNoBulletSpread()
                for _,v in pairs(RS.Game.ItemConfig:GetChildren()) do
                    local gun = require(v)
                    gun.BulletSpread = configs["NoBulletSpread"] and 0 or 0.06
                end
            end
            function updateNoRecoil()
                for _,v in pairs(RS.Game.ItemConfig:GetChildren()) do
                    local gun = require(v)
                    gun.CamShakeMagnitude = configs["NoRecoil"] and 0 or 1
                end
            end
            function updateFullAuto()
                for _,v in pairs(RS.Game.ItemConfig:GetChildren()) do
                    local gun = require(v)
                    gun.FireAuto = configs["FullAuto"] and true
                end
            end
            function updateNoShotDelay()
                for _,v in pairs(RS.Game.ItemConfig:GetChildren()) do
                    local gun = require(v)
                    gun.FireFreq = configs["NoShotDelay"] and math.huge or 1
                end
            end

            updateNoReloadTime()
            updateNoBulletSpread()
            updateNoRecoil()
            updateFullAuto()
            updateNoShotDelay()
        end

        -- TP HACK
        local tpForward do
            function tpForward()
                pcall(function()
                    player.Character.PrimaryPart.CFrame = player.Character.PrimaryPart.CFrame*CFrame.new(0,0,-5)
                end)
            end
        end
        
        -- UI INITIATION
        do
            -- two underscores (__) at beggining of ui objects to differ from normal naming conventions
        
            -- PAGES
            do -- Player Page
                local __player = UI:CreatePage("Player",10288655901)
        
                local __character = __player:CreateSection("Character")
                local __utilities = __player:CreateSection("Utilities")
        
                __character:CreateToggle("Character Fly",configs["CharacterFlyEnabled"],function(newValue)
                    notify("Character fly binded to "..configs["CharacterFlyBind"])
                    configs["CharacterFlyEnabled"] = newValue
                    setCharacterFlyEnabled(false)
                end)

                __character:CreateSlider("Walk Speed",0,160,configs["WalkSpeed"],function(newValue)
                    configs["WalkSpeed"] = newValue
                end)

                __character:CreateSlider("Jump Power",0,500,configs["JumpPower"],function(newValue)
                    configs["JumpPower"] = newValue
                end)
        
                __utilities:CreateSlider("Character Fly Speed",5,120,configs["CharacterFlySpeed"],function(newValue)
                    configs["CharacterFlySpeed"] = newValue
                end,true,0)
        
                __utilities:CreateToggle("No Parachute",configs["NoParachute"],function(newValue)
                    configs["NoParachute"] = newValue;
                end)
        
                __utilities:CreateToggle("No Fall Damage",configs["NoFallDamage"],function(newValue)
                    configs["NoFallDamage"] = newValue;
                end)
        
                __utilities:CreateToggle("No Ragdoll",configs["NoRagdoll"],function(newValue)
                    configs["NoRagdoll"] = newValue;
                end)
        
                __utilities:CreateToggle("No E Wait",configs["NoPromptWait"],function(newValue)
                    configs["NoPromptWait"] = newValue;
                end)
        
                __utilities:CreateToggle("Remove Lasers",configs["LaserRemove"],function(newValue)
                    configs["LaserRemove"] = newValue;
                end)

                __utilities:CreateToggle("Door No-Clip",configs["DoorNoClip"],function(newValue)
                    configs["DoorNoClip"] = newValue;
                end)
        
                __utilities:CreateToggle("No-Clip Doors Transparent",configs["DoorNoClipTransparent"],function(newValue)
                    configs["DoorNoClipTransparent"] = newValue;
                end)
        
                __utilities:CreateToggle("Keycard Door Bypass",configs["KeycardDoorBypass"],function(newValue)
                    configs["KeycardDoorBypass"] = newValue;
                end)
        
                __utilities:CreateButton("Open All Doors",openAllDoors)
        
                __utilities:CreateToggle("Loop Open All Doors",configs["OpenAllDoorsLoop"],function(newValue)
                    configs["OpenAllDoorsLoop"] = newValue;
                end)
        
                __utilities:CreateToggle("No Cell Time",configs["NoCellTime"],function(newValue)
                    configs["NoCellTime"] = newValue;
                end)
        
                __utilities:CreateToggle("Anti-Taze",configs["AntiTaze"],function(newValue)
                    configs["AntiTaze"] = newValue;
                end)

                __utilities:CreateToggle("No Team Change Delay",configs["NoDelayTeamChange"],function(newValue)
                    configs["NoDelayTeamChange"] = newValue;
                end)
            end
            do -- Vehicle Page
                local __vehicle = UI:CreatePage("Vehicle",10253587852)
        
                local __utilities = __vehicle:CreateSection("Utilities")
                local __carMods = __vehicle:CreateSection("Car Mods")
        
                __utilities:CreateToggle("Inf Nitro",configs["InfNitro"],function(newValue)
                    configs["InfNitro"] = newValue
                end)
        
                __utilities:CreateToggle("Car Fly",configs["CarFlyEnabled"],function(newValue)
                    notify("Car fly binded to "..configs["CarFlyBind"])
                    configs["CarFlyEnabled"] = newValue
                    setCarFlyEnabled(false)
                end)
        
                __utilities:CreateSlider("Car Fly Speed",5,600,configs["CarFlySpeed"],function(newValue)
                    configs["CarFlySpeed"] = newValue
                end,true,0)
        
                __carMods:CreateSlider("Engine Speed",0,120,configs["CarEngineSpeed"],function(newValue)
                    configs["CarEngineSpeed"] = newValue
                end,true,0)
        
                __carMods:CreateSlider("Turn Speed",0,60,configs["CarTurnSpeed"],function(newValue)
                    configs["CarTurnSpeed"] = newValue/10
                end,true,0)
        
                __carMods:CreateSlider("Suspension Height",0,100,configs["CarSuspensionHeight"],function(newValue)
                    configs["CarSuspensionHeight"] = newValue
                end,true,0)
        
                __carMods:CreateSlider("Brakes Speed",0,120,configs["CarBrakesSpeed"],function(newValue)
                    configs["CarBrakesSpeed"] = newValue
                end,true,0)
        
                __carMods:CreateToggle("Tire Pop Bypass",configs["TirePopBypass"],function(newValue)
                    configs["TirePopBypass"] = newValue
                end,true)
            end
            do -- Combat Page
                local __combat = UI:CreatePage("Combat",10385782061)
        
                local __gunMods = __combat:CreateSection("Gun Mods")
        
                __gunMods:CreateToggle("No Reload Time",configs["NoReloadTime"],function(newValue)
                    configs["NoReloadTime"] = newValue
                    updateNoReloadTime()
                end)
                __gunMods:CreateToggle("No Bullet Spread",configs["NoBulletSpread"],function(newValue)
                    configs["NoBulletSpread"] = newValue
                    updateNoBulletSpread()
                end)
                __gunMods:CreateToggle("No Recoil",configs["NoRecoil"],function(newValue)
                    configs["NoRecoil"] = newValue
                    updateNoRecoil()
                end)
                __gunMods:CreateToggle("No Shot Delay",configs["NoShotDelay"],function(newValue)
                    configs["NoShotDelay"] = newValue
                    updateNoShotDelay()
                end)
                __gunMods:CreateToggle("Full Auto",configs["FullAuto"],function(newValue)
                    configs["FullAuto"] = newValue
                    updateFullAuto()
                end)
            end
            do -- Keybinds Page
                local __vehicle = UI:CreatePage("Keybinds",10298464250)
        
                local __ui = __vehicle:CreateSection("UI")
                local __other = __vehicle:CreateSection("Other")
        
                __ui:CreateKeybind("Toggle UI",Enum.KeyCode[configs["ToggleUI"]],function(newValue)
                    configs["ToggleUI"] = newValue.Name
                end)
        
                __other:CreateKeybind("Character Fly Bind",Enum.KeyCode[configs["CharacterFlyBind"]],function(newValue)
                    configs["CharacterFlyBind"] = newValue.Name
                end)
        
                __other:CreateKeybind("Car Fly Bind",Enum.KeyCode[configs["CarFlyBind"]],function(newValue)
                    configs["CarFlyBind"] = newValue.Name
                end)

                __other:CreateKeybind("TP Forward Bind",Enum.KeyCode[configs["ForwardBind"]],function(newValue)
                    configs["ForwardBind"] = newValue.Name
                end)
        
                -- Input
                UIS.InputBegan:Connect(function(input,gpe)
                    if input.UserInputType == Enum.UserInputType.Keyboard and not gpe then
                        if input.KeyCode.Name == configs["ToggleUI"] then
                            UI:Toggle()
                        elseif input.KeyCode.Name == configs["CharacterFlyBind"] then
                            setCharacterFlyEnabled()
                        elseif input.KeyCode.Name == configs["CarFlyBind"] then
                            setCarFlyEnabled()
                        elseif input.KeyCode.Name == configs["ForwardBind"] then
                            if not Kratos:GetLocalPlayerVehicle() then
                                tpForward()
                            end
                        end
                    end
                end)
            end
            if IS_PREMIUM then -- Premium
                do -- Premium Page
                    local __premium = UI:CreatePage("Premium",10379380543)
                end
                do -- Beta Page
                    local __beta = UI:CreatePage("Beta",10382512488)


                end
            end
        end
    end;

    --[[

    ██████╗░░█████╗░██╗███╗░░██╗██████╗░░█████╗░░██╗░░░░░░░██╗  ███████╗██████╗░██╗███████╗███╗░░██╗██████╗░░██████╗
    ██╔══██╗██╔══██╗██║████╗░██║██╔══██╗██╔══██╗░██║░░██╗░░██║  ██╔════╝██╔══██╗██║██╔════╝████╗░██║██╔══██╗██╔════╝
    ██████╔╝███████║██║██╔██╗██║██████╦╝██║░░██║░╚██╗████╗██╔╝  █████╗░░██████╔╝██║█████╗░░██╔██╗██║██║░░██║╚█████╗░
    ██╔══██╗██╔══██║██║██║╚████║██╔══██╗██║░░██║░░████╔═████║░  ██╔══╝░░██╔══██╗██║██╔══╝░░██║╚████║██║░░██║░╚═══██╗
    ██║░░██║██║░░██║██║██║░╚███║██████╦╝╚█████╔╝░░╚██╔╝░╚██╔╝░  ██║░░░░░██║░░██║██║███████╗██║░╚███║██████╔╝██████╔╝
    ╚═╝░░╚═╝╚═╝░░╚═╝╚═╝╚═╝░░╚══╝╚═════╝░░╚════╝░░░░╚═╝░░░╚═╝░░  ╚═╝░░░░░╚═╝░░╚═╝╚═╝╚══════╝╚═╝░░╚══╝╚═════╝░╚═════╝░

    ]]--

    [8888615802] = function()
        -- HELIOS VARS
        local configs = {
            ["CharacterFlyEnabled"] = false;
            ["CharacterFlySpeed"] = 35;
            ["ToggleUI"] = "LeftControl";
            ["FlyBind"] = "X";
            ["LoopFillInv"] = false;
            ["GayDialogue"] = false;
            ["LoopReturnTable"] = false;
            ["LoopFeedOrange"] = false;
            ["BeTheCutscene"] = false;
        }

        local FILE_TREE = {
            ["configs.json"] = {}
        }

        local metadata = {
            ["inBeta"] = true;
            
        }

        -- START LOADING
        UI:StartLoading({
            ["Title"] = Rank;
            ["ThumbnailId"] = 10026592733;
            ["GameName"] = "Rainbow Friends";
            ["TitleTextColor"] = RankColor;
        })

        -- GENERAL VARIABLES
        local Dialogue = player:WaitForChild("PlayerGui",60):WaitForChild("PermanentGUI",60):WaitForChild("Dialogue",60)
        local Monsters = workspace:WaitForChild("Monsters")
        local Map = workspace:WaitForChild("Map_C1")

        -- SCRIPT VARIABLES

        -- HELIOS INIT
        data,oldMetadata,key = Helios:Init(game.PlaceId,FILE_TREE,metadata)
        if typeof(data["configs.json"])=="table" then
            configs = Helios:reconcile(data["configs.json"],configs)
        end

        -- METADATA INIT
        do
            local function wipe()
                delfolder(Helios._place_directory)
            end
            
        end

        -- KRATOS FUNCTIONS
        do
            function Kratos:GetLocalCharacter()
                local c = player.Character

                if c and c:IsDescendantOf(workspace) and c:FindFirstChild("Head") and c.PrimaryPart and c:FindFirstChild("Humanoid") then
                    if c:FindFirstChild("Humanoid") and c:FindFirstChild("Humanoid").Health > 0 then
                        return c
                    else
                        return false
                    end
                end
            end
        
            function Kratos:Init()

                -- Saving Configs
                local lastSave = os.clock()
                LPH_JIT_MAX(function()
                    Run.RenderStepped:Connect(function()
                        local now = os.clock()
                        if now-lastSave>=1 then
                            lastSave = now
                            data["configs.json"] = Helios:encode(configs)
                            Helios:updateWithDirectory(data)
                        end
                    end)
                end)()
            end
        end
        
        Kratos:Init()

        
        -- CHARACTER FLY
        local setCharacterFlyEnabled do
            local _fly = false

            function setCharacterFlyEnabled(toggle)
                if toggle == nil then
                    toggle = not _fly
                end
                _fly = toggle
            end

            local core
        
            local function repairCore(char)
                if core == nil then
                    core = Instance.new("Part")
                    Instance.new("Weld").Parent = core
                    Instance.new("BodyPosition").Parent = core
                    Instance.new("BodyForce").Parent = core
                end
                core.Size = Vector3.new(2,5.6,2)
                core.Anchored = false
                core.CanCollide = true
                core.Transparency = 1
                core.CanTouch = false
                core.CanQuery = false
                core.Massless = true
            
                core.Weld.Part0 = core
                core.Weld.Part1 = char.PrimaryPart
            
                core.BodyPosition.MaxForce = Vector3.new(400000,400000,400000)
                core.BodyPosition.D = 4000
                core.BodyPosition.P = 70000
            
                core.BodyForce.Force = Vector3.new(0, char.PrimaryPart.AssemblyMass * workspace.Gravity, 0);
            
                core.Parent = workspace
            end
        
            local keysDown = {}

            LPH_JIT_ULTRA(function()
                Run.RenderStepped:Connect(function()
                    local char = Kratos:GetLocalCharacter()
                    if char and char.Humanoid.Sit == false and _fly and configs["CharacterFlyEnabled"] and workspace.CurrentCamera then
                        local direction = Vector3.new()
                
                        if keysDown[Enum.KeyCode.W] then
                            direction = direction+Vector3.new(0,0,-1)
                        end
                        if keysDown[Enum.KeyCode.S] then
                            direction = direction+Vector3.new(0,0,1)
                        end
                        if keysDown[Enum.KeyCode.A] then
                            direction = direction+Vector3.new(-1,0,0)
                        end
                        if keysDown[Enum.KeyCode.D] then
                            direction = direction+Vector3.new(1,0,0)
                        end
                        if keysDown[Enum.KeyCode.Space] then
                            direction = direction+Vector3.new(0,1,0)
                        end
                
                        if math.abs(direction.X)+math.abs(direction.Y)+math.abs(direction.Z)>1 then
                            local sq2 = math.sqrt(2)/2
                            direction = direction*sq2
                        end
                
                        direction = Vector3.new(direction.X,direction.Y*0.75,direction.Z)
                
                        repairCore(char)
                        local current = char.PrimaryPart.Position
                        local body = core.BodyPosition
                        local lv = workspace.CurrentCamera.CFrame.LookVector
                        local goal = CFrame.lookAt(Vector3.zero,lv)+current
                        goal = goal*CFrame.new(direction*configs["CharacterFlySpeed"])
                        char.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false)
                        body.Position = goal.Position
                    else
                        --print(char,char.Humanoid.Sit == false, _fly, configs["CharacterFlyEnabled"], workspace.CurrentCamera)
                        if core then
                            pcall(function()
                                core:Destroy()
                            end)
                        end
                        pcall(function()
                            char.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown,true)
                        end)
                        core = nil
                    end
                end)
            end)()
        
            UIS.InputBegan:Connect(function(input,gpe)
                if input.UserInputType == Enum.UserInputType.Keyboard and not gpe then
                    keysDown[input.KeyCode] = true
                end
            end)
        
            UIS.InputEnded:Connect(function(input,gpe)
                if input.UserInputType == Enum.UserInputType.Keyboard and not gpe then
                    keysDown[input.KeyCode] = false
                end
            end)
        
            player.CharacterRemoving:Connect(function()
                pcall(function()
                    core:Destroy()
                end)
                core = nil
            end)
        end

        local fillInventory do
            local function isObject(v)
                return string.find(v.Name,"Food") or string.find(v.Name,"Block") or string.find(v.Name,"Fuse") or string.find(v.Name,"Battery")
            end

            local function touch(char,v,toggle)
                pcall(function()
                    firetouchinterest(char.PrimaryPart,v.TouchTrigger,toggle and 1 or 0)
                end)
            end

            function fillInventory()
                local char = Kratos:GetLocalCharacter()

                if char then
                    local objects = {}

                    for _,v in pairs(workspace:GetChildren()) do
                        if isObject(v) then
                            table.insert(objects,v)
                            touch(char,v,true)
                        end
                    end
                    Kratos:Wait()
                    for _,v in pairs(objects) do
                        if isObject(v) then
                            touch(char,v,false)
                        end
                    end
                end
            end
        end

        local returnToTable do
            local groupStructures = workspace:WaitForChild("GroupBuildStructures")

            local function touch(char,v,toggle)
                pcall(function()
                    firetouchinterest(char.PrimaryPart,v,toggle and 1 or 0)
                end)
            end

            function returnToTable()
                local char = Kratos:GetLocalCharacter()

                if char then
                    for _,v in pairs(groupStructures:GetChildren()) do
                        touch(char,v.Trigger,false)
                        Kratos:Wait()
                        touch(char,v.Trigger,true)
                    end
                end
            end
        end

        local feedOrange do
            local function touch(char,v,toggle)
                pcall(function()
                    firetouchinterest(char.PrimaryPart,v,toggle and 1 or 0)
                end)
            end

            function feedOrange()
                local char = Kratos:GetLocalCharacter()
                local dispenser = Map:FindFirstChild("FoodDispenser")

                if dispenser and char then
                    touch(char,dispenser.Trigger,false)
                    Kratos:Wait()
                    touch(char,dispenser.Trigger,true)
                end
            end
        end

        -- LOOP FILL INV
        do
            local TIME_BETWEEN_LOOP = 0.05
            local _lastRan = 0
            LPH_JIT_MAX(function()
                Run.RenderStepped:Connect(function()
                    local now = os.clock()
                    if configs["LoopFillInv"] and now-_lastRan>= TIME_BETWEEN_LOOP then
                        _lastRan = now
                        fillInventory()
                    end
                end)
            end)()
        end

        -- LOOP RETURN TABLE
        do
            local TIME_BETWEEN_LOOP = 0.1
            local _lastRan = 0
            LPH_JIT_MAX(function()
                Run.RenderStepped:Connect(function()
                    local now = os.clock()
                    if configs["LoopReturnTable"] and now-_lastRan>= TIME_BETWEEN_LOOP then
                        _lastRan = now
                        returnToTable()
                    end
                end)
            end)()
        end

        -- LOOP FEED ORANGE
        do
            local TIME_BETWEEN_LOOP = 0.05
            local _lastRan = 0
            LPH_JIT_MAX(function()
                Run.RenderStepped:Connect(function()
                    local now = os.clock()
                    if configs["LoopFeedOrange"] and now-_lastRan>= TIME_BETWEEN_LOOP then
                        _lastRan = now
                        feedOrange()
                    end
                end)
            end)()
        end

        -- BE THE CUTSCENE
        do
            LPH_JIT_MAX(function()
                Run.RenderStepped:Connect(function()
                    local camera = workspace.CurrentCamera
                    if camera and camera.CameraType == Enum.CameraType.Scriptable and configs["BeTheCutscene"] then
                        local char = Kratos:GetLocalCharacter()
                        if char then
                            local root = char.PrimaryPart
                            char.Humanoid.Sit = false
                            root.CFrame = CFrame.lookAt((camera.CFrame*CFrame.new(0,-0.5,-5)).Position,camera.CFrame.Position)
                        end
                    end
                end)
            end)()
        end

        -- GAY DIALOGUE
        do
            local gay = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)), ColorSequenceKeypoint.new(1/6, Color3.fromRGB(255, 255, 0)), ColorSequenceKeypoint.new(1/3, Color3.fromRGB(0, 255, 0)), ColorSequenceKeypoint.new(1/2, Color3.fromRGB(0, 255, 255)), ColorSequenceKeypoint.new(2/3, Color3.fromRGB(0, 0, 255)), ColorSequenceKeypoint.new(5/6, Color3.fromRGB(255, 0, 255)),ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))}

            local function getColor(percentage, ColorKeyPoints)
                if (percentage < 0) or (percentage>1) then
                    Kratos:Warn('getColor got out of bounds percentage (less than 0 or greater than 1')
                end
                
                local closestToLeft = ColorKeyPoints[1]
                local closestToRight = ColorKeyPoints[#ColorKeyPoints]
                local LocalPercentage = 0.5
                local color = closestToLeft.Value
                
                for i=1,#ColorKeyPoints-1 do
                    if (ColorKeyPoints[i].Time <= percentage) and (ColorKeyPoints[i+1].Time >= percentage) then
                        closestToLeft = ColorKeyPoints[i]
                        closestToRight = ColorKeyPoints[i+1]
                        LocalPercentage = (percentage-closestToLeft.Time)/(closestToRight.Time-closestToLeft.Time)
                        color = closestToLeft.Value:Lerp(closestToRight.Value,LocalPercentage)
                        return color
                    end
                end
                Kratos:Warn('Color not found!')
                return color
            end

            local function getGay(t)
                return getColor(t%1,gay.Keypoints)
            end

            local speaker = Dialogue:WaitForChild("Frame"):WaitForChild("ImageLabel")
            local message = Dialogue:WaitForChild("Message")

            LPH_JIT_MAX(function()
                Run.RenderStepped:Connect(function()
                    local on = configs["GayDialogue"]
                    local t = os.clock()*0.3
                    speaker.ImageColor3 = on and getGay(t) or Color3.new(0,0,0)
                    message.TextColor3 = on and getGay(t) or Color3.new(1,1,1)
                end)
            end)()
        end

        -- UI INITIATION
        do
            -- two underscores (__) at beggining of ui objects to differ from normal naming conventions
        
            -- PAGES
            do -- Player Page
                local __player = UI:CreatePage("Player",10288655901)
        
                local __character = __player:CreateSection("Character")
                local __utilities = __player:CreateSection("Utilities")

                __character:CreateToggle("Fly",configs["CharacterFlyEnabled"],function(newValue)
                    configs["CharacterFlyEnabled"] = newValue
                end)

                __character:CreateSlider("Character Fly Speed",5,120,configs["CharacterFlySpeed"],function(newValue)
                    configs["CharacterFlySpeed"] = newValue
                end,true,0)

                __utilities:CreateToggle("Be The Cutscene",configs["BeTheCutscene"],function(newValue)
                    configs["BeTheCutscene"] = newValue
                end)

                __utilities:CreateButton("Fill Inventory",fillInventory)

                __utilities:CreateToggle("Loop Fill Inventory",configs["LoopFillInv"],function(newValue)
                    configs["LoopFillInv"] = newValue
                end)

                __utilities:CreateButton("Return To Table",returnToTable)

                __utilities:CreateToggle("Loop Return To Table",configs["LoopReturnTable"],function(newValue)
                    configs["LoopReturnTable"] = newValue
                end)

                __utilities:CreateButton("Feed Orange",feedOrange)

                __utilities:CreateToggle("Loop Feed Orange",configs["LoopFeedOrange"],function(newValue)
                    configs["LoopFeedOrange"] = newValue
                end)
                
                __utilities:CreateToggle("Gay Dialogue",configs["GayDialogue"],function(newValue)
                    configs["GayDialogue"] = newValue
                end)
            end
            do -- Keybinds Page
                local __keybinds = UI:CreatePage("Keybinds",10298464250)
        
                local __ui = __keybinds:CreateSection("UI")
                local __other = __keybinds:CreateSection("Other")
        
                __ui:CreateKeybind("Toggle UI",Enum.KeyCode[configs["ToggleUI"]],function(newValue)
                    configs["ToggleUI"] = newValue.Name
                end)
        
                __other:CreateKeybind("Fly Bind",Enum.KeyCode[configs["FlyBind"]],function(newValue)
                    configs["FlyBind"] = newValue.Name
                end)
        
                -- Input
                UIS.InputBegan:Connect(function(input,gpe)
                    if input.UserInputType == Enum.UserInputType.Keyboard and not gpe then
                        if input.KeyCode.Name == configs["ToggleUI"] then
                            UI:Toggle()
                        elseif input.KeyCode.Name == configs["FlyBind"] then
                            setCharacterFlyEnabled()
                        end
                    end
                end)
            end
            if IS_PREMIUM then -- Premium
                do -- Premium Page
                    local __premium = UI:CreatePage("Premium",10379380543)
                end
                do -- Beta Page
                    local __beta = UI:CreatePage("Beta",10382512488)


                end
            end
        end
    end;

    [0] = function()
        -- HELIOS VARS
        local configs = {
            
        }

        local FILE_TREE = {
            ["configs.json"] = {}
        }

        local metadata = {
            ["inBeta"] = true;
            
        }

        -- START LOADING
        UI:StartLoading({
            ["Title"] = Rank;
            ["ThumbnailId"] = 10026592733;
            ["GameName"] = "Rainbow Friends";
            ["TitleTextColor"] = RankColor;
        })

        -- GENERAL VARIABLES
        

        -- SCRIPT VARIABLES


        -- HELIOS INIT
        data,oldMetadata,key = Helios:Init(game.PlaceId,FILE_TREE,metadata)
        if typeof(data["configs.json"])=="table" then
            configs = Helios:reconcile(data["configs.json"],configs)
        end

        -- METADATA INIT
        do
            local function wipe()
                delfolder(Helios._place_directory)
            end
            
        end

        -- KRATOS FUNCTIONS
        do
            function Kratos:GetLocalCharacter()
                local c = player.Character

                if c and c:IsDescendantOf(workspace) and c:FindFirstChild("Head") and c.PrimaryPart and c:FindFirstChild("Humanoid") then
                    if c:FindFirstChild("Humanoid") and c:FindFirstChild("Humanoid").Health > 0 then
                        return c
                    else
                        return false
                    end
                end
            end
        
            function Kratos:Init()

                -- Saving Configs
                local lastSave = os.clock()
                LPH_JIT_MAX(function()
                    Run.RenderStepped:Connect(function()
                        local now = os.clock()
                        if now-lastSave>=1 then
                            lastSave = now
                            data["configs.json"] = Helios:encode(configs)
                            Helios:updateWithDirectory(data)
                        end
                    end)
                end)()
            end
        end
        
        Kratos:Init()

        


        -- UI INITIATION
        do
            -- two underscores (__) at beggining of ui objects to differ from normal naming conventions
        
            -- PAGES
            do -- Player Page
                local __player = UI:CreatePage("Player",10288655901)
        
                local __utilities = __player:CreateSection("Utilities")

                __utilities:CreateSlider("Deez Nutz",0,160,3,function(newValue)
                    newValue = 3
                end)
            end
            if IS_PREMIUM then -- Premium
                do -- Premium Page
                    local __premium = UI:CreatePage("Premium",10379380543)
                end
                do -- Beta Page
                    local __beta = UI:CreatePage("Beta",10382512488)


                end
            end
        end
    end;
}

if places[game.PlaceId] then
    places[game.PlaceId]()
end

-- ANTI-IDLE KICK
do
    local clickLocation = Vector2.new()
    player.Idled:Connect(function()
        VU:CaptureController()
        VU:ClickButton2(clickLocation)
    end)
end

-- KEY SYSTEM INITIATION
do
    local __premium = UI:CreatePage("Key",10380403928)

    local __key = __premium:CreateSection("Premium")

    local inputKey = key

    __key:CreateTextBox("Premium Key",key,function(newValue)
        newValue = string.gsub(newValue, "^%s+", "")
        newValue = string.gsub(newValue, "%s+$", "")
        inputKey = newValue
    end)

    __key:CreateButton("Update Key",function()
        Helios:setKey(inputKey)
    end)

    local body = "Premium gives you access to certain features in all of our games that free users do not have. You also get access to beta features before anyone else does!\n \nYou can purchase a key at our Discord server, click the button below to copy the invite. Follow the instructions in the server on how to purchase a key. Upon retrieving your key, enter it in the text box above and click the update key button. Afterwards, rejoin and reload the script and if the key is valid, you should be a premium user. Contact us on our Discord for any issues."

    __key:CreateLabel(body)

    __key:CreateButton("Copy Discord Invite",function()
        setclipboard(DISCORD)
    end)
end

-- DONE LOADING
UI:StopLoading()
print("Kratos v"..VERSION.." initiated")
