
--==================================================
-- OPIUMWARE V4
-- AUTO LOAD + AUTO REINCARNATE
-- ON / OFF | DRAG UI
--==================================================

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local pg = player:WaitForChild("PlayerGui")
local interface = pg:WaitForChild("Interface")
local main = interface.Frames.Main

-- SETTINGS
local LOAD_WAIT = 0
local CHECK_INTERVAL = 1
local RB_TIMEOUT = 20

local enabled = false
local busy = false

--==================================================
-- EXACT GUI PATHS
--==================================================

local loadButton = main.ProgressionNew.Holder.List
    .Blueprints.Holder.Row.Buttons.LoadAll

local rbRoot = main.Progression.Holder.List.Reincarnate

local rbButton = rbRoot.Holder.Reincarnate
local priceLabel = rbRoot.Holder.Price

local moneyLabel = interface.Overlays.Currencies.Money.Label

local lifeLabel = rbRoot:FindFirstChild("Life", true)

--==================================================
-- MONEY SYSTEM
--==================================================

local suffix = {
    K = 1,
    M = 2,
    B = 3,
    T = 4,
    QA = 5,
    QN = 6,
    SX = 7,
    SP = 8,
    O = 9,
    N = 10,
    DE = 11,
    UDE = 12,
    DDE = 13,
    TDE = 14
}

local function parseMoney(str)
    if not str then return nil end

    str = str:gsub("<.->", "")
    str = str:gsub("%$", "")
    str = str:gsub(",", "")
    str = str:upper():gsub("%s+", "")

    local number, unit =
        str:match("^([%d%.]+)(%a*)$")

    number = tonumber(number)

    if not number then return nil end

    local power = suffix[unit]

    if unit == "" then
        power = 0
    end

    if power == nil then
        return nil
    end

    return number * (1000 ^ power)
end

--==================================================
-- GUI EVENT ACTIVATION
--==================================================

local function activateButton(button)
    if not enabled then return false end

    if not button or not button:IsA("GuiButton") then
        warn("[AUTO] Invalid button")
        return false
    end

    if not button.Visible or not button.Active then
        warn("[AUTO] Button not ready:", button:GetFullName())
        return false
    end

    -- Activate the actual GUI event callbacks
    local success, connections = pcall(
        getconnections,
        button.Activated
    )

    if success and connections and #connections > 0 then
        for _, connection in ipairs(connections) do
            if connection.Enabled and connection.Fire then
                local fired = pcall(function()
                    connection:Fire()
                end)

                if fired then
                    print("[AUTO] CALLBACK FIRED:", button.Name)
                    return true
                end
            end
        end
    end

    -- Fallback: Activated signal
    if typeof(firesignal) == "function" then
        local ok = pcall(function()
            firesignal(button.Activated)
        end)

        if ok then
            print("[AUTO] SIGNAL FIRED:", button.Name)
            return true
        end
    end

    warn("[AUTO] Cannot activate:", button.Name)
    return false
end

--==================================================
-- UI
--==================================================

local old = pg:FindFirstChild("OpiumwareV4")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "OpiumwareV4"
gui.ResetOnSpawn = false
gui.DisplayOrder = 999
gui.Parent = pg

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(240, 120)
frame.Position = UDim2.new(0, 25, 0.5, -60)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
frame.BorderSizePixel = 0
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius =
    UDim.new(0, 10)

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(80, 110, 150)
stroke.Thickness = 1.5
stroke.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "OPIUMWARE V4"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.Parent = frame

local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(1, -20, 0, 38)
toggle.Position = UDim2.fromOffset(10, 35)
toggle.BackgroundColor3 = Color3.fromRGB(145, 45, 45)
toggle.Text = "AUTO: OFF"
toggle.TextColor3 = Color3.new(1, 1, 1)
toggle.Font = Enum.Font.GothamBold
toggle.TextSize = 15
toggle.Parent = frame

