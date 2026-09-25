

local function Notify(Library,Title,Content,Duration)
   Library:Notify({
    Title = Title,
    Content = Content,
    Duration = Duration
})
end

local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/pruebasjoao/test/refs/heads/main/JmodsLibV1.0'))()


local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")


local Client = Players.LocalPlayer

local Script = {
 PlayersInfo = {},
 DroppedGun = nil,
}

local Esp = {
 EveryoneInLobby = false,
 
 Enabled = false,
 Murderer = false,
 Sheriff = false,
 Hero = false,
 Innocent = false,
 Dead = false,
 DroppedGun = false,
 
 Name = false,
 DisplayName = false,
 Role = false,
 
 Colors = {
  Innocent = Color3.fromRGB(0,255,0),
  Sheriff = Color3.fromRGB(0,0,255),
  Hero = Color3.fromRGB(255,255,0),
  Murderer = Color3.fromRGB(255,0,0),
  Dead = Color3.fromRGB(255,255,255),
  Lobby = Color3.fromRGB(0,0,0),
  DroppedGun = Color3.fromRGB(170,0,255),
 }
}

local Sheriff = {
 AutoShoot = false,
 AutoHackerShoot = false,
 Prediction = false,
 PredictionValue = 0,
 
 AutoGetDroppedGun = false,
 DroppedGunNotify = false,
 
 ShootKeybind = "",
 HackerShootKeybind = "",
 GetDroppedGunKeybind = "",
}

local Murderer = {
 AutoThrownKnife = false,
 AutoHackerThrownKnife = false,
 
 KillAura = false,
 KillAuraRange = 20,
 
 Hitbox = false,
 HitboxSize = 10,
 Transparency = 0.8,
 OldHitboxes = {},
 
 ThrownKnifeKeybind = "",
 HackerThrownKnifeKeybind = "",
 HitboxKeybind = "",
}

local Autofarm = {
 Enabled = false,
 AutoRejoin = false,
 AutoFinishRound = false,
 Mode = "Normal", --//Normal or Underground
}

local Target = {
 CurrentTarget = nil,
 Spectating = false,
}

Autofarm.AutoRejoin = getgenv().AutoRejoin or false
Autofarm.AutoFinishRound = getgenv().AutoFinishRound or false
Autofarm.Mode = getgenv().AutofarmMode or "Normal"

if getgenv().AutofarmEnabled then
    Autofarm.Enabled = true
end

local function GetPlayersData()
 local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
 if Remotes then
  local Gameplay = Remotes:FindFirstChild("Gameplay")
  if Gameplay then
   local GetCurrentPlayerData = Gameplay:FindFirstChild("GetCurrentPlayerData")
   if GetCurrentPlayerData then
    local Data = GetCurrentPlayerData:InvokeServer()
    
    local DataTable = {}
    
    for Name,PlayerData in pairs(Data) do
     local Player = Players:FindFirstChild(Name)
     if Player then
      
      if not DataTable[Player] then
       DataTable[Player] = PlayerData
      end
      
     end
    end
    
    return DataTable
    
   end
  end
 end
 return nil
end

local function GetPlayerByPartialName(Name)
 for i,Player in ipairs(Players:GetPlayers()) do
  if Player.Name:lower():find(Name:lower()) or Player.DisplayName:lower():find(Name:lower()) then
   return Player
  end
 end
 return nil
end

local function GetRootPart(Player)
 local Character = Player.Character
 if Character then
  local RootPart = Character:FindFirstChild("HumanoidRootPart")
  if RootPart then
   return RootPart
  end
 end
 return nil
end

local function GetHumanoid(Player)
 local Character = Player.Character
 if Character then
  local Humanoid = Character:FindFirstChild("Humanoid")
  if Humanoid then
   return Humanoid
  end
 end
 return nil
end

local function GetClosestPlayer()
 local MaxDistance = math.huge
 local ClosestPlayer = nil
 for i,Player in ipairs(Players:GetPlayers()) do
  if Player ~= Client then
   local PlayerRootPart = GetRootPart(Player)
   local RootPart = GetRootPart(Client)
   if PlayerRootPart and RootPart then
    local Distance = (RootPart.Position - PlayerRootPart.Position).Magnitude
    if Distance < MaxDistance then
     MaxDistance = Distance
     ClosestPlayer = Player
    end
   end
  end
 end
 return ClosestPlayer
end

local function ManagePlayersInfo(InfoTable)
 for PlayerName,Info in pairs(InfoTable) do
  local Player = Players:FindFirstChild(PlayerName)
  if Player then
   Script.PlayersInfo[Player] = {}
   Script.PlayersInfo[Player] = Info
  end
 end
end

local function UpdateEsp(Player)
	if not Player then
		return
	end

	local Character = Player.Character
	if not Character then
		return
	end

	--// ESP Highlight
	local EspObject = Character:FindFirstChild("Esp")

	if not EspObject then
		EspObject = Instance.new("Highlight")
		EspObject.Name = "Esp"
		EspObject.FillColor = Color3.new(0, 0, 0)
		EspObject.FillTransparency = 1
		EspObject.OutlineColor = Color3.new(0, 0, 0)
		EspObject.OutlineTransparency = 0
		EspObject.Enabled = false
		EspObject.Parent = Character
	end

	--// Player Info
	local PlayerInfo = Script.PlayersInfo[Player]

	local Role
	local Dead = false

	if PlayerInfo then
		Role = PlayerInfo.Role
		Dead = PlayerInfo.Dead
	end

	--// Role Color
	local RoleColor

	if Esp.EveryoneInLobby then
		RoleColor = Esp.Colors.Lobby
	elseif Dead then
		RoleColor = Esp.Colors.Dead
	elseif Role then
		RoleColor = Esp.Colors[Role]
	end

	--// Highlight color
	if RoleColor then
		EspObject.OutlineColor = RoleColor
	end

	--// Highlight enabled
	local ShouldEnable = false

	if Esp.Enabled then
		if Dead then
			ShouldEnable = Esp.Dead
		elseif Role then
			ShouldEnable = Esp[Role] == true
		end
	end

	EspObject.Enabled = ShouldEnable

	--// Name ESP
	local Head = Character:FindFirstChild("Head")
	if not Head then
		return
	end

	local BillboardGui = Head:FindFirstChild("BillboardGui")

	if not BillboardGui then
		BillboardGui = Instance.new("BillboardGui")
		BillboardGui.Name = "BillboardGui"
		BillboardGui.AlwaysOnTop = true
		BillboardGui.Size = UDim2.fromOffset(150, 50)
		BillboardGui.StudsOffset = Vector3.new(0, 3, 0)
		BillboardGui.Parent = Head
	end

	local Text = BillboardGui:FindFirstChild("TextLabel")

	if not Text then
		Text = Instance.new("TextLabel")
		Text.Name = "TextLabel"
		Text.BackgroundTransparency = 1
		Text.Size = UDim2.fromScale(1, 1)
		Text.Font = Enum.Font.GothamBold
		Text.TextSize = 14
		Text.TextStrokeTransparency = 0
		Text.TextStrokeColor3 = Color3.new(0, 0, 0)
		Text.Parent = BillboardGui
	end

	--// Text
	local Content = {}
	local Offset = 1

	-- Name NO depende de PlayerInfo
	if Esp.Name then
		table.insert(Content, "Name: " .. Player.Name)
		Offset += 1
	end

	-- DisplayName NO depende de PlayerInfo
	if Esp.DisplayName then
		table.insert(Content, "DisplayName: " .. Player.DisplayName)
		Offset += 1
	end

	-- Role SÍ depende de PlayerInfo
	if Esp.Role and Role then
		table.insert(Content, "Role: " .. Role)
		Offset += 1
	end

	Text.Text = table.concat(Content, "\n")
	Text.TextColor3 = RoleColor or Color3.new(1, 1, 1)

	BillboardGui.StudsOffset = Vector3.new(0, Offset, 0)

	local TextActive =
		(Esp.Name
		or Esp.DisplayName
		or Esp.Role) and Esp.Enabled

	Text.Visible = TextActive == true
