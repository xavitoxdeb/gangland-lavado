fx_version 'bodacious'
game 'gta5'

author 'Xavitox'
version '1.0.0'

shared_scripts {
    'config.lua'
}

server_scripts {
    '@es_extended/locale.lua',
    'server.lua',
    '@mysql-async/lib/MySQL.lua'
}

client_scripts {
    '@es_extended/locale.lua',
    'client.lua'
}
