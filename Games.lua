local NyxModsUniversal = getgenv().NyxModsUniversal
local Window = NyxModsUniversal.Window

local Config = {
  Scripts = {
    ["MM2 Yarhm"] = "https://rawscripts.net/raw/Universal-Script-YARHM-12403",
    ["99 night in the forest FoxName"] = "https://raw.githubusercontent.com/caomod2077/Script/refs/heads/main/FoxnameHub.lua",
    ["MM2 FoxName"] = "https://raw.githubusercontent.com/xv3gasx/Murder-Mystery-2/refs/heads/main/Release.lua",
    ["Animal hospital FoxName"] = "https://raw.githubusercontent.com/caomod2077/Script/refs/heads/main/FN_AnimalHospital.lua",
    ["KAT"] = "https://raw.githubusercontent.com/xv3gasx/KAT/refs/heads/main/main.lua",
    ["Sell Lemons (Key)"] = "https://raw.githubusercontent.com/Fluxyyy333/HoshiOnTop/main/loader.lua",
    ["Natural Disaster"] = "https://rawscripts.net/raw/Universal-Script-Fire-Hub-Solara-and-mobile-support-17673",
    ["Brookhaven"] = "https://raw.githubusercontent.com/KitUserss/DarkHub/refs/heads/main/carregamento",
    ["Build a boat (Key)"] = "https://raw.githubusercontent.com/TheRealAsu/BABFT/refs/heads/main/Loader.lua"
  }
}

local Tab = Window:CreateTab("Games")
local Section = Tab:CreateSection("Scripts for games")

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