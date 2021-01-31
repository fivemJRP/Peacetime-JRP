local peacetimeActive = false

RegisterServerEvent('peacetime:sync')
AddEventHandler('peacetime:sync', function()
    TriggerClientEvent('peacetime:toggle', source, peacetimeActive)
end)

RegisterCommand(Config.Command, function(source, args, rawCommand)
    --if IsPlayerAceAllowed(source, Config.ACEPerm) then
        if peacetimeActive then
            peacetimeActive = false
        else
            peacetimeActive = true
        end
        
        TriggerClientEvent('peacetime:toggle', -1, peacetimeActive)
        SendWebhook(source, peacetimeActive)
    --end
end)





function SendWebhook(source, status)
	discordEmbed = {
		{
			['color'] = '16711680',
			['title'] = 'Peacetime Toggled',
            ['description'] = '**' .. GetPlayerName(source) .. '** toggled the peacetime status to `' .. tostring(status) .. '`',
		}
	}

    if Config.WebhookURL then
		PerformHttpRequest(Config.WebhookURL, function(err, text, headers) end, 'POST', json.encode({username = Config.WebhookName, embeds = discordEmbed}), { ['Content-Type'] = 'application/json' })
	end
end