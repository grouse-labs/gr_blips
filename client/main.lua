local blip = glib.require('src.blip') --[[@module 'gr_blips.src.blip']]
local TXD <const> = CreateRuntimeTxd('gr_blips')
local IMAGE_PATH <const> = 'images/%s.png'
local NUI_PATH <const> = 'https://cfx-nui-%s/%s'
local images = {}
local creator_sf = nil

---@enum (key) CREATOR_TYP_ARGS
local CREATOR_TYP_ARGS = {
  [0] = {0, 1},
  [1] = {0, 1},
  [2] = {0, 1},
  [3] = {0, 1},
  [4] = {0, 0},
  [5] = {0, 0}
}
--------------------- FUNCTIONS ---------------------

---@param path string
---@param name string
---@param width integer
---@param height integer
---@return integer
local function create_runtime_from_nui(path, name, width, height)
  local obj = CreateDui(path, width, height)
  CreateRuntimeTextureFromDuiHandle(TXD, name, GetDuiHandle(obj))
  return obj
end

---@param title string
---@param verified integer?
---@param rp string?
---@param money string?
---@param ap string?
---@param image string|{resource: string, path: string, name: string, width: integer, height: integer}
local function set_creator_title(title, verified, rp, money, ap, image)
  local is_string = type(image) == 'string'
  if image and image ~= '' and not images[is_string and image or image.name] then
    images[image] = is_string and CreateRuntimeTextureFromImage(TXD, image --[[@as string]], IMAGE_PATH:format(image)) or create_runtime_from_nui(NUI_PATH:format(image.resource, image.path), image.name, image.width, image.height)
    glib.stream.textdict('gr_blips')
  end
  if not creator_sf then creator_sf = glib.scaleform({screen = {frontend = true}}) end
  creator_sf:call('SET_COLUMN_TITLE', {
    1,
    '',
    title,
    verified or 0,
    {texture = true, name = 'gr_blips'},
    {texture = true, name = image and image ~= '' and (is_string and image or image.name) or ''},
    1,
    0,
    rp == '' and false or rp,
    money == '' and false or money,
    ap == '' and false or ap
  })
  if not image then return end
  SetStreamedTextureDictAsNoLongerNeeded('gr_blips')
end

---@param state boolean
local function show_display(state)
  if not creator_sf then return end
  creator_sf:call('SHOW_COLUMN', {1, state})
end

local function clear_display()
  if not creator_sf then return end
  creator_sf:call('SET_DATA_SLOT_EMPTY', {1})
end

local function update_display()
  if not creator_sf then return end
  creator_sf:call('DISPLAY_DATA_SLOT', {1})
end

local function deinit(resource)
  if type(resource) == 'string' and glib._RESOURCE ~= resource then return end
  show_display(false)
  clear_display()
  ReleaseControlOfFrontend()
  SetStreamedTextureDictAsNoLongerNeeded('gr_blips')
  blip.clearall()
  Images = {}
end
--------------------- EXPORTS ---------------------

exports('getall', blip.getall)
exports('getonscreen', blip.getonscreen)
exports('remove', blip.remove)
exports('clearall', blip.clearall)
exports('togglepolice', blip.togglepolice)
exports('createcategory', blip.createcategory)
exports('doescategoryexist', blip.doescategoryexist)
exports('get', blip.get)

exports('new', function(_type, data, options, creator_options)
  local obj = blip.new(_type, data, options, creator_options)
  if not obj then return end
  return obj.id
end)

exports('create', function(handle, _type, data)
  local obj = blip.get(handle):create(_type, data)
  if not obj then return end
  return obj.id
end)

exports('destroy', function(handle)
  local obj = blip.get(handle)
  if not obj then return end
  obj:destroy()
end)

exports('setcoords', function(handle, coords, heading)
  local obj = blip.get(handle)
  if not obj then return end
  obj:setcoords(coords, heading)
end)

exports('setcategory', function(handle, category)
  local obj = blip.get(handle)
  if not obj then return end
  obj:setcategory(category)
end)

exports('setdisplay', function(handle, display)
  local obj = blip.get(handle)
  if not obj then return end
  obj:setdisplay(display)
end)

exports('setpriority', function(handle, priority)
  local obj = blip.get(handle)
  if not obj then return end
  obj:setpriority(priority)
end)

exports('setcolour', function(handle, primary)
  local obj = blip.get(handle)
  if not obj then return end
  obj:setcolour(primary)
end)

exports('setsecondary', function(handle, secondary)
  local obj = blip.get(handle)
  if not obj then return end
  obj:setsecondary(secondary)
end)

exports('setcustomcolour', function(handle, colour)
  local obj = blip.get(handle)
  if not obj then return end
  obj:setcustomcolour(colour)
end)

exports('setopacity', function(handle, opacity)
  local obj = blip.get(handle)
  if not obj then return end
  obj:setopacity(opacity)
end)

