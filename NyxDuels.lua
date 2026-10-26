--//Library
local WindUI = loadstring(game:HttpGet(
    "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"
))()

--// Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Net = Packages and Packages:WaitForChild("Net")
local ThrowEvent = Net and Net:WaitForChild("RE/ThrowEvent")

--// Variables
local Client = Players.LocalPlayer

--// Utils
local Utils = {}

--// Cache
local Cache = {
    ClosestPlayers = {},
}

function Utils:Character(Player)
    if not Player then
        return
    end

    return Player.Character
end

function Utils:GetCharacterInstance(Character,Name)
    if not Character or not Name then
        return
    end

    return Character:FindFirstChild(Name,true)
end

function Utils:TeamCheck(Player,WaitForTeam)
    if not Player then
        return
    end

    local Character = self:Character(Player)
    if not Character then
        return
    end

    local IsTeam = Utils:GetCharacterInstance(Character,"TeammateIconPart") 

    return IsTeam
end

function Utils:WallCheck(PlayerA,PlayerB)
    if not PlayerA or not PlayerB then
        return true
    end

    local CharacterA = self:Character(PlayerA)
    local CharacterB = self:Character(PlayerB)
    if not CharacterA or not CharacterB then
        return true
    end

    local RootPartA = self:GetCharacterInstance(CharacterA,"HumanoidRootPart")
    if not RootPartA then
        return true
    end

    local Params = RaycastParams.new()
    Params.FilterType = Enum.RaycastFilterType.Exclude
    Params.FilterDescendantsInstances = {
        CharacterA
    }

    for _,Object in ipairs(CharacterB:GetChildren()) do
        if not Object:IsA("BasePart") then
            continue
        end

            local Origin = RootPartA.Position
            local Direction = (Object.Position - RootPartA.Position) 

            local Result = Workspace:Raycast(Origin,Direction,Params)

            if not Result then
                continue
            end

            if not Result.Instance then
                continue
            end

            if Result.Instance:IsDescendantOf(CharacterB) then
                return false, Result.Instance
            end

    end

    return true
end

function Utils:IsDead(Player)
    if not Player then
        return
    end

    local Character = self:Character(Player)
    if not Character then
        return
    end

    local Humanoid = self:GetCharacterInstance(Character,"Humanoid")
    if not Humanoid then
        return
    end

    return Humanoid.Health == 0 or false
end

function Utils:OnLobby()
    local PlayerGui = Client:FindFirstChild("PlayerGui")
    local Main = PlayerGui and PlayerGui:FindFirstChild("Main")
    local MainGameFrame = Main and Main:FindFirstChild("MainGameFrame")

    if not MainGameFrame or not MainGameFrame.Visible then
        return true
    end

    return false
end

function Utils:GetClosestPlayers()
    local ClosestPlayers = {}

    local Character  = self:Character(Client)
    if not Character then
        ClosestPlayers = {{
         Player = Client,
         Distance = 0,
        }}
       Cache.ClosestPlayers = ClosestPlayers
        return
    end

    local RootPart = self:GetCharacterInstance(Character,"HumanoidRootPart")
    if not RootPart then
     ClosestPlayers = {{
         Player = Client,
         Distance = 0,
        }}
       Cache.ClosestPlayers = ClosestPlayers
        return
    end

    for _,Player in ipairs(Players:GetPlayers()) do
        if Player == Client then
            continue
        end

        local PlayerCharacter = self:Character(Player)
        if not PlayerCharacter then
            continue
        end

        local PlayerRootPart = self:GetCharacterInstance(PlayerCharacter,"HumanoidRootPart")
        if not PlayerRootPart then
            continue
        end

        local Distance = (RootPart.Position - PlayerRootPart.Position).Magnitude

        table.insert(ClosestPlayers,{
            Player = Player,
            Distance = Distance,
        })
    end

    table.sort(ClosestPlayers,function(DataA,DataB)
        return DataA.Distance < DataB.Distance
    end)

    Cache.ClosestPlayers = ClosestPlayers
    return ClosestPlayers
end

