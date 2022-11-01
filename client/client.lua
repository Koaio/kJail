ESX = nil
Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent(Config.ESX..'esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)

local JailTime = 0

RegisterNetEvent("requestRequetteJailTime")
AddEventHandler("requestRequetteJailTime", function(result)
    JailTime = result
    if JailTime == 0 then
        RageUI.CloseAll()
    end 
end)


RegisterNetEvent("koaio:menujail")
AddEventHandler("koaio:menujail", function(time, raison, staffname)
    local mainjail = RageUI.CreateMenu("Prison", "Vous êtes emprisonnée")
    mainjail.Closable = false 
    
    RageUI.Visible(mainjail, not RageUI.Visible(mainjail))

    inJail = true 

    while mainjail do 
        Wait(0)

        RageUI.IsVisible(mainjail, function()

            if tostring(JailTime) == "1" then 
                RageUI.Separator("Temps restant:~r~ 1 minute")
            else
                RageUI.Separator("Temps restant:~r~ "..ESX.Math.Round(JailTime).." minutes")
            end


            if raison ~= nil then 
                RageUI.Button("Raison: ~o~"..raison.."", nil, {}, true, {})
            else
                RageUI.Button("Raison: ~o~ Indéfinie", nil, {}, true, {})
            end

            if staffname ~= nil then 
                RageUI.Button("Nom du staff: ~g~"..staffname, nil, {}, true, {})
            else
                RageUI.Button("> CONSOLE", nil, {}, true, {})
            end

        end, function()
        end)

        if not RageUI.Visible(mainjail) then 
            mainjail = RMenu:DeleteType('mainjail')
        end
    end
end)

Citizen.CreateThread(function()
    Wait(2500)
    TriggerServerEvent("requestjailtime")
    while true do
        if tonumber(JailTime) >= 1 then
            Wait(60000)
            JailTime = JailTime - 1
            TriggerServerEvent("UpdateJailTick", JailTime)
        end
        if tonumber(JailTime) == 0 then 
            RageUI.CloseAll()
        end
        Wait(2500)
    end
end)

Citizen.CreateThread(function()
    while true do
        if tonumber(JailTime) >= 1 then
            if #(GetEntityCoords(PlayerPedId()) - Config.PointEntrer) > 50 then
                SetEntityCoords(PlayerPedId(), Config.PointEntrer)
            end
            if tonumber(JailTime) == 1 then 
                DrawMissionText('~w~Vous avez été mis en prison par un membre du staff\nVous sortirez dans ~b~'..ESX.Math.Round(JailTime)..' ~w~minute', 100)
            else
                DrawMissionText('~w~Vous avez été mis en prison par un membre du staff\nVous sortirez dans ~b~'..ESX.Math.Round(JailTime)..' ~w~minutes', 100)
            end
        end
        if tonumber(JailTime) >= 1 then
            Wait(0)
        else
            Wait(2500)
        end
    end
end)

function DrawMissionText(msg, time)
    ClearPrints()
    BeginTextCommandPrint('STRING')
    AddTextComponentSubstringPlayerName(msg)
    EndTextCommandPrint(time, 1)
end

AddEventHandler('esx:onPlayerDeath', function(aa)
    TriggerServerEvent("koaio:updatejailplayerider", true)
end)

Citizen.CreateThread(function()
    TriggerEvent('chat:addSuggestion', '/jail', 'Id, temps, raison')

end)

Citizen.CreateThread(function()
    TriggerEvent('chat:addSuggestion', '/jailoffline', 'license, temps, raison ')

end)

Citizen.CreateThread(function()
    TriggerEvent('chat:addSuggestion', '/unjail', 'Id')

end)

Citizen.CreateThread(function()
    local blip = AddBlipForCoord(Config.JailBlip)

    SetBlipSprite(blip, 188)
    SetBlipScale (blip, 1.2)
    SetBlipColour(blip, 40)
    SetBlipAsShortRange(blip, true)

    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName('~b~Prison ~s~| Grand Senora Desert')
    EndTextCommandSetBlipName(blip)
end)