-- Optimized by Justice Gaming Network (JGN) - Elevate your FiveM experience with top-tier scripts!

local peacetimeActive = false
local peacetimeTimer = nil  -- Cache timer handle for proper cleanup
local playerCooldowns = {}  -- Track per-player toggle cooldowns

-- Config validation on startup
Citizen.CreateThread(function()
    if not Config.WebhookURL or Config.WebhookURL == 'PUT WEBHOOK HERE' then
        print('Warning: Webhook URL not set in config.lua')
    end
    if Config.Duration < 0 then
        Config.Duration = 0
        print('Warning: Duration set to 0 (manual toggle only)')
    end
end)

RegisterServerEvent('peacetime:sync')
AddEventHandler('peacetime:sync', function()
    TriggerClientEvent('peacetime:toggle', source, peacetimeActive)
end)

RegisterCommand(Config.Command, function(source, args, rawCommand)
    if not IsPlayerAceAllowed(source, Config.ACEPerm) then
        TriggerClientEvent('chat:addMessage', source, {color = {255, 0, 0}, args = {'Peacetime', 'You lack permission to toggle peacetime.'}})
        return
    end
    
    -- Per-player cooldown (5s)
    local now = GetGameTimer()
    if playerCooldowns[source] and (now - playerCooldowns[source]) < 5000 then
        TriggerClientEvent('chat:addMessage', source, {color = {255, 0, 0}, args = {'Peacetime', 'Cooldown active. Wait 5 seconds.'}})
        return
    end
    playerCooldowns[source] = now
    
    Citizen.Wait(100)  -- Throttle rapid toggles
    local duration = tonumber(args[1]) or Config.Duration  -- Use argument or config default
    if duration < 0 then duration = 0 end  -- Ensure non-negative
    peacetimeActive = not peacetimeActive
    -- Send to each player with their bypass status
    for _, playerId in ipairs(GetPlayers()) do
        local hasBypass = Config.AllowAdminBypass and IsPlayerAceAllowed(playerId, Config.ACEPerm) or false
        TriggerClientEvent('peacetime:toggle', playerId, peacetimeActive, GetPlayerName(source), hasBypass)
    end
    -- Send server-wide chat message with duration
    local durationText = duration > 0 and ' for ' .. duration .. ' seconds' or ''
    local msg = (peacetimeActive and Config.Message.Active or Config.Message.Deactive):gsub('{activator}', GetPlayerName(source)) .. durationText
    TriggerClientEvent('chat:addMessage', -1, {color = peacetimeActive and {0, 255, 0} or {255, 0, 0}, args = {Config.Message.Prefix, msg}})
    SendWebhook(source, peacetimeActive)
    
    -- Reintroduce timer for auto-toggle if Duration > 0
    if peacetimeActive and duration > 0 then
        if peacetimeTimer then Citizen.ClearTimeout(peacetimeTimer) end
        peacetimeTimer = Citizen.SetTimeout(duration * 1000, function()
            peacetimeActive = false
            TriggerClientEvent('peacetime:toggle', -1, peacetimeActive, 'System')
            SendWebhook(-1, peacetimeActive)
        end)
    elseif not peacetimeActive and peacetimeTimer then
        Citizen.ClearTimeout(peacetimeTimer)
        peacetimeTimer = nil
    end
end)

function SendWebhook(source, status)
    local timestamp = os.date('%Y-%m-%d %H:%M:%S')
    local embedColor = status and 65280 or 16711680
    local thumbnailUrl = status and 'https://i.imgur.com/peaceicon.png' or 'https://i.imgur.com/waricon.png'
    local discordEmbed = {
        {
            ['color'] = embedColor,
            ['title'] = '🌿 Peacetime Toggled',
            ['description'] = '**' .. (source == -1 and 'System' or GetPlayerName(source)) .. '** toggled peacetime to `' .. tostring(status) .. '` at ' .. timestamp,
            ['thumbnail'] = {['url'] = thumbnailUrl},
            ['fields'] = {
                {['name'] = 'Duration', ['value'] = Config.Duration > 0 and tostring(Config.Duration) .. ' seconds' or 'Manual', ['inline'] = true},
                {['name'] = 'Server Status', ['value'] = status and 'Peace Mode Active' or 'Normal Operations', ['inline'] = true}
            },
            ['footer'] = {['text'] = 'Powered by Justice Gaming Network (JGN) - Keep the peace! 🕊️'}
        }
    }
    
    -- Validate embed limits
    local embedJson = json.encode(discordEmbed)
    if #embedJson > 6000 then
        discordEmbed[1]['description'] = string.sub(discordEmbed[1]['description'], 1, 2000) .. '...'
        print('Webhook embed truncated to fit Discord limits')
    end
    
    if Config.WebhookURL then
        local payload = json.encode({username = Config.WebhookName, embeds = discordEmbed})
        print('Sending webhook to: ' .. string.sub(Config.WebhookURL, 1, 50) .. '...' .. ' | Payload size: ' .. #payload .. ' bytes')
        
        -- Webhook retries with backoff
        local retryCount = 0
        local function attemptWebhook()
            PerformHttpRequest(Config.WebhookURL, function(err, text, headers)
                if err == 200 or err == 204 then
                    print('Webhook sent successfully! Status: ' .. tostring(err))
                elseif err == 0 and retryCount < 3 then
                    retryCount = retryCount + 1
                    Citizen.Wait(1000 * retryCount)  -- Exponential backoff
                    attemptWebhook()
                elseif err == 0 then
                    print('Webhook error: Network failure (status 0) - Check your webhook URL or internet connection. URL: ' .. string.sub(Config.WebhookURL, 1, 50) .. '...')
                else
                    print('Webhook error: ' .. tostring(err) .. ' | Response: ' .. (text or 'No response') .. ' | Headers: ' .. json.encode(headers or {}))
                end
            end, 'POST', payload, { ['Content-Type'] = 'application/json' })
        end
        attemptWebhook()
    else
        print('Webhook URL not set in config.lua')
    end
end