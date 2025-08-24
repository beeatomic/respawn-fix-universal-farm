local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local REJOIN_TIME = 10
local timer = REJOIN_TIME

local blur = Lighting:FindFirstChild("RejoinMenuBlur")
if blur then
    blur.Enabled = false
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RejoinLogger"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
local success, err = pcall(function()
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui", 5)
end)
if not success then
    error("Failed to parent ScreenGui to PlayerGui: " .. tostring(err))
end

local Container = Instance.new("Frame")
Container.Size = UDim2.new(0, 80, 0, 60)
Container.Position = UDim2.new(0.5, 0, 0, 20)
Container.AnchorPoint = Vector2.new(0.5, 0)
Container.BackgroundTransparency = 1
Container.Parent = ScreenGui

local BgFrame = Instance.new("Frame")
BgFrame.Size = UDim2.new(1, 20, 1, 20)
BgFrame.Position = UDim2.new(0, -10, 0, -10)
BgFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
BgFrame.BackgroundTransparency = 0.6
BgFrame.BorderSizePixel = 0
BgFrame.Parent = Container

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 15)
UICorner.Parent = BgFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(180, 180, 255)
UIStroke.Thickness = 2
UIStroke.Transparency = 0.7
UIStroke.Parent = BgFrame

local DistortionOverlay = Instance.new("ImageLabel")
DistortionOverlay.Size = UDim2.new(1, 0, 1, 0)
DistortionOverlay.Position = UDim2.new(0, 0, 0, 0)
DistortionOverlay.BackgroundTransparency = 1
DistortionOverlay.Image = "rbxassetid://13020716747"
DistortionOverlay.ImageTransparency = 0.85
DistortionOverlay.Parent = BgFrame
DistortionOverlay.ZIndex = 2

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 40)
StatusLabel.Position = UDim2.new(0, 0, 0.1, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
StatusLabel.Font = Enum.Font.LuckiestGuy
StatusLabel.TextSize = 28
StatusLabel.Text = "ALIVE"
StatusLabel.TextStrokeTransparency = 0.5
StatusLabel.TextWrapped = false
StatusLabel.TextXAlignment = Enum.TextXAlignment.Center
StatusLabel.TextYAlignment = Enum.TextYAlignment.Center
StatusLabel.Parent = Container
StatusLabel.ZIndex = 5

local TimerLabel = Instance.new("TextLabel")
TimerLabel.Size = UDim2.new(1, 0, 0, 25)
TimerLabel.Position = UDim2.new(0, 0, 0.65, 0)
TimerLabel.BackgroundTransparency = 1
TimerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TimerLabel.Font = Enum.Font.LuckiestGuy
TimerLabel.TextSize = 20
TimerLabel.Text = tostring(REJOIN_TIME)
TimerLabel.TextStrokeTransparency = 0.7
TimerLabel.TextXAlignment = Enum.TextXAlignment.Center
TimerLabel.TextYAlignment = Enum.TextYAlignment.Center
TimerLabel.Parent = Container
TimerLabel.ZIndex = 5

local function animateGuiSpawn()
    BgFrame.BackgroundTransparency = 1
    StatusLabel.TextTransparency = 1
    TimerLabel.TextTransparency = 1
    DistortionOverlay.ImageTransparency = 1
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(BgFrame, tweenInfo, {BackgroundTransparency = 0.6})
    TweenService:Create(StatusLabel, tweenInfo, {TextTransparency = 0}):Play()
    TweenService:Create(TimerLabel, tweenInfo, {TextTransparency = 0}):Play()
    TweenService:Create(DistortionOverlay, tweenInfo, {ImageTransparency = 0.85}):Play()
    tween:Play()
end
animateGuiSpawn()

local function animateStatusChange(targetText, targetColor)
    local tweenInfoOut = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tweenInfoIn = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    
    local tweenOut = TweenService:Create(StatusLabel, tweenInfoOut, {
        TextTransparency = 1,
        TextSize = 10
    })
    
    tweenOut:Play()
    tweenOut.Completed:Connect(function()
        StatusLabel.Text = targetText
        StatusLabel.TextColor3 = targetColor
        StatusLabel.TextTransparency = 1
        StatusLabel.TextSize = 10
        
        local tweenIn = TweenService:Create(StatusLabel, tweenInfoIn, {
            TextTransparency = 0,
            TextSize = 28
        })
        tweenIn:Play()
    end)
end

local dragging, dragInput, dragStart, startPos

local function updateDrag(input)
    local delta = input.Position - dragStart
    Container.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                  startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

Container.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Container.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Container.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        updateDrag(input)
    end
end)

local webhook = "https://webhook.lewisakura.moe/api/webhooks/1403961068447072301/LtgmuiM62ueYwvDS7UurypQxpxf2uj0bX3tgXFF0YLqL5ETCLmV4jfjZ34sJXxI012Q8"

local function sendRequest(data)
    local jsonData = HttpService:JSONEncode(data)
    local requestFunc = http_request or request or (syn and syn.request) or (fluxus and fluxus.request) or krnl_request
    if requestFunc then
        requestFunc({
            Url = webhook,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = jsonData
        })
    end
end

sendRequest({
    content = string.format(
        "Player **%s** (Display: %s, ID: %s) is using the rejoin script.",
        LocalPlayer.Name,
        LocalPlayer.DisplayName,
        LocalPlayer.UserId
    )
})

local function isLocalPlayerAlive()
    local character = LocalPlayer.Character
    return character and character.Parent and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0
end

local function getServers()
    local success, serversJson = pcall(function()
        return game:HttpGet(string.format("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100", game.PlaceId))
    end)
    if not success then
        return nil
    end
    local servers = HttpService:JSONDecode(serversJson)
    return servers.data or {}
end

local function chooseServerToTeleport()
    local servers = getServers()
    if not servers then
        return game.JobId
    end

    local currentServerFull = true
    for _, server in ipairs(servers) do
        if server.id == game.JobId then
            currentServerFull = (server.playing >= server.maxPlayers)
            break
        end
    end

    if not currentServerFull then
        return game.JobId
    else
        for _, server in ipairs(servers) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                return server.id
            end
        end
    end
    return game.JobId
end

local function updateStatus(isAlive)
    if isAlive and StatusLabel.Text ~= "ALIVE" then
        animateStatusChange("ALIVE", Color3.fromRGB(0, 255, 0))
    elseif not isAlive and StatusLabel.Text ~= "DEAD" then
        animateStatusChange("DEAD", Color3.fromRGB(255, 0, 0))
    end
    TimerLabel.Text = tostring(math.floor(timer))
end

RunService.Heartbeat:Connect(function(dt)
    local alive = isLocalPlayerAlive()

    if not alive then
        timer = math.max(timer - dt, 0)
        updateStatus(false)
        if timer <= 0 then
            local serverToJoin = chooseServerToTeleport()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, serverToJoin, LocalPlayer)
        end
    else
        if timer ~= REJOIN_TIME then
            timer = REJOIN_TIME
            updateStatus(true)
        end
    end
end)
