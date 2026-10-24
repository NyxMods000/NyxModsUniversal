local NyxModsUniversal = getgenv().NyxModsUniversal
local Window = NyxModsUniversal.Window
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local VirtualInputManager = nil
local GuiService = game:GetService("GuiService")
local Client = Players.LocalPlayer

if game.PlaceId ~= 135856908115931 then
  VirtualInputManager = game:GetService("VirtualInputManager")
end

local Config = {
  FpsViewer = false,
  Fps = 0,
  PlayersHistory = {},
  ServersList = nil,
  ServerName = nil,
  SelectedServerData = nil,
  MuteGame = false,
  PausedInstances = {},
  AutoClicker = {
    Enabled = false,
    Points = 0,
    PointsTable = {},
    Cooldown = 0.01,
    ToggleCooldown = false,
  }
}

local function GetServersNames()
  local List = {}
  if Config.ServersList then
    for i,v in pairs(Config.ServersList) do
      table.insert(List,i)
    end
  end
  return List
end

local function GetSavedServersList()
  if isfolder("NyxMods-Servers") then
    if isfile("NyxMods-Servers/Servers.json") then
      local ServersList = HttpService:JSONDecode(readfile("NyxMods-Servers/Servers.json"))
      if ServersList then
        return ServersList
      end
    end
  end
  return {}
end

Config.ServersList = GetSavedServersList()

local function SaveServer(Name)
  local PlaceId = game.PlaceId
  local JobId = game.JobId

  if Config.ServersList then
    Config.ServersList[Name] = {
      PlaceId = PlaceId,
      JobId = JobId,
    }
  end

  local ServersListJSON = HttpService:JSONEncode(Config.ServersList)

  if not isfolder("NyxMods-Servers") then
    pcall(makefolder("NyxMods-Servers"))
  end

  writefile("NyxMods-Servers/Servers.json",ServersListJSON)
end

local function DeleteServer(Data)
  if isfolder("NyxMods-Servers") then
    if isfile("NyxMods-Servers/Servers.json") then
      local ServersData = HttpService:JSONDecode(readfile("NyxMods-Servers/Servers.json"))
      if ServersData then
        local ServerName = nil
        for i,v in pairs(ServersData) do
          if v.PlaceId == Data.PlaceId and v.JobId == Data.JobId then
            ServerName = tostring(i)
            break
          end
        end
        if ServerName then
          ServersData[ServerName] = nil
          Config.ServersList = ServersData
          local ServersListJSON = HttpService:JSONEncode(ServersData)
          writefile("NyxMods-Servers/Servers.json",ServersListJSON)
        end
      end
    end
  end
end

local function GetServersList()
  local ServersTable = {}
  local PlaceId = game.PlaceId
  local Cursor

  for i = 1,100,1 do
    local Url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(PlaceId)

    if Cursor then
      Url ..= "&cursor="..Cursor
    end

    local Servers = HttpService:JSONDecode(game:HttpGet(Url))

    for i,Server in ipairs(Servers.data) do
      table.insert(ServersTable,Server)
    end

    Cursor = Servers.nextPageCursor
    if not Cursor then
      break
    end
  end

  return ServersTable
end

local function ServerHop()
  local Servers = GetServersList()
  local JobId = game.JobId

  for i,Server in ipairs(Servers) do
    local queue_on_teleport = queue_on_teleport or queueonteleport or (syn and syn.queue_on_teleport)
    if Server.playing < Server.maxPlayers and Server.id ~= JobId then
      print("entro hop")
      if queue_on_teleport then
        queue_on_teleport([[task.wait(2) loadstring(game:HttpGet("https://raw.githubusercontent.com/NyxMods000/NyxModsUniversal/refs/heads/main/Loader.lua"))()]])
      end
      TeleportService:TeleportToPlaceInstance(game.PlaceId,Server.id,Client)
      return
    end
  end
end

local function SmallServer()
  local Servers = GetServersList()
  local JobId = game.JobId
  local MaxPlayers = math.huge
  local Small = nil

  for _, Server in ipairs(Servers) do
    if Server.id ~= JobId and Server.playing < Server.maxPlayers and Server.playing < MaxPlayers then
      MaxPlayers = Server.playing
      Small = Server
    end
  end

  print("Salio small")
  local queue_on_teleport = queue_on_teleport or queueonteleport or (syn and syn.queue_on_teleport)

  if Small.playing < Small.maxPlayers and Small.id ~= JobId then
    print("entro small")
    if queue_on_teleport then
      queue_on_teleport([[task.wait(2) loadstring(game:HttpGet("https://raw.githubusercontent.com/NyxMods000/NyxModsUniversal/refs/heads/main/Loader.lua"))()]])
    end
    TeleportService:TeleportToPlaceInstance(game.PlaceId,Small.id,Client)
    return
  end
