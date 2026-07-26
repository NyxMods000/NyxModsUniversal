
--//Variables
local NyxModsUniversal = getgenv().NyxModsUniversal
local Window = NyxModsUniversal.Window
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Client = Players.LocalPlayer

local Config = {
  Esp = {
    Name = false,
    DisplayName = false,
    Health = false,
    Distance = false,
    Box = false,
    Line = false,
    Skeleton = false,
    Objects = {},
    R15SkeletonPoints = {
      {"UpperTorso","Head"},
      {"UpperTorso","RightUpperArm"},
      {"UpperTorso","LeftUpperArm"},
      {"RightUpperArm","RightLowerArm"},
      {"LeftUpperArm","LeftLowerArm"},
      {"LeftLowerArm","LeftHand"},
      {"RightLowerArm","RightHand"},
      {"UpperTorso","LowerTorso"},
      {"LowerTorso","LeftUpperLeg"},
      {"LowerTorso","RightUpperLeg"},
      {"LeftUpperLeg","LeftLowerLeg"},
      {"RightUpperLeg","RightLowerLeg"},
      {"RightLowerLeg","RightFoot"},
      {"LeftLowerLeg","LeftFoot"},
    },
    R6SkeletonPoints = {
      {"Torso","Head"},
      {"Torso","Right Arm"},
      {"Torso","Left Arm"},
      {"Torso","Right Leg"},
      {"Torso","Left Leg"}
    },
    BoxColor = Color3.fromRGB(0,0,0),
    LineColor = Color3.fromRGB(0,0,0),
    TextColor = Color3.fromRGB(0,0,0)
  },
  Fullbright = {
    Enabled = false,
    DefaultBrightness = nil,
    DefaultGlobalShadows = nil,
    Brightness = nil,
  },
  Ambient = {
    Enabled = false,
    Color = nil,
    DefaultColor = nil,
  },
  OutdoorAmbient = {
    Enabled = false,
    Color = nil,
    DefaultColor = nil,
  },
  RemoveFog = {
    DefaultFogStart = nil,
    DefaultFogEnd = nil,
  },
  ClockTime = {
    Enabled = false,
    Time = nil,
    DefaultTime = nil,
  }
}


--//Functions
local function GetCharacter(Player)
  local Character = Player.Character
  if Character then
    return Character
  end
  return nil
end

local function GetModelInstance(Model,Instance)
  local Instance = Model:FindFirstChild(Instance)
  if Instance then
    return Instance
  end
  return nil
end

local function GetPlayerInstance(Player,Instance)
  local Character = GetCharacter(Player)
  if Character then
    local Instance = GetModelInstance(Character,Instance)
    if Instance then
      return Instance
    end
  end
  return nil
end

local function CreateDrawingInstance(Instance,Properties)
  local Instance = Drawing.new(Instance)
  for Property,Value in pairs(Properties) do
    Instance[Property] = Value
  end
  return Instance
end

local function UpdateLine(Line,Part1,Part2)
  local Camera = Workspace.CurrentCamera
  if Camera then
    local Pos1, OnScreen1 = Camera:WorldToViewportPoint(Part1.Position)
    local Pos2, OnScreen2 = Camera:WorldToViewportPoint(Part2.Position)
    if OnScreen1 and OnScreen2 then
      if Line then
      Line.Color = Config.Esp.LineColor
      Line.From = Vector2.new(Pos1.X,Pos1.Y)
      Line.To = Vector2.new(Pos2.X,Pos2.Y)
      Line.Visible = true
      end
    else
      if Line then
      Line.Visible = false
      end
    end
  end
end

local function UpdateBox(Box,Part1,Part2)
  local Camera = Workspace.CurrentCamera
  if Camera then
    local Pos, OnScreen = Camera:WorldToViewportPoint(Part1.Position)
    local Pos2, OnScreen2 = Camera:WorldToViewportPoint(Part2.Position + Vector3.new(0,1,0))
    if OnScreen and OnScreen2 then
      local Height = math.abs(Pos.Y - Pos2.Y) * 2
      local Width = Height / 2
      Box.Color = Config.Esp.BoxColor
      Box.Size = Vector2.new(Width,Height)
      Box.Position = Vector2.new(Pos.X,Pos.Y) - (Box.Size / 2)
      Box.Visible = true
    else
      Box.Visible = false
    end
  end
end

