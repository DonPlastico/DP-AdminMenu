fx_version 'cerulean'
game 'gta5'

author 'DP-AdminMenu'
description 'DP-AdminMenu - Panel de Administración Avanzado'
version '1.2.5'

ui_page 'html/index.html'

shared_scripts {
    'config.lua',
    '@qb-core/shared/locale.lua'
}

client_scripts {
    'client/main_cl.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main_sv.lua'
}

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/sounds/alert.mp3',
    'html/sounds/whoosh.mp3',
    'html/img/MAP.webp',
    'html/img/Ubicaciones/*.png'
}

dependencies {
    'qb-core',
    'oxmysql'
}