end

local function UpdateAllPlayersEsp()
 for i,Player in ipairs(Players:GetPlayers()) do
  UpdateEsp(Player)
 end
end

local function FindKnife(Player)
 local Character = Player.Character
  local Backpack = Player:FindFirstChild("Backpack")
  if Character and Backpack then
   local Knife = Character:FindFirstChild("Knife") or Backpack:FindFirstChild("Knife")
   if Knife then
    return Knife
   end
  end
  return nil
end

local function FindGun(Player)
 local Character = Player.Character
  local Backpack = Player:FindFirstChild("Backpack")
  if Character and Backpack then
   local Gun = Character:FindFirstChild("Gun") or Backpack:FindFirstChild("Gun")
   if Gun then
    return Gun
   end
  end
  return nil
end

local function FindDroppedGun()
 for i,Instance in ipairs(Workspace:GetDescendants()) do
  if Instance:IsA("BasePart") then
   if Instance.Name:lower():find("gun") and Instance.Name:lower():find("drop") then
    return Instance
   end
  end
 end
 return nil
end

local function GetMurderer()
 --//Busca al jugador que tenga el Knife
 for i,Player in ipairs(Players:GetPlayers()) do
  if FindKnife(Player) then
   return Player
  end
 end
 
 --//Busca al jugador con el rol murderer si no encontro a alguien con knife
 local PlayersInfo = Script.PlayersInfo
 if PlayersInfo ~= nil then
  for Player,Info in pairs(PlayersInfo) do
   local Role = Info["Role"]
   if Role == "Murderer" then
    if Player then
     return Player
    end
   end
  end
 end
 
 --//Retorna nil si no encontro al murderer
 return nil
end

local function GetSheriff()
  --//Busca al jugador que tenga uns gun
 for i,Player in ipairs(Players:GetPlayers()) do
  if FindGun(Player) then
   return Player
  end
 end
 
 local PlayersInfo = Script.PlayersInfo
 if PlayersInfo ~= nil then
  for Player,Info in pairs(PlayersInfo) do
   local Role = Info["Role"]
   if Role == "Hero" then
    if Player then
     return Player
    end
   end
  end
 end
 
 --//Busca al jugador con el rol sheriff si no encontro a alguien con una gun o hero
 local PlayersInfo = Script.PlayersInfo
 if PlayersInfo ~= nil then
  for Player,Info in pairs(PlayersInfo) do
   local Role = Info["Role"]
   if Role == "Sheriff" then
    if Player then
     return Player
    end
   end
  end
 end
 
 --//Retorna nil si no encontro al sheriff
 return nil
end

local function Shoot(Origen,Destination)
 local Gun = FindGun(Client)
 if Gun then
  local Shoot = Gun:FindFirstChild("Shoot")
  if Shoot then
   Shoot:FireServer(Origen,Destination)
  end
 end
end

local function ShootMurderer(Hacker)
 local Murderer = GetMurderer()
  if Murderer then
   local Gun = FindGun(Client)
   if Gun then
    local Character = Client.Character
    local RootPart = GetRootPart(Client)
    local MurdererRootPart = GetRootPart(Murderer)
    if Character and RootPart and MurdererRootPart then
     
     local BulletSpeed = 200
     local Distance = (RootPart.Position - MurdererRootPart.Position).Magnitude
     
     local TravelTime = Distance / BulletSpeed
     local PredictionTime = TravelTime * Sheriff.PredictionValue
     
     local PredictionCFrame = MurdererRootPart.CFrame + MurdererRootPart.AssemblyLinearVelocity * PredictionTime
     local MurdererCFrame = MurdererRootPart.CFrame
     
     --//Equipar la gun y disparar
     Gun.Parent = Character
     if Hacker then
      if Sheriff.Prediction then
      Shoot(MurdererRootPart.CFrame * CFrame.new(0,0,1.5),PredictionCFrame)
      else
       Shoot(MurdererRootPart.CFrame * CFrame.new(0,0,1.5),MurdererCFrame)
      end
     else
      if Sheriff.Prediction then
      Shoot(RootPart.CFrame,PredictionCFrame)
      else
       Shoot(RootPart.CFrame,MurdererCFrame)
      end
     end
     
    end
   end
  end
end

local function AutoShoot()
 local Connection
 Connection = RunService.Heartbeat:Connect(function()
  --//Se autodesactiva si autoshoot es false
  if not Sheriff.AutoShoot then
   Connection:Disconnect()
   Connection = nil
  end
  
  --//Busca al murderer, Verifica que el cliente tenga la gun, Verifica que tenga equipada la gun, Dispara
  local Murderer = GetMurderer()
  if Murderer then
   local Gun = FindGun(Client)
   if Gun then
    local Character = Client.Character
    if Character then
     
     --//Disparar solo si tiene la gun equipada
     if Gun.Parent == Character then
      ShootMurderer(false)
     end
     
    end
   end
  end
 end)
end

local function AutoHackerShoot()
 local Connection
 Connection = RunService.Heartbeat:Connect(function()
  --//Se autodesactiva si autoshoot es false
  if not Sheriff.AutoHackerShoot then
   Connection:Disconnect()
   Connection = nil
  end
  
  --//Busca al murderer, Verifica que el cliente tenga la gun, Verifica que tenga equipada la gun, Dispara
  local Murderer = GetMurderer()
  if Murderer then
   local Gun = FindGun(Client)
   if Gun then
    local Character = Client.Character
    if Character then
     
     --//Disparar solo si tiene la gun equipada
     if Gun.Parent == Character then
      ShootMurderer(true)
     end
     
    end
   end
  end
 end)
end

local function TpShootMurderer()
 local Murderer = GetMurderer()
 if Murderer then
  local Gun = FindGun(Client)
  local Character = Client.Character
  if Gun and Character then
   local MurdererRootPart = GetRootPart(Murderer)
   local RootPart = GetRootPart(Client)
   if MurdererRootPart and RootPart then
    Gun.Parent = Character
    local OldCFrame = RootPart.CFrame
    RootPart.CFrame = MurdererRootPart.CFrame * CFrame.new(0,0,3)
    ShootMurderer(true)
    task.wait(0.05)
    RootPart.CFrame = OldCFrame
   end
  end
 end
end

local function GetDroppedGun()
 local DroppedGun = FindDroppedGun()
 local RootPart = GetRootPart(Client)
 if DroppedGun and RootPart then
  local TouchInterest = DroppedGun:FindFirstChildOfClass("TouchInterest")
  
  if TouchInterest and firetouchinterest then
   firetouchinterest(RootPart,DroppedGun,0)
   task.wait(0.05)
   firetouchinterest(RootPart,DroppedGun,1)
  else
   local OldCFrame = RootPart.CFrame
   
   RootPart.CFrame = DroppedGun.CFrame
   task.wait(0.05)
   RootPart.CFrame = OldCFrame
  end
  
 end
end

local function KnifeThrown(Origen,Destination)
 local Knife = FindKnife(Client)
 if Knife then
  local Events = Knife:FindFirstChild("Events")
  if Events then
   local KnifeThrown = Events:FindFirstChild("KnifeThrown")
   if KnifeThrown then
    KnifeThrown:FireServer(Origen,Destination)
   end
  end
 end
end

