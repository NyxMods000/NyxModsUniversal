--//Variables
local NyxModsUniversal = getgenv().NyxModsUniversal
local Window = NyxModsUniversal.Window
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Client = Players.LocalPlayer

local Config = {
  Target = nil,
  TargetCharacterAdded = nil,
  Fling = {
    FlingInProgress = false,
    StopFling = false
  },
  Spectate = {
    Enabled = false,
  },
  Bang = {
    Enabled = false,
    Speed = 0.5,
    BangAnimation = {
      Id = 133422692462315,
      TimePosition = 0,
      Pause = false,
      Speed = 0,
      Looped = true
    }
  },
  FaceBang = {
    Enabled = false,
    Speed = 0.5,
    FaceBangAnimation = {
      Id = 139395178419877,
      TimePosition = 0.5,
      Pause = true,
      Speed = 0,
      Looped = true
    }
  },
  Suck = {
    Enabled = false,
    Speed = 0.5,
    SuckAnimation = {
      Id = 123822744060080,
      TimePosition = 0.5,
      Pause = true,
      Speed = 0,
      Looped = true
    }
  },
  GetBang = {
    Enabled = false,
    Speed = 0.5,
    GetBangAnimation = {
      Id = 80401449796551,
      TimePosition = 0,
      Pause = false,
      Speed = 1,
      Looped = true
    }
  },
  Orbit = {
    Enabled = false,
    Speed = 10,
    Radius = 10,
    Irregular = false
  }
}

--//Functions
function GetPlayerByPartialName(Text)
  local Name = Text and Text:lower()
  for i,v in ipairs(Players:GetPlayers()) do
    if v.Name:lower():sub(1,#Name) == Name or v.DisplayName:lower():sub(1,#Name) == Name then
      return v
    end
  end
end

function GetHumanoidRootPart(Player)
  local Character = Player.Character
  if Character then
    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
    if HumanoidRootPart then
      return HumanoidRootPart
    end
  end
end

function GetHumanoid(Player)
  local Character = Player.Character
  if Character then
    local Humanoid = Character:FindFirstChild("Humanoid")
    if Humanoid then
      return Humanoid
    end
  end
end

function ItsPlayingAnimation(Player,Id)
  local Humanoid = GetHumanoid(Player)
  if Humanoid then
    for _,Track in ipairs(Humanoid:GetPlayingAnimationTracks()) do
      local Animation = Track and Track.Animation
      if Animation then
        if Animation.AnimationId == Id or Animation.AnimationId == "rbxassetid://"..Id then
          return true
        end
      end
    end
    return nil
  end
  return nil
end

function PlayAnimation(Id,Pause,Time,Speed,Looped)
  local Humanoid = GetHumanoid(Client)
  if Humanoid then
    local Animator = Humanoid:FindFirstChild("Animator")
    if Animator then
      local Animation = Instance.new("Animation")
      Animation.AnimationId = "rbxassetid://"..Id
      
      local Track = Animator:LoadAnimation(Animation)
      Track.Priority = Enum.AnimationPriority.Action4
      Track:Play()
      
      Track:AdjustSpeed(Speed)
      Track.TimePosition = Time
      
      if Pause then
        Track.TimePosition = Time
        Track:AdjustSpeed(0)
      end
      
      if Looped then
        Track.Looped = true
      end
      
    elseif Humanoid then
      local Animation = Instance.new("Animation")
      Animation.AnimationId = "rbxassetid://"..Id
      
      local Track = Humanoid:LoadAnimation(Animation)
      Track:Play()
      
      Track:AdjustSpeed(Speed)
      Track.TimePosition = Time
      
      if Pause then
        Track.TimePosition = Time
        Track.AdjustSpeed(0)
      end
    end
  end
end

function StopAnimation(Id)
  local Humanoid = GetHumanoid(Client)
  if Humanoid then
    for _,Track in ipairs(Humanoid:GetPlayingAnimationTracks()) do
      local Animation = Track and Track.Animation
      if Animation then
        if Animation.AnimationId == Id or Animation.AnimationId == "rbxassetid://"..Id then
          Track:Stop()
        end
      end
    end
    return nil
  end
  return nil
end

function TeleportToPlayer(Player)
  local TargetHumanoidRootPart = GetHumanoidRootPart(Player)
  local HumanoidRootPart = GetHumanoidRootPart(Client)
  if TargetHumanoidRootPart and HumanoidRootPart then
    HumanoidRootPart.CFrame = TargetHumanoidRootPart.CFrame
  end
end

function FlingPlayer(Target)
  if Config.Fling.FlingInProgress then
    Config.Fling.StopFling = true
    task.wait(0.1)
    Config.Fling.StopFling = false
  end
  
  local AlreadyFlinged = false
  local OldPosition = nil
  local i = 0
  task.spawn(function()
    Config.Fling.FlingInProgress = true
    while true do
      if Target then
        local TargetHumanoidRootPart = GetHumanoidRootPart(Target)
        local TargetHumanoid = GetHumanoid(Target)
        local HumanoidRootPart = GetHumanoidRootPart(Client)
        if TargetHumanoidRootPart and HumanoidRootPart then
          --// Save initial position
          if not OldPosition then
            OldPosition = HumanoidRootPart.CFrame
          end
          --// Stop fling
          if AlreadyFlinged or Config.Fling.StopFling or not Target or i >= 200 then
            if OldPosition then
              for i = 1,50,1 do
                HumanoidRootPart.Velocity = Vector3.new(0,0,0)
                HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0,0,0)
                HumanoidRootPart.AssemblyAngularVelocity = Vector3.new(0,0,0)
                HumanoidRootPart.CFrame = OldPosition
              end
            end
            Config.Fling.FlingInProgress = false
            break
          end
          
          if Target and TargetHumanoidRootPart and TargetHumanoidRootPart.Velocity.Magnitude >= 100 then
            AlreadyFlinged = true
          end
          
          if not AlreadyFlinged and not Config.Fling.StopFling and Target and TargetHumanoidRootPart and HumanoidRootPart then
            local MoveVelocity = TargetHumanoidRootPart.AssemblyLinearVelocity
            
            HumanoidRootPart.CFrame = TargetHumanoidRootPart.CFrame + MoveVelocity / 1.5
            HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(11000,11000,11000)
          end
          
          
        end
      end
      i = i + 1
      task.wait(0.01)
    end
  end)
