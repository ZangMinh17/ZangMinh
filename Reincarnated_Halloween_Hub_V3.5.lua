--==================================================
-- REINCARNATED HALLOWEEN HUB V3.5
-- Rayfield UI + Auto Crate + Auto Trick or Treat
-- House Manager + Candy Auto Deposit + Glutton TP
-- FIX: Preserve active house during Candy deposit
--==================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local Player = Players.LocalPlayer

-- CONFIG
local HOUSE_FILE = "Reincarnated_Houses.json"
local DELAY = 0.7
local SCAN_DELAY = 1
local HOUSE_WAIT = 2
local CHECK_DELAY = 0.1
local CycleCooldown = 40
local CandyThreshold = 0
local CandyWaitTimeout = 1

local Running = {Crate = false, House = false, Candy = false}
local Busy = false
local ManualGlutton = false
local HousePositions = {}
local HouseIndex = 1
local PendingHouseIndex = nil
local Visited = {Crate = {}, House = {}}

-- RAYFIELD
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Window = Rayfield:CreateWindow({
    Name = "Reincarnated Halloween Hub",
    LoadingTitle = "Reincarnated Hub",
    LoadingSubtitle = "V3.5 | House Resume Fix",
    ConfigurationSaving = {Enabled = false},
    KeySystem = false
})
local FarmTab = Window:CreateTab("Auto Farm", 4483362458)
local HouseTab = Window:CreateTab("House Manager", 4483362458)
FarmTab:CreateSection("Automation")
FarmTab:CreateSection("Candy Settings")
HouseTab:CreateSection("House Positions")

-- CHARACTER
local function GetCharacter()
    local char = Player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not hum or not root or hum.Health <= 0 then return end
    return char, hum, root
end

-- STATUS
local function Notify(title, content)
    Rayfield:Notify({Title = title, Content = content, Duration = 4})
end

local function SetStatus(message)
    Notify("Reincarnated Hub", message)
end

-- CANDY READER
local function GetCandyLabel()
    local playerGui = Player:FindFirstChild("PlayerGui")
    if not playerGui then return nil end
    local bucket = playerGui:FindFirstChild("CandyBucket" .. tostring(Player.UserId))
    if not bucket then return nil end
    local count = bucket:FindFirstChild("Count")
    if count and count:IsA("TextLabel") then return count end
    return nil
end

local function ReadCandy()
    local label = GetCandyLabel()
    if not label then return nil, nil end
    local current, maximum = label.Text:match("(%d+)%s*/%s*(%d+)")
    current, maximum = tonumber(current), tonumber(maximum)
    if not current or not maximum then return nil, nil end
    return current, maximum
end

local function GetCandyTarget(maximum)
    if CandyThreshold <= 0 then return maximum end
    return math.min(CandyThreshold, maximum)
end

-- HOUSE POSITION HELPERS
local function GetHouseCFrame(index)
    local data = HousePositions[index]
    if not data then return nil end
    local position = Vector3.new(data.x, data.y, data.z)
    local look = Vector3.new(data.lx or 0, data.ly or 0, data.lz or -1)
    if look.Magnitude < 0.01 then look = Vector3.new(0, 0, -1) end
    return CFrame.lookAt(position, position + look.Unit)
end

-- GLUTTON
local function FindGlutton()
    local gameFolder = Workspace:FindFirstChild("Game")
    if not gameFolder then return nil end
    local interactables = gameFolder:FindFirstChild("Interactables")
    if not interactables then return nil end
    local npc = interactables:FindFirstChild("Glutton")
    if npc and npc:IsA("Model") then return npc end
    return nil
end

local function TeleportToGlutton()
    local char, hum, root = GetCharacter()
    if not char or not root then return false end
    local npc = FindGlutton()
    if not npc then
        SetStatus("Cannot find Glutton NPC")
        return false
    end
    char:PivotTo(CFrame.new(npc:GetPivot().Position + Vector3.new(0, 3, 5)))
    task.wait(0.5)
    return true
