function logs(Couleur, Titre, Message, Webhook)
    local Content = {
        {
            ["color"] = Couleur,
            ["title"] = Titre,
            ["description"] = Message,
            ["footer"] = {
                ["text"] = LeTime(),
                ["icon_url"] = Config.Logo,
            }
        }
    }
    PerformHttpRequest(Webhook, function() end, 'POST', json.encode({username = nil, embeds = Content}), {['Content-Type'] = 'application/json'})
end


ESX = nil

TriggerEvent(Config.ESX..'esx:getSharedObject', function(obj) ESX = obj end)

local JailTime = {}
local PlayerDead = {}

local function LeTime()
    local date = os.date('*t')

    if date.month < 10 then date.month = '0'..tostring(date.month) end
    if date.day < 10 then date.day = '0'..tostring(date.day) end
    if date.hour < 10 then date.hour = '0'..tostring(date.hour) end
    if date.min < 10 then date.min = '0'..tostring(date.min) end
    if date.sec < 10 then date.sec = '0'..tostring(date.sec) end

    local date = date.day.."/"..date.month.."/"..date.year.." - "..date.hour.." heure "..date.min.." min "..date.sec.." secondes "
    return date
end

function Discord(Couleur, Titre, Message, Webhook)
    local Content = {
        {
            ["color"] = Couleur,
            ["title"] = Titre,
            ["description"] = Message,
            ["footer"] = {
                ["text"] = LeTime(),
                ["icon_url"] = Config.Logo,
            }
        }
    }
    PerformHttpRequest(Webhook, function() end, 'POST', json.encode({username = nil, embeds = Content}), {['Content-Type'] = 'application/json'})
end

RegisterNetEvent("koaio:updatejailplayerider", function(check)
    local xPlayer = ESX.GetPlayerFromId(source)
    if check then 
        PlayerDead[source] = {}
        print(PlayerDead[source])

    else
        PlayerDead[source] = nil
    end
end)

RegisterNetEvent("requestjailtime")
AddEventHandler("requestjailtime", function()
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.Async.fetchAll('SELECT * FROM `jail_player` WHERE `identifier` = @identifier', {
        ['@identifier'] = xPlayer.identifier
    }, function(result)
        if result[1] then
            if not JailTime[xPlayer.source] then
                print(result[1].staffname)
                JailTime[xPlayer.source] = {}
                JailTime[xPlayer.source].time = result[1].time
                JailTime[xPlayer.source].reason = result[1].raison
                JailTime[xPlayer.source].staffname = result[1].staffname
                TriggerClientEvent("requestRequetteJailTime", xPlayer.source, JailTime[xPlayer.source].time)
                SetEntityCoords(GetPlayerPed(xPlayer.source), Config.PointEntrer)
                TriggerClientEvent(Config.ESX.."esx:showNotification", xPlayer.source, 'Vous vous êtes déconnecter en étant en jail.')
                TriggerClientEvent("koaio:menujail", xPlayer.source, JailTime[xPlayer.source].time, JailTime[xPlayer.source].reason, JailTime[xPlayer.source].staffname)
            end
        else
            JailTime[xPlayer.source] = {}
            JailTime[xPlayer.source].time = 0
        end
    end)
end)

RegisterNetEvent("UpdateJailTick")
AddEventHandler("UpdateJailTick", function(NewJailTime)
    local xPlayer = ESX.GetPlayerFromId(source)
    JailTime[xPlayer.source].time = NewJailTime
    if tonumber(JailTime[xPlayer.source].time) == 0 then
        JailTime[xPlayer.source].time = 0
        TriggerClientEvent(Config.ESX.."esx:showNotification", source, 'Votre sanction est désormais terminer, prenez celle-ci comme un avertissement avant le ban. Bon jeu à vous !')
        MySQL.Async.execute('DELETE FROM jail_player WHERE `identifier` = @identifier', {
            ['@identifier'] = xPlayer.identifier
        })
        SetEntityCoords(GetPlayerPed(xPlayer.source), Config.PointSortie)
    end
end)