function Utils:GetGun(Player)
    if not Player then
        return
    end

    local Backpack = Player.Backpack
    local Character = self:Character(Player)

    if not Backpack or not Character then
        return
    end

    local Fire = Backpack:FindFirstChild("fire",true) or Character:FindFirstChild("fire",true)
    if not Fire then
        return
    end

    return Fire and Fire.Parent or nil
end

function Utils:GetKnife(Player)
    if not Player then
        return
    end

    local Backpack = Player.Backpack
    local Character = self:Character(Player)

    if not Backpack or not Character then
        return
    end

    local Throw = Backpack:FindFirstChild("Throw",true) or Character:FindFirstChild("Throw",true)
    if not Throw then
        return
    end

    return Throw and Throw.Parent or nil
end

function Utils:EquipTool(Tool)
    if not Tool then
        return
    end

    local Character = self:Character(Client)
    if not Character then
        return
    end

    pcall(function()
    Tool.Parent = Character
    end)
end

function Utils:ChangeKnifeMode(State)
 local PlayerGui = Client:FindFirstChild("PlayerGui")
 if not PlayerGui then
  return
 end

 local Main = PlayerGui:FindFirstChild("Main")
 if not Main then
  return
 end

 local MobileKnifeGui = Main:FindFirstChild("MobileKnifeGui")
 if not MobileKnifeGui then
  return
 end

 local ThrowMode = MobileKnifeGui:FindFirstChild("ThrowMode")
 if not ThrowMode then
  return
 end

 ThrowMode.Value = State
end

--// Aimbot

local AimbotManager = {
    State = false,

    Methods = {},

    TeamCheck = true,
    WallCheck = false,
    IgnoreDead = true,
}

function AimbotManager.Methods:GetTarget()
    local ClosestPlayers = Cache.ClosestPlayers

    for _,Data in ipairs(ClosestPlayers) do
        local Player = Data.Player
        if not Player then
            continue
        end

        if AimbotManager.TeamCheck then
            if Utils:TeamCheck(Player,false) then
                continue
            end
        end

        if AimbotManager.WallCheck then
            if Utils:WallCheck(Client,Player) then
                continue
            end
        end

        if AimbotManager.IgnoreDead then
            if Utils:IsDead(Player) then
                continue
            end
        end

        return Player

    end

    return nil
end

--!mv:omit
function AimbotManager.Methods:EnableAimbot()
    local Connection

    Connection = RunService.Heartbeat:Connect(function()
        if not AimbotManager.State then
            Connection:Disconnect()
            return
        end

        if Utils:IsDead(Client) then
            return
        end

        if Utils:OnLobby() then
            return
        end

        local Target = AimbotManager.Methods:GetTarget()
        if not Target then
            return
        end

        local Character = Utils:Character(Target)
        if not Character then
            return
        end

        local Part = nil

        if AimbotManager.WallCheck then
            local WallCheck,VisiblePart = Utils:WallCheck(Client,Target)
            if not VisiblePart then
                return
            end

            Part = VisiblePart
        end

        if not AimbotManager.WallCheck then
            Part = Utils:GetCharacterInstance(Character,"HumanoidRootPart")
        end

        if not Part then
            return
        end

        local Camera = Workspace.CurrentCamera
        if not Camera then
            return
        end

        Camera.CameraType = Enum.CameraType.Track
        Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position,Part.Position)

    end)
end

--// Auto Shoot
local AutoShootManager = {
    State = false,

    Methods = {},

    TeamCheck = true,
    WallCheck = true,
    IgnoreDead = true,
}

function AutoShootManager.Methods:GetTarget()
    local ClosestPlayers = Cache.ClosestPlayers

    for _,Data in ipairs(ClosestPlayers) do
        local Player = Data.Player
        if not Player then
            continue
        end

        if AutoShootManager.TeamCheck then
            if Utils:TeamCheck(Player,false) then
                continue
            end
        end

        if AutoShootManager.WallCheck then
            if Utils:WallCheck(Client,Player) then
                continue
            end
        end

        if AutoShootManager.IgnoreDead then
            if Utils:IsDead(Player) then
                continue
            end
        end

        return Player

    end
end

