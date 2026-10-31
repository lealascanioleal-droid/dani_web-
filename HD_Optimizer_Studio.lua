-- HD OPTIMIZER - LocalScript para Roblox Studio
-- Coloca este archivo como LocalScript en StarterPlayer > StarterPlayerScripts.
-- Los cambios son locales para el jugador y no modifican el servidor.

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Evita duplicar la interfaz si se ejecuta más de una vez.
local oldGui = playerGui:FindFirstChild("HDOptimizerGui")
if oldGui then
    oldGui:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "HDOptimizerGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = playerGui

local function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 10)
    c.Parent = parent
    return c
end

local function stroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or Color3.fromRGB(65, 115, 210)
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0
    s.Parent = parent
    return s
end

local function makeLabel(parent, text, size, position, font, color)
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextSize = size
    label.Font = font or Enum.Font.Gotham
    label.TextColor3 = color or Color3.fromRGB(235, 240, 255)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Position = position
    label.Size = UDim2.new(1, 0, 0, 24)
    label.Parent = parent
    return label
end

local panel = Instance.new("Frame")
panel.Name = "MainPanel"
panel.Size = UDim2.fromOffset(410, 440)
panel.Position = UDim2.new(0.5, -205, 0.5, -220)
panel.BackgroundColor3 = Color3.fromRGB(15, 19, 31)
panel.BorderSizePixel = 0
panel.Parent = gui
corner(panel, 16)
stroke(panel, Color3.fromRGB(70, 125, 235), 1.5, 0.15)

local top = Instance.new("Frame")
top.Size = UDim2.new(1, 0, 0, 62)
top.BackgroundColor3 = Color3.fromRGB(24, 34, 57)
top.BorderSizePixel = 0
top.Parent = panel
corner(top, 16)

local topCover = Instance.new("Frame")
topCover.Size = UDim2.new(1, 0, 0, 16)
topCover.Position = UDim2.new(0, 0, 1, -16)
topCover.BackgroundColor3 = top.BackgroundColor3
topCover.BorderSizePixel = 0
topCover.Parent = top

local title = makeLabel(top, "✦  HD OPTIMIZER", 20, UDim2.fromOffset(18, 9), Enum.Font.GothamBold)
title.Size = UDim2.new(1, -110, 0, 25)

local subtitle = makeLabel(top, "VISUAL QUALITY  •  PERFORMANCE", 9, UDim2.fromOffset(20, 34), Enum.Font.GothamMedium, Color3.fromRGB(145, 170, 220))
subtitle.Size = UDim2.new(1, -120, 0, 16)

local minimize = Instance.new("TextButton")
minimize.Size = UDim2.fromOffset(30, 28)
minimize.Position = UDim2.new(1, -72, 0, 16)
minimize.Text = "—"
minimize.TextSize = 18
minimize.Font = Enum.Font.GothamBold
minimize.TextColor3 = Color3.fromRGB(235, 240, 255)
minimize.BackgroundColor3 = Color3.fromRGB(47, 62, 92)
minimize.BorderSizePixel = 0
minimize.Parent = top
corner(minimize, 8)

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(30, 28)
close.Position = UDim2.new(1, -36, 0, 16)
close.Text = "×"
close.TextSize = 20
close.Font = Enum.Font.GothamBold
close.TextColor3 = Color3.fromRGB(255, 225, 230)
close.BackgroundColor3 = Color3.fromRGB(112, 48, 67)
close.BorderSizePixel = 0
close.Parent = top
corner(close, 8)

local content = Instance.new("Frame")
content.BackgroundTransparency = 1
content.Position = UDim2.fromOffset(18, 76)
content.Size = UDim2.new(1, -36, 1, -92)
content.Parent = panel

makeLabel(content, "ELIGE TU CALIDAD GRÁFICA", 12, UDim2.fromOffset(0, 0), Enum.Font.GothamBold, Color3.fromRGB(160, 185, 235))

local status = makeLabel(content, "●  Perfil actual: Original", 11, UDim2.fromOffset(0, 25), Enum.Font.GothamMedium, Color3.fromRGB(120, 220, 170))
status.Size = UDim2.new(1, 0, 0, 20)

