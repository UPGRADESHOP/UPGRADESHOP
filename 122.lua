if getgenv().nexus then return end 

local HttpService = game:GetService("HttpService")
local fileName = "FLORENCE/SETTINGS/" .. game.PlaceId .. '.txt'
getgenv().settings = {}
getgenv().nexus = true

if isfile("FLORENCE/SETTINGS/" .. game.PlaceId .. '.txt') then
    local sl, er = pcall(function()
        getgenv().settings = game:GetService('HttpService'):JSONDecode(readfile("FLORENCE/SETTINGS/" .. game.PlaceId .. '.txt'))
    end)
    if er ~= nil then
        forceServerHop()
        return
    end
end 

writefile("FLORENCE/SETTINGS/" .. game.PlaceId .. '.txt', HttpService:JSONEncode(getgenv().settings))

function forceServerHop()
    local Api = "https://games.roblox.com/v1/games/"
    local placeId, jobId = game.PlaceId, game.JobId
    local serversUrl = Api .. placeId .. "/servers/Public?sortOrder=Desc&limit=100"

    local function ListServers(cursor)
        local raw = game:HttpGet(serversUrl .. (cursor and "&cursor=" .. cursor or ""))
        return HttpService:JSONDecode(raw)
    end

    local nextCursor
    repeat
        local serversData = ListServers(nextCursor)
        for _, server in ipairs(serversData.data) do
            if server.playing < server.maxPlayers and server.id ~= jobId then
                local success, result = pcall(TeleportService.TeleportToPlaceInstance, TeleportService, placeId, server.id, LocalPlayer)
                if success then
                    break
                end
            end
        end
        nextCursor = serversData.nextPageCursor
    until not nextCursor
end

local myEvent = Instance.new("BindableEvent")
local connection = myEvent.Event:Connect(function()
end)

local function createLoop(callback)
    return spawn(function()
        while task.wait() do
            if connection.Connected == true then
                local success, result = pcall(function() 
                    callback()
                end)
            end
        end
    end)
end

createLoop(function()
    for key, value in pairs(getgenv().settings) do
	if connection.Connected == true and getgenv().settings.AutoSave == true then 
        getgenv().settings[key] = value
        writefile(fileName, HttpService:JSONEncode(getgenv().settings))
		end
    end
end)

local Fluent = loadstring(game:HttpGet("https://github.com/13B8B/nexus/releases/download/nexus/nexus.txt"))()
--[[
   premium = true
]]

local Window = Fluent:CreateWindow({
    Title = "DACKSHOP - universal ", "",
    SubTitle = "",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
})

local Tabs = {
    Main = Window:AddTab({
        Title = "Main",
        Icon = "rbxassetid://10723424505"
    }),
    Settings = Window:AddTab({
        Title = "Settings",
        Icon = "settings"
    }),
        Premium = premium == "premium" and Window:AddTab({
        Title = "Premium",
        Icon = "rbxassetid://10709819149"
    }),

}

Tabs.Main:AddParagraph({
    Title = "DACKSHOP Universal",
    Content = "Welcome to DACKSHOP Universal!\n\nWe're excited to introduce the upcoming Universal script to enhance your experience. Currently in development, this script is designed to bring you a host of new features and improvements.\n\nOur dedicated team is working diligently to make this script a reality. While it's not ready just yet, we're making great progress.\n\nStay tuned for updates, and thank you for your patience and support! https://discord.gg/KHKu84ZyhD"
})

local KeyBindName = getgenv().settings.KeyBind or ""

local Keybind = Tabs.Settings:AddKeybind("Keybind", {
    Title = "KeyBind",
    Mode = "Toggle",
    Default = KeyBindName,
    ChangedCallback = function(New)
        KeyBindName = New.Name
        getgenv().settings.KeyBind = New.Name  
    end
})

game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessedEvent)
    local settingsKeyBind = getgenv().settings.KeyBind

    if input.KeyCode == Enum.KeyCode.Home or settingsKeyBind == input.KeyCode.Name then
        if game:GetService("CoreGui").ScreenGui.Frame.Visible then
            Fluent:Notify({Title = 'Window Minimized', Content = 'Press ' .. settingsKeyBind .. ' to Open the UI', Duration = 5 })
        end
        Window:Minimize() 
    end
end)

local Toggle = Tabs.Settings:AddToggle("Toggle", {
    Title = "Auto Save Settings",
    Default = getgenv().settings.AutoSave,
    Callback = function(value)
        getgenv().settings.AutoSave = value
        writefile(fileName, HttpService:JSONEncode(getgenv().settings))
    end
})

local Toggle = Tabs.Settings:AddToggle("Toggle", {
    Title = "Auto ReExecute",
    Default = getgenv().settings.AutoExecute,
    Callback = function(value)
    getgenv().settings.AutoExecute = value
     if getgenv().settings.AutoExecute then
            local queueteleport = (syn and syn.queue_on_teleport) or queue_on_teleport or (fluxus and fluxus.queue_on_teleport)
            if queueteleport then
                queueteleport('loadstring(game:HttpGet("https://raw.githubusercontent.com/13B8B/nexus/main/loadstring"))()')
            end
        end
    end
})

local Toggle = Tabs.Settings:AddToggle("Toggle", {
   Title = "Auto Rejoin",
   Default = getgenv().settings.AutoRejoin,
   Callback = function(value)
      getgenv().settings.AutoRejoin = value
      if getgenv().settings.AutoRejoin then
          Fluent:Notify({Title = 'Auto Rejoin', Content = 'You will rejoin if you are kicked or disconnected from the game', Duration = 5 })
          repeat task.wait() until game.CoreGui:FindFirstChild('RobloxPromptGui')
          local lp,po,ts = game:GetService('Players').LocalPlayer,game.CoreGui.RobloxPromptGui.promptOverlay,game:GetService('TeleportService')
          po.ChildAdded:connect(function(a)
              if a.Name == 'ErrorPrompt' then
                  while true do
                      ts:Teleport(game.PlaceId)
                      task.wait(2)
                  end
              end
          end)
      end
  end
})

