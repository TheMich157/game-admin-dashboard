local HttpService = game:GetService("HttpService")
local url = "http://localhost:3000/api/banstatus/" .. username

local response = HttpService:GetAsync(url)
local data = HttpService:JSONDecode(response)
if data.banned then
    print(username .. " is banned")
else
    print(username .. " is not banned")
end
