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
    SendWebhook(source, peacetimeActive)
    
    if peacetimeActive and Config.Duration > 0 then
        if peacetimeTimer then Citizen.ClearTimeout(peacetimeTimer) end  -- Clear existing timer to avoid overlaps
        peacetimeTimer = Citizen.SetTimeout(Config.Duration * 1000, function()
            peacetimeActive = false
            TriggerClientEvent('peacetime:toggle', -1, peacetimeActive, 'System')
            SendWebhook(-1, peacetimeActive)
        end)
    elseif not peacetimeActive then
        if peacetimeTimer then
            Citizen.ClearTimeout(peacetimeTimer)  -- Ensure cleanup to prevent memory leaks
            peacetimeTimer = nil
        end
    end
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
        PerformHttpRequest(Config.WebhookURL, function(err, text, headers)
            if err ~= 200 then
                print('Webhook error: ' .. tostring(err))  -- Async handling prevents blocking server threads
            end
        end, 'POST', json.encode({username = Config.WebhookName, embeds = discordEmbed}), { ['Content-Type'] = 'application/json' })
    end
end