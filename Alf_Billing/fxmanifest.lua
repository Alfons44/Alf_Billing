fx_version 'adamant'
games {'gta5'};



ui_page('html/ui.html')


files {
    'html/ui.html',
    'html/script.js',
    'html/style.css'
}


client_script {
  '@es_extended/locale.lua',
  'config.lua',
  'client.lua'
}

server_script {
  '@mysql-async/lib/MySQL.lua',
  '@es_extended/locale.lua',
  'config.lua',
  'server.lua'
}