end

function SpectatePlayer(Player)
  local Camera = Workspace.CurrentCamera
  local Humanoid = GetHumanoid(Player)
  if Humanoid then
    Camera.CameraSubject = Humanoid
  end
end

function Bang()
  task.spawn(function()
    local i = 1
    local Direction = 1
    local OrignalGravity = Workspace.Gravity
    while true do
      local Target = Config.Target
      local Speed = Config.Bang.Speed
      if not Config.Bang.Enabled then
        StopAnimation(Config.Bang.BangAnimation.Id)
        Workspace.Gravity = OrignalGravity
        break
      end
      
      if i <= 1 then
        Direction = 1
      elseif i >= 7 then
        Direction = 0
      end
      
      if Direction == 0 then
        i = i - Speed
      elseif Direction == 1 then
        i = i + Speed
      end
      
      if Target then
        local TargetHumanoidRootPart = GetHumanoidRootPart(Target)
        local HumanoidRootPart = GetHumanoidRootPart(Client)
        if TargetHumanoidRootPart and HumanoidRootPart then
          HumanoidRootPart.CFrame = TargetHumanoidRootPart.CFrame * CFrame.new(0,0,i)
          HumanoidRootPart.CFrame = HumanoidRootPart.CFrame * CFrame.Angles(0,math.rad(180),0)
          if not ItsPlayingAnimation(Client,Config.Bang.BangAnimation.Id) then
            PlayAnimation(Config.Bang.BangAnimation.Id,Config.Bang.BangAnimation.Pause,Config.Bang.BangAnimation.TimePosition,Config.Bang.BangAnimation.Speed,Config.Bang.BangAnimation.Looped)
          end
        end
      else
        StopAnimation(Config.Bang.BangAnimation.Id)
        Workspace.Gravity = OrignalGravity
        break
      end
      
      task.wait(0.01)
    end
  end)
