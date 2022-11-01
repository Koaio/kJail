fx_version "adamant"
game "gta5"
author "Koaio For MaxiDev"

client_scripts {
    "RageUI/RMenu.lua",
    "RageUI/menu/RageUI.lua",
    "RageUI/menu/Menu.lua",
    "RageUI/menu/MenuController.lua",
    "RageUI/components/*.lua",
    "RageUI/menu/**/*.lua",
    "client/config.lua",
    "client/client.lua"
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    "server/sv_config.lua",
    "server/server.lua"
}
