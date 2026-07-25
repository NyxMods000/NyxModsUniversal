local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/pruebasjoao/test/refs/heads/main/JmodsLibV1.0'))()

getgenv().NyxModsUniversal = {
  Version = "1.0.0",
  Window = nil,
  TabsOrder = {
    "Home",
    "Movement",
    "Troll",
    "Visuals",
    "Combat",
    "Misc"
  },
  TabsUrl = {
    Home = "https://raw.githubusercontent.com/NyxMods000/NyxModsUniversal/refs/heads/main/Home.lua",
    Movement = "https://raw.githubusercontent.com/NyxMods000/NyxModsUniversal/refs/heads/main/Movement.lua",
    Troll = "https://raw.githubusercontent.com/NyxMods000/NyxModsUniversal/refs/heads/main/Troll.lua",
    Visuals = "https://raw.githubusercontent.com/NyxMods000/NyxModsUniversal/refs/heads/main/Visuals.lua",
    Combat = "",
    Misc = ""
  }
}

local NyxModsUniversal = getgenv().NyxModsUniversal

NyxModsUniversal.Window = Library:CreateWindow({
  Name = "NyxMods Universal",
  Icon = 86507528059862,
  LoadingTitle = "Cargando... espera...",
  LoadingSubtitle = "ya casi está",
  Theme = "neon_indigo",
  OpenButtomImage = 86507528059862,
  Intro = true,
  IntroIcon = 86507528059862,
  AnimationIntro = 3,
  DragImage = 86507528059862
})

task.wait(10)

for _,v in ipairs(NyxModsUniversal.TabsOrder) do
  local Executed, Error = pcall(function()
    local Url = NyxModsUniversal.TabsUrl[v]
    if Url ~= "" then
    loadstring(game:HttpGet(Url))()
    task.wait(5)
    else
      print(tostring(v) .." doesn't have a URL")
    end
  end)
  if not Executed then
    print("Failed to execute: " .. tostring(v) .. "\nError: " .. Error)
  else
    print(tostring(v) .. " Executed successfully")
  end
end