end

local function Rejoin()
  local PlaceId = game.PlaceId
  local JobId = game.JobId
  local queue_on_teleport = queue_on_teleport or queueonteleport or (syn and syn.queue_on_teleport)

  if queue_on_teleport then
    queue_on_teleport([[task.wait(2) loadstring(game:HttpGet("https://raw.githubusercontent.com/NyxMods000/NyxModsUniversal/refs/heads/main/Loader.lua"))()]])
  end

  TeleportService:TeleportToPlaceInstance(PlaceId,JobId,Client)
end

local function Respawn(InPosition)
  local OldPosition = nil
  local Character = Client.Character

  if Character then
    local Humanoid = Character:FindFirstChild("Humanoid")
    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")

    if Humanoid and HumanoidRootPart then
      if InPosition then
        OldPosition = HumanoidRootPart.CFrame
        Humanoid.Health = -Humanoid.MaxHealth * 2
        Client.CharacterAdded:Wait()
        task.wait(0.1)
        Character = Client.Character

        if Character then
          HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
          if HumanoidRootPart then
            HumanoidRootPart.CFrame = OldPosition
          end
        end
      else
        Humanoid.Health = -Humanoid.MaxHealth * 2
      end
    end
  end
end

local function Sit()
  local Character = Client.Character
  if Character then
    local Humanoid = Character:FindFirstChild("Humanoid")
    if Humanoid then
      Humanoid.Sit = true
    end
  end
end

local function Ragdoll()
  local Character = Client.Character
  if Character then
    local Humanoid = Character:FindFirstChild("Humanoid")
    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")

    if Humanoid and HumanoidRootPart then
      for i = 1,30,1 do
        if HumanoidRootPart then
          HumanoidRootPart.CFrame = HumanoidRootPart.CFrame * CFrame.Angles(math.rad(-2),0,0)
          Humanoid.PlatformStand = true
        end
        task.wait(0.01)
      end

      task.wait(1)

      if Humanoid then
        Humanoid.PlatformStand = false
      end
    end
  end
end

function FpsViewer()
  task.spawn(function()
    while true do
      if Config.FpsViewer then
        local CoreGui = game:GetService("CoreGui")

        if CoreGui then
          if not CoreGui:FindFirstChild("FpsScreenGui") then
            local FpsScreenGui = Instance.new("ScreenGui")
            FpsScreenGui.Name = "FpsScreenGui"
            FpsScreenGui.Parent = CoreGui
          end

          local FpsScreenGui = CoreGui:FindFirstChild("FpsScreenGui")

          if FpsScreenGui then
            if not FpsScreenGui:FindFirstChild("FpsFrame") then
              local FpsFrame = Instance.new("Frame")
              FpsFrame.Name = "FpsFrame"
              FpsFrame.Active = false
              FpsFrame.Size = UDim2.new(1,0,1,0)
              FpsFrame.BackgroundTransparency = 1
              FpsFrame.Parent = FpsScreenGui
            end

            local FpsFrame = FpsScreenGui:FindFirstChild("FpsFrame")

            if FpsFrame then
              if not FpsFrame:FindFirstChild("FpsText") then
                local FpsText = Instance.new("TextLabel")
                FpsText.Name = "FpsText"
                FpsText.Active = false
                FpsText.TextSize = 24
                FpsText.Position = UDim2.new(0.9,0,0,0)
                FpsText.BackgroundTransparency = 1
                FpsText.TextColor3 = Config.Fps <= 20 and Color3.fromRGB(255,0,0) or Config.Fps > 20 and Config.Fps <= 40 and Color3.fromRGB(255,128,26) or Config.Fps > 40 and Color3.fromRGB(0,255,0)
                FpsText.Parent = FpsFrame
              end

              local FpsText = FpsFrame:FindFirstChild("FpsText")

              if FpsText then
                FpsText.Text = "Fps: ".. tostring(Config.Fps)
                FpsText.TextColor3 = Config.Fps <= 20 and Color3.fromRGB(255,0,0) or Config.Fps > 20 and Config.Fps <= 40 and Color3.fromRGB(255,128,26) or Config.Fps > 40 and Color3.fromRGB(0,255,0)
                Config.Fps = 0
              end
            end
          end
        end
      else
        local CoreGui = game:GetService("CoreGui")

        if CoreGui then
          local FpsScreenGui = CoreGui:FindFirstChild("FpsScreenGui")

          if FpsScreenGui then
            FpsScreenGui:Destroy()
            break
          end

          break
        end

        break
      end

      task.wait(1)
    end
  end)