local function ThrownKnife(Hacker)
 local ClosestPlayer = GetClosestPlayer()
 if ClosestPlayer then
  local Knife = FindKnife(Client)
  if Knife then
   local Character = Client.Character
   local RootPart = GetRootPart(Client)
   local ClosestRootPart = GetRootPart(ClosestPlayer)
   if Character and RootPart and ClosestRootPart then
    
    Knife.Parent = Character
    if Hacker then
     KnifeThrown(ClosestRootPart.CFrame * CFrame.new(0,0,1.5),ClosestRootPart.CFrame)
    else
     KnifeThrown(RootPart.CFrame,ClosestRootPart.CFrame)
    end
    
   end
  end
 end
end

local function AutoThrownKnife()
 local Connection
 Connection = RunService.Heartbeat:Connect(function()
  --//Se autodesactiva si autoshoot es false
  if not Murderer.AutoThrownKnife then
   Connection:Disconnect()
   Connection = nil
  end
  
  --//Busca al murderer, Verifica que el cliente tenga la gun, Verifica que tenga equipada la gun, Dispara
  local ClosestPlayer = GetClosestPlayer()
  if ClosestPlayer then
   local Knife = FindKnife(Client)
   if Knife then
    local Character = Client.Character
    if Character then
     
     --//Disparar solo si tiene la gun equipada
     if Knife.Parent == Character then
      ThrownKnife(false)
     end
     
    end
   end
  end
 end)
end

local function AutoHackerThrownKnife()
 local Connection
 Connection = RunService.Heartbeat:Connect(function()
  --//Se autodesactiva si autoshoot es false
  if not Murderer.AutoHackerThrownKnife then
   Connection:Disconnect()
   Connection = nil
  end
  
  --//Busca al murderer, Verifica que el cliente tenga la gun, Verifica que tenga equipada la gun, Dispara
  local ClosestPlayer = GetClosestPlayer()
  if ClosestPlayer then
   local Knife = FindKnife(Client)
   if Knife then
    local Character = Client.Character
    if Character then
     
     --//Disparar solo si tiene la gun equipada
     if Knife.Parent == Character then
      ThrownKnife(true)
     end
     
    end
   end
  end
 end)
end

local function KillEveryone()
 local RootPart = GetRootPart(Client)
 local Knife = FindKnife(Client)
 if RootPart and Knife then
  for i,Player in ipairs(Players:GetPlayers()) do
   if Player == Client then continue end
   local PlayerRootPart = GetRootPart(Player)
   if PlayerRootPart then
    
    task.spawn(function()
    for i = 1,50,1 do
     if RootPart and PlayerRootPart and Knife then
      Knife.Parent = RootPart.Parent
      PlayerRootPart.CFrame = RootPart.CFrame * CFrame.new(0,0,-2)
     else
      break
     end
     task.wait(0.01)
    end
    end)
    
   end
  end
 end
end

local function BringSheriff()
 local Sheriff = GetSheriff()
 if Sheriff then
  local RootPart = GetRootPart(Client)
  local SheriffRootPart = GetRootPart(Sheriff)
  if RootPart and SheriffRootPart then
   
   for i = 1,500,1 do
    if RootPart and SheriffRootPart then
     SheriffRootPart.CFrame = RootPart.CFrame * CFrame.new(0,0,-2)
    else
     break
    end
    task.wait(0.01)
   end
   
  end
 end
end

local function KillAura()
 local Connection
 Connection = RunService.Heartbeat:Connect(function()
  if not Murderer.KillAura then
   Connection:Disconnect()
   Connection = nil
  end
  
  local Knife = FindKnife(Client)
  if not Knife then
   return
  end
  
  local Events = Knife:FindFirstChild("Events")
  if not Events then
   return
  end
  
  local HandleTouched = Events:FindFirstChild("HandleTouched")
  if not HandleTouched then
   return
  end
  
  local PlayersInRange = {}
  for i,Player in ipairs(Players:GetPlayers()) do
   local RootPart = GetRootPart(Client)
   local PlayerRootPart = GetRootPart(Player)
   if RootPart and PlayerRootPart then
    local Distance = (RootPart.Position - PlayerRootPart.Position).Magnitude
    if Distance <= Murderer.KillAuraRange then
     PlayersInRange[Player] = PlayerRootPart
    end
   end
  end
  
  for Player,PlayerRootPart in pairs(PlayersInRange) do
   if not PlayerRootPart then
    continue
   end
   HandleTouched:FireServer(PlayerRootPart)
  end
  
 end)
end

local function Hitbox()
 local Connection
 Connection = RunService.Heartbeat:Connect(function()
  
  for i,Player in ipairs(Players:GetPlayers()) do
   if Player == Client then continue end
   local Character = Player.Character
   if Character then
    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
    if HumanoidRootPart then
     
     if Murderer.Hitbox then
      
      if Murderer.OldHitboxes[Player] == nil then
       Murderer.OldHitboxes[Player] = HumanoidRootPart.Size
      end
      
      HumanoidRootPart.Size = Vector3.new(1,1,1) * Murderer.HitboxSize
      HumanoidRootPart.Transparency = Murderer.Transparency
      HumanoidRootPart.CanCollide = false
      
     else
      
      if Murderer.OldHitboxes[Player] ~= nil then
       HumanoidRootPart.Size = Murderer.OldHitboxes[Player]
      end
      
      HumanoidRootPart.Transparency = 1
      HumanoidRootPart.CanCollide = true
      
     end
     
    end
   end
  end
  
  if not Murderer.Hitbox then
   Connection:Disconnect()
   Connection = nil
   return
  end
  
 end)
end

local function DroppedGunEsp()
 local DroppedGun = FindDroppedGun()
 if DroppedGun then
  local EspObject = DroppedGun:FindFirstChild("Esp")
  if not EspObject then
   EspObject = Instance.new("Highlight")
   EspObject.FillColor = Esp.Colors.DroppedGun
   EspObject.FillTransparency = 0.5
   EspObject.OutlineColor = Esp.Colors.DroppedGun
   EspObject.Name = "Esp"
   EspObject.Parent = DroppedGun
  end
  
  EspObject.FillColor = Esp.Colors.DroppedGun
  EspObject.FillTransparency = 0.5
  EspObject.OutlineColor = Esp.Colors.DroppedGun
  
  if Esp.DroppedGun then
   EspObject.Enabled = true
  else
   EspObject.Enabled = false
  end
  
  local BillboardGui = DroppedGun:FindFirstChild("BillboardGui")
      if not BillboardGui then
       BillboardGui = Instance.new("BillboardGui")
       BillboardGui.AlwaysOnTop = true
       BillboardGui.Size = UDim2.fromOffset(100,50)
       BillboardGui.StudsOffset = Vector3.new(0,3,0)
       BillboardGui.Parent = DroppedGun
      end
      local Text = BillboardGui:FindFirstChild("TextLabel")
      if not Text then
       Text = Instance.new("TextLabel")
       Text.BackgroundTransparency = 1
       Text.Size = UDim2.fromScale(1,1)
       Text.Text = ""
       Text.Font = Enum.Font.GothamBold
       Text.TextSize = 14
       Text.TextStrokeTransparency = 0
       Text.TextStrokeColor3 = Color3.new(0, 0, 0)
       Text.Parent = BillboardGui
      end
      
      Text.Text = "GUN"
      Text.TextColor3 = Esp.Colors.DroppedGun
      BillboardGui.StudsOffset = Vector3.new(0,1,0)
      
      if Esp.DroppedGun then
       Text.Visible = true
      else
       Text.Visible = false
      end
      
      
  
 end
end



