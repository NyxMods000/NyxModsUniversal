local NyxModsUniversal = getgenv().NyxModsUniversal
local Version = NyxModsUniversal.Version
local Window = NyxModsUniversal.Window


local Home = Window:CreateTab("Home")

local WelcomeSection = Home:CreateSection("Welcome")

Home:CreateParagraph({
    Title = "Welcome to NyxMods Universal!",
    Content = "Thanks for using NyxMods Universal.\nI hope you enjoy the hub! 💜💚"
})

local ScriptInfoSection = Home:CreateSection("Script info")

Home:CreateParagraph({
    Title = "Hub Info",
    Content = "Version: "..Version.."\nStatus: Stable\nGame: Universal\nDeveloper: NyxMods"
})

Home:CreateParagraph({
    Title = "Changelog",
    Content = "Version: "..Version.."\nInitial release\nHome tab"
})

local SocialSection = Home:CreateSection("Social")

Home:CreateButton({
  Name = "Copy discord link",
  Callback = function()
    setclipboard("")
  end
})

Home:CreateButton({
  Name = "Copy whatsapp link",
  Callback = function()
    setclipboard("")
  end
})

Home:CreateButton({
  Name = "Copy youtube link",
  Callback = function()
    setclipboard("")
  end
})

local CreditsSection = Home:CreateSection("Credits")

Home:CreateParagraph({
    Title = "Credits to:",
    Content = "Developer: NyxMods"
})

local ComingSoonSection = Home:CreateSection("ComingSoon")

Home:CreateParagraph({
    Title = "Coming soon",
    Content = "✓ More Universal Features\n✓ Better UI\n✓ Game Support\n✓ Performance Improvements"
})
