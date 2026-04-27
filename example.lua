--[[
    SnowyLib — Roblox UI Library

    Cách dùng:
        local SnowyLib = loadstring(game:HttpGet("RAW_URL"))()
        local Window = SnowyLib.CreateWindow({ ... })
        local Options = Window.Options  -- truy cập control theo key

    Có 2 cách thêm element:
        1. Qua Section (nhóm có tiêu đề):
               local s = Tab:CreateSection("Name")
               s:CreateToggle({ ... })

        2. Trực tiếp trên Tab (không cần section):
               Tab:AddToggle("MyKey", { ... })
               Options.MyKey.Value  -- đọc giá trị
               Options.MyKey:SetValue(true)

    Icon hỗ trợ:
        "settings"          → auto-detect (Lucide → Phosphor)
        "lucide:settings"   → Lucide  https://lucide.dev/icons/
        "ph:gear"           → Phosphor https://phosphoricons.com/
        "rbxassetid://..."  → asset ID trực tiếp
--]]

local SnowyLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/bqhyuu/SnowyLib/refs/heads/main/SnowyLib.lua"))()

-- ─── Window ───────────────────────────────────────────────────────────────────
local Window = SnowyLib.CreateWindow({
    Title     = "Meyy Hub",
    Version   = "1.0.0",
    Theme     = "Dark",
    ToggleKey = Enum.KeyCode.RightControl,
})

local Options = Window.Options

-- ─── Tabs ─────────────────────────────────────────────────────────────────────
local Tabs = {
    Main     = Window:CreateTab({ Title = "Main",     Icon = "ph:house" }),
    Combat   = Window:CreateTab({ Title = "Combat",   Icon = "ph:sword" }),
    Settings = Window:CreateTab({ Title = "Settings", Icon = "ph:gear"  }),
}

-- ─── Notify ───────────────────────────────────────────────────────────────────
Window:Notify({
    Title    = "Welcome",
    Content  = "Meyy Hub loaded!",
    Duration = 4,
})

-- ─── Paragraph ────────────────────────────────────────────────────────────────
Tabs.Main:AddParagraph({
    Title   = "Info",
    Content = "Welcome to Meyy Hub.",
})

-- ─── Button ───────────────────────────────────────────────────────────────────
Tabs.Main:AddButton({
    Title    = "Execute",
    Callback = function()
        Window:Dialog({
            Title   = "Confirm",
            Content = "Run the script?",
            Buttons = {
                { Title = "Run",    Primary = true, Callback = function() print("Executed") end },
                { Title = "Cancel",                 Callback = function() end },
            },
        })
    end,
})

-- ─── Toggle ───────────────────────────────────────────────────────────────────
local Toggle = Tabs.Main:AddToggle("Aimbot", {
    Title   = "Aimbot",
    Default = false,
    Callback = function(v) print("Aimbot:", v) end,
})

-- ─── Slider ───────────────────────────────────────────────────────────────────
local Slider = Tabs.Main:AddSlider("FOV", {
    Title    = "FOV",
    Min      = 10,
    Max      = 120,
    Default  = 60,
    Rounding = 0,
    Callback = function(v) print("FOV:", v) end,
})

-- ─── Dropdown ─────────────────────────────────────────────────────────────────
local Dropdown = Tabs.Main:AddDropdown("Target", {
    Title   = "Target",
    Values  = { "Closest", "Lowest HP", "Random" },
    Default = 1,
    Callback = function(v) print("Target:", v) end,
})

-- ─── Textbox ──────────────────────────────────────────────────────────────────
local section = Tabs.Combat:CreateSection("Player")

section:CreateTextbox({
    Title       = "Username",
    Placeholder = "Enter name...",
    Callback    = function(v) print("Username:", v) end,
})

-- ─── Keybind ──────────────────────────────────────────────────────────────────
section:CreateKeybind({
    Title   = "Sprint Key",
    Default = Enum.KeyCode.LeftShift,
    Pressed = function() print("Sprint!") end,
})

-- ─── Settings ─────────────────────────────────────────────────────────────────
Window:LoadSettings(Tabs.Settings)
