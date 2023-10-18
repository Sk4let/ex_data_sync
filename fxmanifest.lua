--[[ FX Information ]] --
fx_version 'cerulean'
use_experimental_fxv2_oal 'yes'
lua54 'yes'
game 'gta5'

--[[ Resource Information ]] --
name 'ex_data_sync'
version '0.0.1'
description 'ex data using statebag & require onesync'
author 'http://extend-studio.com/'
repository 'https://github.com/Sk4let/ex_data_sync'

--[[ Manifest ]] --

server_scripts {
    'config.lua',
    'server/main.lua'
}

server_only 'yes'