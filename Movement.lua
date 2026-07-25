--//Variables
local NyxModsUniversal = getgenv().NyxModsUniversal
local Window = NyxModsUniversal.Window
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Client = Players.LocalPlayer

--//Tables
local Config = {
  WalkSpeed = {
    Enabled = false,
    Value = 16,
    Default = 16,
    Force = false
  },
  JumpPower = {
    Enabled = false,
    Value = 52,
    Default = 52,
    Force = false
  },
  Slide = {
    Enabled = false,
    Value = 1,
    Method = "CFrame" --// CFrame or velocity
  },
  Noclip = {
    Enabled = false,
    Default = {}
  },
  TeleportTool = {
    Enabled = false,
    Tool = nil
  },
  ControlClickTp = {
    Enabled = false,
    Pressed = false
  },
  InfiniteJump = {
    Enabled = false
  },
  AirWalk = {
    Enabled = false,
    Margin = 0.5,
    Platform = nil
  },
  HipHeight = {
    Enabled = false,
    Value = 0,
    Default = nil
  },
  WayPointTeleport = {
    Saved = nil
  },
  Spin = {
    Enabled = false,
    Value = 0
  }
}

--//Functions
local function GetHumanoid()
  local Character = Client and Client.Character
  if Character then
    local Humanoid = Character:FindFirstChild("Humanoid")
    if Humanoid then
      return Humanoid
    end
    return nil
  end
  return nil
end

local function GetHumanoidRootPart()
  local Character = Client and Client.Character
  if Character then
    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
    if HumanoidRootPart then
      return HumanoidRootPart
    end
    return nil
  end
  return nil
end

local function GetMoveDirection()
  local Humanoid = GetHumanoid()
  if Humanoid then
    return Humanoid and Humanoid.MoveDirection
  end
end

local function UpdateHumanoidProperty(Property,Data)
  local Humanoid = GetHumanoid()
  if Humanoid then
    if not Data.Default then
      Data.Default = Humanoid[Property]
    end
    Humanoid[Property] = Data.Enabled and Data.Value or Data.Default
  end
  return nil
end

local function Teleport(Position)
  local HumanoidRootPart = GetHumanoidRootPart()
  if HumanoidRootPart then
    if typeof(Position) == "CFrame" then
      HumanoidRootPart.CFrame = Position
    elseif typeof(Position) == "Vector3" then
      HumanoidRootPart.CFrame = CFrame.new(Position)
    end
  end
end

local function ApplyVelocity(Velocity)
  local HumanoidRootPart = GetHumanoidRootPart()
  if HumanoidRootPart then
    HumanoidRootPart.AssemblyLinearVelocity = Velocity
  end
end

local function UpdateNoclip(Data)
  local Character = Client.Character
  if Character then
    local Default = Config.Noclip.Default
    for _,v in ipairs(Character:GetDescendants()) do
      if v:IsA("BasePart") then
        if not Default[v.Name] then
          Default[v.Name] = v.CanCollide
        end
        if Data and Data.Enabled then
          v.CanCollide = false
        elseif Data and not Data.Enabled then
          if Default and Default[v.Name] ~= nil then
            v.CanCollide = Default[v.Name]
          else
            v.CanCollide = true
          end
        end
      end
    end
  end
end

local function CreateTeleportTool()
  local Tool = Instance.new("Tool")
  Tool.Name = "Teleport Tool"
  Tool.RequiresHandle = false
  
  Tool.Activated:Connect(function()
    if Config.TeleportTool.Enabled then
      local Mouse = Client:GetMouse()
      if Mouse and Mouse.Hit then
        Teleport(Mouse.Hit)
      end
    end
  end)
  
  return Tool
end

local function GetTeleportTool()
  if Config.TeleportTool.Tool then
    Config.TeleportTool.Tool:Destroy()
  end
  
  local Tool = CreateTeleportTool()
  if Tool then
    Config.TeleportTool.Tool = Tool
    Tool.Parent = Client and Client.Backpack or Client and Client:WaitForChild("Backpack")
  end
end

local function CreatePlatform()
  if Config.AirWalk.Platform then
    return Config.AirWalk.Platform
  end
  
  local Platform = Instance.new("Part")
  Platform.Size = Vector3.new(20,1,20)
  Platform.Transparency = 0.5
  Platform.Anchored = true
  Platform.CanCollide = true
  Platform.Parent = Workspace
  
  Config.AirWalk.Platform = Platform
  
  return Platform
end

local function UpdatePlatform()
  local Platform = CreatePlatform()
  local HumanoidRootPart = GetHumanoidRootPart()
  local Humanoid = GetHumanoid()
  local Margin = Config.AirWalk.Margin
  if Platform  and HumanoidRootPart and Humanoid then
    local Relative = Platform.CFrame:PointToObjectSpace(HumanoidRootPart.Position)
    local Half = Platform.Size / 2
    
    local NearEdgeX = math.abs(Relative.X) >= Half.X - Margin or math.abs(Relative.Y) >= 5
    local NearEdgeZ = math.abs(Relative.Z) >= Half.Z - Margin or math.abs(Relative.Y) >= 5
    
    if NearEdgeX or NearEdgeZ then
      Platform.Position = HumanoidRootPart.Position + Vector3.new(0,-3.5,0)
    end
    
  end