end

local function ExecutorViewer(State)
  local Executor = identifyexecutor and identifyexecutor() or getexecutorname and getexecutorname() or "Desconocido / Unknow"

  if State then
    local CoreGui = game:GetService("CoreGui")

    if CoreGui then
      if not CoreGui:FindFirstChild("ExecutorScreenGui") then
        local ExecutorScreenGui = Instance.new("ScreenGui")
        ExecutorScreenGui.Name = "ExecutorScreenGui"
        ExecutorScreenGui.Parent = CoreGui
      end

      local ExecutorScreenGui = CoreGui:FindFirstChild("ExecutorScreenGui")

      if ExecutorScreenGui then
        if not ExecutorScreenGui:FindFirstChild("ExecutorFrame") then
          local ExecutorFrame = Instance.new("Frame")
          ExecutorFrame.Name = "ExecutorFrame"
          ExecutorFrame.Active = false
          ExecutorFrame.Size = UDim2.new(1,0,1,0)
          ExecutorFrame.BackgroundTransparency = 1
          ExecutorFrame.Parent = ExecutorScreenGui
        end

        local ExecutorFrame = ExecutorScreenGui:FindFirstChild("ExecutorFrame")

        if ExecutorFrame then
          if not ExecutorFrame:FindFirstChild("ExecutorText") then
            local ExecutorText = Instance.new("TextLabel")
            ExecutorText.Name = "ExecutorText"
            ExecutorText.Active = false
            ExecutorText.TextSize = 24
            ExecutorText.Position = UDim2.new(0.9,0,0.07,0)
            ExecutorText.BackgroundTransparency = 1
            ExecutorText.TextColor3 = Color3.fromRGB(255,255,255)
            ExecutorText.Parent = ExecutorFrame
          end

          local ExecutorText = ExecutorFrame:FindFirstChild("ExecutorText")

          if ExecutorText then
            ExecutorText.Text = "Executor: ".. Executor
            ExecutorText.TextColor3 = Color3.fromRGB(255,255,255)
          end
        end
      end
    end
  else
    local CoreGui = game:GetService("CoreGui")

    if CoreGui then
      local ExecutorScreenGui = CoreGui:FindFirstChild("ExecutorScreenGui")

      if ExecutorScreenGui then
        ExecutorScreenGui:Destroy()
      end
    end
  end
end

local function MuteGame(State)
  if State then
    for i,v in ipairs(Workspace:GetDescendants()) do
      if v:IsA("Sound") then
        if not v.Playing then
          continue
        else
          v:Pause()
          table.insert(Config.PausedInstances,v)
        end

        v:GetPropertyChangedSignal("Playing"):Connect(function()
          if Config.MuteGame then
            if v.Playing then
              v:Pause()
              table.insert(Config.PausedInstances,v)
            end
          end
        end)
      end
    end
  else
    for i,v in ipairs(Config.PausedInstances) do
      if v:IsDescendantOf(Workspace) then
        table.remove(Config.PausedInstances,i)
      end
    end
  end
end