local function UpdateText(Text,Part,Offset,Content)
  local Camera = Workspace.CurrentCamera
  if Camera then
    local Distance = (Camera.CFrame.Position - Part.Position).Magnitude
      local OffsetY = Distance * 0.1
    local Pos, OnScreen = Camera:WorldToViewportPoint(Part.Position + Offset + Vector3.new(0,OffsetY,0))
    if OnScreen then
      Text.Color = Config.Esp.TextColor
      Text.Position = Vector2.new(Pos.X,Pos.Y)
      Text.Text = Content
      Text.Size = math.clamp(1000 / Distance,12,24)
      Text.Visible = true
      Text.Font = 2
      Text.Outline = true
      Text.OutlineColor = Color3.fromRGB(0,0,0)
    else
      Text.Visible = false
    end
  end
end

local function CreatePlayerEsp(Player)
  local Text = CreateDrawingInstance("Text",{
    Text = "",
    Center = true,
  })
  local Box = CreateDrawingInstance("Square",{
    Thickness = 1,
    Filled = false,
    Visible = false,
  })
  local Line = CreateDrawingInstance("Line",{
    Thickness = 1,
    Visible = false,
  })
  local Skeleton = {}
  local RigType = nil

  local Humanoid = GetPlayerInstance(Player,"Humanoid")
  if Humanoid then
    if Humanoid.RigType == Enum.HumanoidRigType.R15 then
      for i = 1,#Config.Esp.R15SkeletonPoints,1 do
        local Bone = CreateDrawingInstance("Line",{
          Thickness = 1,
          Visible = false,
        })
        table.insert(Skeleton,Bone)
        RigType = Humanoid.RigType
      end
    else
      for i = 1,#Config.Esp.R6SkeletonPoints,1 do
        local Bone = CreateDrawingInstance("Line",{
          Thickness = 1,
          Visible = false,
        })
        table.insert(Skeleton,Bone)
        RigType = Humanoid.RigType
      end
    end
  end

  local PlayerEsp = {
    Text = Text,
    Box = Box,
    Line = Line,
    Skeleton = Skeleton,
    RigType = RigType,
  }

  return PlayerEsp
end

local function UpdatePlayerEsp(Player)
  if not Config.Esp.Objects[Player] then
    Config.Esp.Objects[Player] = CreatePlayerEsp(Player)
  end
  if Config.Esp.Objects[Player] then
    local Humanoid = GetPlayerInstance(Player,"Humanoid")
    if Humanoid then
    local Esp = Config.Esp
    local Objects = Esp.Objects[Player]
    local Text = Objects.Text
    local Box = Objects.Box
    local Line = Objects.Line
    local SkeletonLines = Objects.Skeleton
    local RigType = Humanoid.RigType
    local SkeletonPoints = RigType == Enum.HumanoidRigType.R15 and Esp.R15SkeletonPoints or RigType == Enum.HumanoidRigType.R6 and Esp.R6SkeletonPoints

    local Name = Esp.Name
    local DisplayName = Esp.DisplayName
    local Health = Esp.Health
    local Distance = Esp.Distance
    local Skeleton = Esp.Skeleton

    if Skeleton and SkeletonPoints then
      for i,Connections in ipairs(SkeletonPoints) do
        local Line = SkeletonLines[i]
        local Part1 = GetPlayerInstance(Player,Connections[1])
        local Part2 = GetPlayerInstance(Player,Connections[2])
        if Part1 and Part2 then
          UpdateLine(Line,Part1,Part2)
        end
      end
    else
      for i,v in ipairs(SkeletonLines) do
        v.Visible = false
      end
    end


    if Name or DisplayName or Health or Distance then
      local Head = GetPlayerInstance(Player,"Head")
      local HumanoidRootPart1 = GetPlayerInstance(Client,"HumanoidRootPart")
      local HumanoidRootPart2 = GetPlayerInstance(Player,"HumanoidRootPart")
      if Head and Humanoid then
        local Content = ""
        if Name then
          Content = Content.."\nName: "..Player.Name
        end
        if DisplayName then
          Content = Content.."\nDisplayName: "..Player.DisplayName
        end
        if Health then
          Content = Content.."\nHealth: "..Humanoid.Health
        end
        if Distance then
          if HumanoidRootPart1 and HumanoidRootPart2 then
            local Distance = (HumanoidRootPart1.Position - HumanoidRootPart2.Position).Magnitude
            Content = Content.."\nDistance: "..math.floor(Distance)
          end
        end
        local Offset = 2
        if Name then
          Offset = Offset + 0.5
        end
        if DisplayName then
          Offset = Offset + 0.5
        end
        if Health then
          Offset = Offset + 0.5
        end
        if Distance then
          Offset = Offset + 0.5
        end
        UpdateText(Text,Head,Vector3.new(0,Offset,0),Content)
      end
    else
      Text.Visible = false
    end
    if Esp.Box then
      local HumanoidRootPart = GetPlayerInstance(Player,"HumanoidRootPart")
      local Head = GetPlayerInstance(Player,"Head")
      if HumanoidRootPart and Head then
        UpdateBox(Box,HumanoidRootPart,Head)
      end
    else
      Box.Visible = false
    end
    if Esp.Line then
      local HumanoidRootPart2 = GetPlayerInstance(Player,"HumanoidRootPart")
      local HumanoidRootPart1 = GetPlayerInstance(Client,"HumanoidRootPart")
      if HumanoidRootPart2 and HumanoidRootPart1 then
        UpdateLine(Line,HumanoidRootPart1,HumanoidRootPart2)
      end
    else
      Line.Visible = false
    end
    end
  end