RegisterCommand('jail', function(source,args)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.getGroup() ~= 'user' then
        local TargetPlayer = ESX.GetPlayerFromId(args[1])
        if TargetPlayer then
            Wait(100)
            if tonumber(JailTime[TargetPlayer.source].time) >= 1 then
                TriggerClientEvent(Config.ESX.."esx:showNotification", source, 'Le joueur est déjà en jail pendant: ~b~'.. JailTime[TargetPlayer.source].time.. ' ~w~minutes')
            else
                local reason = table.concat(args, ' ', 3)
                JailTime[TargetPlayer.source].time = args[2]
                JailTime[TargetPlayer.source].reason = reason
                JailTime[TargetPlayer.source].staffname = xPlayer.getName()
                TriggerClientEvent("requestRequetteJailTime", TargetPlayer.source, JailTime[TargetPlayer.source].time)
                SetEntityCoords(GetPlayerPed(TargetPlayer.source), Config.PointEntrer)
                if args[2] == tostring("1") then 
                    TriggerClientEvent(Config.ESX.."esx:showNotification", source, 'Vous avez jail ~b~'..GetPlayerName(TargetPlayer.source)..' ~w~pendant ~b~'..args[2].. ' ~w~minute')
                else
                    TriggerClientEvent(Config.ESX.."esx:showNotification", source, 'Vous avez jail ~b~'..GetPlayerName(TargetPlayer.source)..' ~w~pendant ~b~'..args[2].. ' ~w~minutes')
                end
                TriggerClientEvent(Config.ESX.."esx:showNotification", TargetPlayer.source, 'Vous avez jail été jail ~w~pendant ~b~'..args[2].. ' ~w~minute')

                TriggerClientEvent("koaio:menujail", TargetPlayer.source, nil,  JailTime[TargetPlayer.source].reason, JailTime[TargetPlayer.source].staffname)
                logs(15158332,"Jail Player", "Le staff **"..xPlayer.getName()..'('..source.."/ "..xPlayer.getGroup()..')** à jail le joueur **'..TargetPlayer.identifier..'('..TargetPlayer.source..")** pendant **"..args[2].." minutes ** pour **"..reason.."**", Config.WebhookJail)

            end
        else
            TriggerClientEvent(Config.ESX.."esx:showNotification", source, 'Aucun joueur trouvé avec l\'id que vous avez entrer')
        end
    end
end)

RegisterCommand('unjail', function(source, args)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.getGroup() ~= 'user' then
        local TargetPlayer = ESX.GetPlayerFromId(args[1])
        if TargetPlayer then
            Wait(100)
            if tonumber(JailTime[TargetPlayer.source].time) >= 0 then
                if Config.StaffOnlyUnjailPlayerJail then 
                    if JailTime[TargetPlayer.source].staffname == xPlayer.getName() then 
                        JailTime[TargetPlayer.source].time = 0
                        TriggerClientEvent(Config.ESX.."esx:showNotification", source, 'Le joueur ~b~'..GetPlayerName(xPlayer.source)..' ~w~à été unjail')
                        TriggerClientEvent("requestRequetteJailTime", TargetPlayer.source, 0)
                        SetEntityCoords(GetPlayerPed(TargetPlayer.source), Config.PointSortie)
                        MySQL.Async.execute('DELETE FROM jail_player WHERE `identifier` = @identifier', {
                            ['@identifier'] = TargetPlayer.identifier
                        })
                        logs(3066993,"Unjail Player", "Le staff **"..xPlayer.getName()..'('..source.."/ "..xPlayer.getGroup()..')** à sorti de jail le joueur **'..TargetPlayer.identifier..'('..TargetPlayer.source..") **", Config.WebhookUnJail)
                    else
                        xPlayer.showNotification("Vous ne pouvez pas sortir ce joueur de prison car vous n'êtes pas l'auteur du jail !")
                    end
                else
                    JailTime[TargetPlayer.source].time = 0
                    TriggerClientEvent(Config.ESX.."esx:showNotification", source, 'Le joueur ~b~'..GetPlayerName(xPlayer.source)..' ~w~à été unjail')
                    TriggerClientEvent("requestRequetteJailTime", TargetPlayer.source, 0)
                    SetEntityCoords(GetPlayerPed(TargetPlayer.source), Config.PointSortie)
                    MySQL.Async.execute('DELETE FROM jail_player WHERE `identifier` = @identifier', {
                        ['@identifier'] = TargetPlayer.identifier
                    })
                    logs(3066993,"Unjail Player", "Le staff **"..xPlayer.getName()..'('..source.."/ "..xPlayer.getGroup()..')** à sorti de jail le joueur **'..TargetPlayer.identifier..'('..TargetPlayer.source..") **", Config.WebhookUnJail)
                end
            else
                TriggerClientEvent(source, 'Le joueur ~b~'..GetPlayerName(TargetPlayer.source)..' ~w~n\'est pas en jail')
            end
        else
            TriggerClientEvent(Config.ESX.."esx:showNotification", source, 'Aucun joueur trouvé avec l\'id que vous avez entrer')
        end
    end
end)

