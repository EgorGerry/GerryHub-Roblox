if _G.IntrudersHubLoaded then
local oldGui = game:GetService("CoreGui"):FindFirstChild("IntrudersHubMenu") or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("IntrudersHubMenu")
if oldGui then oldGui:Destroy() end
end
_G.IntrudersHubLoaded = true
_G.ESP_Enabled = false
_G.SearchableESP_Enabled = false
_G.GeneratorESP_Enabled = false
_G.Fullbright_Enabled = false
_G.NoClip_Enabled = false
_G.Fly_Enabled = false
_G.CameraUnlock_Enabled = false
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local localPlayer = Players.LocalPlayer
local monsterName = "Monster"
local targetGui = (gethui and gethui()) or game:GetService("CoreGui") or localPlayer:WaitForChild("PlayerGui")
local function showNotification(titleText, descText)
local NotifFrame = Instance.new("Frame")
NotifFrame.Name = "GerryNotif"
NotifFrame.Size = UDim2.new(0, 250, 0, 70)
NotifFrame.Position = UDim2.new(1, 30, 0, 20)
NotifFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
NotifFrame.BorderSizePixel = 0
NotifFrame.Parent = targetGui
local NotifCorner = Instance.new("UICorner")
NotifCorner.CornerRadius = UDim.new(0, 8)
NotifCorner.Parent = NotifFrame
local NotifStroke = Instance.new("UIStroke")
NotifStroke.Color = Color3.fromRGB(0, 185, 255)
NotifStroke.Thickness = 1.5
NotifStroke.Parent = NotifFrame
local NotifTitle = Instance.new("TextLabel")
NotifTitle.Size = UDim2.new(1, -20, 0, 30)
NotifTitle.Position = UDim2.new(0, 10, 0, 5)
NotifTitle.BackgroundTransparency = 1
NotifTitle.Text = titleText
NotifTitle.TextColor3 = Color3.fromRGB(0, 185, 255)
NotifTitle.Font = Enum.Font.SourceSansBold
NotifTitle.TextSize = 16
NotifTitle.TextXAlignment = Enum.TextXAlignment.Left
NotifTitle.Parent = NotifFrame
local NotifDesc = Instance.new("TextLabel")
NotifDesc.Size = UDim2.new(1, -20, 0, 30)
NotifDesc.Position = UDim2.new(0, 10, 0, 30)
NotifDesc.BackgroundTransparency = 1
NotifDesc.Text = descText
NotifDesc.TextColor3 = Color3.fromRGB(230, 230, 230)
NotifDesc.Font = Enum.Font.SourceSans
NotifDesc.TextSize = 14
NotifDesc.TextXAlignment = Enum.TextXAlignment.Left
NotifDesc.Parent = NotifFrame
TweenService:Create(NotifFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2.new(1, -270, 0, 20)}):Play()
task.delay(4, function()
local hideTween = TweenService:Create(NotifFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Position = UDim2.new(1, 30, 0, 20)})
hideTween:Play()
hideTween.Completed:Connect(function()
NotifFrame:Destroy()
end)
end)
end
showNotification("Gerry Hub v1.1", "Скрипт успешно запущен!")
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "IntrudersHubMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = targetGui
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 220, 0, 385)
MainFrame.Position = UDim2.new(0, 40, 0, 150)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
Title.Text = "  Gerry Hub v1.1 | Intruders"
Title.TextColor3 = Color3.fromRGB(0, 185, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 15
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame
local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = Title
local CollapseButton = Instance.new("TextButton")
CollapseButton.Size = UDim2.new(0, 30, 0, 30)
CollapseButton.Position = UDim2.new(1, -35, 0, 7)
CollapseButton.BackgroundTransparency = 1
CollapseButton.Text = "_"
CollapseButton.TextColor3 = Color3.fromRGB(200, 200, 200)
CollapseButton.Font = Enum.Font.SourceSansBold
CollapseButton.TextSize = 22
CollapseButton.Parent = MainFrame
local OpenButton = Instance.new("TextButton")
OpenButton.Size = UDim2.new(0, 80, 0, 35)
OpenButton.Position = UDim2.new(0, 15, 0, 15)
OpenButton.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
OpenButton.Text = "Open Hub"
OpenButton.TextColor3 = Color3.fromRGB(0, 185, 255)
OpenButton.Font = Enum.Font.SourceSansBold
OpenButton.TextSize = 14
OpenButton.Visible = false
OpenButton.Parent = ScreenGui
local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(0, 8)
OpenCorner.Parent = OpenButton
CollapseButton.MouseButton1Click:Connect(function()
MainFrame.Visible = false
OpenButton.Visible = true
end)
OpenButton.MouseButton1Click:Connect(function()
MainFrame.Visible = true
OpenButton.Visible = false
end)
local function createToggle(name, text, yPos, callback)
local Button = Instance.new("TextButton")
Button.Name = name
Button.Size = UDim2.new(0, 200, 0, 35)
Button.Position = UDim2.new(0, 10, 0, yPos)
Button.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
Button.Text = text .. " [OFF]"
Button.TextColor3 = Color3.fromRGB(240, 70, 70)
Button.Font = Enum.Font.SourceSansBold
Button.TextSize = 14
Button.Parent = MainFrame
local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 6)
BtnCorner.Parent = Button
local enabled = false
Button.MouseButton1Click:Connect(function()
enabled = not enabled
if enabled then
Button.BackgroundColor3 = Color3.fromRGB(50, 90, 60)
Button.Text = text .. " [ON]"
Button.TextColor3 = Color3.fromRGB(80, 255, 80)
else
Button.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
Button.Text = text .. " [OFF]"
Button.TextColor3 = Color3.fromRGB(240, 70, 70)
end
callback(enabled)
end)
end
RunService.RenderStepped:Connect(function()
if _G.CameraUnlock_Enabled and localPlayer then
localPlayer.CameraMode = Enum.CameraMode.Classic
localPlayer.CameraMinZoomDistance = 0.5
localPlayer.CameraMaxZoomDistance = 500
end
end)
createToggle("TglCam", "Zoom Lock", 55, function(bool)
_G.CameraUnlock_Enabled = bool
if not bool and localPlayer then
localPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
end
end)
local function updateMonsterESP()
local monster = Workspace:FindFirstChild(monsterName)
if monster and _G.ESP_Enabled then
if not monster:FindFirstChild("Intruders_MonsterESP") then
local hl = Instance.new("Highlight")
hl.Name = "Intruders_MonsterESP"
hl.FillColor = Color3.fromRGB(255, 0, 50)
hl.FillTransparency = 0.3
hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
hl.Parent = monster
end
else
if monster then
local hl = monster:FindFirstChild("Intruders_MonsterESP")
if hl then hl:Destroy() end
end
end
end
Workspace.ChildAdded:Connect(function() task.wait(0.2) updateMonsterESP() end)
createToggle("TglMonster", "Monster ESP", 100, function(bool)
_G.ESP_Enabled = bool
updateMonsterESP()
end)
local activeConnections = {}
local processedModels = {}
local function clearSearchableESP()
for _, connection in ipairs(activeConnections) do
if connection then connection:Disconnect() end
end
activeConnections = {}
processedModels = {}
local descendants = Workspace:GetDescendants()
for i = 1, #descendants do
local hl = descendants[i]:FindFirstChild("Strict_Search_Highlight")
if hl then hl:Destroy() end
end
end
local function processModelESP(model)
if not model:IsA("Model") or string.sub(model.Name, 1, 10) ~= "Searchable" then return end
if processedModels[model] then return end
processedModels[model] = true
local prompt = model:FindFirstChild("SearchPrompt", true) or model:FindFirstChildWhichIsA("ProximityPrompt", true)
local function checkPromptState()
local existingHighlight = model:FindFirstChild("Strict_Search_Highlight")
if prompt and (not prompt.Parent or prompt.ActionText == "Empty") then
if existingHighlight then existingHighlight:Destroy() end
if prompt and prompt.Parent then prompt:Destroy() end
return
end
if _G.SearchableESP_Enabled and prompt and prompt.Enabled then
if not existingHighlight then
local hl = Instance.new("Highlight")
hl.Name = "Strict_Search_Highlight"
hl.FillColor = Color3.fromRGB(0, 160, 255)
hl.FillTransparency = 0.4
hl.OutlineColor = Color3.fromRGB(255, 255, 255)
hl.OutlineTransparency = 0
hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
hl.Parent = model
end
else
if existingHighlight then existingHighlight:Destroy() end
end
end
if prompt then
checkPromptState()
local changedSignal = prompt:GetPropertyChangedSignal("ActionText"):Connect(checkPromptState)
local enabledSignal = prompt:GetPropertyChangedSignal("Enabled"):Connect(checkPromptState)
table.insert(activeConnections, changedSignal)
table.insert(activeConnections, enabledSignal)
end
end
createToggle("TglSearch", "Searchable Items ESP", 145, function(bool)
_G.SearchableESP_Enabled = bool
if bool then
local descendants = Workspace:GetDescendants()
for i = 1, #descendants do
processModelESP(descendants[i])
end
local addedConnection = Workspace.DescendantAdded:Connect(function(descendant)
if _G.SearchableESP_Enabled then
processModelESP(descendant)
end
end)
table.insert(activeConnections, addedConnection)
else
clearSearchableESP()
end
end)
local function updateGeneratorESP()
local container = Workspace:FindFirstChild("BlackoutGenerators")
if container then
local generators = container:GetChildren()
for i = 1, #generators do
local gen = generators[i]
local existingHighlight = gen:FindFirstChild("Generator_Highlight")
if _G.GeneratorESP_Enabled then
if not existingHighlight then
local hl = Instance.new("Highlight")
hl.Name = "Generator_Highlight"
hl.FillColor = Color3.fromRGB(235, 180, 0)
hl.FillTransparency = 0.4
hl.OutlineColor = Color3.fromRGB(255, 255, 255)
hl.OutlineTransparency = 0
hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
hl.Parent = gen
end
else
if existingHighlight then existingHighlight:Destroy() end
end
end
end
end
createToggle("TglGenerator", "Generator ESP", 190, function(bool)
_G.GeneratorESP_Enabled = bool
updateGeneratorESP()
end)
local originalEffects = {}
local effectNames = {"IntrudersBloom", "IntrudersDof", "IntrudersGrade"}
RunService.RenderStepped:Connect(function()
if _G.Fullbright_Enabled then
Lighting.Brightness = 2
Lighting.ClockTime = 14
Lighting.GlobalShadows = false
Lighting.Ambient = Color3.fromRGB(255, 255, 255)
Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
for _, name in ipairs(effectNames) do
local fx = Lighting:FindFirstChild(name)
if fx and (fx:IsA("PostEffect") or fx:IsA("DepthOfFieldEffect") or fx:IsA("BloomEffect") or fx:IsA("ColorCorrectionEffect")) then
if fx.Enabled then
originalEffects[name] = true
fx.Enabled = false
end
end
end
end
end)
createToggle("TglFB", "Fullbright + AntiBlur", 235, function(bool)
_G.Fullbright_Enabled = bool
if not bool then
Lighting.GlobalShadows = true
Lighting.Ambient = Color3.fromRGB(0, 0, 0)
for _, name in ipairs(effectNames) do
local fx = Lighting:FindFirstChild(name)
if fx and originalEffects[name] then fx.Enabled = true end
end
end
end)
RunService.Stepped:Connect(function()
if _G.NoClip_Enabled and localPlayer.Character then
local targetParts = localPlayer.Character:GetChildren()
for i = 1, #targetParts do
local part = targetParts[i]
if part:IsA("BasePart") then part.CanCollide = false end
end
end
end)
createToggle("TglNC", "Noclip", 280, function(bool)
_G.NoClip_Enabled = bool
if not bool and localPlayer.Character then
local targetParts = localPlayer.Character:GetChildren()
for i = 1, #targetParts do
local part = targetParts[i]
if part:IsA("BasePart") then part.CanCollide = true end
end
end
end)
local flySpeed = 45
local flyForceInstance = nil
createToggle("TglFly", "Fly Mode", 325, function(bool)
_G.Fly_Enabled = bool
local char = localPlayer.Character
local hrp = char and char:FindFirstChild("HumanoidRootPart")
local hum = char and char:FindFirstChild("Humanoid")
if bool then
if hum then hum.PlatformStand = true end
if hrp then
flyForceInstance = Instance.new("BodyVelocity")
flyForceInstance.Name = "IntrudersFlyForce"
flyForceInstance.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
flyForceInstance.Velocity = Vector3.new(0, 0, 0)
flyForceInstance.Parent = hrp
end
else
if hum then hum.PlatformStand = false end
if flyForceInstance then flyForceInstance:Destroy() flyForceInstance = nil end
if hrp then hrp.Velocity = Vector3.new(0, 0, 0) end
end
end)
RunService.RenderStepped:Connect(function()
if _G.Fly_Enabled and localPlayer.Character and flyForceInstance then
local camera = Workspace.CurrentCamera
local moveDirection = Vector3.new(0, 0, 0)
if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDirection = moveDirection + camera.CFrame.LookVector end
if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDirection = moveDirection - camera.CFrame.LookVector end
if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDirection = moveDirection - camera.CFrame.RightVector end
if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDirection = moveDirection + camera.CFrame.RightVector end
if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDirection = moveDirection + Vector3.new(0, 1, 0) end
if moveDirection.Magnitude > 0 then
flyForceInstance.Velocity = moveDirection.Unit * flySpeed
else
flyForceInstance.Velocity = Vector3.new(0, 0, 0)
end
end
end)