end

-- CANDY DEPOSIT
local function ProcessCandyDeposit()
    local current, maximum = ReadCandy()
    if not current or not maximum then
        SetStatus("Cannot read Candy count")
        task.wait(2)
        return
    end

    local target = GetCandyTarget(maximum)
    if not ManualGlutton and current < target then return end

    local char, hum, root = GetCharacter()
    if not char or not root then
        task.wait(1)
        return
    end

    -- Snapshot the active house before leaving. PendingHouseIndex is
    -- assigned by ProcessHouse before it can move to the next house.
    local resumeIndex = PendingHouseIndex or HouseIndex
    local returnCFrame = GetHouseCFrame(resumeIndex) or root.CFrame

    SetStatus("Candy " .. current .. "/" .. maximum ..
        " - Going to Glutton (House " .. tostring(resumeIndex) .. ")")

    if not TeleportToGlutton() then
        ManualGlutton = false
        task.wait(2)
        return
    end
    ManualGlutton = false

    -- A decrease confirms that Glutton accepted at least some Candy.
    local deadline = os.clock() + CandyWaitTimeout
    local deposited = false
    while os.clock() < deadline do
        task.wait(0.25)
        local newCandy = ReadCandy()
        if newCandy and newCandy < current then
            deposited = true
            break
        end
        if not Running.Candy and not Running.House then break end
    end

    if deposited then
        SetStatus("Candy decreased - returning to House " .. resumeIndex)
    else
        SetStatus("Deposit timeout - returning to House " .. resumeIndex)
    end

    task.wait(0.5)
    local currentChar = Player.Character
    if currentChar then
        local currentHum = currentChar:FindFirstChildOfClass("Humanoid")
        if currentHum and currentHum.Health > 0 then
            currentChar:PivotTo(returnCFrame)
        end
    end

    -- Re-check the same house. Never advance here.
    HouseIndex = resumeIndex
    PendingHouseIndex = nil
    task.wait(1)
    if Running.House then
        SetStatus("Returned to House " .. resumeIndex .. " - checking remaining Candy")
    end
end

-- HOUSE SAVE / LOAD
local function SaveHouses()
    if not writefile then return false end
    local success, err = pcall(function()
        writefile(HOUSE_FILE, HttpService:JSONEncode(HousePositions))
    end)
    if not success then warn("[Hub] Save error:", err) end
    return success
end

local function LoadHouses()
    if not isfile or not readfile then return false end
    if not isfile(HOUSE_FILE) then return false end
    local success, data = pcall(function()
        return HttpService:JSONDecode(readfile(HOUSE_FILE))
    end)
    if success and type(data) == "table" then
        HousePositions = data
        HouseIndex = 1
        PendingHouseIndex = nil
        return true
    end
    return false
end
LoadHouses()

