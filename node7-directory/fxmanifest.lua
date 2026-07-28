fx_version 'cerulean'
game 'rdr3'

rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

lua54 'yes'

author 'NODE7 Development Studios'
description 'Premium native-inspired RedM server guide and location directory for the NODE7 Framework.'
version '1.2.2'

shared_scripts {
    'config.lua',
    'shared/validation.lua'
}

client_scripts {
    'client/preload.lua',
    'client/main.lua'
}

server_scripts {
    'server/preload.lua',
    'server/main.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/app.js',
    'html/sounds/*.ogg'
}

dependency 'node7-core'