end

local function Fullbright()

task.spawn(function()
  while true do
  if Config.Fullbright.Enabled then
    if not Config.Fullbright.DefaultBrightness then
      Config.Fullbright.DefaultBrightness = Lighting.Brightness
    end
    if not Config.Fullbright.DefaultGlobalShadows then
      Config.Fullbright.DefaultGlobalShadows = Lighting.GlobalShadows
    end
    Lighting.Brightness = tonumber(Config.Fullbright.Brightness) or Config.Fullbright.DefaultBrightness or 1
    Lighting.GlobalShadows = false
  else

    if Config.Fullbright.DefaultBrightness then
      Lighting.Brightness = Config.Fullbright.DefaultBrightness
    end

    if Config.Fullbright.DefaultGlobalShadows then
      Lighting.GlobalShadows = Config.Fullbright.DefaultGlobalShadows
    end

    break
  end
  task.wait(0.01)
  end
end)

end

function AmbientColor()
  task.spawn(function()
    while true do
      if Config.Ambient.Enabled then
        if not Config.Ambient.DefaultColor then
          Config.Ambient.DefaultColor = Lighting.Ambient
        end
        Lighting.Ambient = Config.Ambient.Color or Color3.fromRGB(0,0,0)
      else
        if Config.Ambient.DefaultColor then
          Lighting.Ambient = Config.Ambient.DefaultColor
        end
        break
      end
      task.wait(0.01)
    end
  end)
end

function OutdoorAmbientColor()
  task.spawn(function()
    while true do
      if Config.OutdoorAmbient.Enabled then
        if not Config.OutdoorAmbient.DefaultColor then
          Config.OutdoorAmbient.DefaultColor = Lighting.OutdoorAmbient
        end
        Lighting.OutdoorAmbient = Config.OutdoorAmbient.Color or Color3.fromRGB(0,0,0)
      else
        if Config.OutdoorAmbient.DefaultColor then
          Lighting.OutdoorAmbient = Config.OutdoorAmbient.DefaultColor
        end
        break
      end
      task.wait(0.01)
    end
  end)
end

function RemoveFog(State)
  if not Config.RemoveFog.DefaultFogStart then
    Config.RemoveFog.DefaultFogStart = Lighting.FogStart
  end
  if not Config.RemoveFog.DefaultFogEnd then
    Config.RemoveFog.DefaultFogEnd = Lighting.FogEnd
  end
  
  if State then
    Lighting.FogStart = 10000000
    Lighting.FogEnd = 10000000
  else
    Lighting.FogStart = Config.RemoveFog.DefaultFogStart or 0
    Lighting.FogEnd = Config.RemoveFog.DefaultFogEnd or 2000
  end
  
end

function ClockTime()
  task.spawn(function()
    while true do
      if Config.ClockTime.Enabled then
        if not Config.ClockTime.DefaultTime then
          Config.ClockTime.DefaultTime = Lighting.ClockTime
        end
        Lighting.ClockTime = Config.ClockTime.Time
      else
        if Config.ClockTime.DefaultTime then
          Lighting.ClockTime = Config.ClockTime.DefaultTime
        end
        break
      end
      task.wait(0.01)
    end
  end)
end

--//Library
local Tab = Window:CreateTab("Visuals")
local Section = Tab:CreateSection("Esp toggles")

Tab:CreateToggle({
    Name = "Name esp",
    CurrentValue = false,
    Callback = function(State)
      Config.Esp.Name = State
    end
})

Tab:CreateToggle({
    Name = "DisplayName esp",
    CurrentValue = false,
    Callback = function(State)
      Config.Esp.DisplayName = State
    end
})

Tab:CreateToggle({
    Name = "Health esp",
    CurrentValue = false,
    Callback = function(State)
      Config.Esp.Health = State
    end
})

