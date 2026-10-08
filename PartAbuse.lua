--//Variables
local NyxModsUniversal = getgenv().NyxModsUniversal
local Window = NyxModsUniversal.Window

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local Client = Players.LocalPlayer

--//Tables
local Telekinesis = {
    Enabled = false,
    Mode = "Ring", --// Ring, Mouse, Star, Invert Gravity, Words, Black Hole

    --// Ring
    RingRadius = 20,
    RingSpeed = 20,
    RingOffset = Vector3.new(0, 0, 0),

    --// Mouse
    MouseDistance = 20,
    MouseSpeed = 20,

    --// Star
    StarRadius = 25,
    StarInnerRadius = 10,
    StarSpeed = 1,

    --// Invert Gravity
    GravityForce = 20,

    --// Words
    WordsText = "LOL",
    WordsSize = 2,
    WordsLetterSpacing = 2,
    WordsOffset = Vector3.new(0, 25, 0),
    
    BlackHoleForce = 0.1,
}

local Network = {
    BaseParts = {},
    NetworkVelocity = 14.46262424,
    SimulationRadius = 5000,
}

--// Functions

local function GetPlayerCharacter(Player)
    if not Player then
        return
    end

    return Player.Character
end

local function GetPlayerInstance(Player, Name)
    if not Player then
        return
    end

    local Character = GetPlayerCharacter(Player)

    if Character then
        local Instance = Character:FindFirstChild(Name)

        if Instance then
            return Instance
        end
    end

    return nil
end

local function IsAPlayerInstance(Instance)
    for _, Player in ipairs(Players:GetPlayers()) do

        if not Player then
            continue
        end

        local Character = Player.Character

        if Character then
            if Instance:IsDescendantOf(Character) then
                return true
            end
        end
    end

    return false
end

local function OwnedPart(Part)
    if not Part then
        return false
    end

    if not Part:IsA("BasePart") then
        return false
    end

    if isnetworkowner and not isnetworkowner(Part) then
        return false
    end

    if Part.Anchored then
        return false
    end

    if Part.ReceiveAge > 0 then
        return false
    end

    return true
end

local function SetOwner(Part, Time, Velocity)
    if not Part then
        return
    end

    if Part.Anchored then
        return
    end

    Part.Velocity = Vector3.new(
        0,
        -Velocity,
        0
    )

    Part.CanQuery = false

    Part.CustomPhysicalProperties = PhysicalProperties.new(
        0.01,
        0.01,
        0.01,
        0.01,
        0.01
    )
end

--//==================================================
--// WORD FONT
--//==================================================