end

function FaceBang()
  task.spawn(function()
    local i = 1
    local Direction = 1
    local OrignalGravity = Workspace.Gravity
    while true do
      local Target = Config.Target
      local Speed = Config.FaceBang.Speed
      if not Config.FaceBang.Enabled then
        StopAnimation(Config.FaceBang.FaceBangAnimation.Id)
        Workspace.Gravity = OrignalGravity
        break
      end
      
      if i <= -5 then
        Direction = 1
      elseif i >= -1 then
        Direction = 0
      end
      
      if Direction == 0 then
        i = i - Speed
      elseif Direction == 1 then
        i = i + Speed
      end
      
      if Target then
        local TargetCharacter = Target.Character
        local HumanoidRootPart = GetHumanoidRootPart(Client)
        if TargetCharacter and HumanoidRootPart then
          local Head = TargetCharacter:FindFirstChild("Head")
          if Head then
            HumanoidRootPart.CFrame = Head.CFrame * CFrame.new(0,1.5,i)
            HumanoidRootPart.CFrame = HumanoidRootPart.CFrame * CFrame.Angles(0,math.rad(180),0)
            if not ItsPlayingAnimation(Client,Config.FaceBang.FaceBangAnimation.Id) then
            PlayAnimation(Config.FaceBang.FaceBangAnimation.Id,Config.FaceBang.FaceBangAnimation.Pause,Config.FaceBang.FaceBangAnimation.TimePosition,Config.FaceBang.FaceBangAnimation.Speed,Config.FaceBang.FaceBangAnimation.Looped)
          end
          end
        end
      else
        StopAnimation(Config.FaceBang.FaceBangAnimation.Id)
        Workspace.Gravity = OrignalGravity
        break
      end
      
      task.wait(0.01)
    end
  end)
end

function Suck()
  task.spawn(function()
    local i = 1
    local Direction = 1
    local OrignalGravity = Workspace.Gravity
    while true do
      local Target = Config.Target
      local Speed = Config.Suck.Speed
      if not Config.Suck.Enabled then
        StopAnimation(Config.Suck.SuckAnimation.Id)
        Workspace.Gravity = OrignalGravity
        break
      end
      
      if i <= -7 then
        Direction = 1
      elseif i >= -2.5 then
        Direction = 0
      end
      
      if Direction == 0 then
        i = i - Speed
      elseif Direction == 1 then
        i = i + Speed
      end
      
      if Target then
        local HumanoidRootPart = GetHumanoidRootPart(Client)
        local TargetHumanoidRootPart = GetHumanoidRootPart(Target)
        if TargetHumanoidRootPart and HumanoidRootPart then
            HumanoidRootPart.CFrame = TargetHumanoidRootPart.CFrame * CFrame.new(0,0.5,i)
            HumanoidRootPart.CFrame = HumanoidRootPart.CFrame * CFrame.Angles(0,math.rad(180),0)
            if not ItsPlayingAnimation(Client,Config.Suck.SuckAnimation.Id) then
            PlayAnimation(Config.Suck.SuckAnimation.Id,Config.Suck.SuckAnimation.Pause,Config.Suck.SuckAnimation.TimePosition,Config.Suck.SuckAnimation.Speed,Config.Suck.SuckAnimation.Looped)
          end
        end
      else
        StopAnimation(Config.Suck.SuckAnimation.Id)
        Workspace.Gravity = OrignalGravity
        break
      end
      
      task.wait(0.01)
    end
  end)
end