Tab:CreateToggle({
    Name = "Distance esp",
    CurrentValue = false,
    Callback = function(State)
      Config.Esp.Distance = State
    end
})

Tab:CreateToggle({
    Name = "Box esp",
    CurrentValue = false,
    Callback = function(State)
      Config.Esp.Box = State
    end
})

Tab:CreateToggle({
    Name = "Line esp",
    CurrentValue = false,
    Callback = function(State)
      Config.Esp.Line = State
    end
})

Tab:CreateToggle({
    Name = "Skeleton esp",
    CurrentValue = false,
    Callback = function(State)
      Config.Esp.Skeleton = State
    end
})

local Section2 = Tab:CreateSection("Esp Config")

Tab:CreateColorPicker({
    Name = "Text Color",
    Color = Color3.fromRGB(255, 0, 0),
    Callback = function(Color)
      Config.Esp.TextColor = Color
    end
})

Tab:CreateColorPicker({
    Name = "Line Color",
    Color = Color3.fromRGB(255, 0, 0),
    Callback = function(Color)
      Config.Esp.LineColor = Color
    end
})

Tab:CreateColorPicker({
    Name = "Box Color",
    Color = Color3.fromRGB(255, 0, 0),
    Callback = function(Color)
      Config.Esp.BoxColor = Color
    end
})

local Section3 = Tab:CreateSection("World / Lighting")

Tab:CreateToggle({
    Name = "Fullbright",
    CurrentValue = false,
    Callback = function(State)
      Config.Fullbright.Enabled = State
      Fullbright()
    end
})

Tab:CreateSlider({
    Name = "Fullbright Value",
    Range = {0, 100}, --- Mínimo y máximo
    Increment = 1, --- De cuánto en cuánto cambia
    Suffix = "Brightness", --- Texto después del valor
    CurrentValue = 1, --- Valor inicial
    Callback = function(Value)
      Config.Fullbright.Brightness = Value
    end
})

Tab:CreateToggle({
    Name = "Ambient Color",
    CurrentValue = false,
    Callback = function(State)
      Config.Ambient.Enabled = State
      AmbientColor()
    end
})

Tab:CreateColorPicker({
    Name = "Ambient Color Value",
    Color = Color3.fromRGB(255, 0, 0),
    Callback = function(Color)
      Config.Ambient.Color = Color
    end
})

Tab:CreateToggle({
    Name = "OutdoorAmbient Color",
    CurrentValue = false,
    Callback = function(State)
      Config.OutdoorAmbient.Enabled = State
      OutdoorAmbientColor()
    end
})

Tab:CreateColorPicker({
    Name = "OutdoorAmbient Color Value",
    Color = Color3.fromRGB(255, 0, 0),
    Callback = function(Color)
      Config.OutdoorAmbient.Color = Color
    end
})

Tab:CreateToggle({
    Name = "Remove Fog",
    CurrentValue = false,
    Callback = function(State)
      RemoveFog(State)
    end
})

Tab:CreateToggle({
    Name = "Clock Time",
    CurrentValue = false,
    Callback = function(State)
      Config.ClockTime.Enabled = State
      ClockTime()
    end
})

Tab:CreateSlider({
    Name = "Clock Time Value",
    Range = {0, 24}, --- Mínimo y máximo
    Increment = 0.01, --- De cuánto en cuánto cambia
    Suffix = "Brightness", --- Texto después del valor
    CurrentValue = 1, --- Valor inicial
    Callback = function(Value)
      Config.ClockTime.Time = Value
    end
})

--//Events
Players.PlayerRemoving:Connect(function(Player)
  if Config.Esp.Objects[Player] then
    pcall(function()
    Config.Esp.Objects[Player].Line:Destroy()
    Config.Esp.Objects[Player].Box:Destroy()
    Config.Esp.Objects[Player].Text:Destroy()
    end)
    pcall(function()
      Config.Esp.Objects[Player].Line:Remove()
    Config.Esp.Objects[Player].Box:Remove()
    Config.Esp.Objects[Player].Text:Remove()
    end)
    for i,v in ipairs(Config.Esp.Objects[Player].Skeleton) do
      pcall(function()
      v:Destroy()
      end)
      pcall(function()
      v:Remove()
      end)
    end
    Config.Esp.Objects[Player] = nil
  end
end)

--//Loops
RunService.Heartbeat:Connect(function()
  for i,v in ipairs(Players:GetPlayers()) do
    if v ~= Client then
    UpdatePlayerEsp(v)
    end
  end
end)