local WordFont = {

    A = {
        "01110",
        "10001",
        "10001",
        "11111",
        "10001",
        "10001",
        "10001",
    },

    B = {
        "11110",
        "10001",
        "10001",
        "11110",
        "10001",
        "10001",
        "11110",
    },

    C = {
        "01111",
        "10000",
        "10000",
        "10000",
        "10000",
        "10000",
        "01111",
    },

    D = {
        "11110",
        "10001",
        "10001",
        "10001",
        "10001",
        "10001",
        "11110",
    },

    E = {
        "11111",
        "10000",
        "10000",
        "11110",
        "10000",
        "10000",
        "11111",
    },

    F = {
        "11111",
        "10000",
        "10000",
        "11110",
        "10000",
        "10000",
        "10000",
    },

    G = {
        "01111",
        "10000",
        "10000",
        "10111",
        "10001",
        "10001",
        "01111",
    },

    H = {
        "10001",
        "10001",
        "10001",
        "11111",
        "10001",
        "10001",
        "10001",
    },

    I = {
        "11111",
        "00100",
        "00100",
        "00100",
        "00100",
        "00100",
        "11111",
    },

    J = {
        "00111",
        "00010",
        "00010",
        "00010",
        "00010",
        "10010",
        "01100",
    },

    K = {
        "10001",
        "10010",
        "10100",
        "11000",
        "10100",
        "10010",
        "10001",
    },

    L = {
        "10000",
        "10000",
        "10000",
        "10000",
        "10000",
        "10000",
        "11111",
    },

    M = {
        "10001",
        "11011",
        "10101",
        "10101",
        "10001",
        "10001",
        "10001",
    },

    N = {
        "10001",
        "11001",
        "10101",
        "10011",
        "10001",
        "10001",
        "10001",
    },

    O = {
        "01110",
        "10001",
        "10001",
        "10001",
        "10001",
        "10001",
        "01110",
    },

    P = {
        "11110",
        "10001",
        "10001",
        "11110",
        "10000",
        "10000",
        "10000",
    },

    Q = {
        "01110",
        "10001",
        "10001",
        "10001",
        "10101",
        "10010",
        "01101",
    },

    R = {
        "11110",
        "10001",
        "10001",
        "11110",
        "10100",
        "10010",
        "10001",
    },

    S = {
        "01111",
        "10000",
        "10000",
        "01110",
        "00001",
        "00001",
        "11110",
    },

    T = {
        "11111",
        "00100",
        "00100",
        "00100",
        "00100",
        "00100",
        "00100",
    },

    U = {
        "10001",
        "10001",
        "10001",
        "10001",
        "10001",
        "10001",
        "01110",
    },

    V = {
        "10001",
        "10001",
        "10001",
        "10001",
        "10001",
        "01010",
        "00100",
    },

    W = {
        "10001",
        "10001",
        "10001",
        "10101",
        "10101",
        "11011",
        "10001",
    },

    X = {
        "10001",
        "10001",
        "01010",
        "00100",
        "01010",
        "10001",
        "10001",
    },

    Y = {
        "10001",
        "10001",
        "01010",
        "00100",
        "00100",
        "00100",
        "00100",
    },

    Z = {
        "11111",
        "00001",
        "00010",
        "00100",
        "01000",
        "10000",
        "11111",
    },

    ["0"] = {
        "01110",
        "10001",
        "10011",
        "10101",
        "11001",
        "10001",
        "01110",
    },

    ["1"] = {
        "00100",
        "01100",
        "00100",
        "00100",
        "00100",
        "00100",
        "01110",
    },

    ["2"] = {
        "01110",
        "10001",
        "00001",
        "00010",
        "00100",
        "01000",
        "11111",
    },

    ["3"] = {
        "11110",
        "00001",
        "00001",
        "01110",
        "00001",
        "00001",
        "11110",
    },

    ["4"] = {
        "00010",
        "00110",
        "01010",
        "10010",
        "11111",
        "00010",
        "00010",
    },

    ["5"] = {
        "11111",
        "10000",
        "10000",
        "11110",
        "00001",
        "00001",
        "11110",
    },

    ["6"] = {
        "01110",
        "10000",
        "10000",
        "11110",
        "10001",
        "10001",
        "01110",
    },

    ["7"] = {
        "11111",
        "00001",
        "00010",
        "00100",
        "01000",
        "01000",
        "01000",
    },

    ["8"] = {
        "01110",
        "10001",
        "10001",
        "01110",
        "10001",
        "10001",
        "01110",
    },

    ["9"] = {
        "01110",
        "10001",
        "10001",
        "01111",
        "00001",
        "00001",
        "01110",
    },

    ["?"] = {
        "01110",
        "10001",
        "00001",
        "00010",
        "00100",
        "00000",
        "00100",
    },

    [":"] = {
        "0000000",
        "0011000",
        "0011000",
        "0000000",
        "0000000",
        "0011000",
        "0011000",
    },

    ["("] = {
        "0011000",
        "0110000",
        "1100000",
        "1100000",
        "1100000",
        "0110000",
        "0011000",
    },

    [")"] = {
        "1100000",
        "0110000",
        "0011000",
        "0011000",
        "0011000",
        "0110000",
        "1100000",
    },

    [";"] = {
        "0000000",
        "0011000",
        "0011000",
        "0000000",
        "0011000",
        "0110000",
        "0100000",
    },

    ["!"] = {
        "0011000",
        "0011000",
        "0011000",
        "0011000",
        "0011000",
        "0000000",
        "0011000",
    },

    ["}"] = {
        "0110000",
        "0011000",
        "0011000",
        "0110000",
        "0011000",
        "0011000",
        "0110000",
    },

    ["{"] = {
        "0001100",
        "0011000",
        "0011000",
        "0110000",
        "0011000",
        "0011000",
        "0001100",
    },

    [">"] = {
        "1000000",
        "1100000",
        "0110000",
        "0011000",
        "0110000",
        "1100000",
        "1000000",
    },

    ["<"] = {
        "0000100",
        "0001100",
        "0011000",
        "0110000",
        "0011000",
        "0001100",
        "0000100",
    },

    ["]"] = {
        "1110000",
        "0011000",
        "0011000",
        "0011000",
        "0011000",
        "0011000",
        "1110000",
    },

    ["["] = {
        "1110000",
        "1100000",
        "1100000",
        "1100000",
        "1100000",
        "1100000",
        "1110000",
    },

    ["="] = {
        "0000000",
        "0000000",
        "1111100",
        "0000000",
        "1111100",
        "0000000",
        "0000000",
    },

    ["|"] = {
        "0011000",
        "0011000",
        "0011000",
        "0011000",
        "0011000",
        "0011000",
        "0011000",
    },

    ["\\"] = {
        "1100000",
        "0110000",
        "0011000",
        "0011000",
        "0001100",
        "0001100",
        "0000110",
    },

    ["_"] = {
        "0000000",
        "0000000",
        "0000000",
        "0000000",
        "0000000",
        "0000000",
        "1111110",
    },

    ["-"] = {
        "0000000",
        "0000000",
        "0000000",
        "1111110",
        "0000000",
        "0000000",
        "0000000",
    },

    ["+"] = {
        "0000000",
        "0011000",
        "0011000",
        "1111110",
        "0011000",
        "0011000",
        "0000000",
    },

    ["'"] = {
        "0011000",
        "0011000",
        "0001000",
        "0000000",
        "0000000",
        "0000000",
        "0000000",
    },

    ['"'] = {
        "0110110",
        "0110110",
        "0110110",
        "0000000",
        "0000000",
        "0000000",
        "0000000",
    },

    ["."] = {
        "0000000",
        "0000000",
        "0000000",
        "0000000",
        "0000000",
        "0011000",
        "0011000",
    },
}