local function Fling(Player)
 Workspace.FallenPartsDestroyHeight = -9e9
 
 local Character = Client.Character
 local PlayerCharacter = Player.Character
 
 local RootPart = GetRootPart(Client)
 local PlayerRootPart = GetRootPart(Player)
 local PlayerHumanoid = GetHumanoid(Player)
 local Humanoid = GetHumanoid(Client)
 local Camera = Workspace.CurrentCamera
 if PlayerRootPart and RootPart and PlayerHumanoid and Camera and Humanoid then
  local FlingEnd = false
  
  local OldCFrame = RootPart.CFrame
  local Time = 0
  
  local Angle = 0
  
  local function StopFling(Connection)
   Connection:Disconnect()
    
    Humanoid = GetHumanoid(Client)
    Camera = Workspace.CurrentCamera
    if Humanoid and Camera then
     Camera.CameraSubject = Humanoid
    end
    
    if RootPart then
     RootPart.Velocity = Vector3.zero
     RootPart.RotVelocity = Vector3.zero
     RootPart.AssemblyAngularVelocity = Vector3.zero
     RootPart.AssemblyLinearVelocity = Vector3.zero
     RootPart.CFrame = OldCFrame
    end
    FlingEnd = true
  end
  
  local Connection
  Connection = RunService.Heartbeat:Connect(function(dt)
   Time = Time + dt
   
   if Character ~= Client.Character then
    RootPart = GetRootPart(Client)
    Humanoid = GetHumanoid(Client)
    Camera = Workspace.CurrentCamera
    
    if Humanoid and Camera then
     Camera.CameraSubject = Humanoid
    end
   end
   
   if not Player or Player and not Player.Parent then
    
    StopFling(Connection)
    return
   end
   
   if PlayerCharacter ~= Player.Character then
    StopFling(Connection)
    return
   end
   
   if not PlayerRootPart then
    StopFling(Connection)
    return
   end
   
   if not RootPart then
    RootPart = GetRootPart(Client)
    return
   end
   
   if not PlayerHumanoid then
    StopFling(Connection)
    return
   end
   
   if not Camera then
    Camera = Workspace.CurrentCamera
    return
   end
   
   if not Humanoid then
    Humanoid = GetHumanoid(Client)
    return
   end
   
   if PlayerRootPart.Velocity.Magnitude > 500 or Time >= 8 then
    StopFling(Connection)
    return
   end
   
   local SomePart = PlayerCharacter and PlayerCharacter:FindFirstChildWhichIsA("BasePart")
   
   if not SomePart then
    StopFling(Connection)
    return
   end
   
   local MoveDirection = PlayerRootPart.CFrame:VectorToObjectSpace(PlayerHumanoid.MoveDirection)
   
   Angle = Angle + 60 * dt
   
   local AssemblyLinearVelocity = PlayerRootPart.CFrame:VectorToObjectSpace(PlayerRootPart.AssemblyLinearVelocity)
   
   local X = math.sin(Angle) * AssemblyLinearVelocity.X * 0.9
   local Z = math.cos(Angle) * AssemblyLinearVelocity.Z * 0.9
   
   local Offset = Vector3.new(X,0,Z)
   
   RootPart.AssemblyLinearVelocity = Vector3.new(0,-10000,0)
   RootPart.AssemblyAngularVelocity = Vector3.new(0,10000,0)
   RootPart.Velocity = Vector3.new(0,-10000,0)
   
   RootPart.CFrame = CFrame.new(PlayerRootPart.CFrame.Position) * CFrame.new(Offset) * CFrame.Angles(math.rad(math.random(0,360)),math.rad(math.random(0,360)),math.rad(math.random(0,360)))
   
   if Camera and PlayerHumanoid then
    Camera.CameraSubject = PlayerHumanoid
   end
   
  end)
  repeat task.wait() until FlingEnd or Time >= 8
 end
 Workspace.FallenPartsDestroyHeight = -500
end


local cachedCoinContainer = nil

local function GetCoinContainer()
	if cachedCoinContainer and cachedCoinContainer.Parent then
		return cachedCoinContainer
	end

	for _, Instance in Workspace:GetDescendants() do
		local name = Instance.Name:lower()
		if name:find("coin") and name:find("container") then
			cachedCoinContainer = Instance
			return Instance
		end
	end

	return nil
end

local function GetClosestCoins()
	local CoinContainer = GetCoinContainer()
	local RootPart = GetRootPart(Client)

	if not CoinContainer or not RootPart then
		return
	end

	local ClosestCoins = {}
	local rootPos = RootPart.Position

	for _, Coin in CoinContainer:GetChildren() do
		if Coin:IsA("BasePart") then
			table.insert(ClosestCoins, Coin)
		end
	end

	table.sort(ClosestCoins, function(A, B)
		return (A.Position - rootPos).Magnitude < (B.Position - rootPos).Magnitude
	end)

	return table.unpack(ClosestCoins)
end

local function CreateTween(Part, CFrameA, CFrameB, MaxTime)
	local Distance = (CFrameA.Position - CFrameB.Position).Magnitude
	local TweenTime = Distance * 0.12

	local Info = TweenInfo.new(
		TweenTime,
		Enum.EasingStyle.Quad,
		Enum.EasingDirection.Out
	)

	local Tween = TweenService:Create(Part, Info, {
		CFrame = CFrameB
	})

	return Tween, TweenTime
end

local function GetCurrentCoins(Player)
	local PlayersInfo = Script.PlayersInfo
	if PlayersInfo then
		local PlayerInfo = PlayersInfo[Player]
		if PlayerInfo then
			local Coins = PlayerInfo["Coins"]
			if Coins then
				return Coins
			end
		end
	end
	return nil
end

