# 🌿 Peacetime-JRP

[![FiveM](https://img.shields.io/badge/FiveM-Compatible-brightgreen)](https://fivem.net/)  
[![Lua](https://img.shields.io/badge/Language-Lua-blue)](https://www.lua.org/)  
[![License](https://img.shields.io/badge/License-None-lightgrey)]()

A sleek, performance-optimized peacetime script for FiveM roleplay servers. Enforce calm by disabling weapons and drive-by during active peacetime, with immersive notifications, screen effects, and Discord logging. Perfect for events or server-wide chill vibes! 🕊️

## ✨ Features
- **Dynamic Toggling**: Admins can toggle peacetime with a simple command, including auto-deactivation after a set duration.
- **Weapon Control**: Automatically disables firing, drive-by, and weapon switching when peacetime is active.
- **Immersive UI**: Cool notifications with emojis, screen blur effects, and help text for players.
- **Personalized Messages**: Displays the activator's name in notifications for accountability.
- **Discord Integration**: Logs toggles to a webhook with timestamps and details.
- **Performance Optimized**: Conditional threads and configurable loop waits to minimize CPU usage.
- **Configurable**: Easy-to-edit settings for commands, permissions, messages, and more.

## 🚀 Installation
1. Download the script files (`server.lua`, `client.lua`, `config.lua`).
2. Place them in your FiveM resource folder: `resources/[your-resource-name]/`.
3. Add `start [your-resource-name]` to your `server.cfg`.
4. Configure `config.lua` with your settings (e.g., webhook URL, permissions).
5. Restart your server and enjoy! 🎉

### Dependencies
- FiveM server (latest recommended).
- No external dependencies—just pure Lua magic.

## 📖 Usage
- **Command**: Use `/peacetime` (requires ACE permission `peacetime.toggle`).
- **For Players**: When peacetime is active, weapons are disabled, and you'll see cool notifications.
- **For Admins**: Toggle anytime; the system auto-logs to Discord.

### Example Notification
When activated:  
![Notification Example](https://via.placeholder.com/300x100?text=🔒+Peacetime+activated+by+Admin!+Weapons+on+lockdown.+Chill!+🕊️)

## ⚙️ Configuration
Edit `config.lua` to customize:
- `Config.Command`: Change the toggle command.
- `Config.Duration`: Set auto-deactivation time (in seconds).
- `Config.LoopWait`: Adjust performance (higher = better CPU, lower = more responsive).
- `Config.Message`: Tweak notification text with `{activator}` placeholder.
- `Config.WebhookURL`: Add your Discord webhook for logging.

```lua
Config = {
    Command = 'peacetime',
    Duration = 300,  -- 5 minutes
    LoopWait = 1000,  -- 1 second checks
    Message = {
        Prefix = '🌿 Peacetime Alert',
        Active = '🔒 Peacetime activated by {activator}! Time to chill! 🕊️'
    }
}
```

## 🤝 Contributing
Got ideas to make it cooler? Fork the repo, tweak the code, and submit a PR. Let's keep the peace flowing! 💡

## 📞 Support
- Issues? Open a GitHub issue or hit up the FiveM forums.
- Inspired by community scripts—stay peaceful out there! ⚡
