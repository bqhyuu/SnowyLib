# SnowyLib

Roblox UI library — clean, modern, template-style.

## Structure

```
SnowyLib.lua       ← Main library file
example.client.lua ← Usage example
```

## Usage (executor)

```lua
local SnowyLib = loadstring(game:HttpGet("RAW_URL/dist/SnowyLib.lua"))()

local Window = SnowyLib.CreateWindow({
    Title    = "My Hub",
    Subtitle = "Universal Script Hub",
    Version  = "1.0.0",
    Theme    = "Dark",
})

local Tab = Window:CreateTab({ Title = "Main", Icon = "ph:house" })
local section = Tab:CreateSection("Combat")

section:CreateToggle({ Title = "Aimbot", Callback = function(v) end })
```

## Icons

```lua
Icon = "ph:gear"          -- Phosphor
Icon = "lucide:settings"  -- Lucide
Icon = "settings"         -- auto-detect
Icon = "rbxassetid://..." -- direct asset
```

## Themes

`Dark` · `Midnight` · `Amethyst` · `Rose` · `Aqua` · `Emerald` · `Darker`