Tabs.Settings:AddButton({
    Title = "Rejoin-Server",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, Player)
    end
})

Tabs.Settings:AddButton({
    Title = "Server-Hop", 
    Callback = function()
       local Http = game:GetService("HttpService")
        local TPS = game:GetService("TeleportService")
        local Api = "https://games.roblox.com/v1/games/"
        local _place,_id = game.PlaceId, game.JobId
        local _servers = Api.._place.."/servers/Public?sortOrder=Desc&limit=100"
        local function ListServers(cursor)
            local Raw = game:HttpGet(_servers .. ((cursor and "&cursor="..cursor) or ""))
            return Http:JSONDecode(Raw)
        end
        local Next; repeat
            local Servers = ListServers(Next)
            for i,v in next, Servers.data do
                if v.playing < v.maxPlayers and v.id ~= _id then
                    local s,r = pcall(TPS.TeleportToPlaceInstance,TPS,_place,v.id,Player)
                    if s then break end
                end
            end
            Next = Servers.nextPageCursor
        until not Next
    end
})

createLoop(function()
    if premium == "premium" then
        game.Players:Chat("DACKSHOP-premium")
    else task.wait(math.random(0.1, 1)) 
        game.Players:Chat("DACKSHOP-is-back")
    end
end)

----------// PREMIUM \\----------
Tab = premium == "premium" and Tabs.Premium:AddButton({
    Title = "Kick",
    Callback = function()
        game.Players:Chat(".k " .. getgenv().Selected)
    end 
})
Tab = premium == "premium" and Tabs.Premium:AddButton({
    Title = "Kill",
    Callback = function()
        game.Players:Chat(".r " .. getgenv().Selected)
    end
})
Tab = premium == "premium" and Tabs.Premium:AddButton({
    Title = "Teleport",
    Callback = function()
        game.Players:Chat(".b " .. getgenv().Selected)
    end
})
Tab = premium == "premium" and Tabs.Premium:AddButton({
    Title = "Shut Game Down",
    Callback = function()
        game.Players:Chat(".s " .. getgenv().Selected)
    end
})
Tab = premium == "premium" and Tabs.Premium:AddButton({
    Title = "Freeze",
    Callback = function()
        game.Players:Chat(".f " .. getgenv().Selected)
    end
})
Tab = premium == "premium" and Tabs.Premium:AddButton({
    Title = "Unfreeze",
    Callback = function()
        game.Players:Chat(".u " .. getgenv().Selected)
    end
})

task.spawn(function()
    while task.wait() do 
        local playersService = game:GetService("Players")
        local textChatService = game:GetService("TextChatService")
        local lplr = playersService.LocalPlayer
        local localPlayerNameWithoutUnderscores = lplr.Name:gsub("_", "")
        
        for _, player in ipairs(playersService:GetPlayers()) do
            player.Chatted:Connect(function(msg)
                local success, errorMessage = pcall(function()
                    local processedMsg = msg:gsub("_", "")
                    if processedMsg == ".k " .. localPlayerNameWithoutUnderscores then
                        game.Players.LocalPlayer:kick("DACKSHOP-premium user has kicked you")
                    elseif processedMsg == ".r " .. localPlayerNameWithoutUnderscores then
                        game.Players.LocalPlayer.Character.Humanoid.Health = 0
                    elseif processedMsg == ".b " .. localPlayerNameWithoutUnderscores then
                        game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame = workspace[player.Name].HumanoidRootPart.CFrame
                    elseif processedMsg == ".s " .. localPlayerNameWithoutUnderscores then
                        game:Shutdown()
                    elseif processedMsg == ".f " .. localPlayerNameWithoutUnderscores then
                        game.Players.LocalPlayer.Character.HumanoidRootPart.Anchored = true
                    elseif processedMsg == ".u " .. localPlayerNameWithoutUnderscores then
                        game.Players.LocalPlayer.Character.HumanoidRootPart.Anchored = false    
                    end  
                end)
            end) 
        end
        wait(1)  
    end 
end)
local nexus = {}
local updatedPlayers = {} 
local Dropdown

local function UpdateDropdownValues()
    if Dropdown then
        Dropdown:SetValues(nexus)
    end
end
local function RemovePlayer(player)
    for i, playerName in ipairs(nexus) do
        if playerName == player.Name then
            table.remove(nexus, i)
            updatedPlayers[player] = nil
            UpdateDropdownValues()
            break
        end
    end
end
game.Players.PlayerRemoving:Connect(function(player)
    RemovePlayer(player)
end)

task.spawn(function()
    while wait() do 
        for _, player in ipairs(game.Players:GetPlayers()) do
            player.Chatted:Connect(function(msg)
                if msg == "nexus-is-back" and not updatedPlayers[player] then
                    if not table.find(nexus, player.Name) and player ~= game.Players.LocalPlayer then
                        local playerNameWithoutUnderscores = player.Name:gsub("_", "")
                        table.insert(nexus, playerNameWithoutUnderscores)
                        print("Detected:", playerNameWithoutUnderscores)
                        updatedPlayers[player] = true  
                        UpdateDropdownValues() 
                    end
                end  
            end) 
        end
    end
end)

Dropdown = premium == "premium" and Tabs.Premium:AddDropdown("Dropdown", {
    Title = "Select DACKSHOP User",
    Values = DACKSHOP, 
    Multi = false,
    Default = "",
    Callback = function(value)
        getgenv().Selected = value
    end
})

Window:SelectTab(1)