-- HOUSE MANAGER
local function AddHouse()
    local _, _, root = GetCharacter()
    if not root then
        SetStatus("Character not found")
        return
    end
    local pos = root.Position
    local look = root.CFrame.LookVector
    table.insert(HousePositions, {
        x = pos.X, y = pos.Y, z = pos.Z,
        lx = look.X, ly = look.Y, lz = look.Z
    })
    SetStatus("Added House " .. #HousePositions)
end

local function UndoHouse()
    if #HousePositions == 0 then
        SetStatus("No houses to remove")
        return
    end
    table.remove(HousePositions)
    HouseIndex = math.clamp(HouseIndex, 1, math.max(1, #HousePositions))
    if PendingHouseIndex and PendingHouseIndex > #HousePositions then
        PendingHouseIndex = nil
    end
    SetStatus("Last house removed")
end

local function ClearHouses()
    HousePositions = {}
    HouseIndex = 1
    PendingHouseIndex = nil
    SetStatus("House list cleared")
end

-- OBJECT DETECTION
local function GetPart(prompt)
    local parent = prompt.Parent
    if not parent then return nil end
    if parent:IsA("BasePart") then return parent end
    if parent:IsA("Attachment") then return parent.Parent end
    return parent:FindFirstAncestorWhichIsA("BasePart")
end

local function GetPromptText(prompt)
    local names = {prompt.Name, prompt.ActionText, prompt.ObjectText}
    local parent = prompt.Parent
    for i = 1, 5 do
        if not parent then break end
        table.insert(names, parent.Name)
        parent = parent.Parent
    end
    return string.lower(table.concat(names, " "))
end

local function Classify(prompt)
    local name = GetPromptText(prompt)
    if name:find("knock") or name:find("trick or treat") then
        return "House"
    end
    local crateWords = {"crate", "box", "chest", "supply", "loot", "present", "gift"}
    for _, word in ipairs(crateWords) do
        if name:find(word) then return "Crate" end
    end
    return nil
end

-- FIND CRATE
local function FindNearestCrate()
    local _, _, root = GetCharacter()
    if not root then return nil end
    local nearest, shortest = nil, math.huge
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.Enabled
            and not Visited.Crate[obj] and Classify(obj) == "Crate" then
            local part = GetPart(obj)
            if part then
                local distance = (root.Position - part.Position).Magnitude
                if distance < shortest then
                    shortest, nearest = distance, obj
                end
            end
        end
    end
    return nearest
end

-- FIND HOUSE PROMPT
local function FindHousePrompt(position)
    local nearest, shortest = nil, 25
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.Enabled
            and Classify(obj) == "House" then
            local part = GetPart(obj)
            if part then
                local distance = (part.Position - position).Magnitude
                if distance < shortest then
                    shortest, nearest = distance, obj
                end
            end
        end
    end
    return nearest
end

-- MOVE TO HOUSE
local function GoToHouse(index)
    local destination = GetHouseCFrame(index)
    if not destination then return false end
    local char = GetCharacter()
    if not char then return false end
    char:PivotTo(destination)
    task.wait(0.5)
    return true
end

-- INTERACT
local function Interact(prompt, kind)
    if not prompt or not prompt.Parent then return false end
    local _, _, root = GetCharacter()
    if not root then return false end
    local part = GetPart(prompt)
    if not part then return false end
    if (root.Position - part.Position).Magnitude > prompt.MaxActivationDistance then
        return false
    end
    if not prompt.Enabled then return false end

    local success = pcall(function()
        prompt:InputHoldBegin()
        task.wait(math.max(prompt.HoldDuration, 0.2))
        prompt:InputHoldEnd()
    end)
    if success then Visited[kind][prompt] = true end
    task.wait(DELAY)
    return success
end

-- AUTO CRATE
local function ProcessCrate()
    local target = FindNearestCrate()
    if not target then
        task.wait(SCAN_DELAY)
        return
    end
    local part = GetPart(target)
    if not part then return end
    local _, hum, root = GetCharacter()
    if not root or not hum then return end
    hum:MoveTo(part.Position)
    local timeout = os.clock() + 15
    repeat
        task.wait(0.2)
        if not Running.Crate or not target.Parent then return end
    until (root.Position - part.Position).Magnitude <= target.MaxActivationDistance
        or os.clock() > timeout

    if (root.Position - part.Position).Magnitude <= target.MaxActivationDistance then
        Interact(target, "Crate")
    else
        Visited.Crate[target] = true
    end
end

-- VERIFY HOUSE
local function VerifyHouse(index, position)
    task.wait(HOUSE_WAIT)
    if not Running.House then return false end
    local firstCheck = FindHousePrompt(position) ~= nil
    task.wait(CHECK_DELAY)
    if not Running.House then return false end
    local secondCheck = FindHousePrompt(position) ~= nil
    return not firstCheck and not secondCheck
end

-- CYCLE COOLDOWN
local function WaitCycleCooldown()
    local remaining = CycleCooldown
    SetStatus("Vòng hoàn tất. Chờ " .. tostring(remaining) .. " giây...")
    while remaining > 0 and Running.House do
        task.wait(1)
        remaining -= 1
    end
    if Running.House then
        HouseIndex = 1
        PendingHouseIndex = nil
        SetStatus("Bắt đầu vòng mới")
    end
end

-- AUTO TRICK OR TREAT
local function ProcessHouse()
    if #HousePositions == 0 then
        SetStatus("Setup houses first!")
        Running.House = false
        return
    end

    local index = PendingHouseIndex or HouseIndex
    if index > #HousePositions then
        WaitCycleCooldown()
        return
    end

    local data = HousePositions[index]
    local position = Vector3.new(data.x, data.y, data.z)

    if not GoToHouse(index) then
        SetStatus("Cannot move to House " .. index)
        Running.House = false
        return
    end
    if not Running.House then return end

    local target = FindHousePrompt(position)

    -- Prompt absent: house is complete. Advance only after checking.
    if not target then
        HouseIndex = index + 1
        PendingHouseIndex = nil
        task.wait(DELAY)
        return
    end

    -- Lock the current house before interacting or any deposit check.
    HouseIndex = index
    PendingHouseIndex = index

    local success = Interact(target, "House")
    if not success then
        task.wait(1)
        return
    end
    if not Running.House then return end

    local completed = VerifyHouse(index, position)
    if not Running.House then return end

    -- Candy threshold is checked before allowing HouseIndex to advance.
    local currentCandy, maximumCandy = ReadCandy()
    local candyAtThreshold = false
    if Running.Candy and currentCandy and maximumCandy then
        candyAtThreshold = currentCandy >= GetCandyTarget(maximumCandy)
    end

    if candyAtThreshold then
        HouseIndex = index
        PendingHouseIndex = index
        SetStatus("Candy threshold reached - saved House " .. index)
        return
    end

    if completed then
        HouseIndex = index + 1
        PendingHouseIndex = nil
        SetStatus("House " .. index .. " completed. Next: House " .. HouseIndex)
    else
        HouseIndex = index
        PendingHouseIndex = index
        SetStatus("House " .. index .. " still has Candy. Continue collecting.")
    end
    task.wait(DELAY)
end

-- UI: AUTO FARM
FarmTab:CreateToggle({
    Name = "Auto Crate",
    CurrentValue = false,
    Flag = "AutoCrate",
    Callback = function(value)
        Running.Crate = value
        SetStatus("Auto Crate: " .. (value and "ON" or "OFF"))
    end
})

FarmTab:CreateToggle({
    Name = "Auto Trick or Treat",
    CurrentValue = false,
    Flag = "AutoHouse",
    Callback = function(value)
        Running.House = value
        if value then
            if #HousePositions == 0 then
                Running.House = false
                SetStatus("Add house positions first!")
                return
            end
            if HouseIndex > #HousePositions then HouseIndex = 1 end
        end
        SetStatus("Auto Trick or Treat: " .. (Running.House and "ON" or "OFF"))
    end
})

-- UI: CANDY SETTINGS
FarmTab:CreateToggle({
    Name = "Auto Candy Deposit",
    CurrentValue = false,
    Flag = "AutoCandy",
    Callback = function(value)
        Running.Candy = value
        SetStatus("Auto Candy Deposit: " .. (value and "ON" or "OFF"))
    end
})

FarmTab:CreateInput({
    Name = "Candy Threshold (0 = Max Capacity)",
    CurrentValue = "0",
    PlaceholderText = "150 / 200 / 300 / 0",
    RemoveTextAfterFocusLost = false,
    Flag = "CandyThreshold",
    Callback = function(value)
        local number = tonumber(value)
        if number and number >= 0 then
            CandyThreshold = math.floor(math.clamp(number, 0, 100000))
            SetStatus("Candy threshold: " ..
                (CandyThreshold == 0 and "Max Capacity" or tostring(CandyThreshold)))
        else
            SetStatus("Invalid Candy threshold")
        end
    end
})

FarmTab:CreateButton({
    Name = "Teleport to Glutton Now",
    Callback = function()
        if Busy then
            SetStatus("Hub is busy. Try again shortly.")
            return
        end
        ManualGlutton = true
    end
})

FarmTab:CreateButton({
    Name = "Show Candy Count",
    Callback = function()
        local current, maximum = ReadCandy()
        if current and maximum then
            SetStatus("Candy: " .. current .. "/" .. maximum)
        else
            SetStatus("Candy UI not found")
        end
    end
})

-- UI: CYCLE SETTINGS
FarmTab:CreateSection("Cycle Settings")
FarmTab:CreateInput({
    Name = "Cooldown giữa các vòng (giây)",
    CurrentValue = "40",
    PlaceholderText = "Nhập số giây",
    RemoveTextAfterFocusLost = false,
    Flag = "CycleCooldown",
    Callback = function(value)
        local number = tonumber(value)
        if number and number >= 0 then
            CycleCooldown = math.floor(math.clamp(number, 0, 3600))
            SetStatus("Cycle cooldown: " .. CycleCooldown .. " giây")
        else
            SetStatus("Cooldown không hợp lệ")
        end
    end
})

FarmTab:CreateButton({
    Name = "Stop All",
    Callback = function()
        Running.Crate = false
        Running.House = false
        Running.Candy = false
        ManualGlutton = false
        SetStatus("All automation stopped")
    end
})

-- UI: HOUSE MANAGER
HouseTab:CreateButton({Name = "Add House - Current Position", Callback = AddHouse})
HouseTab:CreateButton({Name = "Undo Last House", Callback = UndoHouse})
HouseTab:CreateButton({
    Name = "Save House Positions",
    Callback = function()
        if SaveHouses() then
            SetStatus("House positions saved")
        else
            SetStatus("Save failed")
        end
    end
})
HouseTab:CreateButton({
    Name = "Load House Positions",
    Callback = function()
        if LoadHouses() then
            SetStatus("Loaded " .. #HousePositions .. " houses")
        else
            SetStatus("No saved house file")
        end
    end
})
HouseTab:CreateButton({Name = "Clear All Houses", Callback = ClearHouses})
HouseTab:CreateSection("House Information")
HouseTab:CreateButton({
    Name = "Show Saved House Count",
    Callback = function()
        SetStatus("Saved Houses: " .. #HousePositions)
    end
})

-- MAIN WORKER
task.spawn(function()
    while true do
        task.wait(0.1)

        if not Busy and (ManualGlutton or Running.Candy or Running.House or Running.Crate) then
            Busy = true
            local success, err = pcall(function()
                local current, maximum = ReadCandy()
                local shouldDeposit = ManualGlutton

                if Running.Candy and current and maximum then
                    if current >= GetCandyTarget(maximum) then
                        shouldDeposit = true
                    end
                end

                if shouldDeposit then
                    -- Capture the active house immediately before teleporting.
                    if Running.House and not PendingHouseIndex then
                        PendingHouseIndex = HouseIndex
                    end
                    ProcessCandyDeposit()
                elseif Running.House then
                    ProcessHouse()
                elseif Running.Crate then
                    ProcessCrate()
                end
            end)

            if not success then
                warn("[Reincarnated Hub] Error:", err)
                SetStatus("Error - check console")
            end
            Busy = false
        end
    end
end)

-- LOADED
Rayfield:Notify({
    Title = "Reincarnated Hub V3.5",
    Content = "House Resume + Candy Auto Deposit loaded!",
    Duration = 5
})

print("[Reincarnated Hub V3.5] Loaded")
print("Saved houses:", #HousePositions)
local candyNow, candyMax = ReadCandy()
print("Candy:", candyNow, candyMax)
