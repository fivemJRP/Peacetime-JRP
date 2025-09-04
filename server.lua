-- Optimized by Justice Gaming Network (JGN) - Elevate your FiveM experience with top-tier scripts!

local peacetimeActive = false
local peacetimeTimer = nil  -- Cache timer handle for proper cleanup

RegisterServerEvent('peacetime:sync')
AddEventHandler('peacetime:sync', function()
    TriggerClientEvent('peacetime:toggle', source, peacetimeActive)
end)

RegisterCommand(Config.Command, function(source, args, rawCommand)
    if not IsPlayerAceAllowed(source, Config.ACEPerm) then
        TriggerClientEvent('chat:addMessage', source, {color = {255, 0, 0}, args = {'Peacetime', 'You lack permission to toggle peacetime.'}})
        return
    end
    
    Citizen.Wait(100)  -- Throttle rapid toggles to prevent command spam and server overload
    peacetimeActive = not peacetimeActive
    TriggerClientEvent('peacetime:toggle', -1, peacetimeActive, GetPlayerName(source))
    -- Send server-wide chat message
    local msg = peacetimeActive and Config.Message.Active:gsub('{activator}', GetPlayerName(source)) or Config.Message.Deactive:gsub('{activator}', GetPlayerName(source))
    TriggerClientEvent('chat:addMessage', -1, {color = peacetimeActive and {0, 255, 0} or {255, 0, 0}, args = {Config.Message.Prefix, msg}})
    SendWebhook(source, peacetimeActive)
    
    -- Removed timer logic since Duration = 0
end)

function SendWebhook(source, status)
    local timestamp = os.date('%Y-%m-%d %H:%M:%S')
    local embedColor = status and 65280 or 16711680  -- Green for active, red for inactive
    local thumbnailUrl = status and 'https://i.imgur.com/peaceicon.png' or 'https://i.imgur.com/waricon.png'  -- Placeholder for cool icons
    local discordEmbed = {
        {
            ['color'] = embedColor,
            ['title'] = '🌿 Peacetime Toggled',
            ['description'] = '**' .. (source == -1 and 'System' or GetPlayerName(source)) .. '** toggled peacetime to `' .. tostring(status) .. '` at ' .. timestamp,  -- This logs the activator's name
            ['thumbnail'] = {['url'] = thumbnailUrl},
            ['fields'] = {
                {['name'] = 'Duration', ['value'] = Config.Duration > 0 and tostring(Config.Duration) .. ' seconds' or 'Manual', ['inline'] = true},
                {['name'] = 'Server Status', ['value'] = status and 'Peace Mode Active' or 'Normal Operations', ['inline'] = true}
            },
            ['footer'] = {['text'] = 'Powered by Justice Gaming Network (JGN) - Keep the peace! 🕊️'}
        }
    }
    
    if Config.WebhookURL then
        local payload = json.encode({username = Config.WebhookName, embeds = discordEmbed})
        print('Sending webhook to: ' .. string.sub(Config.WebhookURL, 1, 50) .. '...' .. ' | Payload size: ' .. #payload .. ' bytes')
        PerformHttpRequest(Config.WebhookURL, function(err, text, headers)
            if err == 200 or err == 204 then
                print('Webhook sent successfully! Status: ' .. tostring(err))
            elseif err == 0 then
                print('Webhook error: Network failure (status 0) - Check your webhook URL or internet connection. URL: ' .. string.sub(Config.WebhookURL, 1, 50) .. '...')
            else
                print('Webhook error: ' .. tostring(err) .. ' | Response: ' .. (text or 'No response') .. ' | Headers: ' .. json.encode(headers or {}))
            end
        end, 'POST', payload, { ['Content-Type'] = 'application/json' })
    else
        print('Webhook URL not set in config.lua')
    end
end