end

local function WayPointTeleport(Type)
  local HumanoidRootPart = GetHumanoidRootPart()
  if HumanoidRootPart then
    if Type == "Save" then
      Config.WayPointTeleport.Saved = HumanoidRootPart.CFrame
    elseif Type == "Teleport" then
      if Config.WayPointTeleport.Saved then
        Teleport(Config.WayPointTeleport.Saved)
      end
    elseif Type == "Delete" then
      Config.WayPointTeleport.Saved = nil
    end
  end
end

--//Library
local Tab = Window:CreateTab("Movement")

local Section = Tab:CreateSection("Character")

Tab:CreateToggle({
    Name = "Enable WalkSpeed",
    CurrentValue = false,
    Callback = function(State)
      Config.WalkSpeed.Enabled = State
      UpdateHumanoidProperty("WalkSpeed",Config.WalkSpeed)
    end
})

Tab:CreateSlider({
    Name = "WalkSpeed Value",
    Range = {0, 1000}, --- Mínimo y máximo
    Increment = 0.1, --- De cuánto en cuánto cambia
    Suffix = "studs/s", --- Texto después del valor
    CurrentValue = 16, --- Valor inicial
    Callback = function(Value)
      Config.WalkSpeed.Value = Value
      UpdateHumanoidProperty("WalkSpeed",Config.WalkSpeed)
    end
})

Tab:CreateToggle({
    Name = "Force WalkSpeed",
    CurrentValue = false,
    Callback = function(State)
      Config.WalkSpeed.Force = State
    end
})

Tab:CreateToggle({
    Name = "Enable JumpPower",
    CurrentValue = false,
    Callback = function(State)
      Config.JumpPower.Enabled = State
      UpdateHumanoidProperty("JumpPower",Config.JumpPower)
    end
})

Tab:CreateSlider({
    Name = "JumpPower Value",
    Range = {0, 1000}, --- Mínimo y máximo
    Increment = 0.1, --- De cuánto en cuánto cambia
    Suffix = "studs/s", --- Texto después del valor
    CurrentValue = 52, --- Valor inicial
    Callback = function(Value)
      Config.JumpPower.Value = Value
      UpdateHumanoidProperty("JumpPower",Config.JumpPower)
    end
})

Tab:CreateToggle({
    Name = "Force JumpPower",
    CurrentValue = false,
    Callback = function(State)
      Config.JumpPower.Force = State
    end
})

Tab:CreateToggle({
    Name = "Enable Slide",
    CurrentValue = false,
    Callback = function(State)
      Config.Slide.Enabled = State
    end
})

Tab:CreateSlider({
    Name = "Slide Value",
    Range = {0, 100}, --- Mínimo y máximo
    Increment = 1, --- De cuánto en cuánto cambia
    Suffix = "studs/s", --- Texto después del valor
    CurrentValue = 1, --- Valor inicial
    Callback = function(Value)
      Config.Slide.Value = Value
    end
})

Tab:CreateDropdown({
    Name = "Slide Method",
    Options = {
      "CFrame",
      "Velocity"
    },
    Callback = function(Option)
        Config.Slide.Method = Option
    end
})

Tab:CreateToggle({
    Name = "Enable HipHeight",
    CurrentValue = false,
    Callback = function(State)
      Config.HipHeight.Enabled = State
      UpdateHumanoidProperty("HipHeight",Config.HipHeight)
    end
})

Tab:CreateSlider({
    Name = "HipHeight Value",
    Range = {0, 100}, --- Mínimo y máximo
    Increment = 1, --- De cuánto en cuánto cambia
    Suffix = "studs/s", --- Texto después del valor
    CurrentValue = 1, --- Valor inicial
    Callback = function(Value)
      Config.HipHeight.Value = Value
      UpdateHumanoidProperty("HipHeight",Config.HipHeight)
    end
})

local Section2 = Tab:CreateSection("Teleport")

Tab:CreateToggle({
    Name = "Teleport Tool",
    CurrentValue = false,
    Callback = function(State)
      Config.TeleportTool.Enabled = State
      if State then
        GetTeleportTool()
      else
        local Tool = Config.TeleportTool.Tool or Client and Client:FindFirstChild("Backpack") and Client.Backpack:FindFirstChild("TeleportTool")
        if Tool then
          Tool:Destroy()
          Config.TeleportTool.Tool = nil
        end
      end
    end
})

Tab:CreateToggle({
    Name = "ControlClick Teleport",
    CurrentValue = false,
    Callback = function(State)
      Config.ControlClickTp.Enabled = State
    end
})

Tab:CreateButton({
  Name = "Save WayPoint",
  Callback = function()
    WayPointTeleport("Save")
  end
})

