Config = {}

Config.ESX = "" -- Si vous utilisez une base calif, mettez "::{korioz#0110}::" entre les guillaumets sinon laisser vide

Config.PointSortie = vector3(1853.835, 2639.68, 45.672) -- Position de l'unjail
Config.PointEntrer = vector3(1642.493, 2570.144, 45.564) -- Position de la jail
Config.JailBlip = vector3(1702.31, 2592.37, 45.56)  -- Position du blip sur la carte

Config.WebhookJail = "WEBHOOK" -- Logs des personnes jail
Config.WebhookUnJail = "" -- Logs des personnes unjail
Config.WebhookJailOffline = ""-- Logs des personnes jail offline
Config.StaffOnlyUnjailPlayerJail = true -- True = si vous voulez que seulement la personne qui la mis en jail peut le unjail / Flase = si vous voulez pas cette option
Config.TimerJailMortDeco = 10 -- Le temps du jail si la personne se déco si il est coma
Config.JailPlayerDead = true -- True = si vous voulez que la personne sois en jail si elle déco / False si vous voulez pas cette option
Config.Logo = "URL LOGO" -- l'url du footer de votre logs discord

-- Si vous souhaitez retirer le joueur de la table quand il est revive pour éviter qu'il soit mis en prison, mettez le trigger : TriggerServerEvent("koaio:updatejailplayerider", true)