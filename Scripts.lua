local NyxModsUniversal = getgenv().NyxModsUniversal
local Window = NyxModsUniversal.Window

local Config = {
  Scripts = {
    ["Infinite yield"] = "https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source",
    ["Dex"] = "https://rawscripts.net/raw/Universal-Script-DeX-Explorer-114771",
    ["Fly"] = "https://pastefy.app/TOXICU4j/raw",
    ["Invisible"] = "https://rawscripts.net/raw/Universal-Script-Fe-invisible-script-237876",
    ["Shift lock"] = "https://rawscripts.net/raw/Universal-Script-Shiftlock-by-namsobased-88371",
    ["AFEM (Emotes R15)"] = "https://rawscripts.net/raw/Universal-Script-AFEM-Max-Open-Alpha-50210",
    ["Ghost Hub"] = "https://raw.githubusercontent.com/GhostPlayer352/Test4/main/GhostHub",
    ["Cobalt (Remote spy)"] = "https://github.com/notpoiu/cobalt/releases/latest/download/Cobalt.luau",
    ["Pshade (Shader)"] = "https://raw.githubusercontent.com/randomstring0/pshade-ultimate/refs/heads/main/src/cd.lua",
    ["Simple shader"] = "https://raw.githubusercontent.com/p0e1/1/refs/heads/main/SimpleShader.lua",
    ["Fps booster"] = "https://rawscripts.net/raw/Universal-Script-Anti-Lag-Script-Open-Source-129466",
    ["Mobile keyboard"] = "https://rawscripts.net/raw/Universal-Script-Mobile-Keyboard-44308",
  }
}

local Tab = Window:CreateTab("Scripts")
local Section = Tab:CreateSection("Scripts")

for Name,Url in pairs(Config.Scripts) do
  if Url ~= "" then
    Tab:CreateButton({
    Name = tostring(Name),
    Callback = function()
        loadstring(game:HttpGet(Url))()
    end
    })
  end
end