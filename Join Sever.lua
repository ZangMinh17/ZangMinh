repeat task.wait() until game:IsLoaded()     

-- XÓA MENU CŨ NẾU CÓ ĐỂ TRÁNH TRÙNG LẶP
local CoreGui = game:GetService("CoreGui")
if CoreGui:FindFirstChild("HWF_SmartMenu") then
    CoreGui.HWF_SmartMenu:Destroy()
end

-- KHỞI TẠO INTERFACE (UI Jinx ĐẹpZai chuẩn màu tối hồng)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HWF_SmartMenu"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MainFrame.Position = UDim2.new(0.1, 0, 0.25, 0)
MainFrame.Size = UDim2.new(0, 240, 0, 190) 
MainFrame.Active = true
MainFrame.Draggable = true 

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(255, 105, 180) 
UIStroke.Thickness = 2
UIStroke.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 12, 0, 8)
Title.Size = UDim2.new(0, 150, 0, 25)
Title.Font = Enum.Font.SourceSansBold
Title.Text = "Jinx ĐepZai | Joiner"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left

-- TÍNH NĂNG LOGO MINI TRÒN KHI THU NHỎ
local LogoBtn = Instance.new("TextButton")
LogoBtn.Name = "LogoMini"
LogoBtn.Parent = ScreenGui
LogoBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
LogoBtn.Position = UDim2.new(0, 15, 0, 15)
LogoBtn.Size = UDim2.new(0, 45, 0, 45)
LogoBtn.Font = Enum.Font.SourceSansBold
LogoBtn.Text = "O"
LogoBtn.TextColor3 = Color3.fromRGB(255, 105, 180)
LogoBtn.TextSize = 24
LogoBtn.Visible = false
LogoBtn.Draggable = true

local LogoCorner = Instance.new("UICorner")
LogoCorner.CornerRadius = UDim.new(1, 0)
LogoCorner.Parent = LogoBtn

local LogoStroke = Instance.new("UIStroke")
LogoStroke.Color = Color3.fromRGB(255, 105, 180)
LogoStroke.Thickness = 2
LogoStroke.Parent = LogoBtn

local function HideToLogo()
    MainFrame.Visible = false
    LogoBtn.Visible = true
end

local function ShowFromLogo()
    MainFrame.Visible = true
    LogoBtn.Visible = false
end

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Name = "MinimizeBtn"
MinimizeBtn.Parent = MainFrame
MinimizeBtn.BackgroundTransparency = 1
MinimizeBtn.Position = UDim2.new(1, -55, 0, 8)
MinimizeBtn.Size = UDim2.new(0, 25, 0, 25)
MinimizeBtn.Font = Enum.Font.SourceSansBold
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
MinimizeBtn.TextSize = 22
MinimizeBtn.MouseButton1Click:Connect(HideToLogo)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Parent = MainFrame
CloseBtn.BackgroundTransparency = 1
CloseBtn.Position = UDim2.new(1, -30, 0, 8)
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseBtn.TextSize = 16
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end) 

LogoBtn.MouseButton1Click:Connect(ShowFromLogo)

---------------------------------------------------------
-- PHẦN XỬ LÝ DỮ LIỆU CHÍNH (FIX LỖI 771)
---------------------------------------------------------
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local player = game:GetService("Players").LocalPlayer

local ServerLabel = Instance.new("TextLabel")
ServerLabel.Parent = MainFrame
ServerLabel.BackgroundTransparency = 1
ServerLabel.Position = UDim2.new(0.1, 0, 0, 45)
ServerLabel.Size = UDim2.new(0.8, 0, 0, 20)
ServerLabel.Font = Enum.Font.SourceSansBold
ServerLabel.Text = "Nhập Job ID / Link Server"
ServerLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
ServerLabel.TextSize = 13
ServerLabel.TextXAlignment = Enum.TextXAlignment.Left

local ServerInput = Instance.new("TextBox")
ServerInput.Parent = MainFrame
ServerInput.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
ServerInput.Position = UDim2.new(0.1, 0, 0, 70)
ServerInput.Size = UDim2.new(0.8, 0, 0, 35)
ServerInput.Font = Enum.Font.SourceSans
ServerInput.PlaceholderText = "Paste JobID or Link here..."
ServerInput.Text = ""
ServerInput.TextColor3 = Color3.fromRGB(255, 255, 255)
ServerInput.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
ServerInput.TextSize = 13
ServerInput.ClearTextOnFocus = false