RegisterCommand('jailoffline', function(source, args)
    local xPlayer = ESX.GetPlayerFromId(source)
    local reason = table.concat(args, " ", 3)

    if xPlayer.getGroup() ~= 'user' then
        MySQL.Async.execute("INSERT INTO jail_player (identifier, time, raison, staffname) VALUES (@identifier, @time, @raison, @staffname)", {
            ["@identifier"] = args[1], 
            ["@time"] = args[2],
            ["@raison"] = reason, 
            ["@staffname"] = xPlayer.getName()
        })
        logs(15105570,"Jail offline Player", "Le staff **"..xPlayer.getName().."("..source.."/ "..xPlayer.getGroup()..")** à jail offline le joueur **"..args[1].."* pendant **"..args[2].." minutes ** ", Config.WebhookJailOffline)
    end
end)

AddEventHandler('playerDropped', function (reason)
    local xPlayer = ESX.GetPlayerFromId(source)
    if tonumber(JailTime[xPlayer.source].time) > 0 then 
        reasontobdd = JailTime[xPlayer.source].reason
        staffnametobb = JailTime[xPlayer.source].staffname    
    end
    print(PlayerDead[xPlayer.source])
    if (xPlayer) then
        if JailTime[xPlayer.source] then
            local TimeJail = tonumber(JailTime[xPlayer.source].time)
            if tonumber(TimeJail) >= 1 then
                MySQL.Async.fetchAll('SELECT * FROM `jail_player` WHERE `identifier` = @identifier', {
                    ['@identifier'] = xPlayer.identifier
                }, function(result)
                    if result[1] then
                        MySQL.Async.execute('UPDATE jail_player SET time = @time WHERE identifier = @identifier',{
                            ['@identifier'] = xPlayer.identifier,
                            ['@time'] = TimeJail,
                        })
                    else
                        MySQL.Async.execute('INSERT INTO jail_player (identifier, time, raison, staffname) VALUES (@identifier, @time, @raison, @staffname)', {
                            ['@identifier'] = xPlayer.identifier,
                            ['@time'] = TimeJail,
                            ["@raison"] = reasontobdd,
                            ["@staffname"] = staffnametobb
                        }, function()
                        end)
                    end
                end)
                JailTime[xPlayer.source] = nil
            end
        end
        if Config.JailPlayerDead then 
            if PlayerDead[source] then 
                MySQL.Async.execute('INSERT INTO jail_player (identifier, time, raison, staffname) VALUES (@identifier, @time, @raison, @staffname)', {
                    ['@identifier'] = xPlayer.identifier,
                    ['@time'] = 10,
                    ["@raison"] = "Déco mort",
                    ["@staffname"] = "ANTI DECO MORT"
                })
            end
        end
    end
end)