local profiles = {
    {name = "ULTRA", desc = "Más iluminación y efectos", color = Color3.fromRGB(118, 83, 210)},
    {name = "HD", desc = "Colores vivos y buena iluminación", color = Color3.fromRGB(48, 125, 220)},
    {name = "EQUILIBRADO", desc = "Buena imagen y rendimiento", color = Color3.fromRGB(35, 155, 135)},
    {name = "FPS", desc = "Menos efectos para mayor fluidez", color = Color3.fromRGB(190, 125, 48)},
}

local original = {
    GlobalShadows = Lighting.GlobalShadows,
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
    EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale,
    EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale,
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    Technology = Lighting.Technology,
}
local effectStates = {}
for _, obj in ipairs(Lighting:GetChildren()) do
    if obj:IsA("PostEffect") then
        effectStates[obj] = obj.Enabled
    end
end

local createdEffects = {}
local function getOrCreateEffect(className, name)
    local existing = Lighting:FindFirstChild(name)
    if existing and existing.ClassName == className then
        return existing
    end
    local effect = Instance.new(className)
    effect.Name = name
    effect.Parent = Lighting
    table.insert(createdEffects, effect)
    return effect
end

local function setStatus(text, color)
    status.Text = "●  " .. text
    status.TextColor3 = color or Color3.fromRGB(120, 220, 170)
end

local function applyProfile(profile)
    -- No cambia la tecnología de iluminación ni fuerza ajustes no compatibles.
    Lighting.GlobalShadows = profile ~= "FPS"
    Lighting.FogEnd = 100000

    if profile == "ULTRA" then
        Lighting.Brightness = 2.5
        Lighting.EnvironmentDiffuseScale = 1
        Lighting.EnvironmentSpecularScale = 1
        Lighting.Ambient = Color3.fromRGB(105, 105, 125)
        Lighting.OutdoorAmbient = Color3.fromRGB(145, 145, 165)

        local bloom = getOrCreateEffect("BloomEffect", "HDOptimizer_Bloom")
        bloom.Intensity = 0.35
        bloom.Size = 28
        bloom.Threshold = 1.1
        bloom.Enabled = true

        local color = getOrCreateEffect("ColorCorrectionEffect", "HDOptimizer_Color")
        color.Brightness = 0.03
        color.Contrast = 0.12
        color.Saturation = 0.18
        color.TintColor = Color3.fromRGB(235, 242, 255)
        color.Enabled = true

        local rays = getOrCreateEffect("SunRaysEffect", "HDOptimizer_Rays")
        rays.Intensity = 0.08
        rays.Spread = 0.75
        rays.Enabled = true

    elseif profile == "HD" then
        Lighting.Brightness = 2.2
        Lighting.EnvironmentDiffuseScale = 0.85
        Lighting.EnvironmentSpecularScale = 0.8
        Lighting.Ambient = Color3.fromRGB(100, 105, 125)
        Lighting.OutdoorAmbient = Color3.fromRGB(135, 140, 160)

        local bloom = getOrCreateEffect("BloomEffect", "HDOptimizer_Bloom")
        bloom.Intensity = 0.22
        bloom.Size = 24
        bloom.Threshold = 1.2
        bloom.Enabled = true

        local color = getOrCreateEffect("ColorCorrectionEffect", "HDOptimizer_Color")
        color.Brightness = 0.02
        color.Contrast = 0.08
        color.Saturation = 0.12
        color.TintColor = Color3.fromRGB(245, 248, 255)
        color.Enabled = true

        local rays = getOrCreateEffect("SunRaysEffect", "HDOptimizer_Rays")
        rays.Intensity = 0.04
        rays.Spread = 0.7
        rays.Enabled = true

    elseif profile == "EQUILIBRADO" then
        Lighting.Brightness = 2
        Lighting.EnvironmentDiffuseScale = 0.65
        Lighting.EnvironmentSpecularScale = 0.55
        Lighting.Ambient = Color3.fromRGB(90, 90, 105)
        Lighting.OutdoorAmbient = Color3.fromRGB(120, 120, 135)

        for _, name in ipairs({"HDOptimizer_Bloom", "HDOptimizer_Color", "HDOptimizer_Rays"}) do
            local effect = Lighting:FindFirstChild(name)
            if effect and effect:IsA("PostEffect") then
                effect.Enabled = name == "HDOptimizer_Color"
            end
        end
        local color = getOrCreateEffect("ColorCorrectionEffect", "HDOptimizer_Color")
        color.Brightness = 0
        color.Contrast = 0.04
        color.Saturation = 0.06
        color.TintColor = Color3.fromRGB(255, 255, 255)
        color.Enabled = true

    elseif profile == "FPS" then
        Lighting.Brightness = 1.8
        Lighting.EnvironmentDiffuseScale = 0.35
        Lighting.EnvironmentSpecularScale = 0.2
        Lighting.Ambient = Color3.fromRGB(90, 90, 90)
        Lighting.OutdoorAmbient = Color3.fromRGB(110, 110, 110)

        for _, obj in ipairs(Lighting:GetChildren()) do
            if obj:IsA("PostEffect") then
                obj.Enabled = false
            end
        end
    end

    setStatus("Perfil actual: " .. profile, Color3.fromRGB(120, 220, 170))