local ServerInputCorner = Instance.new("UICorner")
ServerInputCorner.CornerRadius = UDim.new(0, 6)
ServerInputCorner.Parent = ServerInput

local JoinBtn = Instance.new("TextButton")
JoinBtn.Parent = MainFrame
JoinBtn.BackgroundColor3 = Color3.fromRGB(255, 105, 180) 
JoinBtn.Position = UDim2.new(0.1, 0, 0, 115)
JoinBtn.Size = UDim2.new(0.8, 0, 0, 35)
JoinBtn.Font = Enum.Font.SourceSansBold
JoinBtn.Text = "JOIN SERVER"
JoinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
JoinBtn.TextSize = 16

local JoinCorner = Instance.new("UICorner")
JoinCorner.CornerRadius = UDim.new(0, 8)
JoinCorner.Parent = JoinBtn

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Parent = MainFrame
StatusLabel.BackgroundTransparency = 1
StatusLabel.Position = UDim2.new(0.1, 0, 0, 151)
StatusLabel.Size = UDim2.new(0.8, 0, 0, 15)
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.Text = "Status: Ready"
StatusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
StatusLabel.TextSize = 12
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left

local CreditLabel = Instance.new("TextLabel")
CreditLabel.Parent = MainFrame
CreditLabel.BackgroundTransparency = 1
CreditLabel.Position = UDim2.new(0, 0, 0, 168)
CreditLabel.Size = UDim2.new(1, 0, 0, 20)
CreditLabel.Font = Enum.Font.SourceSansItalic
CreditLabel.Text = "Bấm H Để Ẩn/Hiện UI"
CreditLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
CreditLabel.TextSize = 12

-- PHÍM TẮT H
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.H then
        if MainFrame.Visible then HideToLogo() elseif LogoBtn.Visible then ShowFromLogo() else MainFrame.Visible = true end
    end
end)

-- CLICK BUTTON ĐỂ TELEPORT
JoinBtn.MouseButton1Click:Connect(function()
    local inputText = ServerInput.Text:match("^%s*(.-)%s*$")

    if inputText == "" then
        StatusLabel.Text = "Status: Enter ID or Link first"
        return
    end

    StatusLabel.Text = "Status: Processing input..."
    task.wait(0.1)

    -- ĐOẠN KHẮC PHỤC LỖI: Nhận diện link share và bóc tách dữ liệu
    if inputText:find("://roblox.com") or inputText:find("code=") then
        local shareCode = inputText:match("code=([^&]+)")
        if not shareCode then
            StatusLabel.Text = "Failed: Invalid link format"
            return
        end

        StatusLabel.Text = "Status: Resolving link..."
        
        local success, result = pcall(function()
            local url = "https://apis.://roblox.com-links/v1/share-links/" .. shareCode
            return HttpService:JSONDecode(game:HttpGet(url))
        end)

        if success and result and result.gameInstanceInfo then
            local targetPlaceId = result.gameInstanceInfo.placeId
            
            -- FIX LỖI 771: Nếu hệ thống trả về PrivateServerLinkCode (accessCode) thì dùng nó để bypass lỗi JobID
            if result.gameInstanceInfo.privateServerLinkCode then
                StatusLabel.Text = "Status: Teleporting via AccessCode..."
                local acSuccess, acErr = pcall(function()
                    TeleportService:TeleportToPrivateServer(targetPlaceId, result.gameInstanceInfo.privateServerLinkCode, {player})
                end)
                if acSuccess then return end
            end
            
            -- Phương án dự phòng nếu link là server thường không phải VIP
            local targetJobId = result.gameInstanceInfo.gameInstanceId
            StatusLabel.Text = "Status: Teleporting via Instance..."
            pcall(function()
                TeleportService:TeleportToPlaceInstance(targetPlaceId, targetJobId, player)
            end)
        else
            StatusLabel.Text = "Failed: Cannot resolve Link"
        end

    -- Nếu nhập Job ID dạng Text thông thường
    else
        StatusLabel.Text = "Status: Teleporting via Job ID..."
        local tpSuccess, tpErr = pcall(function()
            TeleportService:TeleportToPlaceInstance(98502499119821, inputText, player)
        end)
        if not tpSuccess then
            StatusLabel.Text = "Failed: " .. tostring(tpErr)
        end
    end
end)