function AutoShootManager.Methods:GetFallBackTarget()
 local ClosestPlayers = Cache.ClosestPlayers

    for _,Data in ipairs(ClosestPlayers) do
        local Player = Data.Player
        if not Player then
            continue
        end

        if AutoShootManager.TeamCheck then
            if Utils:TeamCheck(Player,false) then
                continue
            end
        end

        if AutoShootManager.IgnoreDead then
            if Utils:IsDead(Player) then
                continue
            end
        end

        return Player

    end
end

--!mv:omit
function AutoShootManager.Methods:EnableAutoShoot()
    local LastShoot = os.clock()

    local Connection

    Connection = RunService.Heartbeat:Connect(function()
        if not AutoShootManager.State then
            Connection:Disconnect()
            return
        end

        if Utils:IsDead(Client) then
            return
        end

        if Utils:OnLobby() then
            return
        end

        local Target = AutoShootManager.Methods:GetTarget()
        if not Target then
            return
        end

        local Character = Utils:Character(Target)
        if not Character then
            return
        end

        local Part = nil

        if AutoShootManager.WallCheck then
            local WallCheck,VisiblePart = Utils:WallCheck(Client,Target)
            if not VisiblePart then
                return
            end

            Part = VisiblePart
        end

        if not AutoShootManager.WallCheck then
            Part = Utils:GetCharacterInstance(Character,"HumanoidRootPart")
        end

        if not Part then
            return
        end

        local Gun = Utils:GetGun(Client)
        if not Gun then
            return
        end

        if os.clock() - LastShoot >= 2.6 then

         for _,Script in ipairs(Gun:GetChildren()) do
         if Script:IsA("LocalScript") then
          Script.Enabled = false
          task.wait(0.05)
          Script.Enabled = true
          task.wait(0.05)
         end
        end

            Utils:EquipTool(Gun)
            Gun:Activate()
            LastShoot = os.clock()
        end

    end)
end

local OrbsFarmManager = {
    State = false,

    Methods = {},

    CollectOrbDelay = 1,
    InstaCollect = false,
}

function OrbsFarmManager.Methods:GetOrbs()
    local SpawnablesClient = Workspace:FindFirstChild("SpawnablesClient")
    if not SpawnablesClient then
        return nil
    end

    local Orbs = {}
    for _,Orb in ipairs(SpawnablesClient:GetChildren()) do
        local Touch = Orb:FindFirstChild("Touch")
        if not Touch then
            continue
        end

        table.insert(Orbs,Touch)
    end

    return Orbs
end

function OrbsFarmManager.Methods:AutoFarmOrbsEnable()
    task.spawn(function()
        while true do
            if not OrbsFarmManager.State then
                break
            end

            local Character = Utils:Character(Client)
            if not Character then
                continue
            end

            local RootPart = Utils:GetCharacterInstance(Character,"HumanoidRootPart")
            if not RootPart then
                continue
            end

            local Orbs = self:GetOrbs()

            if not Orbs then
                continue
            end

            for _,Orb in ipairs(Orbs) do
                if not Orb then
                    continue
                end

                if not Orb:IsA("BasePart") then
                    continue
                end

                if not Orb.Parent then
                    continue
                end

                if not firetouchinterest then
                    continue
                end

                pcall(function()
                firetouchinterest(RootPart,Orb,0)
                task.wait(0.01)
                firetouchinterest(RootPart,Orb,1)
                end)

                if not OrbsFarmManager.InstaCollect then
                    task.wait(OrbsFarmManager.CollectOrbDelay)
                end

            end
            task.wait(0.01)
        end
    end)
end

--// Esp
local EspManager = {
    State = false,

    Methods = {},

    EspObjects = {},

    TeamColor = Color3.fromRGB(0,255,0),
    EnemyColor = Color3.fromRGB(255,0,0),
    ClientColor = Color3.fromRGB(128, 0, 255),

    FillTransparency = 0.5,
    OutlineTransparency = 0,

    ExcludeClient = false,
}