function GetBang()
  task.spawn(function()
    local i = 1
    local Direction = 1
    local OrignalGravity = Workspace.Gravity
    while true do
      local Target = Config.Target
      local Speed = Config.GetBang.Speed
      if not Config.GetBang.Enabled then
        StopAnimation(Config.GetBang.GetBangAnimation.Id)
        Workspace.Gravity = OrignalGravity
        break
      end
      
      if i <= -7 then
        Direction = 1
      elseif i >= -1 then
        Direction = 0
      end
      
      if Direction == 0 then
        i = i - Speed
      elseif Direction == 1 then
        i = i + Speed
      end
      
      if Target then
        local HumanoidRootPart = GetHumanoidRootPart(Client)
        local TargetHumanoidRootPart = GetHumanoidRootPart(Target)
        if TargetHumanoidRootPart and HumanoidRootPart then
            HumanoidRootPart.CFrame = TargetHumanoidRootPart.CFrame * CFrame.new(0,0.5,i)
            if not ItsPlayingAnimation(Client,Config.GetBang.GetBangAnimation.Id) then
            PlayAnimation(Config.GetBang.GetBangAnimation.Id,Config.GetBang.GetBangAnimation.Pause,Config.GetBang.GetBangAnimation.TimePosition,Config.GetBang.GetBangAnimation.Speed,Config.GetBang.GetBangAnimation.Looped)
          end
        end
      else
        StopAnimation(Config.GetBang.GetBangAnimation.Id)
        Workspace.Gravity = OrignalGravity
        break
      end
      
      task.wait(0.01)
    end
  end)
end

function Orbit()
  task.spawn(function()
    local i = 0
    local OrignalGravity = Workspace.Gravity
    while true do
      if not Config.Orbit.Enabled then
        Workspace.Gravity = OrignalGravity
        break
      end
      
      local Target = Config.Target
      local Speed = Config.Orbit.Speed / 200
      local Radius = Config.Orbit.Radius
      local Irregular = Config.Orbit.Irregular
      
      if Target then
        local TargetHumanoidRootPart = GetHumanoidRootPart(Target)
        local HumanoidRootPart = GetHumanoidRootPart(Client)
        if TargetHumanoidRootPart and HumanoidRootPart then
          
          local X = nil
          local Y = nil
          local Z = nil
          
          if Irregular then
            X = math.sin(i) * Radius
            Y = math.sin(i) * math.random(-5,5)
            Z = math.cos(i) * Radius
          else
            X = math.sin(i) * Radius
            Y = 0
            Z = math.cos(i) * Radius
          end
          
          HumanoidRootPart.CFrame = TargetHumanoidRootPart.CFrame * CFrame.new(X,Y,Z)
          Workspace.Gravity = 0
          
          i = i + Speed
        end
      else
        Workspace.Gravity = OrignalGravity
        break
      end
      task.wait(0.01)
    end
  end)
end

--//Library
local Tab = Window:CreateTab("Troll")
local Section = Tab:CreateSection("Select Target")

Tab:CreateInput({
  Name = "Player Name",
  PlaceholderText = "Write a name...",
  Callback = function(Text)
    local Player = GetPlayerByPartialName(Text)
    if Player then
      Config.Target = Player
      if Config.TargetCharacterAdded then
        Config.TargetCharacterAdded:Disconnect()
        Config.TargetCharacterAdded = nil
      end
      if not Config.TargetCharacterAdded then
        Config.TargetCharacterAdded = Player.CharacterAdded:Connect(function(Character)
          local Humanoid = GetHumanoid(Player)
          if not Humanoid then
            Character:WaitForChild("Humanoid")
          end
          if Config.Spectate.Enabled then
            if Config.Target then
              SpectatePlayer(Config.Target)
            end
          end
        end)
      end
    else
      
    end
  end
})

Tab:CreateToggle({
    Name = "Spectate",
    CurrentValue = false,
    Callback = function(State)
      Config.Spectate.Enabled = State
      if State then
        SpectatePlayer(Config.Target)
      else
        SpectatePlayer(Client)
      end
    end
})