end

local function restoreOriginal()
    for property, value in pairs(original) do
        pcall(function()
            Lighting[property] = value
        end)
    end
    for effect, enabled in pairs(effectStates) do
        if effect and effect.Parent then
            effect.Enabled = enabled
        end
    end
    for _, effect in ipairs(createdEffects) do
        if effect and effect.Parent then
            effect:Destroy()
        end
    end
    createdEffects = {}
    setStatus("Perfil actual: Original", Color3.fromRGB(180, 195, 220))
end

local function makeProfileButton(info, index)
    local button = Instance.new("TextButton")
    button.Name = info.name
    button.Size = UDim2.new(1, 0, 0, 54)
    button.Position = UDim2.fromOffset(0, 55 + (index - 1) * 62)
    button.BackgroundColor3 = Color3.fromRGB(27, 34, 52)
    button.BorderSizePixel = 0
    button.Text = ""
    button.AutoButtonColor = true
    button.Parent = content
    corner(button, 10)
    stroke(button, info.color, 1, 0.25)

    local stripe = Instance.new("Frame")
    stripe.Size = UDim2.new(0, 4, 1, -14)
    stripe.Position = UDim2.fromOffset(8, 7)
    stripe.BackgroundColor3 = info.color
    stripe.BorderSizePixel = 0
    stripe.Parent = button
    corner(stripe, 3)

    local name = makeLabel(button, info.name, 13, UDim2.fromOffset(22, 7), Enum.Font.GothamBold)
    name.Size = UDim2.new(1, -30, 0, 18)
    local desc = makeLabel(button, info.desc, 10, UDim2.fromOffset(22, 28), Enum.Font.Gotham, Color3.fromRGB(160, 174, 202))
    desc.Size = UDim2.new(1, -30, 0, 16)

    button.MouseButton1Click:Connect(function()
        applyProfile(info.name)
    end)
end

for index, info in ipairs(profiles) do
    makeProfileButton(info, index)
end

local restore = Instance.new("TextButton")
restore.Size = UDim2.new(1, 0, 0, 38)
restore.Position = UDim2.fromOffset(0, 310)
restore.BackgroundColor3 = Color3.fromRGB(55, 62, 82)
restore.BorderSizePixel = 0
restore.Text = "↺   RESTAURAR GRÁFICOS ORIGINALES"
restore.TextColor3 = Color3.fromRGB(240, 242, 250)
restore.TextSize = 11
restore.Font = Enum.Font.GothamBold
restore.Parent = content
corner(restore, 9)
restore.MouseButton1Click:Connect(restoreOriginal)

local note = makeLabel(content, "Los perfiles cambian iluminación y efectos locales.", 9, UDim2.fromOffset(0, 358), Enum.Font.Gotham, Color3.fromRGB(125, 140, 170))
note.Size = UDim2.new(1, 0, 0, 18)

-- Arrastrar la ventana con mouse o pantalla táctil.
local dragging = false
local dragInput
local dragStart
local startPosition

top.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = panel.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

top.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - dragStart
        panel.Position = UDim2.new(
            startPosition.X.Scale, startPosition.X.Offset + delta.X,
            startPosition.Y.Scale, startPosition.Y.Offset + delta.Y
        )
    end
end)

local minimized = false
minimize.MouseButton1Click:Connect(function()
    minimized = not minimized
    content.Visible = not minimized
    panel.Size = minimized and UDim2.fromOffset(410, 62) or UDim2.fromOffset(410, 440)
    minimize.Text = minimized and "+" or "—"
end)

close.MouseButton1Click:Connect(function()
    restoreOriginal()
    gui:Destroy()
end)