function EspManager.Methods:AddEsp(Player)
    if not Player then
        return
    end

    if EspManager.EspObjects[Player] then
        return EspManager.EspObjects[Player]
    end

    local Esp = Instance.new("Highlight")
    Esp.Name = "Nyx Esp"
    Esp.FillColor = Color3.new(0, 0, 0)
    Esp.OutlineColor = Color3.new(0, 0, 0)
    Esp.FillTransparency = EspManager.FillTransparency
    Esp.OutlineTransparency = EspManager.OutlineTransparency
    Esp.Enabled = false
    Esp.Parent = Workspace

    EspManager.EspObjects[Player] = Esp

    self:UpdateEsp(Player)

    return Esp
end


function EspManager.Methods:RemoveEsp(Player)
    if not Player then
        return
    end

    local Esp = EspManager.EspObjects[Player]
    if not Esp then
        return
    end

    Esp:Destroy()
    EspManager.EspObjects[Player] = nil
end

function EspManager.Methods:UpdateEsp(Player)
    if not Player then
        return
    end

    local Esp = EspManager.EspObjects[Player]
    if not Esp then
        Esp = self:AddEsp(Player)
        if not Esp then
            return
        end
    end

    local Character = Utils:Character(Player)

    -- Puede ser nil durante el respawn.
    Esp.Adornee = Character

    if Player == Client then
        Esp.OutlineColor = EspManager.ClientColor
        Esp.FillColor = EspManager.ClientColor
    else
        local IsTeammate = Utils:TeamCheck(Player,true)
        local Color = IsTeammate
            and EspManager.TeamColor
            or EspManager.EnemyColor

        Esp.OutlineColor = Color
        Esp.FillColor = Color
    end

    Esp.FillTransparency = EspManager.FillTransparency
    Esp.OutlineTransparency = EspManager.OutlineTransparency

    Esp.Enabled = EspManager.State
        and Character ~= nil
        and not (Player == Client and EspManager.ExcludeClient)
end

local HitboxManager = {
 State = false,

 Objects = {},
 Methods = {},

 Size = 10,
 Transparency = 0.5,
 Color = Color3.fromRGB(0,0,0),

 TeamCheck = true,
 IgnoreDead = true,
}

function HitboxManager.Methods:CreateHitbox(Player)
 if not Player then
  return
 end

 if Player == Client then
  return
 end

 local Character = Utils:Character(Player)
 if not Character then
  return
 end

 local RootPart = Utils:GetCharacterInstance(Character,"HumanoidRootPart")
 if not RootPart then
  return
 end

 local Hitbox = Instance.new("Part")
 Hitbox.Name = "H"
 Hitbox.Size = Vector3.one * HitboxManager.Size
 Hitbox.Transparency = HitboxManager.Transparency
 Hitbox.Color = HitboxManager.Color
 Hitbox.Material = Enum.Material.Neon
 Hitbox.CanCollide = false
 Hitbox.CanTouch = true
 Hitbox.Massless = true
 Hitbox.CanQuery = true
 Hitbox.Anchored = false
 Hitbox.Parent = Character

 Hitbox.CFrame = RootPart.CFrame

 local Weld = Instance.new("WeldConstraint")
 Weld.Part0 = Hitbox
 Weld.Part1 = RootPart
 Weld.Parent = Hitbox

 HitboxManager.Objects[Player] = Hitbox

 Hitbox.Size = HitboxManager.State and Vector3.one * HitboxManager.Size or Vector3.zero
 return Hitbox
end


function HitboxManager.Methods:UpdateHitbox(Player)
    if not Player or Player == Client then
        return
    end

    local Character = Player.Character
    if not Character then
        return
    end

    local Hitbox = HitboxManager.Objects[Player]

    if not Hitbox
        or not Hitbox.Parent
        or not Hitbox:IsDescendantOf(Character)
    then
        Hitbox = self:CreateHitbox(Player)
    end

    if not Hitbox then
        return
    end

    local Enabled = HitboxManager.State

    if Enabled and HitboxManager.TeamCheck then
        if Utils:TeamCheck(Player, false) then
            Enabled = false
        end
    end

    if Enabled and HitboxManager.IgnoreDead then
        if Utils:IsDead(Player) then
            Enabled = false
        end
    end

    Hitbox.Size = Enabled
        and Vector3.one * HitboxManager.Size
        or Vector3.zero

    Hitbox.Transparency = HitboxManager.Transparency
    Hitbox.Color = HitboxManager.Color
end