Instance.new("UICorner", toggle).CornerRadius =
    UDim.new(0, 7)

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -10, 0, 25)
status.Position = UDim2.fromOffset(5, 82)
status.BackgroundTransparency = 1
status.Text = "STATUS: OFF"
status.TextColor3 = Color3.fromRGB(200, 200, 200)
status.Font = Enum.Font.Gotham
status.TextSize = 12
status.Parent = frame

local function setStatus(value)
    status.Text = "STATUS: " .. value
end

toggle.Activated:Connect(function()
    enabled = not enabled

    if enabled then
        toggle.Text = "AUTO: ON"
        toggle.BackgroundColor3 = Color3.fromRGB(30, 145, 75)
        setStatus("STARTING")
        print("[AUTO] ENABLED")
    else
        toggle.Text = "AUTO: OFF"
        toggle.BackgroundColor3 = Color3.fromRGB(145, 45, 45)
        setStatus("STOPPED")
        print("[AUTO] DISABLED")
    end
end)

--==================================================
-- DRAG
--==================================================

local dragging = false
local dragStart
local startPos

title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and (
        input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
    ) then
        local delta = input.Position - dragStart

        frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

--==================================================
-- AUTO LOAD
--==================================================

local function autoLoad()
    if not enabled then return false end

    setStatus("LOADING")

    print("[AUTO] ACTIVATING LOAD ALL")

    if not activateButton(loadButton) then
        setStatus("LOAD FAILED")
        return false
    end

    local start = os.clock()

    while enabled and os.clock() - start < LOAD_WAIT do
        task.wait(0.2)
    end

    if not enabled then return false end

    setStatus("LOAD WAIT FINISHED")
    return true
end

--==================================================
-- AUTO REINCARNATE
--==================================================

local function autoRB()
    if not enabled then return false end

    local money = parseMoney(moneyLabel.Text)
    local price = parseMoney(priceLabel.Text)

    if not money or not price then
        setStatus("CURRENCY ERROR")
        warn("[AUTO] MONEY:", moneyLabel.Text)
        warn("[AUTO] PRICE:", priceLabel.Text)
        return false
    end

    print("[AUTO] MONEY:", moneyLabel.Text)
    print("[AUTO] PRICE:", priceLabel.Text)

    if money < price then
        setStatus("WAITING FOR MONEY")
        return false
    end

    setStatus("ENOUGH MONEY - RB")

    print("[AUTO] ENOUGH MONEY!")

    local oldLife = lifeLabel and lifeLabel.Text
    local oldMoney = moneyLabel.Text
    local oldPrice = priceLabel.Text

    if not activateButton(rbButton) then
        setStatus("RB CLICK FAILED")
        return false
    end

    local start = os.clock()

    while enabled and os.clock() - start < RB_TIMEOUT do
        task.wait(0.5)

        local changed =
            (lifeLabel and lifeLabel.Text ~= oldLife)
            or moneyLabel.Text ~= oldMoney
            or priceLabel.Text ~= oldPrice

        if changed then
            print("[AUTO] RB CHANGE DETECTED")
            setStatus("RB SUCCESS")
            return true
        end
    end

    warn("[AUTO] RB NOT CONFIRMED")
    setStatus("RB NOT CONFIRMED")

    return false
end

--==================================================
-- MAIN LOOP
--==================================================

print("================================")
print(" OPIUMWARE V4 LOADED")
print(" Press ON to start")
print("================================")

while gui.Parent do

    if enabled and not busy then
        busy = true

        local ok, err = pcall(function()

            -- Load when ON
            if not autoLoad() then
                return
            end

            while enabled do

                if autoRB() then
                    task.wait(3)

                    if enabled then
                        autoLoad()
                    end
                else
                    task.wait(CHECK_INTERVAL)
                end
            end
        end)

        if not ok then
            warn("[AUTO] ERROR:", err)
            setStatus("ERROR")
        end

        busy = false
    end

    task.wait(0.2)
end
