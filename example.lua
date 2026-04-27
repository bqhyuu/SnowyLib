local SnowyLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/bqhyuu/SnowyLib/refs/heads/main/SnowyLib.lua"))()

local Window = SnowyLib.CreateWindow({
    Title = "Snowy Hub V2"
})

local MainTab = Window:CreateTab("Trang Chính")
local CombatTab = Window:CreateTab("Chiến Đấu")

MainTab:AddButton("Chào mừng bạn!", function()
    print("Nút đã được nhấn")
end)

MainTab:AddToggle("Tự động Farm", false, function(state)
    print("Auto Farm:", state)
end)

CombatTab:AddToggle("Aimbot", true, function(state)
    print("Aimbot:", state)
end)

CombatTab:AddButton("Reset Nhân Vật", function()
    game.Players.LocalPlayer.Character:BreakJoints()
end)
