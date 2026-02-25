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
    'html/sounds/*.mp3',
    'html/sounds/*.wav',
    'html/img/MAP.webp',
    'html/img/Ubicaciones/*.png'
}

dependencies {
    'qb-core',
    'oxmysql'
}