function HitboxManager.Methods:UpdateAllHitbox()
    for _, Player in ipairs(Players:GetPlayers()) do
        self:UpdateHitbox(Player)
    end
end

local UpdatingHitboxes = false
local HitboxesDirty = false

function HitboxManager.Methods:RequestUpdate()
    HitboxesDirty = true

    if UpdatingHitboxes then
        return
    end

    UpdatingHitboxes = true

    task.defer(function()
        repeat
            HitboxesDirty = false
            self:UpdateAllHitbox()
        until not HitboxesDirty

        UpdatingHitboxes = false
    end)
end

local PowerfulManager = {
    TpKill = {
        InProgress = false,
        TargetsCount = 1,

        CurrentTarget = nil,

        Methods = {},
    }
}

function PowerfulManager.TpKill.Methods:GetTargets()
    local Targets = {}

    for i = 1, 999999 do
        if #Targets >= PowerfulManager.TpKill.TargetsCount then
            break
        end

        local Data = Cache.ClosestPlayers[i]

        if not Data then
            break
        end

        local Target = Data.Player

        if not Target or Target == Client then
            continue
        end

        if Utils:TeamCheck(Target) then
            continue
        end

        if Utils:IsDead(Target) then
            continue
        end

        table.insert(Targets, Target)
    end

    return Targets
end

--!mv:omit
function PowerfulManager.TpKill.Methods:TpKill()
    if PowerfulManager.TpKill.InProgress then
        return
    end

    Utils:GetClosestPlayers()
    PowerfulManager.TpKill.InProgress = true

    local Targets = self:GetTargets()
    if #Targets == 0 then
        PowerfulManager.TpKill.InProgress = false
        return
    end

    for _,Target in ipairs(Targets) do

        if not Target then
            continue
        end

        if Utils:IsDead(Target) then
            continue
        end

        PowerfulManager.TpKill.CurrentTarget = Target

        local Character = Utils:Character(Target)
        local MyCharacter = Utils:Character(Client)
        if not Character or not MyCharacter then
            continue
        end

        local RootPart = Utils:GetCharacterInstance(Character,"HumanoidRootPart")
        local MyRootPart = Utils:GetCharacterInstance(MyCharacter,"HumanoidRootPart")
        if not RootPart or not MyRootPart then
            continue
        end

        local Gun = Utils:GetGun(Client)
        if not Gun then
            continue
        end

        local TeleportA = true
        local OldCFrame = MyRootPart.CFrame

        task.spawn(function()
            while true do
                if TeleportA == true then
                    if MyRootPart and RootPart then
                        MyRootPart.CFrame = RootPart.CFrame * CFrame.new(0,0,5)
                    end
                elseif TeleportA == false then
                    if MyRootPart then
                        MyRootPart.CFrame = OldCFrame
                    end
                elseif TeleportA == "Stop" then
                    break
                end
                task.wait(0.01)
            end
        end)

        for _,Script in ipairs(Gun:GetChildren()) do
         if Script:IsA("LocalScript") then
          Script.Enabled = false
          task.wait(0.05)
          Script.Enabled = true
          task.wait(0.05)
         end
        end

        task.wait(1)
        Gun.Parent = MyCharacter
        Gun:Activate()
        task.wait(0.25)
        TeleportA = false
        task.wait(0.25)
        TeleportA = "Stop"
        task.wait(2.6)
    end

    PowerfulManager.TpKill.InProgress = false
    PowerfulManager.TpKill.CurrentTarget = nil
end

--// Ui
local Window = WindUI:CreateWindow({
    Title = "NyxDuels",
    Author = "NyxMods",
    Icon = "rbxassetid://86507528059862",
    Background = "rbxassetid://86507528059862",
    BackgroundImageTransparency = 0.5,
})

local AimbotTab = Window:Tab({
    Title = "Aimbot",
    Icon = "crosshair"
})

local AimbotSection = AimbotTab:Section({
    Title = "Aimbot Settings",
    Desc = "Manage aimbot features and options.",
})

AimbotTab:Toggle({
    Title = "Enable",
    Value = false,
    Callback = function(Value)
        AimbotManager.State = Value

        if Value then
            AimbotManager.Methods:EnableAimbot()
        end

    end
})