local function InitAutofarm()
	local CurrentTween = false
	local FlingInProgress = false
	local Connection

	local InitialCFrame = nil
	local LastCoinsFolder = nil

	local WorkerRunning = false
	local AutoFinishRunning = false

	local NormalGravity = 192.6
	local ZeroGravity = 0

	local OriginalCoinCFrames = {}

	local function GetCoinsFolder()
		return Workspace:FindFirstChild("Coins")
	end

	local function StopTween()
		CurrentTween = false
		Workspace.Gravity = NormalGravity
	end

	local function RestoreInitialPosition()
		if not InitialCFrame then
			return
		end

		local RootPart = GetRootPart(Client)
		if RootPart and RootPart.Parent then
			RootPart.CFrame = InitialCFrame
		end

		InitialCFrame = nil
	end

	local function ResetCoinPositions()
		OriginalCoinCFrames = {}
	end

	local function GetOriginalCoinCFrame(Coin)
		if not Coin then
			return nil
		end

		if not OriginalCoinCFrames[Coin] then
			OriginalCoinCFrames[Coin] = Coin.CFrame
		end

		return OriginalCoinCFrames[Coin]
	end

	local function MoveCoinUnderground(Coin)
		if not Coin or not Coin.Parent then
			return
		end

		local OriginalCFrame = GetOriginalCoinCFrame(Coin)
		if not OriginalCFrame then
			return
		end

		local TargetCFrame = OriginalCFrame * CFrame.new(0, -5, 0)
		Coin.CFrame = TargetCFrame

		local CoinVisual = Coin:FindFirstChild("CoinVisual")
		if CoinVisual then
			CoinVisual.CFrame = TargetCFrame
		end
	end

	local function IsCoinValid(Coin)
		if not Coin or not Coin.Parent then
			return false
		end

		local CoinVisual = Coin:FindFirstChild("CoinVisual")
		local MainCoin = CoinVisual and CoinVisual:FindFirstChild("MainCoin")

		return MainCoin and MainCoin.Transparency <= 0
	end

	local function GetValidClosestCoin()
		local Coins = {GetClosestCoins()}
		if #Coins < 1 then
			return nil
		end

		for i = 1, #Coins do
			local Candidate = Coins[i]
			if IsCoinValid(Candidate) then
				return Candidate
			end
		end

		return nil
	end

	local function RunAutoFinish()
		if AutoFinishRunning then
			return
		end

		if not Autofarm.Enabled then
			return
		end

		if not Autofarm.AutoFinishRound then
			return
		end

		if Esp.EveryoneInLobby then
			return
		end

		if not Script.PlayersInfo[Client] then
			return
		end
		
		local CurrentCoins = GetCurrentCoins(Client)
		local PlayerInfo = Script.PlayersInfo[Client]
		local Dead = PlayerInfo and PlayerInfo["Dead"]
		local Killed = PlayerInfo and PlayerInfo["Killed"]
		
		if (not CurrentCoins or CurrentCoins < 40) and (not Dead and not Killed) then
		 return
		end

		AutoFinishRunning = true

		task.spawn(function()

			for i = 1, 5 do
				if not Autofarm.Enabled or Esp.EveryoneInLobby then
					break
				end
				RunService.Heartbeat:Wait()
			end

			if not Autofarm.Enabled or Esp.EveryoneInLobby then
				AutoFinishRunning = false
				return
			end

			local Gun = FindGun(Client)
			local Knife = FindKnife(Client)

			if Knife then
				KillEveryone()
			elseif Gun then
				TpShootMurderer()
			elseif not Gun and not Knife then
				if not FlingInProgress then
					FlingInProgress = true

					local Murderer = GetMurderer()
					if Murderer then
						Fling(Murderer)
					end

					FlingInProgress = false
				end
			end

			AutoFinishRunning = false
		end)
	end

	local function StartWorker()
		if WorkerRunning then
			return
		end

		WorkerRunning = true

		task.spawn(function()
			while Autofarm.Enabled do
				local PlayerInfo = Script.PlayersInfo[Client]
				local Dead = PlayerInfo and PlayerInfo["Dead"]
				local Killed = PlayerInfo and PlayerInfo["Killed"]

				if Dead or Killed then
					StopTween()
					break
				end

				local RootPart = GetRootPart(Client)
				if not RootPart then
					Workspace.Gravity = NormalGravity
					task.wait(0.1)
					continue
				end

				local Coin = GetValidClosestCoin()
				if not Coin then
					Workspace.Gravity = NormalGravity
					task.wait(0.1)
					continue
				end

				PlayerInfo = Script.PlayersInfo[Client]
				Dead = PlayerInfo and PlayerInfo["Dead"]
				Killed = PlayerInfo and PlayerInfo["Killed"]

				if Dead or Killed then
					StopTween()
					break
				end

				if not InitialCFrame then
					InitialCFrame = RootPart.CFrame
				end

				if Autofarm.Mode == "Underground" then
					MoveCoinUnderground(Coin)
				end

				local StartCFrame = CFrame.new(RootPart.CFrame.Position) * CFrame.Angles(math.rad(90),0,0)
				local TargetCFrame = Coin.CFrame * CFrame.Angles(math.rad(90), 0, 0)
				local Distance = (RootPart.Position - Coin.Position).Magnitude
				local Duration = math.max(Distance * 0.05, 0.01)

				CurrentTween = true
				Workspace.Gravity = ZeroGravity

				local StartTime = tick()

				while CurrentTween and Autofarm.Enabled do
					PlayerInfo = Script.PlayersInfo[Client]
					Dead = PlayerInfo and PlayerInfo["Dead"]
					Killed = PlayerInfo and PlayerInfo["Killed"]

					if Dead or Killed then
						StopTween()
						break
					end

					if not IsCoinValid(Coin) then
						StopTween()
						break
					end

					RootPart = GetRootPart(Client)
					if not RootPart then
						StopTween()
						break
					end

					local Alpha = math.clamp((tick() - StartTime) / Duration, 0, 1)
					RootPart.CFrame = StartCFrame:Lerp(TargetCFrame, Alpha)
					
					RootPart.AssemblyLinearVelocity = Vector3.zero
					RootPart.AssemblyAngularVelocity = Vector3.zero
					RootPart.RotVelocity = Vector3.zero
					RootPart.Velocity = Vector3.zero

					if Alpha >= 1 then
						StopTween()
						break
					end

					RunService.Heartbeat:Wait()
				end

				CurrentTween = false
				Workspace.Gravity = NormalGravity

				PlayerInfo = Script.PlayersInfo[Client]
				Dead = PlayerInfo and PlayerInfo["Dead"]
				Killed = PlayerInfo and PlayerInfo["Killed"]

				if Dead or Killed or not Autofarm.Enabled then
					break
				end

				RunService.Heartbeat:Wait()
			end

			CurrentTween = false
			WorkerRunning = false
			Workspace.Gravity = NormalGravity
		end)
	end

	Connection = RunService.Heartbeat:Connect(function()
		local CoinsFolder = GetCoinsFolder()

		if CoinsFolder ~= LastCoinsFolder then
			if not CoinsFolder then
				InitialCFrame = nil
			end
			ResetCoinPositions()
			LastCoinsFolder = CoinsFolder
		end

		if Autofarm.AutoFinishRound and not Esp.EveryoneInLobby and Script.PlayersInfo[Client] then
			RunAutoFinish()
		end

		if not Autofarm.Enabled then
			StopTween()
			if InitialCFrame then
				RestoreInitialPosition()
			end
			Workspace.Gravity = NormalGravity
			if Connection then
				Connection:Disconnect()
				Connection = nil
			end
			return
		end

		if CurrentTween then
			return
		end

		Workspace.Gravity = NormalGravity

		local CurrentCoins = GetCurrentCoins(Client)
		local PlayerInfo = Script.PlayersInfo[Client]
		local Dead = PlayerInfo and PlayerInfo["Dead"]
		local Killed = PlayerInfo and PlayerInfo["Killed"]

		if Dead or Killed or Esp.EveryoneInLobby then
			Workspace.Gravity = NormalGravity
			return
		end

		if not CurrentCoins or CurrentCoins >= 40 then
			Workspace.Gravity = NormalGravity
			return
		end

		StartWorker()
	end)
end

local function Spectate(Player, State)
	if not Player then
		return
	end

	local Camera = Workspace.CurrentCamera

	if not Camera then
		return
	end

	local Humanoid = GetHumanoid(Client)

	if not State then
		if Humanoid then
			Camera.CameraSubject = Humanoid
		end
		return
	end

	local PlayerHumanoid = GetHumanoid(Player)

	if not PlayerHumanoid then
		return
	end

	Camera.CameraSubject = PlayerHumanoid

	task.spawn(function()
		while Target.CurrentTarget == Player
			and Target.Spectating
		do
			Camera = Workspace.CurrentCamera
			PlayerHumanoid = GetHumanoid(Player)

			if not Camera or not PlayerHumanoid then
				task.wait()
				continue
			end

			if Camera.CameraSubject ~= PlayerHumanoid then
				Camera.CameraSubject = PlayerHumanoid
			end

			task.wait()
		end
	end)
end

local function FlingMurderer()
 local Murderer = GetMurderer()
 if Murderer then
  Fling(Murderer)
 end
end

local function FlingSheriff()
 local Sheriff = GetSheriff()
 if Sheriff then
  Fling(Sheriff)
 end
end

local function FlingAll()
 for i,Player in ipairs(Players:GetPlayers()) do
  if Player == Client then continue end
  Fling(Player)
  task.wait(0.05)
 end
end