Tab:CreateButton({
  Name = "Teleport",
  Callback = function()
    if Config.Target then
      TeleportToPlayer(Config.Target)
    end
  end
})

Tab:CreateButton({
  Name = "Fling",
  Callback = function()
    FlingPlayer(Config.Target)
  end
})

Tab:CreateToggle({
    Name = "Bang",
    CurrentValue = false,
    Callback = function(State)
      Config.Bang.Enabled = State
      if State then
        Bang()
      end
    end
})

Tab:CreateSlider({
    Name = "Bang speed",
    Range = {0.1, 2}, --- Mínimo y máximo
    Increment = 0.01, --- De cuánto en cuánto cambia
    Suffix = "/s", --- Texto después del valor
    CurrentValue = 0.5, --- Valor inicial
    Callback = function(Value)
      Config.Bang.Speed = Value
    end
})

Tab:CreateToggle({
    Name = "Face Bang",
    CurrentValue = false,
    Callback = function(State)
      Config.FaceBang.Enabled = State
      if State then
        FaceBang()
      end
    end
})

Tab:CreateSlider({
    Name = "Face Bang speed",
    Range = {0.1, 2}, --- Mínimo y máximo
    Increment = 0.01, --- De cuánto en cuánto cambia
    Suffix = "/s", --- Texto después del valor
    CurrentValue = 0.5, --- Valor inicial
    Callback = function(Value)
      Config.FaceBang.Speed = Value
    end
})

Tab:CreateToggle({
    Name = "Suck",
    CurrentValue = false,
    Callback = function(State)
      Config.Suck.Enabled = State
      if State then
        Suck()
      end
    end
})

Tab:CreateSlider({
    Name = "Suck speed",
    Range = {0.1, 2}, --- Mínimo y máximo
    Increment = 0.01, --- De cuánto en cuánto cambia
    Suffix = "/s", --- Texto después del valor
    CurrentValue = 0.5, --- Valor inicial
    Callback = function(Value)
      Config.Suck.Speed = Value
    end
})

Tab:CreateToggle({
    Name = "Get bang",
    CurrentValue = false,
    Callback = function(State)
      Config.GetBang.Enabled = State
      if State then
        GetBang()
      end
    end
})

Tab:CreateSlider({
    Name = "Get bang speed",
    Range = {0.1, 2}, --- Mínimo y máximo
    Increment = 0.01, --- De cuánto en cuánto cambia
    Suffix = "/s", --- Texto después del valor
    CurrentValue = 0.5, --- Valor inicial
    Callback = function(Value)
      Config.GetBang.Speed = Value
    end
})

Tab:CreateToggle({
    Name = "Orbit",
    CurrentValue = false,
    Callback = function(State)
      Config.Orbit.Enabled = State
      if State then
        Orbit()
      end
    end
})

Tab:CreateToggle({
    Name = "Irregular orbit",
    CurrentValue = false,
    Callback = function(State)
      Config.Orbit.Irregular = State
    end
})

Tab:CreateSlider({
    Name = "Orbit speed",
    Range = {0.1, 100}, --- Mínimo y máximo
    Increment = 0.01, --- De cuánto en cuánto cambia
    Suffix = "/s", --- Texto después del valor
    CurrentValue = 10, --- Valor inicial
    Callback = function(Value)
      Config.Orbit.Speed = Value
    end
})

Tab:CreateSlider({
    Name = "Orbit radius",
    Range = {0.1, 100}, --- Mínimo y máximo
    Increment = 0.01, --- De cuánto en cuánto cambia
    Suffix = "/s", --- Texto después del valor
    CurrentValue = 10, --- Valor inicial
    Callback = function(Value)
      Config.Orbit.Radius = Value
    end
})

--//Events
Client.CharacterAdded:Connect(function(Character)
  local Humanoid = GetHumanoid(Client)
  if not Humanoid then
    Character:WaitForChild("Humanoid")
  end
  if Config.Spectate.Enabled then
    if Config.Target then
      SpectatePlayer(Config.Target)
    end
  end
end)

--//Loops