local function CreatePoint()
  local CoreGui = game:GetService("CoreGui")

  if CoreGui then
    local AutoClickerGui = CoreGui:FindFirstChild("AutoClickerGui")

    if not AutoClickerGui then
      AutoClickerGui = Instance.new("ScreenGui", CoreGui)
      AutoClickerGui.Name = "AutoClickerGui"
      AutoClickerGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    end

    if AutoClickerGui then
      local Points = Config.AutoClicker.Points

      local AutoClickerButton = Instance.new("Frame", AutoClickerGui)
      AutoClickerButton.BorderSizePixel = 0
      AutoClickerButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
      AutoClickerButton.AnchorPoint = Vector2.new(0.5, 0.5)
      AutoClickerButton.Size = UDim2.new(0.05, 0, 0.12, 0)
      AutoClickerButton.Position = UDim2.new(0.5, 0, 0.5, 0)
      AutoClickerButton.Name = "AutoClickerButton"
      AutoClickerButton.BackgroundTransparency = 1

      local UICorner = Instance.new("UICorner", AutoClickerButton)
      UICorner.CornerRadius = UDim.new(0, 999)

      local TextLabel = Instance.new("TextLabel", AutoClickerButton)
      TextLabel.BorderSizePixel = 0
      TextLabel.TextSize = 32
      TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
      TextLabel.BackgroundTransparency = 1
      TextLabel.AnchorPoint = Vector2.new(0.5, 0.5)
      TextLabel.Size = UDim2.new(0.5, 0, 0.5, 0)
      TextLabel.Text = "O"
      TextLabel.Position = UDim2.new(0.5, 0, 0.5, 0)

      local TextLabel2 = Instance.new("TextLabel", AutoClickerButton)
      TextLabel2.BorderSizePixel = 0
      TextLabel2.TextSize = 66
      TextLabel2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
      TextLabel2.BackgroundTransparency = 1
      TextLabel2.AnchorPoint = Vector2.new(0.5, 0.5)
      TextLabel2.Size = UDim2.new(0.5, 0, 0.5, 0)
      TextLabel2.Text = "+"
      TextLabel2.Position = UDim2.new(0.5, 0, 0.5, 0)

      local UIStroke = Instance.new("UIStroke", AutoClickerButton)
      UIStroke.Thickness = 2

      local Number = Instance.new("TextLabel", AutoClickerButton)
      Number.BorderSizePixel = 0
      Number.TextSize = 16
      Number.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
      Number.BackgroundTransparency = 1
      Number.Size = UDim2.new(0.5, 0, 0.5, 0)
      Number.Text = tostring(Config.AutoClicker.Points + 1)
      Number.Name = "Number"
      Number.Position = UDim2.new(1, 0, -0.3, 0)

      local UICorner2 = Instance.new("UICorner", Number)
      UICorner2.CornerRadius = UDim.new(0, 999)

      local UIStroke2 = Instance.new("UIStroke", Number)
      UIStroke2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

      Config.AutoClicker.Points = Config.AutoClicker.Points + 1
      Config.AutoClicker.PointsTable[Config.AutoClicker.Points] = AutoClickerButton

      local Draggin = false
      local DragStart = nil
      local StartPos = nil

      AutoClickerButton.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
          Draggin = true
          DragStart = Input.Position
          StartPos = AutoClickerButton.Position

          Input.Changed:Connect(function()
            if Input.UserInputState == Enum.UserInputState.End then
              Draggin = false
            end
          end)
        end
      end)

      UserInputService.InputChanged:Connect(function(Input)
        if Draggin and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
          local Delta = Input.Position - DragStart

          AutoClickerButton.Position = UDim2.new(
            StartPos.X.Scale,
            StartPos.X.Offset + Delta.X,
            StartPos.Y.Scale,
            StartPos.Y.Offset + Delta.Y
          )
        end
      end)
    end
  end
end

local function DeletePoint()
  local Points = Config.AutoClicker.Points

  if Points > 0 then
    if Config.AutoClicker.PointsTable[Points] ~= nil then
      Config.AutoClicker.PointsTable[Points]:Destroy()
      Config.AutoClicker.PointsTable[Points] = nil
      Config.AutoClicker.Points = Config.AutoClicker.Points - 1
    end
  end
end

local function GetDevice()
  if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
    return "Mobile"
  elseif UserInputService.GamepadEnabled and not UserInputService.KeyboardEnabled then
    return "Console"
  elseif UserInputService.KeyboardEnabled then
    return "PC"
  end

  return "Unknown"
end

local Tab = Window:Tab({
  Title = "Misc",
  Icon = "circle-ellipsis",
})

local Section = Tab:Section({
  Title = "Utilities"
})

Tab:Toggle({
  Title = "Mute Game (Except Voices)",
  Value = false,
  Callback = function(State)
    Config.MuteGame = State
    MuteGame(State)
  end
})