--//==================================================
--// SPECIAL PATTERNS
--//==================================================

local SpecialPatterns = {

    

}

--//==================================================
--// WORD FUNCTIONS
--//==================================================

local WordTargets = {}

local LastWordText = ""
local LastWordSize = 0
local LastWordSpacing = 0

local function GenerateWordTargets(
    Text,
    PartCount,
    Size,
    LetterSpacing
)

    local Pixels = {}

    Text = string.lower(tostring(Text or ""))

    --//==================================================
    --// SPECIAL PATTERN
    --//==================================================

    local Special = SpecialPatterns[Text]

    if not Special then
        Special = SpecialPatterns[string.lower(Text)]
    end

    if Special then

        local Height = #Special
        local Width = #Special[1]

        for Y, Row in ipairs(Special) do

            for X = 1, Width do

                if Row:sub(X, X) == "1" then

                    table.insert(Pixels, {
                        X = X - 1,
                        Y = Y - 1,
                    })

                end
            end
        end

    else

        --//==================================================
        --// NORMAL WORD
        --//==================================================

        Text = string.upper(Text)

        local CursorX = 0

        for Index = 1, #Text do

            local Character =
                Text:sub(Index, Index)

            local Letter =
                WordFont[Character]

            if Letter then

                local Width =
                    #Letter[1]

                for Y, Row in ipairs(Letter) do

                    for X = 1, Width do

                        if Row:sub(X, X) == "1" then

                            table.insert(Pixels, {
                                X = CursorX + X - 1,
                                Y = Y - 1,
                            })

                        end
                    end
                end

                CursorX +=
                    Width + LetterSpacing

            elseif Character == " " then

                CursorX +=
                    4 + LetterSpacing
            end
        end
    end

    --//==================================================
    --// No Pixels
    --//==================================================

    if #Pixels == 0 then
        return {}
    end

    local Result = {}

    --//==================================================
    --// Fewer Parts than Pixels
    --//==================================================

    if PartCount <= #Pixels then

        for Index = 1, PartCount do

            local Alpha =
                (Index - 1)
                / math.max(
                    PartCount - 1,
                    1
                )

            local PixelIndex =
                math.floor(
                    Alpha
                    * (#Pixels - 1)
                ) + 1

            Result[Index] =
                Pixels[PixelIndex]
        end

    else

        --//==================================================
        --// More Parts than Pixels
        --//==================================================

        for Index = 1, PartCount do

            local Alpha =
                (Index - 1)
                / PartCount

            local PixelIndex =
                math.floor(
                    Alpha
                    * #Pixels
                ) + 1

            PixelIndex =
                math.clamp(
                    PixelIndex,
                    1,
                    #Pixels
                )

            Result[Index] = {
                X = Pixels[PixelIndex].X,
                Y = Pixels[PixelIndex].Y,
            }
        end
    end

    --//==================================================
    --// Center Horizontally
    --//==================================================

    local MinX = math.huge
    local MaxX = -math.huge

    local MinY = math.huge
    local MaxY = -math.huge

    for _, Pixel in ipairs(Result) do

        MinX =
            math.min(
                MinX,
                Pixel.X
            )

        MaxX =
            math.max(
                MaxX,
                Pixel.X
            )

        MinY =
            math.min(
                MinY,
                Pixel.Y
            )

        MaxY =
            math.max(
                MaxY,
                Pixel.Y
            )
    end

    local CenterX =
        (MinX + MaxX) / 2

    local CenterY =
        (MinY + MaxY) / 2

    for _, Pixel in ipairs(Result) do

        Pixel.X -= CenterX
        Pixel.Y =
            CenterY - Pixel.Y
    end

    return Result
end

--//==================================================
--// GUI
--//==================================================

local Tab = Window:Tab({
    Title = "Part Abuse",
    Icon = "box",
})

--//Options
local OptionsSection = Tab:Section({
    Title = "Options"
})

Tab:Toggle({
    Title = "Part Abuse (Laggy)",
    Value = false,

    Callback = function(State)
        Telekinesis.Enabled = State
    end
})

Tab:Dropdown({
    Title = "Mode",

    Values = {
        "Ring",
        "Mouse",
        "Star",
        "Invert Gravity",
        "Words",
        "Black Hole",
    },

    Value = "Ring",

    Callback = function(Option)
        Telekinesis.Mode = Option
    end
})

--//==================================================
--// RING CONFIG
--//==================================================

local RingConfigSection = Tab:Section({
    Title = "Ring Config"
})

Tab:Slider({
    Title = "Ring Radius",
    Step = 1,

    Value = {
        Min = 0,
        Max = 100,
        Default = 20,
    },

    Callback = function(Value)
        Telekinesis.RingRadius = Value
    end
})

Tab:Slider({
    Title = "Ring Speed",
    Step = 1,

    Value = {
        Min = 0,
        Max = 100,
        Default = 20,
    },

    Callback = function(Value)
        Telekinesis.RingSpeed = Value
    end
})

Tab:Slider({
    Title = "Ring Offset X",
    Step = 1,

    Value = {
        Min = -50,
        Max = 50,
        Default = 0,
    },

    Callback = function(Value)

        Telekinesis.RingOffset = Vector3.new(
            Value,
            Telekinesis.RingOffset.Y,
            Telekinesis.RingOffset.Z
        )

    end
})

Tab:Slider({
    Title = "Ring Offset Y",
    Step = 1,

    Value = {
        Min = -50,
        Max = 50,
        Default = 0,
    },

    Callback = function(Value)

        Telekinesis.RingOffset = Vector3.new(
            Telekinesis.RingOffset.X,
            Value,
            Telekinesis.RingOffset.Z
        )

    end
})

Tab:Slider({
    Title = "Ring Offset Z",
    Step = 1,

    Value = {
        Min = -50,
        Max = 50,
        Default = 0,
    },

    Callback = function(Value)

        Telekinesis.RingOffset = Vector3.new(
            Telekinesis.RingOffset.X,
            Telekinesis.RingOffset.Y,
            Value
        )

    end
})

--//==================================================
--// MOUSE CONFIG
--//==================================================

local MouseConfigSection = Tab:Section({
    Title = "Mouse Config"
})

Tab:Slider({
    Title = "Mouse Distance",
    Step = 1,

    Value = {
        Min = 1,
        Max = 100,
        Default = 20,
    },

    Callback = function(Value)
        Telekinesis.MouseDistance = Value
    end
})

Tab:Slider({
    Title = "Mouse Speed",
    Step = 1,

    Value = {
        Min = 1,
        Max = 100,
        Default = 20,
    },

    Callback = function(Value)
        Telekinesis.MouseSpeed = Value
    end
})

--//==================================================
--// STAR CONFIG
--//==================================================

local StarConfigSection = Tab:Section({
    Title = "Star Config"
})

Tab:Slider({
    Title = "Star Radius",
    Step = 1,

    Value = {
        Min = 1,
        Max = 100,
        Default = 25,
    },

    Callback = function(Value)
        Telekinesis.StarRadius = Value
    end
})

Tab:Slider({
    Title = "Star Inner Radius",
    Step = 1,

    Value = {
        Min = 1,
        Max = 100,
        Default = 10,
    },

    Callback = function(Value)
        Telekinesis.StarInnerRadius = Value
    end
})

Tab:Slider({
    Title = "Star Speed",
    Step = 1,

    Value = {
        Min = 1,
        Max = 100,
        Default = 1,
    },

    Callback = function(Value)
        Telekinesis.StarSpeed = Value
    end
})

--//==================================================
--// INVERT GRAVITY CONFIG
--//==================================================

local GravityConfigSection = Tab:Section({
    Title = "Invert Gravity Config"
})

Tab:Slider({
    Title = "Gravity Force",
    Step = 1,

    Value = {
        Min = 1,
        Max = 100,
        Default = 20,
    },

    Callback = function(Value)
        Telekinesis.GravityForce = Value
    end
})

--//==================================================
--// WORDS CONFIG
--//==================================================

local WordsConfigSection = Tab:Section({
    Title = "Words Config"
})

Tab:Input({
    Title = "Text",
    Placeholder = "Write something...",
    Value = "LOL",

    Callback = function(Value)

        Telekinesis.WordsText = Value

        --// Force regeneration
        LastWordText = ""
    end
})

Tab:Slider({
    Title = "Text Size",
    Step = 1,

    Value = {
        Min = 1,
        Max = 10,
        Default = 2,
    },

    Callback = function(Value)

        Telekinesis.WordsSize = Value

        --// Force regeneration
        LastWordSize = 0
    end
})

Tab:Slider({
    Title = "Letter Spacing",
    Step = 1,

    Value = {
        Min = 0,
        Max = 10,
        Default = 2,
    },

    Callback = function(Value)

        Telekinesis.WordsLetterSpacing = Value

        --// Force regeneration
        LastWordSpacing = 0
    end
})

Tab:Slider({
    Title = "Words Offset X",
    Step = 1,

    Value = {
        Min = -50,
        Max = 50,
        Default = 0,
    },

    Callback = function(Value)

        Telekinesis.WordsOffset = Vector3.new(
            Value,
            Telekinesis.WordsOffset.Y,
            Telekinesis.WordsOffset.Z
        )

    end
})

Tab:Slider({
    Title = "Words Offset Y",
    Step = 1,

    Value = {
        Min = -50,
        Max = 100,
        Default = 25,
    },

    Callback = function(Value)

        Telekinesis.WordsOffset = Vector3.new(
            Telekinesis.WordsOffset.X,
            Value,
            Telekinesis.WordsOffset.Z
        )

    end
})

Tab:Slider({
    Title = "Words Offset Z",
    Step = 1,

    Value = {
        Min = -50,
        Max = 50,
        Default = 0,
    },

    Callback = function(Value)

        Telekinesis.WordsOffset = Vector3.new(
            Telekinesis.WordsOffset.X,
            Telekinesis.WordsOffset.Y,
            Value
        )

    end
})

--//==================================================
--// NETWORK CONFIG
--//==================================================

local NetworkConfigSection = Tab:Section({
    Title = "Network Config"
})

Tab:Slider({
    Title = "Ownership Radius (More = More Lag)",
    Step = 500,

    Value = {
        Min = 1000,
        Max = 20000,
        Default = 5000,
    },

    Callback = function(Value)
        Network.SimulationRadius = Value
    end
})

--//==================================================
--// INIT
--//==================================================

for _, Instance in ipairs(Workspace:GetDescendants()) do

    if Instance:IsA("BasePart") then
        Network.BaseParts[Instance] = true
    end

end

--//==================================================
--// EVENTS
--//==================================================

Workspace.DescendantAdded:Connect(function(Instance)

    if Instance:IsA("BasePart") then
        Network.BaseParts[Instance] = true
    end

end)

Workspace.DescendantRemoving:Connect(function(Instance)

    if Instance:IsA("BasePart") then
        Network.BaseParts[Instance] = nil
    end

end)

--//==================================================
--// LOOPS
--//==================================================

local T = 0
local StarProgress = {}
local CollisionRestarted = false

RunService.Heartbeat:Connect(function(Dt)

    if not Telekinesis.Enabled then
        if not CollisionRestarted then
            local BaseParts = Network.BaseParts
            
            for Part,_ in pairs(BaseParts) do
                
                if IsAPlayerInstance(Part) then
                    continue
                end
                
                if not OwnedPart(Part) then
                    continue
                end
                
                if Part:IsDescendantOf(Workspace) then
                    Part.CanCollide = true
                end
                
                
            end
            
            CollisionRestarted = true
        end
        return
    end
    
    CollisionRestarted = false

    T += Dt

    --// Simulation radius
    if sethiddenproperty then

        pcall(function()
            sethiddenproperty(
                Client,
                "MaximumSimulationRadius",
                Network.SimulationRadius
            )
        end)

        pcall(function()
            sethiddenproperty(
                Client,
                "MaxSimulationRadius",
                Network.SimulationRadius
            )
        end)

        pcall(function()
            sethiddenproperty(
                Client,
                "SimulationRadius",
                Network.SimulationRadius
            )
        end)
        
        for i,Player in ipairs(Players:GetPlayers()) do
            if Player ~= Client then
                pcall(function()
                    sethiddenproperty(Player,"MaximumSimulationRadius",0.01)
                end)
                pcall(function()
                    sethiddenproperty(Player,"MaxSimulationRadius",0.01)
                end)
                pcall(function()
                    sethiddenproperty(Player,"SimulationRadius",0.01)
                end)
            end
        end
        
        pcall(function()
            Client.ReplicationFocus = Workspace
        end)
        
        pcall(function()
            settings().Physics.AllowSleep = false
        end)
        
        pcall(function()
            sethiddenproperty(game,"NetworkSleepMaxTime",0/0)
        end)
        
        pcall(function()
            sethiddenproperty(game,"NetworksReplicatorPriority",99999999)
        end)
        
        pcall(function()
            sethiddenproperty(game,"NetworkOwnershipAutoClaim",false)
        end)
        
        pcall(function()
            sethiddenproperty(game,"NetworkWaitTime",0/0)
        end)
        
        pcall(function()
            settings().Physics.PhysicsEnvironmentalThrottle =
    Enum.EnvironmentalPhysicsThrottle.Disabled
        end)
    end

    --// Network
    local BaseParts = Network.BaseParts
    local NetworkVelocity = Network.NetworkVelocity
    local Mode = Telekinesis.Mode

    --// Ring
    local RingRadius = Telekinesis.RingRadius
    local RingSpeed = Telekinesis.RingSpeed

    --// Mouse
    local MouseDistance = Telekinesis.MouseDistance
    local MouseSpeed = Telekinesis.MouseSpeed

    --// Data
    local ControlledParts = 0
    local Amount = 0

    --// Count controlled Parts
    for Part, _ in pairs(BaseParts) do

        if IsAPlayerInstance(Part) then
            continue
        end

        if not OwnedPart(Part) then

            SetOwner(
                Part,
                T,
                NetworkVelocity
            )

            continue
        end

        Amount += 1
    end

    --// No Parts
    if Amount <= 0 then
        return
    end

    --// Generate Word Targets
    if Mode == "Words" then

        if LastWordText ~= Telekinesis.WordsText
            or LastWordSize ~= Telekinesis.WordsSize
            or LastWordSpacing ~= Telekinesis.WordsLetterSpacing
            or #WordTargets ~= Amount then

            LastWordText = Telekinesis.WordsText
            LastWordSize = Telekinesis.WordsSize
            LastWordSpacing = Telekinesis.WordsLetterSpacing

            WordTargets = GenerateWordTargets(
                Telekinesis.WordsText,
                Amount,
                Telekinesis.WordsSize,
                Telekinesis.WordsLetterSpacing
            )

        end
    end

    --// Control Parts
    for Part, _ in pairs(BaseParts) do

        if IsAPlayerInstance(Part) then
            continue
        end
        
        

        if not OwnedPart(Part) then

            SetOwner(
                Part,
                T,
                NetworkVelocity
            )

            continue
        end

        ControlledParts += 1

        Part.Velocity = Vector3.new(
            0,
            -NetworkVelocity,
            0
        )

        local RootPart = GetPlayerInstance(
            Client,
            "HumanoidRootPart"
        )

        if not RootPart then
            continue
        end
        
        local Distance = (RootPart.Position - Part.Position).Magnitude
        
        if Distance >= 1000 then
            continue
        end

        --//==================================================
        --// RING
        --//==================================================
        
        Part.CanCollide = false

        if Mode == "Ring" then
            

            local Angle =
                (2 * math.pi / Amount)
                * ControlledParts
                + T * RingSpeed

            local X =
                math.sin(Angle)
                * RingRadius

            local Z =
                math.cos(Angle)
                * RingRadius

            Part.CFrame =
                RootPart.CFrame
                * CFrame.new(
                    Telekinesis.RingOffset
                )
                * CFrame.new(
                    X,
                    0,
                    Z
                )
        end

        --//==================================================
        --// MOUSE
        --//==================================================

        if Mode == "Mouse" then

            local Mouse = Client:GetMouse()
            local Camera = Workspace.CurrentCamera

            if not Mouse then
                continue
            end

            if not Camera then
                continue
            end

            local MousePosition =
                Mouse.Hit.Position

            local CameraPosition =
                Camera.CFrame.Position

            local Difference =
                MousePosition
                - CameraPosition

            if Difference.Magnitude <= 0 then
                continue
            end

            local Direction =
                Difference.Unit

            local Lerp =
                Part.CFrame:Lerp(
                    CFrame.new(
                        CameraPosition
                        + Direction
                        * MouseDistance
                    ),
                    math.clamp(
                        MouseSpeed / 100,
                        0.01,
                        1
                    )
                )

            Part.CFrame = Lerp
        end

--//==================================================
--// STAR
--//==================================================

if Mode == "Star" then

    local StarRadius =
        Telekinesis.StarRadius or 25

    local StarInnerRadius =
        Telekinesis.StarInnerRadius or 10

    local StarSpeed =
        Telekinesis.StarSpeed or 1

    --// 5-point star = 10 vertices
    local PointCount = 10

    --// Generate the 10 vertices
    local StarPoints = {}

    for Index = 0, PointCount - 1 do

        local Angle =
            (Index / PointCount)
            * math.pi * 2
            - math.pi / 2

        local Radius =
            if Index % 2 == 0
            then StarRadius
            else StarInnerRadius

        StarPoints[Index + 1] =
            Vector3.new(
                math.cos(Angle) * Radius,
                0,
                math.sin(Angle) * Radius
            )
    end

    --// Calculate the length of every segment
    local SegmentLengths = {}
    local TotalLength = 0

    for Index = 1, PointCount do

        local NextIndex =
            (Index % PointCount) + 1

        local Length =
            (StarPoints[NextIndex]
            - StarPoints[Index]).Magnitude

        SegmentLengths[Index] = Length
        TotalLength += Length
    end

    --// Position of this Part along the complete perimeter
    local BaseProgress =
        (ControlledParts - 1)
        / math.max(Amount, 1)

    local Progress =
        (
            BaseProgress
            + T * StarSpeed / TotalLength
        ) % 1

    --// Distance along the complete star
    local Distance =
        Progress * TotalLength

    --// Find which segment we're currently on
    local CurrentDistance = 0
    local Segment = 1

    for Index = 1, PointCount do

        local SegmentLength =
            SegmentLengths[Index]

        if Distance <=
            CurrentDistance + SegmentLength then

            Segment = Index
            break
        end

        CurrentDistance += SegmentLength
    end

    local NextSegment =
        (Segment % PointCount) + 1

    --// Interpolation inside the segment
    local SegmentLength =
        SegmentLengths[Segment]

    local Alpha =
        (Distance - CurrentDistance)
        / SegmentLength

    Alpha =
        math.clamp(
            Alpha,
            0,
            1
        )

    --// Get position
    local A =
        StarPoints[Segment]

    local B =
        StarPoints[NextSegment]

    local Position =
        A:Lerp(B, Alpha)

    --// Move relative to player
    Position =
        RootPart.Position
        + Position

    Part.CFrame =
        CFrame.new(Position)
end

        --//==================================================
        --// INVERT GRAVITY
        --//==================================================

        if Mode == "Invert Gravity" then

            local Force =
                Telekinesis.GravityForce

            Part.Velocity = Vector3.new(
                    0,
                    Force,
                    0
                )

            Part.Massless = true
            Part.CanTouch = false
            Part.CanQuery = false
        end

        --//==================================================
        --// WORDS
        --//==================================================

        if Mode == "Words" then
            

            local Target =
                WordTargets[ControlledParts]

            if Target then

                local Size =
                    Telekinesis.WordsSize

                --// Origin follows the player
                --// Offset is relative to the player's
                --// HumanoidRootPart orientation.
                local Origin =
                    RootPart.Position
                    + RootPart.CFrame.RightVector
                    * Telekinesis.WordsOffset.X
                    + Vector3.new(
                        0,
                        Telekinesis.WordsOffset.Y,
                        0
                    )
                    + RootPart.CFrame.LookVector
                    * Telekinesis.WordsOffset.Z

                local Position =
                    Origin

                    + RootPart.CFrame.RightVector
                    * (-Target.X * Size)

                    + Vector3.new(
                        0,
                        Target.Y * Size,
                        0
                    )

                Part.CFrame =
                    CFrame.new(Position)
            end
        end
        
        if Mode == "Black Hole" then
            local Force = Telekinesis.BlackHoleForce
            
            local RootPart = GetPlayerInstance(Client,"HumanoidRootPart")
            
            if not RootPart then
                continue
            end
            
            local TargetCFrame = RootPart.CFrame * CFrame.new(math.random(-5,5),math.random(-5,5),math.random(-5,5))
            
            Part.CFrame = TargetCFrame
            Part.CFrame = Part.CFrame * CFrame.Angles(math.rad(math.random(0,360)),math.rad(math.random(0,360)),math.rad(math.random(0,360)))
            
        end
        
    end
end)

UserInputService.InputBegan:Connect(function(Input,Game)
    if Input.UserInputType == Enum.UserInputType.MouseWheel then
        if not Input then
            return
        end
        
        local Up = (Input.Position.Z > 0 and true) or (Input.Position.Z < 0 and false)
        
        if Up then
            Telekinesis.MouseDistance += 1
        else
            Telekinesis.MouseDistance -= 1
        end
        
    end
end)

print("Part")