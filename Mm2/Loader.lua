local Url = "https://raw.githubusercontent.com/NyxMods000/NyxModsUniversal/refs/heads/main/Mm2/Source.lua"

local Request = (syn and syn.request) or http_request or (http and http.request)

if Request then
 local Response = Request({
  Url = Url,
  Method = "GET",
 })

if Response then
 local Code = Response and Response.Body
 
 pcall(function()
  loadstring(Code)()
  return
 end)
 
 if Code then
  return
 end
end
end

loadstring(game:HttpGet(Url))()