--// Floating AutoClicker Toggle
local function CreateAutoClickerToggle()
    local CoreGui = game:GetService("CoreGui")

    local Existing = CoreGui:FindFirstChild("NyxModsAutoClickerToggle")
    if Existing then
        Existing:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NyxModsAutoClickerToggle"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = CoreGui

    local Button = Instance.new("TextButton")
    Button.Name = "ToggleButton"

    --// Tamaño en SCALE, no en píxeles
    Button.Size = UDim2.new(0.06, 0, 0.09, 0)

    --// Posición inicial
    Button.Position = UDim2.new(0.88, 0, 0.45, 0)

    Button.AnchorPoint = Vector2.new(0.5, 0.5)

    Button.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Button.BackgroundTransparency = 0.08

    Button.BorderSizePixel = 0

    Button.Text = "OFF"
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextScaled = true
    Button.Font = Enum.Font.GothamBold

    Button.AutoButtonColor = false

    Button.Parent = ScreenGui

    --// Bordes redondeados
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0.25, 0)
    Corner.Parent = Button

    --// Borde
    local Stroke = Instance.new("UIStroke")
    Stroke.Thickness = 2
    Stroke.Color = Color3.fromRGB(70, 70, 70)
    Stroke.Transparency = 0
    Stroke.Parent = Button

    --// Sombra
    local Shadow = Instance.new("UIStroke")
    Shadow.Name = "Shadow"
    Shadow.Thickness = 5
    Shadow.Color = Color3.fromRGB(0, 0, 0)
    Shadow.Transparency = 0.65
    Shadow.Parent = Button

    --// Estado visual
    local function UpdateVisual()
        if Config.AutoClicker.Enabled then
            Button.Text = "ON"
            Button.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            Stroke.Color = Color3.fromRGB(0, 255, 120)
        else
            Button.Text = "OFF"
            Button.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
            Stroke.Color = Color3.fromRGB(70, 70, 70)
        end
    end

    UpdateVisual()

    --// Toggle
    Button.Activated:Connect(function()
        if Config.AutoClicker.ToggleCooldown then
            return
        end

        Config.AutoClicker.Enabled = not Config.AutoClicker.Enabled

        Config.AutoClicker.ToggleCooldown = true

        UpdateVisual()

        task.delay(0.5, function()
            Config.AutoClicker.ToggleCooldown = false
        end)
    end)

    --// Drag
    local Dragging = false
    local DragStart = nil
    local StartPosition = nil

    Button.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1
        or Input.UserInputType == Enum.UserInputType.Touch then

            Dragging = true
            DragStart = Input.Position
            StartPosition = Button.Position

            Input.Changed:Connect(function()
                if Input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(Input)
        if not Dragging then
            return
        end

        if Input.UserInputType ~= Enum.UserInputType.MouseMovement
        and Input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        local Delta = Input.Position - DragStart

        Button.Position = UDim2.new(
            StartPosition.X.Scale,
            StartPosition.X.Offset + Delta.X,

            StartPosition.Y.Scale,
            StartPosition.Y.Offset + Delta.Y
        )
    end)

    return ScreenGui
end


local AutoClickerFloatingGui = nil


Tab:Toggle({
    Title = "Auto Clicker",
    Value = false,

    Callback = function(State)

        if not VirtualInputManager then
            Notify("Auto Clicker", "Este juego no soporta autoclicker", 3)
            return
        end

        if State then

            --// Crear botón flotante
            if not AutoClickerFloatingGui then
                AutoClickerFloatingGui = CreateAutoClickerToggle()
            end

        else

            --// Desactivar autoclicker
            Config.AutoClicker.Enabled = false

            --// Eliminar botón flotante
            if AutoClickerFloatingGui then
                AutoClickerFloatingGui:Destroy()
                AutoClickerFloatingGui = nil
            end

            --// Eliminar puntos
            local Points = Config.AutoClicker.Points

            for i = Points, 1, -1 do
                DeletePoint()
            end
        end
    end
})

Tab:Button({
  Title = "Add Button",
  Callback = function()
    pcall(function()
      Notify("Add Button","Button Added",1)
    end)
    CreatePoint()
  end
})

Tab:Button({
  Title = "Remove Button",
  Callback = function()
    pcall(function()
      Notify("Add Button","Button Added",1)
    end)
    DeletePoint()
  end
})

Tab:Slider({
  Title = "Auto Clicker Cooldown",
  Step = 0.01,
  Value = {
    Min = 0,
    Max = 10,
    Default = 0.01
  },
  Callback = function(Value)
    Config.AutoClicker.Cooldown = Value
  end
})