exports('setflashes', function(handle, flashes)
  local obj = blip.get(handle)
  if not obj then return end
  obj:setflashes(flashes)
end)

exports('setstyle', function(handle, style)
  local obj = blip.get(handle)
  if not obj then return end
  obj:setstyle(style)
end)

exports('setindicators', function(handle, indicators)
  local obj = blip.get(handle)
  if not obj then return end
  obj:setindicators(indicators)
end)

exports('setname', function(handle, name)
  local obj = blip.get(handle)
  if not obj then return end
  obj:setname(name)
end)

exports('setplayername', function(handle, player_id)
  local obj = blip.get(handle)
  if not obj then return end
  obj:setplayername(player_id)
end)

exports('setrange', function(handle, distance)
  local obj = blip.get(handle)
  if not obj then return end
  obj:setrange(distance)
end)

exports('setoptions', function(handle, options)
  local obj = blip.get(handle)
  if not obj then return end
  obj:setoptions(options)
end)

exports('setcreator', function(handle, toggle)
  local obj = blip.get(handle)
  if not obj then return end
  obj:setcreator(toggle)
end)

exports('setcreatortitle', function(handle, title, verified)
  local obj = blip.get(handle)
  if not obj then return end
  obj:setcreatortitle(title, verified)
end)

exports('setcreatorimage', function(handle, image)
  local obj = blip.get(handle)
  if not obj then return end
  obj:setcreatorimage(image)
end)

exports('setcreatoreconomy', function(handle, rp, money, ap)
  local obj = blip.get(handle)
  if not obj then return end
  obj:setcreatoreconomy(rp, money, ap)
end)

exports('addinfotitle', function(handle, title)
  local obj = blip.get(handle)
  if not obj then return end
  local _, key = obj:addinfotitle(title)
  return key
end)

exports('addinfotitleandtext', function(handle, title, text)
  local obj = blip.get(handle)
  if not obj then return end
  local _, key = obj:addinfotitleandtext(title, text)
  return key
end)

exports('addinfoicon', function(handle, icon, colour, checked)
  local obj = blip.get(handle)
  if not obj then return end
  local _, key = obj:addinfoicon(icon, colour, checked)
  return key
end)

exports('addinfoplayer', function(handle, title, name, crew, is_social)
  local obj = blip.get(handle)
  if not obj then return end
  local _, key = obj:addinfoplayer(title, name, crew, is_social)
  return key
end)

exports('addinfoheader', function(handle, title)
  local obj = blip.get(handle)
  if not obj then return end
  local _, key = obj:addinfoheader(title)
  return key
end)

exports('addinfotext', function(handle, text)
  local obj = blip.get(handle)
  if not obj then return end
  local _, key = obj:addinfotext(text)
  return key
end)

exports('updateinfo', function(handle, key, info)
  local obj = blip.get(handle)
  if not obj then return end
  obj:updateinfo(key, info)
end)

exports('clearinfo', function(handle, key)
  local obj = blip.get(handle)
  if not obj then return end
  obj:clearinfo(key)
end)

exports('setcreatoroptions', function(handle, options)
  local obj = blip.get(handle)
  if not obj then return end
  obj:setcreatoroptions(options)
end)

--------------------- EVENTS ---------------------

AddEventHandler('onResourceStop', deinit)

--------------------- THREADS ---------------------

CreateThread(function()
  local handle = 0
  local sleep = 1000
  while true do
    if IsPauseMenuActive() then
      if IsFrontendReadyForControl() then
        sleep = 100
        if IsHoveringOverMissionCreatorBlip() then
          handle = GetNewSelectedMissionCreatorBlip()
          if --[[handle ~= last_blip and]] handle ~= 0 then
            local creator = blip.get(handle)?.creator
            -- last_blip = handle
            if not creator then
              show_display(false)
            else
              local info = creator.info
              TakeControlOfFrontend()
              clear_display()
              set_creator_title(creator.title, creator.verified--[[@as integer]], creator.rp, creator.money, creator.ap, creator.image)
              if info and #info > 0 and creator_sf then
                for i = 1, #info do
                  local entry = info[i]
                  local _type = entry._type
                  local args = CREATOR_TYP_ARGS[_type]
                  local index = i - 1
                  creator_sf:call('SET_DATA_SLOT', {
                    1,
                    index,
                    65,
                    index,
                    _type,
                    args[1],
                    args[2],
                    entry.title or entry.text or '',
                    entry.text or entry.name or '',
                    entry.icon or entry.crew,
                    entry.colour or entry.social,
                    entry.checked
                  })
                end
              end
              glib.audio.playsound(false, '', 'SELECT', 'HUD_FRONTEND_DEFAULT_SOUNDSET')
              show_display(true)
              update_display()
              ReleaseControlOfFrontend()
            end
          end
        else
          if handle ~= 0 then
            handle = 0
            show_display(false)
          end
        end
      end
    else
      sleep = 1000
    end
    Wait(sleep)
  end
end)