AimbotTab:Toggle({
    Title = "Team Check",
    Value = true,
    Callback = function(Value)
        AimbotManager.TeamCheck = Value
    end
})

AimbotTab:Toggle({
    Title = "Wall Check",
    Value = false,
    Callback = function(Value)
        AimbotManager.WallCheck = Value
    end
})

AimbotTab:Toggle({
    Title = "Ignore Dead",
    Value = true,
    Callback = function(Value)
        AimbotManager.IgnoreDead = Value
    end
})

local AutoShootTab = Window:Tab({
    Title = "Auto Shoot",
    Icon = "crosshair",
})

local AutoShootSection = AutoShootTab:Section({
    Title = "Auto Shoot Settings",
    Desc = "Manage auto shoot features and options.",
})

AutoShootTab:Toggle({
    Title = "Enable",
    Value = false,
    Callback = function(Value)
        AutoShootManager.State = Value

        if Value then
            AutoShootManager.Methods:EnableAutoShoot()
        end

    end
})

AutoShootTab:Toggle({
    Title = "Team Check",
    Value = true,
    Callback = function(Value)
        AutoShootManager.TeamCheck = Value
    end
})

AutoShootTab:Toggle({
    Title = "Wall Check",
    Value = true,
    Callback = function(Value)
        AutoShootManager.WallCheck = Value
    end
})

AutoShootTab:Toggle({
    Title = "Ignore Dead",
    Value = true,
    Callback = function(Value)
        AutoShootManager.IgnoreDead = Value
    end
})

local HitboxTab = Window:Tab({
 Title = "Hitbox",
 Icon = "box",
})

local HitboxSection = HitboxTab:Section({
 Title = "Hitbox Options",
 Desc = "Customize the hitbox size and visibility of all players.",
})

--// Toggles
HitboxTab:Toggle({
    Title = "Enable",
    Value = HitboxManager.State,
    Callback = function(Value)
        HitboxManager.State = Value

        HitboxManager.Methods:RequestUpdate()
    end
})

HitboxTab:Toggle({
    Title = "Team Check",
    Value = HitboxManager.TeamCheck,
    Callback = function(Value)
        HitboxManager.TeamCheck = Value

        HitboxManager.Methods:RequestUpdate()
    end
})

HitboxTab:Toggle({
    Title = "Ignore Dead",
    Value = HitboxManager.IgnoreDead,
    Callback = function(Value)
        HitboxManager.IgnoreDead = Value

        HitboxManager.Methods:RequestUpdate()
    end
})

--// Sliders
HitboxTab:Slider({
    Title = "Size",
    Value = {
        Min = 1,
        Max = 35,
        Default = HitboxManager.Size,
    },
    Callback = function(Value)
        HitboxManager.Size = Value

        HitboxManager.Methods:RequestUpdate()
    end
})

HitboxTab:Slider({
    Title = "Transparency",
    Value = {
        Min = 0,
        Max = 100,
        Default = HitboxManager.Transparency * 100,
    },
    Callback = function(Value)
        HitboxManager.Transparency = Value / 100

        HitboxManager.Methods:RequestUpdate()
    end
})

--// Color
HitboxTab:Colorpicker({
    Title = "Color",
    Default = HitboxManager.Color,
    Callback = function(Value)
        HitboxManager.Color = Value

        HitboxManager.Methods:RequestUpdate()
    end
})

local PowerfulTab = Window:Tab({
    Title = "Powerful",
    Icon = "zap"
})

local PowerfulSection = PowerfulTab:Section({
    Title = "High Impact",
    Desc = "Features with significant gameplay impact.",
})

PowerfulTab:Button({
    Title = "Tp Kill ClosestPlayers",
    Callback = function()
        PowerfulManager.TpKill.Methods:TpKill()
    end,
})

PowerfulTab:Slider({
    Title = "Max Targets",
    Value = {
        Min = 1,
        Max = 4,
        Default = 1,
    },
    Callback = function(Value)
        PowerfulManager.TpKill.TargetsCount = Value
    end
})

local OrbsFarmTab = Window:Tab({
    Title = "Orbs Farm",
    Icon = "gem",
})

