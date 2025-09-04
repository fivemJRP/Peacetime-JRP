-- Optimized by Justice Gaming Network (JGN) - Elevate your FiveM experience with top-tier scripts!

Config = {}

-- Command to toggle peacetime
Config.Command = 'peacetime'

-- Chat suggestion for the command
Config.CommandSuggestion = 'Toggle peacetime mode'

-- ACE permission required to run the command
Config.ACEPerm = 'peacetime.toggle'

-- Duration in seconds for peacetime to auto-deactivate (0 = no auto-deactivation)
Config.Duration = 0  -- Manual toggle only

-- Loop wait time in ms for client-side checks (higher = better performance, lower = more responsive)
Config.LoopWait = 0  -- Continuous enforcement to prevent firing

-- Notification messages for peacetime changes (use {activator} for the player's name)
Config.Message = {
    Prefix = '🌿 Peacetime Alert',
    Active = '🔒 Peacetime activated by {activator}! Weapons and chaos are on lockdown. Time to chill! 🕊️',
    Deactive = '🔓 Peacetime deactivated by {activator}! Back to the wild west. Stay safe! ⚡'
}

-- Discord webhook URL for logging
Config.WebhookURL = 'PUT WEBHOOK HERE'  -- Replace with your actual webhook URL

-- Name of the webhook "user"
Config.WebhookName = 'Peacetime Logs'