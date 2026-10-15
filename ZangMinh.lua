repeat task.wait() until game:IsLoaded()     

-- XOA MENU CU NEU CO DE TRANH TRUNG LAP
local CoreGui = game:GetService("CoreGui")
if CoreGui:FindFirstChild("HWF_SmartMenu") then
    CoreGui.HWF_SmartMenu:Destroy()
end

-- BIEN CAU HINH HE THONG
local SKILL_SEQUENCE = {}
local DELAY_BETWEEN_SKILLS = 0.1
local COOLDOWN_LOOP = 0.3
_G.AutoSkillActive = false

-- KHOI TAO INTERFACE
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HWF_SmartMenu"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- 1. KHUNG MENU CHINH
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MainFrame.Position = UDim2.new(0.1, 0, 0.25, 0)
MainFrame.Size = UDim2.new(0, 240, 0, 220)
MainFrame.Active = true
MainFrame.Draggable = true 

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(255, 105, 180)
UIStroke.Thickness = 2
UIStroke.Parent = MainFrame

-- Tieu de menu
local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 12, 0, 8)
Title.Size = UDim2.new(0, 150, 0, 25)
Title.Font = Enum.Font.SourceSansBold
Title.Text = "Jinx ĐepZai"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left

-- 2. LOGO TRON KHI THU NHO
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

-- NUT DAU TRU (-) VA NUT X
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
CloseBtn.MouseButton1Click:Connect(HideToLogo) 

LogoBtn.MouseButton1Click:Connect(ShowFromLogo)

-- Nhan huong dan o nhap
local InputLabel = Instance.new("TextLabel")
InputLabel.Parent = MainFrame
InputLabel.BackgroundTransparency = 1
InputLabel.Position = UDim2.new(0.1, 0, 0, 45)
InputLabel.Size = UDim2.new(0.8, 0, 0, 20)
InputLabel.Font = Enum.Font.SourceSansBold
InputLabel.Text = "Nhập Skill Đê"
InputLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
InputLabel.TextSize = 13
InputLabel.TextXAlignment = Enum.TextXAlignment.Left

-- O Nhap Skill Thong Minh (TextBox)
local SkillInput = Instance.new("TextBox")
SkillInput.Parent = MainFrame
SkillInput.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
SkillInput.Position = UDim2.new(0.1, 0, 0, 70)
SkillInput.Size = UDim2.new(0.8, 0, 0, 35)
SkillInput.Font = Enum.Font.SourceSans
SkillInput.Text = "" -- De mac dinh ghi lien nhau de ban biet chuong trinh tu hieu
SkillInput.TextColor3 = Color3.fromRGB(255, 255, 255)
SkillInput.TextSize = 16
SkillInput.ClearTextOnFocus = false

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 6)
InputCorner.Parent = SkillInput

-- Nut Bat/Tat Auto Skill
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Parent = MainFrame
ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
ToggleBtn.Position = UDim2.new(0.1, 0, 0, 125)
ToggleBtn.Size = UDim2.new(0.8, 0, 0, 45)
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.Text = "AUTO SKILL: TAT"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 18

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 8)
BtnCorner.Parent = ToggleBtn

local CreditLabel = Instance.new("TextLabel")
CreditLabel.Parent = MainFrame
CreditLabel.BackgroundTransparency = 1
CreditLabel.Position = UDim2.new(0, 0, 0, 185)
CreditLabel.Size = UDim2.new(1, 0, 0, 20)
CreditLabel.Font = Enum.Font.SourceSansItalic
CreditLabel.Text = "Bấm H Để Tắt UI"
CreditLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
CreditLabel.TextSize = 12

-- XU LY PHIM TAT CHO PC (Phim H)
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.H then
        if MainFrame.Visible then
            HideToLogo()
        elseif LogoBtn.Visible then
            ShowFromLogo()
        else
            MainFrame.Visible = true
        end
    end
end)

-- BO LOC THONG MINH: TU TACH TUNG CHU CAI KHONG CAN DAU PHAY
SkillInput.FocusLost:Connect(function()
    local text = SkillInput.Text
    local newSequence = {}
    
    -- Quet tung ky tu mot trong o text
    for i = 1, #text do
        local char = string.sub(text, i, i)
        -- Chi lay cac ky tu tu A-Z va a-z (bo qua dau phay, cach, so, ki tu dac biet)
        if string.match(char, "%a") then
            table.insert(newSequence, char:upper())
        end
    end
    
    if #newSequence > 0 then
        SKILL_SEQUENCE = newSequence
    else
        -- Neu nguoi dung xoa het chu thi tra ve chuoi mac dinh
        SkillInput.Text = table.concat(SKILL_SEQUENCE, "")
    end
end)

-- Xu ly bat/tat luong Auto Skill
local vim = game:GetService("VirtualInputManager")
ToggleBtn.MouseButton1Click:Connect(function()
    _G.AutoSkillActive = not _G.AutoSkillActive
    if _G.AutoSkillActive then
        ToggleBtn.Text = "Auto Skill: Bật"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        
        task.spawn(function()
            while _G.AutoSkillActive do
                for _, skill in ipairs(SKILL_SEQUENCE) do
                    if not _G.AutoSkillActive then break end
                    local success, keyCode = pcall(function()
                        return Enum.KeyCode[skill:upper()]
                    end)
                    if success and keyCode then
                        vim:SendKeyEvent(true, keyCode, false, game)
                        task.wait(0.05)
                        vim:SendKeyEvent(false, keyCode, false, game)
                        task.wait(DELAY_BETWEEN_SKILLS)
                    end
                end
                task.wait(COOLDOWN_LOOP)
            end
        end)
    else
        ToggleBtn.Text = "Auto Skill: Tắt"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
end)