local OrbsFarmSection = OrbsFarmTab:Section({
    Title = "Orb Farming",
    Desc = "Automate event orb collection.",
})

OrbsFarmTab:Toggle({
    Title = "Auto Farm Orbs",
    Value = false,
    Callback = function(Value)
        OrbsFarmManager.State = Value

        if Value then
            OrbsFarmManager.Methods:AutoFarmOrbsEnable()
        end

    end
})


OrbsFarmTab:Toggle({
    Title = "Insta Collect Orbs",
    Value = false,
    Callback = function(Value)
        OrbsFarmManager.InstaCollect = Value
    end
})

OrbsFarmTab:Slider({
    Title = "Collect Orb Delay",
    Value = {
        Min = 0.01,
        Max = 5,
        Default = 1,
    },
    Callback = function(Value)
        OrbsFarmManager.CollectOrbDelay = Value
    end
})

local EspTab = Window:Tab({
    Title = "Esp",
    Icon = "radar",
})

local EspSection = EspTab:Section({
    Title = "ESP Settings",
    Desc = "Customize player highlights and colors",
})

EspTab:Toggle({
    Title = "Enable",
    Value = false,
    Callback = function(Value)
        EspManager.State = Value

        for _,Player in ipairs(Players:GetPlayers()) do
            EspManager.Methods:UpdateEsp(Player)
        end
    end
})

EspTab:Toggle({
    Title = "Exclude Client",
    Value = false,
    Callback = function(Value)
        EspManager.ExcludeClient = Value

        for _,Player in ipairs(Players:GetPlayers()) do
            EspManager.Methods:UpdateEsp(Player)
        end
    end
})

EspTab:Colorpicker({
    Title = "Team Color",
    Default = Color3.fromRGB(0, 255, 0),
    Callback = function(Color)
        EspManager.TeamColor = Color

        for _,Player in ipairs(Players:GetPlayers()) do
            EspManager.Methods:UpdateEsp(Player)
        end
    end
})

EspTab:Colorpicker({
    Title = "Enemy Color",
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(Color)
        EspManager.EnemyColor = Color

        for _,Player in ipairs(Players:GetPlayers()) do
            EspManager.Methods:UpdateEsp(Player)
        end
    end
})

EspTab:Colorpicker({
    Title = "Client Color",
    Default = Color3.fromRGB(128, 0, 255),
    Callback = function(Color)
        EspManager.ClientColor = Color

        for _,Player in ipairs(Players:GetPlayers()) do
            EspManager.Methods:UpdateEsp(Player)
        end
    end
})

EspTab:Slider({
    Title = "Fill Transparency",
    Value = {
        Min = 0,
        Max = 100,
        Default = 0.5,
    },
    Callback = function(Value)
        EspManager.FillTransparency = Value / 100

        for _,Player in ipairs(Players:GetPlayers()) do
            EspManager.Methods:UpdateEsp(Player)
        end
    end
})

EspTab:Slider({
    Title = "Outline Transparency",
    Value = {
        Min = 0,
        Max = 100,
        Default = 0,
    },
    Callback = function(Value)
        EspManager.OutlineTransparency = Value / 100

        for _,Player in ipairs(Players:GetPlayers()) do
            EspManager.Methods:UpdateEsp(Player)
        end
    end
})

--// Init
--// Init

local function SetupPlayer(Player)
    EspManager.Methods:AddEsp(Player)
    HitboxManager.Methods:CreateHitbox(Player)

    Player.CharacterAdded:Connect(function(Character)
        task.spawn(function()
            if not Character.Parent then
                Character.AncestryChanged:Wait()
            end

            if Player.Character ~= Character then
                return
            end

            EspManager.Methods:UpdateEsp(Player)

            HitboxManager.Methods:CreateHitbox(Player)
            HitboxManager.Methods:UpdateHitbox(Player)

            Character.DescendantAdded:Connect(function()
                EspManager.Methods:UpdateEsp(Player)
                HitboxManager.Methods:UpdateHitbox(Player)
            end)

            local Humanoid = Character and (Character:FindFirstChild("Humanoid") or Character:WaitForChild("Humanoid"))
            if Humanoid then

             Humanoid.Died:Connect(function()
              HitboxManager.Methods:UpdateHitbox(Player)
             end)

            end
        end)
    end)

    Player.CharacterRemoving:Connect(function()
        local Esp = EspManager.EspObjects[Player]

        if Esp then
            Esp.Adornee = nil
            Esp.Enabled = false
        end
    end)

    if Player.Character then
        EspManager.Methods:UpdateEsp(Player)
    end