task.spawn(function()
  while true do
    if Config.AutoClicker.Enabled then
      if not VirtualInputManager then return end

      for i,Button in pairs(Config.AutoClicker.PointsTable) do
        local Device = GetDevice()

        if Button then
          local AbsolutePosition = Button.AbsolutePosition
          local AbsoluteSize = Button.AbsoluteSize

          local X = AbsolutePosition.X + AbsoluteSize.X / 0.75
          local Y = AbsolutePosition.Y + AbsoluteSize.Y / 2

          local Inset = GuiService:GetGuiInset()

          X = X + Inset.X
          Y = Y + Inset.Y

          for a,Instance in ipairs(Button:GetDescendants()) do
            if Instance:IsA("UIStroke") then
              Instance.Color = Color3.fromRGB(255,255,255)
            end

            if Instance:IsA("TextLabel") then
              Instance.TextColor3 = Color3.fromRGB(255,255,255)
            end
          end

          VirtualInputManager:SendMouseButtonEvent(X,Y,0,true,game,0)

          task.wait(Config.AutoClicker.Cooldown)

          VirtualInputManager:SendMouseButtonEvent(X,Y,0,false,game,0)

          for a,Instance in ipairs(Button:GetDescendants()) do
            if Instance:IsA("UIStroke") then
              Instance.Color = Color3.fromRGB(0,0,0)
            end

            if Instance:IsA("TextLabel") then
              Instance.TextColor3 = Color3.fromRGB(0,0,0)
            end
          end
        end
      end
    end

    task.wait(0.000000001)
  end
end)

Tab:Button({
  Title = "Rejoin",
  Callback = function()
    pcall(function()
      Notify("Advertisement","Rejoining...",3)
    end)
    Rejoin()
  end
})

Tab:Button({
  Title = "Server Hop",
  Callback = function()
    pcall(function()
      Notify("Advertisement","ServerHop...",3)
    end)
    ServerHop()
  end
})

Tab:Button({
  Title = "Join Small Server",
  Callback = function()
    pcall(function()
      Notify("Advertisement","Joining to small server",3)
    end)
    SmallServer()
  end
})

Tab:Button({
  Title = "Copy PlaceId",
  Callback = function()
    pcall(function()
      Notify("Advertisement","PlaceId Copied",3)
    end)

    pcall(function()
      setclipboard(game.PlaceId)
    end)
  end
})

Tab:Button({
  Title = "Copy JobId",
  Callback = function()
    pcall(function()
      Notify("Advertisement","JobId Copied",3)
    end)

    pcall(function()
      setclipboard(game.JobId)
    end)
  end
})

Tab:Button({
  Title = "Copy Game Link",
  Callback = function()
    pcall(function()
      Notify("Advertisement","Link Copied",3)
    end)

    pcall(function()
      setclipboard("https://www.roblox.com/games/"..game.PlaceId)
    end)
  end
})

Tab:Button({
  Title = "Copy Name",
  Callback = function()
    pcall(function()
      Notify("Advertisement","Name copied",3)
    end)

    pcall(function()
      setclipboard(Client.Name)
    end)
  end
})

Tab:Button({
  Title = "Copy DisplayName",
  Callback = function()
    pcall(function()
      Notify("Advertisement","DisplayName Copied",3)
    end)

    pcall(function()
      setclipboard(Client.DisplayName)
    end)
  end
})

Tab:Button({
  Title = "Copy UserId",
  Callback = function()
    pcall(function()
      Notify("Advertisement","UserId Copied",3)
    end)

    pcall(function()
      setclipboard(Client.UserId)
    end)
  end
})

local SectionServer = Tab:Section({
  Title = "Server Saver"
})

Tab:Input({
  Title = "Server Name",
  Placeholder = "Write a name...",
  Callback = function(Text)
    Config.ServerName = Text
    print(Text)
  end
})

local ServersDropdown = nil

Tab:Button({
  Title = "Save Server",
  Callback = function()
    if not isfile or not isfolder or not readfile or not writefile then
      pcall(function()
        Notify("Save Server: ","Your Executor Does Not Support This Function",2)
      end)
      return
    end

    SaveServer(Config.ServerName or "Unnamed Server")
    print("Server Saved")

    if ServersDropdown then
      ServersDropdown:Refresh(GetServersNames())
    end

  end
})

local ServersSavedSection = Tab:Section({
  Title = "Servers Saved"
})

ServersDropdown = Tab:Dropdown({
  Title = "Select Server",
  Values = GetServersNames(),
  Value = nil,
  Callback = function(Option)
    if Config.ServersList[Option] then
      Config.SelectedServerData = Config.ServersList[Option]


    else


    end
  end
})

