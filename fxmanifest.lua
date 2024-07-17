fx_version 'cerulean'
game 'gta5'

ui_page 'ui/index.html'

files {
    'ui/index.html',
    'ui/scripts.js',
    'ui/styles.css',
    'ui/images/*.png'
}

client_script 'client/main.lua'
server_script 'server/main.lua'
shared_script 'config.lua'


exports {
    'OpenRegister',
    'OpenPayment'
}
