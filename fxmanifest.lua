fx_version 'cerulean'
game 'gta5'

author 'Grouse Labs'
description 'Interactive Blip Framework for FiveM'
version '2.0.0'
url 'https://github.com/grouse-labs/gr_blips'

shared_script '@gr_lib/init.lua'

client_scripts {
  'client/main.lua',
  -- 'example.lua'
}

files {
  'src/blip.lua',
  'shared/config.lua',
  'images/*.png'
}

dependency 'gr_lib'

lua54 'yes'