local function TeleportToPlayer(Player)
 if not Player then return end
 
 local PlayerRootPart = GetRootPart(Player)
 local RootPart = GetRootPart(Client)
 if PlayerRootPart and RootPart then
  RootPart.CFrame = PlayerRootPart.CFrame * CFrame.new(0,1,0)
 end
end

--//Library

local Window = Library:CreateWindow({
  Name = "MM2 | NyxMods",
  Icon = 86507528059862,
  LoadingTitle = "Cargando... espera...",
  LoadingSubtitle = "ya casi está",
  Theme = "neon_indigo",
  OpenButtomImage = 86507528059862,
  Intro = false,
  IntroIcon = 86507528059862,
  AnimationIntro = 3,
  DragImage = 86507528059862
})

local EspTab = Window:CreateTab("Esp")
local EspTogglesSection = EspTab:CreateSection("Chams")

EspTab:CreateToggle({
    Name = "Enable Esp",
    CurrentValue = false,
    Callback = function(State)
     Esp.Enabled = State
     UpdateAllPlayersEsp()
    end
})

EspTab:CreateToggle({
    Name = "Innocent Esp",
    CurrentValue = false,
    Callback = function(State)
     Esp.Innocent = State
     UpdateAllPlayersEsp()
    end
})

EspTab:CreateToggle({
    Name = "Sheriff Esp",
    CurrentValue = false,
    Callback = function(State)
     Esp.Sheriff = State
     UpdateAllPlayersEsp()
    end
})

EspTab:CreateToggle({
    Name = "Hero Esp",
    CurrentValue = false,
    Callback = function(State)
     Esp.Hero = State
     UpdateAllPlayersEsp()
    end
})

EspTab:CreateToggle({
    Name = "Murderer Esp",
    CurrentValue = false,
    Callback = function(State)
     Esp.Murderer = State
     UpdateAllPlayersEsp()
    end
})

EspTab:CreateToggle({
    Name = "Dead Players Esp",
    CurrentValue = false,
    Callback = function(State)
     Esp.Dead = State
     UpdateAllPlayersEsp()
    end
})

EspTab:CreateToggle({
    Name = "Dropped Gun Esp",
    CurrentValue = false,
    Callback = function(State)
     Esp.DroppedGun = State
     DroppedGunEsp()
    end
})

local TextSection = EspTab:CreateSection("Text")

EspTab:CreateToggle({
    Name = "Name",
    CurrentValue = false,
    Callback = function(State)
     Esp.Name = State
     UpdateAllPlayersEsp()
    end
})

EspTab:CreateToggle({
    Name = "DisplayName",
    CurrentValue = false,
    Callback = function(State)
     Esp.DisplayName = State
     UpdateAllPlayersEsp()
    end
})

EspTab:CreateToggle({
    Name = "Role",
    CurrentValue = false,
    Callback = function(State)
     Esp.Role = State
     UpdateAllPlayersEsp()
    end
})

local ConfigSection = EspTab:CreateSection("Config")

EspTab:CreateColorPicker({
    Name = "Innocent Esp Color",
    Color = Color3.fromRGB(0, 255,0),
    Callback = function(Color)
        Esp.Colors.Innocent = Color
        UpdateAllPlayersEsp()
    end
})

EspTab:CreateColorPicker({
    Name = "Sheriff Esp Color",
    Color = Color3.fromRGB(0,0,255),
    Callback = function(Color)
        Esp.Colors.Sheriff = Color
        UpdateAllPlayersEsp()
    end
})

EspTab:CreateColorPicker({
    Name = "Hero Esp Color",
    Color = Color3.fromRGB(255, 255,0),
    Callback = function(Color)
        Esp.Colors.Hero = Color
        UpdateAllPlayersEsp()
    end
})

EspTab:CreateColorPicker({
    Name = "Murderer Esp Color",
    Color = Color3.fromRGB(255,0,0),
    Callback = function(Color)
        Esp.Colors.Murderer = Color
        UpdateAllPlayersEsp()
    end
})

EspTab:CreateColorPicker({
    Name = "Dead Esp Color",
    Color = Color3.fromRGB(255, 255,255),
    Callback = function(Color)
        Esp.Colors.Dead = Color
        UpdateAllPlayersEsp()
    end
})

EspTab:CreateColorPicker({
    Name = "In Lobby Players Esp Color",
    Color = Color3.fromRGB(0, 0,0),
    Callback = function(Color)
        Esp.Colors.Lobby = Color
        UpdateAllPlayersEsp()
    end
})

EspTab:CreateColorPicker({
    Name = "Dropped Gun Esp Color",
    Color = Color3.fromRGB(170, 0,255),
    Callback = function(Color)
        Esp.Colors.DroppedGun = Color
        UpdateAllPlayersEsp()
    end
})

local SheriffTab = Window:CreateTab("Sheriff")
local NormalShootSection = SheriffTab:CreateSection("Normal Shoot")

SheriffTab:CreateToggle({
    Name = "Auto Shoot",
    CurrentValue = false,
    Callback = function(State)
     Sheriff.AutoShoot = State
     if State then
      AutoShoot()
     end
    end
})


SheriffTab:CreateButton({
  Name = "Shoot Murder",
  Callback = function()
    ShootMurderer(false)
  end
})

local ShootFloatingButton = SheriffTab:CreateButtonFloat({
    Name = "Shoot Murder",
    Width = 100,
    Height = 40,
    X = 0.90,
    Y = 0.5,
    Draggable = false,
    Callback = function()
     ShootMurderer(false)
    end
})

ShootFloatingButton:Hide()

SheriffTab:CreateToggle({
    Name = "Shoot Floating Button",
    CurrentValue = false,
    Callback = function(State)
     ShootFloatingButton:SetVisible(State)
    end
})

SheriffTab:CreateInput({
    Name = "Shoot Keybind",
    PlaceholderText = "Bind a key...",
    Callback = function(Text)
     local KeyCode = Enum.KeyCode[Text:upper()]
     if KeyCode then
      Sheriff.ShootKeybind = KeyCode
     end
    end
})

local HackerShootSection = SheriffTab:CreateSection("Hacker Shoot")

SheriffTab:CreateToggle({
    Name = "Auto Hacker Shoot",
    CurrentValue = false,
    Callback = function(State)
     Sheriff.AutoHackerShoot = State
     if State then
      AutoHackerShoot()
     end
    end
})

SheriffTab:CreateButton({
  Name = "Hacker Shoot",
  Callback = function()
    ShootMurderer(true)
  end
})

local HackerShootFloatingButton = SheriffTab:CreateButtonFloat({
    Name = "H Shoot Murder",
    Width = 100,
    Height = 40,
    X = 0.90,
    Y = 0.625,
    Draggable = false,
    Callback = function()
     ShootMurderer(true)
    end
})

HackerShootFloatingButton:Hide()

SheriffTab:CreateToggle({
    Name = "Hacker Shoot Floating Button",
    CurrentValue = false,
    Callback = function(State)
     HackerShootFloatingButton:SetVisible(State)
    end
})

SheriffTab:CreateInput({
    Name = "Hacker Shoot Keybind",
    PlaceholderText = "Bind a key...",
    Callback = function(Text)
     local KeyCode = Enum.KeyCode[Text:upper()]
     if KeyCode then
      Sheriff.HackerShootKeybind = KeyCode
     end
    end
})

SheriffTab:CreateButton({
  Name = "Teleport Shoot",
  Callback = function()
    TpShootMurderer()
  end
})

local ConfigSection = SheriffTab:CreateSection("Config")

SheriffTab:CreateToggle({
    Name = "Normal/Hacker Shoot Prediction",
    CurrentValue = false,
    Callback = function(State)
     Sheriff.Prediction = State
    end
})