Tab:CreateButton({
  Name = "Teleport To WayPoint",
  Callback = function()
    WayPointTeleport("Teleport")
  end
})

Tab:CreateButton({
  Name = "Delete WayPoint",
  Callback = function()
    WayPointTeleport("Delete")
  end
})

local Section3 = Tab:CreateSection("Physics")

Tab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Callback = function(State)
      Config.Noclip.Enabled = State
      UpdateNoclip(Config.Noclip)
    end
})

Tab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Callback = function(State)
      Config.InfiniteJump.Enabled = State
    end
})

Tab:CreateToggle({
    Name = "AirWalk",
    CurrentValue = false,
    Callback = function(State)
      Config.AirWalk.Enabled = State
      if not State then
        if Config.AirWalk.Platform then
          Config.AirWalk.Platform:Destroy()
          Config.AirWalk.Platform = nil
        end
      end
    end
})

local Section4 = Tab:CreateSection("MiscMovement")

Tab:CreateToggle({
    Name = "Spin",
    CurrentValue = false,
    Callback = function(State)
      Config.Spin.Enabled = State
    end
})

Tab:CreateSlider({
    Name = "Spin Value",
    Range = {0, 180}, --- Mínimo y máximo
    Increment = 1, --- De cuánto en cuánto cambia
    Suffix = "Spin/s", --- Texto después del valor
    CurrentValue = 1, --- Valor inicial
    Callback = function(Value)
      Config.Spin.Value = Value
    end
})

--//Events
Client.CharacterAdded:Connect(function(Character)
    if not Character:FindFirstChild("Humanoid") then
      Character:WaitForChild("Humanoid")
    end
    UpdateHumanoidProperty("WalkSpeed",Config.WalkSpeed)
    UpdateHumanoidProperty("JumpPower",Config.JumpPower)
    UpdateNoclip(Config.Noclip)
    UpdateHumanoidProperty("HipHeight",Config.HipHeight)
end)

UserInputService.InputBegan:Connect(function(Input,GameProcessed)
  if Input.KeyCode == Enum.KeyCode.RightControl or Input.KeyCode == Enum.KeyCode.LeftControl then
    Config.ControlClickTp.Pressed = true
  end
  if Input.UserInputType == Enum.UserInputType.MouseButton1 then
    if Config.ControlClickTp.Enabled and Config.ControlClickTp.Pressed then
      local Mouse = Client:GetMouse()
      if Mouse and Mouse.Hit then
        Teleport(Mouse.Hit)
      end
    end
  end
end)

UserInputService.InputEnded:Connect(function(Input,GameProcessed)
  if Input.KeyCode == Enum.KeyCode.RightControl or Input.KeyCode == Enum.KeyCode.LeftControl then
    Config.ControlClickTp.Pressed = false
  end
end)

UserInputService.JumpRequest:Connect(function()
  if Config.InfiniteJump.Enabled then
    local Character = Client.Character
    if Character then
      local Humanoid = Character:FindFirstChild("Humanoid")
      if Humanoid then
        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
      end
    end
  end
end)

--//Loops
RunService.Heartbeat:Connect(function()
  if Config.WalkSpeed.Enabled then
    if Config.WalkSpeed.Force then
      local Humanoid = GetHumanoid()
      if Humanoid then
        if Humanoid.WalkSpeed ~= Config.WalkSpeed.Value then
          UpdateHumanoidProperty("WalkSpeed",Config.WalkSpeed)
        end
      end
    end
  end
  if Config.JumpPower.Enabled then
    if Config.JumpPower.Force then
      local Humanoid = GetHumanoid()
      if Humanoid then
        if Humanoid.JumpPower ~= Config.JumpPower.Value then
          UpdateHumanoidProperty("JumpPower",Config.JumpPower)
        end
      end
    end
  end
  if Config.Slide.Enabled then
    local HumanoidRootPart = GetHumanoidRootPart()
    if HumanoidRootPart then
      local Method = Config.Slide.Method
      local Value = Config.Slide.Value
      local MoveDirection = GetMoveDirection()
      if MoveDirection and MoveDirection.Magnitude > 0 then
        if Method == "CFrame" then
          Teleport((HumanoidRootPart.Position + MoveDirection.Unit * Value))
        elseif Method == "Velocity" then
          ApplyVelocity(Vector3.new(MoveDirection.X * Value * 4,HumanoidRootPart.AssemblyLinearVelocity.Y,MoveDirection.Z * Value * 4))
        end
      end
    end
  end
  if Config.Noclip.Enabled then
    UpdateNoclip(Config.Noclip)
  end
  if Config.AirWalk.Enabled then
    UpdatePlatform()
  end
  if Config.HipHeight.Enabled then
    UpdateHumanoidProperty("HipHeight",Config.HipHeight)
  end
  if Config.Spin.Enabled then
    local HumanoidRootPart = GetHumanoidRootPart()
    if HumanoidRootPart then
      Teleport(HumanoidRootPart.CFrame * CFrame.Angles(0,math.rad(Config.Spin.Value),0))
    end
  end
end)