Tab:Button({
  Title = "Join Selected Server",
  Callback = function()
    if Config.SelectedServerData then
      pcall(function()
        Notify("Joining To The Server")
      end)

      local Success, Error = pcall(function()
        if queue_on_teleport then
          queue_on_teleport([[task.wait(2) loadstring(game:HttpGet("https://raw.githubusercontent.com/NyxMods000/NyxModsUniversal/refs/heads/main/Loader.lua"))()]])
        end

        TeleportService:TeleportToPlaceInstance(
          Config.SelectedServerData.PlaceId,
          Config.SelectedServerData.JobId,
          Client
        )
      end)

      if not Success then
        pcall(function()
          Notify("Join Selected Server","Teleport Failed...",5)
        end)
      end
    else
      pcall(function()
        Notify("Join Selected Server","Please Select A Server",2)
      end)
    end

    print("Joining")
  end
})

Tab:Button({
  Title = "Delete Selected Server",
  Callback = function()
    if not isfile or not isfolder or not readfile or not writefile then
      pcall(function()
        Notify("Save Server: ","Your Executor Does Not Support This Function",2)
      end)
      return
    end

    if Config.SelectedServerData then
      pcall(function()
        Notify("Delete Selected Server","Deleting Server...",5)
      end)

      DeleteServer(Config.SelectedServerData)
    else
      pcall(function()
        Notify("Delete Selected Server","Please Select A Server",2)
      end)
    end

    print("Server Deleted")
  end
})

local Section2 = Tab:Section({
  Title = "Player"
})

Tab:Button({
  Title = "Respawn",
  Callback = function()
    pcall(function()
      Notify("Advertisement","Respawning...",3)
    end)
    Respawn(false)
  end
})

Tab:Button({
  Title = "Respawn in current Position",
  Callback = function()
    pcall(function()
      Notify("Advertisement","Respawning...",3)
    end)
    Respawn(true)
  end
})

Tab:Button({
  Title = "Sit",
  Callback = function()
    Sit()
  end
})

Tab:Button({
  Title = "Ragdoll",
  Callback = function()
    Ragdoll()
  end
})

local Section3 = Tab:Section({
  Title = "Information"
})

Tab:Toggle({
  Title = "Fps Viewer",
  Value = false,
  Callback = function(State)
    Config.FpsViewer = State
    FpsViewer()
  end
})

Tab:Toggle({
  Title = "Executor Viewer",
  Value = false,
  Callback = function(State)
    ExecutorViewer(State)
  end
})

local PlayersHistory = Tab:Paragraph({
  Title = "State",
  Content = "Waiting..."
})

local Time = 0

RunService.RenderStepped:Connect(function()
  Time = Time + 1
  Config.Fps = Config.Fps + 1

  if Time >= 200 then
    local Content = ""
    Time = 0

    for i,v in pairs(Config.PlayersHistory) do
      if Content == "" then
        Content = ""
      else
        Content = Content.."\n\n"
      end

      if not v then
        Content = Content.."• "..i..":".." It Left The Server."
      else
        Content = Content.."• "..i..":".."It On The Server."
      end
    end

    PlayersHistory:SetTitle("History: ")
    PlayersHistory:SetDesc(Content)
  end
end)

for i,v in ipairs(Players:GetPlayers()) do
  Config.PlayersHistory[v.Name] = true
end

Players.PlayerAdded:Connect(function(Player)
  Config.PlayersHistory[Player.Name] = true
end)

Players.PlayerRemoving:Connect(function(Player)
  Config.PlayersHistory[Player.Name] = false
end)

Workspace.DescendantAdded:Connect(function(Instance)
  if Config.MuteGame then
    if Instance:IsA("Sound") then
      local Found = false

      for i,v in ipairs(Config.PausedInstances) do
        if v == Instance then
          Found = true
          break
        end
      end

      if Instance.Playing then
        Instance:Pause()

        if not Found then
          table.insert(Config.PausedInstances,Instance)
          Found = true
        end
      end

      Instance:GetPropertyChangedSignal("Playing"):Connect(function()
        if Config.MuteGame then
          if Instance.Playing then
            Instance:Pause()

            if not Found then
              table.insert(Config.PausedInstances,Instance)
              Found = true
            end
          end
        end
      end)
    end
  end
end)

--//Arreglado