SheriffTab:CreateSlider({
    Name = "Prediction Value",
    Range = {0,1}, --- Mínimo y máximo
    Increment = 0.01, --- De cuánto en cuánto cambia
    Suffix = "", --- Texto después del valor
    CurrentValue = 0, --- Valor inicial
    Callback = function(Value)
      Sheriff.PredictionValue = Value
    end
})

local DroppedGunSection = SheriffTab:CreateSection("Dropped Gun")

SheriffTab:CreateToggle({
    Name = "Auto Get Dropped Gun",
    CurrentValue = false,
    Callback = function(State)
     Sheriff.AutoGetDroppedGun = State
     if State then
      GetDroppedGun()
     end
    end
})

SheriffTab:CreateButton({
  Name = "Get Dropped Gun",
  Callback = function()
    GetDroppedGun()
  end
})

local GetDroppedGunFloatingButton = SheriffTab:CreateButtonFloat({
    Name = "Get Dropped Gun",
    Width = 100,
    Height = 40,
    X = 0.90,
    Y = 0.35,
    Draggable = false,
    Callback = function()
     GetDroppedGun()
    end
})

GetDroppedGunFloatingButton:Hide()

SheriffTab:CreateToggle({
    Name = "Get Dropped Gun Floating Button",
    CurrentValue = false,
    Callback = function(State)
     GetDroppedGunFloatingButton:SetVisible(State)
    end
})

SheriffTab:CreateInput({
    Name = "Get Dropped Gun Keybind",
    PlaceholderText = "Bind a key...",
    Callback = function(Text)
     local KeyCode = Enum.KeyCode[Text:upper()]
     if KeyCode then
      Sheriff.GetDroppedGunKeybind = KeyCode
     end
    end
})

SheriffTab:CreateToggle({
    Name = "Dropped Gun Notify",
    CurrentValue = false,
    Callback = function(State)
     Sheriff.DroppedGunNotify = State
    end
})

local MurdererTab = Window:CreateTab("Murderer")
local NormalThrownSection = MurdererTab:CreateSection("Normal Thrown Knife")

MurdererTab:CreateToggle({
    Name = "Auto Thrown Knife",
    CurrentValue = false,
    Callback = function(State)
     Murderer.AutoThrownKnife = State
     if State then
      AutoThrownKnife()
     end
    end
})


MurdererTab:CreateButton({
  Name = "Thrown Knife",
  Callback = function()
    ThrownKnife(false)
  end
})

local ThrownKnifeFloatingButton = MurdererTab:CreateButtonFloat({
    Name = "Thrown Knife",
    Width = 100,
    Height = 40,
    X = 0.75,
    Y = 0.5,
    Draggable = false,
    Callback = function()
     ThrownKnife(false)
    end
})

ThrownKnifeFloatingButton:Hide()

MurdererTab:CreateToggle({
    Name = "Thrown Knife Floating Button",
    CurrentValue = false,
    Callback = function(State)
     ThrownKnifeFloatingButton:SetVisible(State)
    end
})

MurdererTab:CreateInput({
    Name = "Thrown Knife Keybind",
    PlaceholderText = "Bind a key...",
    Callback = function(Text)
     local KeyCode = Enum.KeyCode[Text:upper()]
     if KeyCode then
      Murderer.ThrownKnifeKeybind = KeyCode
     end
    end
})

local HackerThrownKnifeSection = MurdererTab:CreateSection("Hacker Thrown")

MurdererTab:CreateToggle({
    Name = "Auto Hacker Thrown Knife",
    CurrentValue = false,
    Callback = function(State)
     Murderer.AutoHackerThrownKnife = State
     if State then
      AutoHackerThrownKnife()
     end
    end
})


MurdererTab:CreateButton({
  Name = "Hacker Thrown Knife",
  Callback = function()
    ThrownKnife(true)
  end
})

local HackerThrownKnifeFloatingButton = MurdererTab:CreateButtonFloat({
    Name = "H Thrown Knife",
    Width = 100,
    Height = 40,
    X = 0.75,
    Y = 0.625,
    Draggable = false,
    Callback = function()
     ThrownKnife(true)
    end
})

HackerThrownKnifeFloatingButton:Hide()

MurdererTab:CreateToggle({
    Name = "H Thrown Knife Floating Button",
    CurrentValue = false,
    Callback = function(State)
     HackerThrownKnifeFloatingButton:SetVisible(State)
    end
})

MurdererTab:CreateInput({
    Name = "Hacker Thrown Knife Keybind",
    PlaceholderText = "Bind a key...",
    Callback = function(Text)
     local KeyCode = Enum.KeyCode[Text:upper()]
     if KeyCode then
      Murderer.HackerThrownKnifeKeybind = KeyCode
     end
    end
})

local OthersSection = MurdererTab:CreateSection("Others")

MurdererTab:CreateButton({
  Name = "Bring Sheriff (5 Seconds)",
  Callback = function()
    BringSheriff()
  end
})

MurdererTab:CreateButton({
  Name = "Kill Everyone",
  Callback = function()
    KillEveryone()
  end
})

MurdererTab:CreateToggle({
    Name = "Kill Aura",
    CurrentValue = false,
    Callback = function(State)
     Murderer.KillAura = State
     if State then
      KillAura()
     end
    end
})

MurdererTab:CreateSlider({
    Name = "Kill Aura Range",
    Range = {1, 100}, --- Mínimo y máximo
    Increment = 1, --- De cuánto en cuánto cambia
    Suffix = "Studs", --- Texto después del valor
    CurrentValue = 20, --- Valor inicial
    Callback = function(Value)
      Murderer.KillAuraRange = Value
    end
})

local HitboxSection = MurdererTab:CreateSection("Hitbox")

MurdererTab:CreateToggle({
    Name = "Hitbox (Knife Only)",
    CurrentValue = false,
    Callback = function(State)
     Murderer.Hitbox = State
     if State then
      Hitbox()
     end
    end
})

MurdererTab:CreateInput({
    Name = "Hitbox Keybind",
    PlaceholderText = "Bind a key...",
    Callback = function(Text)
     local KeyCode = Enum.KeyCode[Text:upper()]
     if KeyCode then
      Murderer.HitboxKeybind = KeyCode
     end
    end
})

MurdererTab:CreateSlider({
    Name = "Hitbox Transparency",
    Range = {0, 1}, --- Mínimo y máximo
    Increment = 0.1, --- De cuánto en cuánto cambia
    Suffix = "", --- Texto después del valor
    CurrentValue = 0.8, --- Valor inicial
    Callback = function(Value)
      Murderer.Transparency = Value
    end
})

MurdererTab:CreateSlider({
    Name = "Hitbox Size",
    Range = {0, 30}, --- Mínimo y máximo
    Increment = 0.1, --- De cuánto en cuánto cambia
    Suffix = "studs/s", --- Texto después del valor
    CurrentValue = 10, --- Valor inicial
    Callback = function(Value)
      Murderer.HitboxSize = Value
    end
})

local AutofarmTab = Window:CreateTab("Autofarm")
local AutofarmSection = AutofarmTab:CreateSection("Options")

local AutofarmCoinsCurrentValue = getgenv().AutofarmEnabled or false

AutofarmTab:CreateToggle({
    Name = "Autofarm Coins",
    CurrentValue = AutofarmCoinsCurrentValue,
    Callback = function(State)
     Autofarm.Enabled = State
     if State then
      InitAutofarm()
     end
    end
})

local AutoFinishRoundCurrentValue = getgenv().AutoFinishRound or false

AutofarmTab:CreateToggle({
    Name = "Auto Finish Round",
    CurrentValue = AutoFinishRoundCurrentValue,
    Callback = function(State)
     Autofarm.AutoFinishRound = State
    end
})

