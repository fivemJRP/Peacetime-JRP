# 🌿 Peacetime-JRP

[![FiveM](https://img.shields.io/badge/FiveM-Compatible-brightgreen)](https://fivem.net/)  
[![Lua](https://img.shields.io/badge/Language-Lua-blue)](https://www.lua.org/)  
[![License](https://img.shields.io/badge/License-None-lightgrey)]()

A sleek, performance-optimized peacetime script for FiveM roleplay servers. Enforce calm by disabling weapons, drive-by, and melee during active peacetime, with immersive notifications, chat announcements, and Discord logging. Perfect for events or server-wide chill vibes! 🕊️

## ✨ Features
- **Dynamic Toggling**: Admins can toggle peacetime with `/peacetime [seconds]` (defaults to 300 if not specified).
- **Weapon Control**: Disables firing, drive-by, melee, and weapon switching while keeping the wheel accessible.
- **Admin Bypass**: Configurable option for admins to bypass restrictions.
- **Immersive UI**: Cool notifications with emojis, help text, and activator names.
- **Server-Wide Messages**: Chat broadcasts with duration info.
- **Discord Logging**: Webhook integration with timestamps, fields, and retries.
- **Performance Optimized**: Conditional threads, configurable loops, and caching for minimal CPU usage.
- **Debug Mode**: Optional console prints for troubleshooting.
- **Configurable**: Easy settings for commands, permissions, messages, and more.

## 🚀 Installation
1. Download from GitHub: [https://github.com/fivemJRP/Peacetime-JRP](https://github.com/fivemJRP/Peacetime-JRP)
2. Place in `resources/[your-resource-name]/`
3. Add `start [your-resource-name]` to `server.cfg`
4. Configure `config.lua` (webhook, perms, bypass, debug, etc.)
5. Restart and enjoy! 🎉

### Dependencies
- FiveM server (latest recommended).
- No external dependencies—just pure Lua goodness.

## 📖 Usage
- **Command**: `/peacetime [seconds]` (admins only, e.g., `/peacetime 600` for 10 minutes)
- **For Players**: Weapons disabled during peacetime, notifications shown.
- **For Admins**: Toggle anytime; bypass if enabled in config.

Example Chat Message:
```
🌿 Peacetime Alert: 🔒 Peacetime activated by Admin! Weapons and chaos are on lockdown. Time to chill! 🕊️ for 300 seconds
```

## ⚙️ Configuration
Edit `config.lua` to customize:
- `Config.Command`: Change the toggle command.
- `Config.Duration`: Set default auto-deactivation time (in seconds).
- `Config.AllowAdminBypass`: Enable/disable admin bypass.
- `Config.Debug`: Enable/disable debug prints.
- `Config.LoopWait`: Adjust performance (lower = more responsive).
- `Config.Message`: Tweak notification text with `{activator}` placeholder.
- `Config.WebhookURL`: Add your Discord webhook for logging.

```lua
Config = {
    Command = 'peacetime',
    Duration = 300,  -- Default 5 minutes
    AllowAdminBypass = true,  -- Admins bypass restrictions
    Debug = false,  -- Enable debug prints
    Message = {
        Prefix = '🌿 Peacetime Alert',
        Active = '🔒 Peacetime activated by {activator}! Time to chill! 🕊️'
    }
}
```

## 🤝 Contributing
Got ideas to make it cooler? Fork the repo, tweak the code, and submit a PR. Let's keep the peace flowing! 💡

## 📞 Support
- Issues? Open a GitHub issue or check the repo for updates.
- Inspired by community scripts—stay peaceful out there! ⚡