end


for _, Player in ipairs(Players:GetPlayers()) do
    SetupPlayer(Player)
end

--// Events
Players.PlayerAdded:Connect(SetupPlayer)

Players.PlayerRemoving:Connect(function(Player)
    EspManager.Methods:RemoveEsp(Player)
end)

--// Loops
RunService.Heartbeat:Connect(function(DeltaTime)
    local NeedUpdate = AimbotManager.State or AutoShootManager.State or PowerfulManager.TpKill.InProgress or false
    if NeedUpdate then
        Utils:GetClosestPlayers()
    end
end)

--// Hooks
if not getrawmetatable or not setreadonly then
    return
end

local MetaTable = getrawmetatable(game)

setreadonly(MetaTable,false)

local OldIndex = MetaTable.__index
MetaTable.__index = function(Self,Property)
    if not AimbotManager.State and not AutoShootManager.State and not PowerfulManager.TpKill.InProgress then
        return OldIndex(Self,Property)
    end

    local Mouse = Client:GetMouse()

    if Self ~= Mouse then
        return OldIndex(Self,Property)
    end

    if Property ~= "Hit" and Property ~= "Target" then
        return OldIndex(Self,Property)
    end

    --// TpKill
    if PowerfulManager.TpKill.InProgress then
        local Target = PowerfulManager.TpKill.CurrentTarget
        if not Target then
            return OldIndex(Self,Property)
        end

        local Character = Utils:Character(Target)
        if not Character then
            return OldIndex(Self,Property)
        end

        local Part = Utils:GetCharacterInstance(Character,"HumanoidRootPart")

        if not Part then
            return OldIndex(Self,Property)
        end

        if Property == "Hit" then
            return Part.CFrame
        elseif Property == "Target" then
            return Part
        end
    end

    --// AutoShoot
    if AutoShootManager.State then
        local FallBack = false

        local Target = AutoShootManager.Methods:GetTarget()
        if not Target then
         Target = AutoShootManager.Methods:GetFallBackTarget()
         FallBack = true
        end

        if not Target then
         return OldIndex(Self,Property)
        end

        local Character = Utils:Character(Target)
        if not Character then
            return OldIndex(Self,Property)
        end

        local Part = nil

        if AutoShootManager.WallCheck then
            local WallCheck,VisiblePart = Utils:WallCheck(Client,Target)

            if VisiblePart then
                Part = VisiblePart
            end

            if not VisiblePart then
             if FallBack then
             Part =  Utils:GetCharacterInstance(Character,"HumanoidRootPart")
             end
            end
        end

        if not AutoShootManager.WallCheck then
            Part = Utils:GetCharacterInstance(Character,"HumanoidRootPart")
        end

        if not Part then
            return OldIndex(Self,Property)
        end

        if Property == "Hit" then
            return Part.CFrame
        elseif Property == "Target" then
            return Part
        end
    end

    --// Aimbot
    if AimbotManager.State then
        local Target = AimbotManager.Methods:GetTarget()
        if not Target then
            return OldIndex(Self,Property)
        end

        local Character = Utils:Character(Target)
        if not Character then
            return OldIndex(Self,Property)
        end

        local Part = nil

        if AimbotManager.WallCheck then
            local WallCheck,VisiblePart = Utils:WallCheck(Client,Target)
            if not VisiblePart then
                return
            end

            Part = VisiblePart
        end

        if not AimbotManager.WallCheck then
            Part = Utils:GetCharacterInstance(Character,"HumanoidRootPart")
        end

        if not Part then
            return OldIndex(Self,Property)
        end

        if Property == "Hit" then
            return Part.CFrame
        elseif Property == "Target" then
            return Part
        end

    end

    return OldIndex(Self,Property)
end


setreadonly(MetaTable,true)