AutofarmTab:CreateDropdown({
    Name = "Autofarm Mode",
    Options = {"Normal","Underground"},
    Callback = function(Option)
     Autofarm.Mode = Option
    end
})

local AutoRejoinCurrentValue = getgenv().AutoRejoin or false

AutofarmTab:CreateToggle({
    Name = "Auto Rejoin",
    CurrentValue = AutoRejoinCurrentValue,
    Callback = function(State)
     Autofarm.AutoRejoin = State
    end
})

local TargetTab = Window:CreateTab("Target")
local TargetOptionsSection = TargetTab:CreateSection("Options")

TargetTab:CreateInput({
    Name = "Player Name",
    PlaceholderText = "Write a name...",
    Callback = function(Text)
     local Player = GetPlayerByPartialName(Text)
     if Player then
      Target.CurrentTarget = Player
     end
    end
})

TargetTab:CreateToggle({
    Name = "Spectate",
    CurrentValue = false,
    Callback = function(State)
     Target.Spectating = State
     Spectate(Target.CurrentTarget,State)
    end
})

TargetTab:CreateButton({
  Name = "Teleport",
  Callback = function()
    TeleportToPlayer(Target.CurrentTarget)
  end
})

local FlingSection = TargetTab:CreateSection("Fling")

TargetTab:CreateButton({
  Name = "Fling Target",
  Callback = function()
    Fling(Target.CurrentTarget)
  end
})

TargetTab:CreateButton({
  Name = "Fling Sheriff",
  Callback = function()
    FlingSheriff()
  end
})

TargetTab:CreateButton({
  Name = "Fling Murderer",
  Callback = function()
    FlingMurderer()
  end
})

TargetTab:CreateButton({
  Name = "Fling All",
  Callback = function()
    FlingAll()
  end
})

--// Events
Players.PlayerAdded:Connect(function(Player)
 Player.CharacterAdded:Connect(function(Character)
  repeat task.wait() until GetRootPart(Player) or not Player
  
  if not Player then return end
  
  UpdateEsp(Player)
 end)
end)

for i,Player in ipairs(Players:GetPlayers()) do
 Player.CharacterAdded:Connect(function(Character)
  UpdateEsp(Player)
 end)
end

  local function OnKick()
  local Content = ""
  print("1")
  if Autofarm.Enabled then
   Content = Content.."\n getgenv().AutofarmEnabled = true"
  end
  if Autofarm.AutoRejoin then
   Content = Content.."\n getgenv().AutoRejoin = true"
  end
  if Autofarm.AutoFinishRound then
   Content = Content.."\n getgenv().AutoFinishRound = true"
  end
  
  Content = Content.."\n getgenv().AutofarmMode = "..string.format("%q", Autofarm.Mode)
  
  Content = Content.."\n\n\n loadstring(game:HttpGet(''))()"
  
  print("2")
  
  if Autofarm.AutoRejoin then
   print("3")
   local Queue = queue_on_teleport or queueonteleport or queueOnTeleport or QueueOnTeleport
   print("4")
   if Queue then
    Queue(Content)
   end
   print("5")
   
   local PlaceId = game.PlaceId
   local JobId = game.JobId
   print("6")
   
   TeleportService:TeleportToPlaceInstance(PlaceId,JobId,Client)
   print("7")
  end
  
  end

GuiService.ErrorMessageChanged:Connect(OnKick)


--//Important Functions
local function ConnectRoundStart()
 local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
 if Remotes then
  local Gameplay = Remotes:FindFirstChild("Gameplay")
  if Gameplay then
   local RoundStart = Gameplay:FindFirstChild("RoundStart")
   if RoundStart then
    
    RoundStart.OnClientEvent:Connect(function(...)
     local Args = {...}
     local Number = Args[1]
     local RoundPlayersInfo = Args[2]
     
     Esp.EveryoneInLobby = false
     ManagePlayersInfo(RoundPlayersInfo)
     UpdateAllPlayersEsp()
    end)
    
   end
  end
 end
end

local function ConnectRoundEnd()
 local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
 if Remotes then
  local Gameplay = Remotes:FindFirstChild("Gameplay")
  if Gameplay then
   local RoundEnd = Gameplay:FindFirstChild("RoundEndFade")
   if RoundEnd then
    
    RoundEnd.OnClientEvent:Connect(function(...)
     local Args = {...}
     local Boolean = Args[1]
     
     Esp.EveryoneInLobby = true
     UpdateAllPlayersEsp()
    end)
    
   end
  end
 end
end

local function ConnectPlayerDataChanged()
 local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
 if Remotes then
  local Gameplay = Remotes:FindFirstChild("Gameplay")
  if Gameplay then
   local PlayerDataChanged = Gameplay:FindFirstChild("PlayerDataChanged")
   if PlayerDataChanged then
    
    PlayerDataChanged.OnClientEvent:Connect(function(...)
     local Args = {...}
     local PlayersData = Args[1]
     
     Esp.EveryoneInLobby = false
     ManagePlayersInfo(PlayersData)
     UpdateAllPlayersEsp()
    end)
    
   end
  end
 end
end

local function ManageDescendantAdded(Descendant)
 if Descendant.Name == "DropGun" or Descendant.Name == "GunDrop" then
  Script.DroppedGun = Descendant
  
  if Sheriff.AutoGetDroppedGun then
   GetDroppedGun()
  end
  
  if Esp.DroppedGun then
   DroppedGunEsp()
  end
  
  if Sheriff.DroppedGunNotify then
   Notify(Library,"Dropped Gun Notify","Dropped Gun Found...",3)
  end
  
 end
end

local function ManageDescendantRemoving(Descendant)
 if Descendant.Name == "DropGun" or Descendant.Name == "GunDrop" then
  Script.DroppedGun = nil
 end
end

local function ConnectDescendantAdded()
 Workspace.DescendantAdded:Connect(function(Descendant)
  ManageDescendantAdded(Descendant)
 end)
end

local function ConnectDescendantRemoving()
 Workspace.DescendantRemoving:Connect(function(Descendant)
  ManageDescendantRemoving(Descendant)
 end)
end

--//Init
ConnectRoundStart()
ConnectRoundEnd()
ConnectPlayerDataChanged()
ConnectDescendantAdded()
ConnectDescendantRemoving()

--//Loops
local Frames = 0
local Connection 
Connection = RunService.Heartbeat:Connect(function()
 Frames += 1
 
 if Frames >= 240 then
  Frames = 0
  
  local Data = GetPlayersData()
  if Data then
   Script.PlayersInfo = Data
  end
  
  UpdateAllPlayersEsp()
 end
 
end)

if getgenv().AutofarmEnabled then
 Autofarm.Enabled = true
 InitAutofarm()
end

UserInputService.InputBegan:Connect(function(Input,GameProcessed)
 if GameProcessed then
  return
 end
 
 if Input.KeyCode == Sheriff.ShootKeybind then
  ShootMurderer(false)
 elseif Input.KeyCode == Sheriff.HackerShootKeybind then
  ShootMurderer(true)
 elseif Input.KeyCode == Sheriff.GetDroppedGunKeybind then
  GetDroppedGun()
 elseif Input.KeyCode == Murderer.ThrownKnifeKeybind then
  ThrownKnife(false)
 elseif Input.KeyCode == Murderer.HackerThrownKnifeKeybind then
  ThrownKnife(true)
 elseif Input.KeyCode == Murderer.HitboxKeybind then
  Murderer.Hitbox = not Murderer.Hitbox
  if Murderer.Hitbox then
   Hitbox()
  end
 end
end)