Config = {}

--Command to start the script
Config.Command = 'peacetime'

--Chat suggestion for command
Config.CommandSuggestion = 'Toggle peacetime'

--ACE Permission required to run the command
Config.ACEPerm = 'peacetime.toggle'

--Color of the "author" of the message
Config.MessageColor = {255, 0, 0}

--Message announcing peacetime change
Config.Message = {
    Prefix = 'Peacetime',
    Active = 'Peacetime has been activated!',
    Deactive = 'Peacetime has been deactivated!',
}

--Discord Webhook Link
Config.WebhookURL = ''

--This is the name of the "user" that will post the webhook
Config.WebhookName = 'Peacetime Logs'