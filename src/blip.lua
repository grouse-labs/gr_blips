local blips = {}
local blip = {}
local _mt = {
  __name = 'blip',
  __index = blip
}

---@enum (key) BLIP_TYPES
local BLIP_TYPES <const> = {
  area = AddBlipForArea,
  coord = AddBlipForCoord,
  entity = AddBlipForEntity,
  ped = AddBlipForEntity,
  vehicle = AddBlipForEntity,
  object = AddBlipForEntity,
  pickup = AddBlipForPickup,
  radius = AddBlipForRadius,
  race = RaceGalleryAddBlip
}

local category_type = {
  --[[
    https://github.com/vhub-team/native-db/blob/f1635dda3a5ac6cda982c97f105c07a341d2c022/enums/BLIP_CATEGORY.md
    https://github.com/scripthookvdotnet/scripthookvdotnet/blob/e219d506b32a2ba9a6676c6eae5d99208a22bff8/source/scripting_v3/GTA/Blip/BlipCategoryType.cs
  ]] --
  nodist = 1,
  dist = 2,
  jobs = 3,
  myjobs = 4,
  mission = 5,
  activity = 6,
  players = 7,
  shops = 8,
  races = 9,
  property = 10,
  ownedproperty = 11,
}

---@enum (key) VERIFIED_TYPES
local VERIFIED_TYPES <const> = {
  none = 0,
  verified = 1,
  created = 2
}

local eBlipType = enum('eBlipType')
local eBlipDisplay = enum('eBlipDisplay')
local police_blips = false

--------------------- FUNCTIONS ---------------------

---@param key string
---@param label string
local function add_label(key, label)
  if DoesTextLabelExist(key) and GetLabelText(key) == label then return end
  AddTextEntry(key, label)
end

local function normalise_alpha(value)
  if not value or type(value) ~= 'number' then return 255 end
  if value < 0 then value = 0 elseif value > 255 then value = 255 end
  return math.floor(value)
end

local function custom_blip_flash(blip_id, colour_a, colour_b, interval, duration)
  if not DoesBlipExist(blip_id) then return end
  CreateThread(function()
    local colours = {colour_a, colour_b}
    local index = 1
    local end_time = GetGameTimer() + duration
    local obj = blip.get(blip_id)
    interval = interval or 500
    while DoesBlipExist(blip_id) and (duration < 0 or GetGameTimer() < end_time) and obj.options.flashes do
      SetBlipColour(blip_id, colours[index])
      index = index == 1 and 2 or 1
      Wait(interval)
    end
  end)
end

local function format_crew_tag(crew) return ('{*_%s}'):format(crew or 'NULL') end

function blip.__getall()
  local result = {}
  for i = 0, 921 do
    local blip_id = GetFirstBlipInfoId(i)
    while DoesBlipExist(blip_id) do
      result[#result + 1] = blip_id
      if not blips['blips:'..blip_id] then
        local _type = eBlipType:lookup(GetBlipInfoIdType(blip_id)):lower() --[[@as string]]
        local coords = _type == 'coord' and GetBlipCoords(blip_id) or nil
        local entity = _type == 'vehicle' or _type == 'ped' or _type == 'object' and GetBlipInfoIdEntityIndex(blip_id) or nil
        blips['blips:'..blip_id] = setmetatable({
          id = blip_id,
          _type = _type,
          data = {
            coords = coords,
            entity = entity,
            ped = entity,
            vehicle = entity,
            object = entity,
            pickup = _type == 'pickup' and GetBlipInfoIdPickupIndex(blip_id) or nil
          },
          options = {
            coords = coords,
            sprite = GetBlipSprite(blip_id),
            primary = GetBlipHudColour(blip_id),
            opacity = GetBlipAlpha(blip_id),
            category = 'unknown',
            display = eBlipDisplay:lookup(GetBlipInfoIdDisplay(blip_id)):lower() --[[@as string]]
          },
          creator_options = {}
        }, _mt)
      end
      blip_id = GetNextBlipInfoId(blip_id)
    end
  end
  return result
end

function blip.getall()
  if not next(blips) then blip.__getall() end
  return blips
end

function blip.getonscreen()
  local all_blips = blip.__getall()
  local result = {}
  for i = 1, #all_blips do
    local blip_id = all_blips[i]
    if IsBlipOnMinimap(blip_id) then
      result[#result + 1] = blips['blips:'..blip_id]
    end
  end
  return result
end

function blip.remove(id)
  if not id or type(id) ~= 'number' then error('bad argument #1 to \'blip.remove\' (number expected)', 2) end
  RemoveBlip(id)
  if blips['blips:'..id] then blips['blips:'..id]._type = 'null' end
end

function blip.clearall()
  if not blips then return end
  for _, obj in pairs(blips) do obj:destroy() end
end

function blip.togglepolice(toggle)
  police_blips = toggle
  SetPoliceRadarBlips(toggle)
  return police_blips
end

function blip.createcategory(name)
  if not name or type(name) ~= 'string' then error('bad argument #1 to \'blip.createcategory\' (string expected)', 2) end
  if category_type[name:lower()] then error('bad argument #1 to \'blip.createcategory\' (category already exists)', 2) end
  local id = #category_type + 1
  if id > 133 then
    error('bad argument #1 to \'blip.createcategory\' (maximum number of categories reached)', 2)
  end
  category_type[name:lower()] = id
  add_label('BLIP_CAT_'..id, name)
  return id
end

function blip.doescategoryexist(name)
  if not name or type(name) ~= 'string' then error('bad argument #1 to \'blip.createcategory\' (string expected)', 2) end
  return category_type[name:lower()] ~= nil
end

function blip.get(id)
  if not id or type(id) ~= 'number' then error('bad argument #1 to \'blip.get\' (number expected)', 2) end
  return blips['blips:'..id]
end

function blip.new(_type, data, options, creator_options)
  _type = _type and _type:lower()
  if not BLIP_TYPES[_type] then error('bad argument #1 to \'blip.new\' (invalid blip type)', 2) end
  if not data or type(data) ~= 'table' then error('bad argument #2 to \'blip.new\' (table expected)', 2) end
  options.sprite = options.sprite or 1
  options.coords = options.coords or data.coords
  options.category = options.category or 'nodist'
  options.display = options.display or 'marker'
  options.primary = options.primary or 1
  options.opacity = options.opacity or 255
  options.is_creator = options.is_creator or false
  local obj = {
    _type = 'null',
    data = data,
    options = options,
    creator = creator_options,
  }
  obj = setmetatable(obj, _mt)
  obj:create(_type, data)
  blips['blips:'..obj.id] = obj
  obj:setoptions(options)
  if creator_options then
    obj:setcreator(true)
    obj:setcreatoroptions(creator_options)
  end
  return obj
end

function blip:create(_type, data)
  _type = _type and _type:lower()
  if not BLIP_TYPES[_type] then error('bad argument #1 to \'blip.create\' (invalid blip type)', 2) end
  if not data or type(data) ~= 'table' then error('bad argument #2 to \'blip.create\' (table expected)', 2) end
  local coords = data.coords
  local width = data.width
  local height = data.height
  local entity = data.entity
  local ped = data.ped
  local vehicle = data.vehicle
  local object = data.object
  local pickup = data.pickup
  local radius = data.radius
  local blip_id = -1
  if _type == 'area' and coords and width and height then
    blip_id = BLIP_TYPES.area(coords.x, coords.y, coords.z, width, height)
  elseif _type == 'coord' and coords then
    blip_id = BLIP_TYPES.coord(coords.x, coords.y, coords.z)
  elseif _type == 'entity' and entity or _type == 'ped' and ped or _type == 'vehicle' and vehicle or _type == 'object' and object then
    if not DoesEntityExist(entity) then
      error('bad argument #2 to \'blip.create\' (entity does not exist)', 2)
    end
    blip_id = BLIP_TYPES.entity(entity)
    _type = eBlipType:lookup(eBlipType:lookup(_type)--[[@as integer]]):lower() --[[@as 'vehicle'|'ped'|'object']]
    self.data.entity = entity or ped or vehicle or object
  elseif _type == 'pickup' and pickup then
    if not DoesPickupExist(pickup) then
      error('bad argument #2 to \'blip.create\' (pickup does not exist)', 2)
    end
    blip_id = BLIP_TYPES.pickup(pickup)
  elseif _type == 'radius' and coords and radius then
    if not radius or type(radius) ~= 'number' then
      error('bad argument #2 to \'blip.create\' (radius expected)', 2)
    end
    blip_id = BLIP_TYPES.radius(coords.x, coords.y, coords.z, radius)
  elseif _type == 'race' and coords then
    blip_id = BLIP_TYPES.race(coords.x, coords.y, coords.z)
  else
    error('bad argument #2 to \'blip.create\' (invalid data)', 2)
  end
  self.id = blip_id
  self._type = _type
  return self
end

function blip:destroy()
  if not blip.get(self.id) then error('bad argument #1 to \'blip.destroy\' (invalid blip)', 2) end
  local blip_id = self.id
  blip.remove(blip_id)
  blips['blips:'..blip_id] = nil
  self = nil
  return true
end

function blip:setcoords(coords, heading)
  if not blip.get(self.id) then error('bad argument #1 to \'blip.setcoords\' (invalid blip)', 2) end
  local blip_id = self.id
  SetBlipCoords(blip_id, coords.x, coords.y, coords.z or 0)
  self.options.coords = coords
  if not heading then return self end
  if heading % 1 ~= 0 then
    SetBlipSquaredRotation(blip_id, heading)
  else
    SetBlipRotation(blip_id, heading)
  end
  self.options.coords.w = heading
  return self
end

function blip:getcoords()
  if not blip.get(self.id) then error('bad argument #1 to \'blip.getcoords\' (invalid blip)', 2) end
  return self.options.coords
end

function blip:setsprite(sprite)
  if not blip.get(self.id) then error('bad argument #1 to \'blip.setsprite\' (invalid blip)', 2) end
  if not sprite or type(sprite) ~= 'number' then error('bad argument #2 to \'blip.setsprite\' (number expected)', 2) end
  local blip_id = self.id
  SetBlipSprite(blip_id, sprite)
  self.options.sprite = sprite
  return self
end

function blip:setcategory(category)
  if not blip.get(self.id) then error('bad argument #1 to \'blip.setcategory\' (invalid blip)', 2) end
  if not category or type(category) ~= 'string' then error('bad argument #2 to \'blip.setcategory\' (string expected)', 2) end
  local blip_id = self.id
  local category_id = category_type[category:lower()] or blip.createcategory(category)
  SetBlipCategory(blip_id, category_id)
  self.options.category = category
  return self
end

function blip:getcategory()
  if not blip.get(self.id) then error('bad argument #1 to \'blip.getcategory\' (invalid blip)', 2) end
  return self.options.category
end

function blip:setdisplay(display)
  if not blip.get(self.id) then error('bad argument #1 to \'blip.setdisplay\' (invalid blip)', 2) end
  display = display:upper()
  if not eBlipDisplay:lookup(display) then
    error('bad argument #2 to \'blip.setdisplay\' (invalid display)', 2)
  end
  local blip_id = self.id
  local display_id = eBlipDisplay:lookup(display) --[[@as integer]]
  SetBlipDisplay(blip_id, display_id)
  self.options.display = display
  return self
end

function blip:getdisplay()
  if not blip.get(self.id) then error('bad argument #1 to \'blip.getdisplay\' (invalid blip)', 2) end
  return self.options.display
end

function blip:setpriority(priority)
  if not blip.get(self.id) then error('bad argument #1 to \'blip.setpriority\' (invalid blip)', 2) end
  if not priority or type(priority) ~= 'number' then error('bad argument #2 to \'blip.setpriority\' (number expected)', 2) end
  local blip_id = self.id
  SetBlipPriority(blip_id, priority) -- NATIVE: -https://github.com/vhub-team/native-db/blob/main/enums/BLIP_PRIORITY.md
  self.options.priority = priority
  return self
end

function blip:getpriority()
  if not blip.get(self.id) then error('bad argument #1 to \'blip.getpriority\' (invalid blip)', 2) end
  return self.options.priority
end

function blip:setcolour(colour)
  if not blip.get(self.id) then error('bad argument #1 to \'blip.setcolour\' (invalid blip)', 2) end
  if not colour or type(colour) ~= 'number' then error('bad argument #2 to \'blip.setcolour\' (number expected)', 2) end
  local blip_id = self.id
  SetBlipColour(blip_id, colour)
  self.options.primary = colour
  return self
end

function blip:getcolour()
  if not blip.get(self.id) then error('bad argument #1 to \'blip.getcolour\' (invalid blip)', 2) end
  local primary = self.options.primary
  return primary ~= 84 and primary or self.options.secondary
end

function blip:setsecondary(secondary)
  if not blip.get(self.id) then error('bad argument #1 to \'blip.setsecondary\' (invalid blip)', 2) end
  if not secondary or not secondary.r or not secondary.g or not secondary.b then error('bad argument #2 to \'blip.setsecondary\' (r, g, b expected)', 2) end
  local blip_id = self.id
  SetBlipSecondaryColour(blip_id, secondary.r, secondary.g, secondary.b)
  self.options.secondary = secondary
  return self
end

function blip:getsecondary()
  if not blip.get(self.id) then error('bad argument #1 to \'blip.getsecondary\' (invalid blip)', 2) end
  return self.options.secondary
end

function blip:setcustomcolour(colour)
  if not blip.get(self.id) then error('bad argument #1 to \'blip.setcustomcolour\' (invalid blip)', 2) end
  if not colour or not colour.r or not colour.g or not colour.b then
    error('bad argument #2 to \'blip.setcustomcolour\' (r, g, b expected)', 2)
  end
  self:setcolour(84) -- Allows RGB primary colour
  self:setsecondary(colour)
  return self
end

function blip:setopacity(opacity)
  if not blip.get(self.id) then error('bad argument #1 to \'blip.setopacity\' (invalid blip)', 2) end
  local blip_id = self.id
  opacity = normalise_alpha(opacity)
  SetBlipAlpha(blip_id, opacity)
  self.options.opacity = opacity
  return self
end

function blip:getopacity()
  if not blip.get(self.id) then error('bad argument #1 to \'blip.getopacity\' (invalid blip)', 2) end
  return self.options.opacity
end

function blip:setflashes(flashes)
  if not blip.get(self.id) then error('bad argument #1 to \'blip.setflashes\' (invalid blip)', 2) end
  if not flashes or type(flashes) ~= 'table' then error('bad argument #2 to \'blip.setflashes\' (table expected)', 2) end
  local enable = flashes.enable
  local interval = flashes.interval
  local duration = flashes.duration
  local colour = flashes.colour
  local blip_id = self.id
  if not colour then
    SetBlipFlashes(blip_id, enable)
    if interval then SetBlipFlashInterval(blip_id, interval) end
    if duration then SetBlipFlashTimer(blip_id, duration) end
  else
    interval = interval or 500
    duration = duration or -1
    custom_blip_flash(blip_id, self.options.primary, colour, interval or 500, duration or -1)
  end
  self.options.flashes = enable
  self.options.__fl_interval = interval
  self.options.__fl_duration = duration
  self.options.__fl_colour = colour
  return self
end

function blip:getflashes()
  if not blip.get(self.id) then error('bad argument #1 to \'blip.getflashes\' (invalid blip)', 2) end
  return {
    enable = self.options.flashes,
    interval = self.options.__fl_interval,
    duration = self.options.__fl_duration,
    colour = self.options.__fl_colour
  }
end

function blip:setstyle(style)
  if not blip.get(self.id) then error('bad argument #1 to \'blip.setstyle\' (invalid blip)', 2) end
  if not style or type(style) ~= 'table' then error('bad argument #2 to \'blip.setstyle\' (table expected)', 2) end
  local scale = style.scale
  local friendly = style.friendly or false
  local bright = style.bright or false
  local hidden = style.hidden or false
  local hd = style.hd or false
  local show_cone = style.show_cone or false
  local short_range = style.short_range or false
  local shrink = style.shrink or false
  local edge = self._type == 'radius' and style.edge or false
  local blip_id = self.id
  style.friendly = friendly
  style.bright = bright
  style.hidden = hidden
  style.hd = hd
  style.show_cone = show_cone
  style.short_range = short_range
  style.shrink = shrink
  style.edge = edge
  if scale then
    if type(scale) == 'table' and scale.x and scale.y then
      SetBlipScaleTransformation(blip_id, scale.x, scale.y)
    elseif type(scale) == 'number' then
      SetBlipScale(blip_id, scale)
    end
  end
  SetBlipFriendly(blip_id, friendly)
  SetBlipBright(blip_id, bright)
  SetBlipHiddenOnLegend(blip_id, hidden)
  SetBlipHighDetail(blip_id, hd)
  SetBlipShowCone(blip_id, show_cone)
  SetBlipAsShortRange(blip_id, short_range)
  SetBlipShrink(blip_id, shrink)
  SetRadiusBlipEdge(blip_id, edge)
  self.options.style = style
  return self
end

function blip:getstyle()
  if not blip.get(self.id) then error('bad argument #1 to \'blip.getstyle\' (invalid blip)', 2) end
  return self.options.style
end

function blip:setindicators(indicators)
  if not blip.get(self.id) then error('bad argument #1 to \'blip.setindicators\' (invalid blip)', 2) end
  if not indicators or type(indicators) ~= 'table' then error('bad argument #2 to \'blip.setindicators\' (table expected)', 2) end
  local crew = indicators.crew or false
  local friend = indicators.friend or false
  local completed = indicators.completed or false
  local heading = indicators.heading or false
  local height = indicators.height or false
  local count = indicators.count or false
  local outline = indicators.outline or false
  local tick = indicators.tick or false
  local blip_id = self.id
  indicators = {
    crew = crew,
    friend = friend,
    completed = completed,
    heading = heading,
    height = height,
    count = count or nil,
    outline = outline,
    tick = tick
  }
  ShowCrewIndicatorOnBlip(blip_id, crew)
  ShowFriendIndicatorOnBlip(blip_id, friend)
  ShowHasCompletedIndicatorOnBlip(blip_id, completed)
  ShowHeadingIndicatorOnBlip(blip_id, heading)
  ShowHeightOnBlip(blip_id, height)
  if count then ShowNumberOnBlip(blip_id, count) end
  ShowOutlineIndicatorOnBlip(blip_id, outline)
  ShowTickOnBlip(blip_id, tick)
  return self
end

function blip:getindicators()
  if not blip.get(self.id) then error('bad argument #1 to \'blip.getindicators\' (invalid blip)', 2) end
  return self.options.indicators
end

function blip:setname(name)
  if not blip.get(self.id) then error('bad argument #1 to \'blip.setname\' (invalid blip)', 2) end
  if not name or type(name) ~= 'string' then error('bad argument #2 to \'blip.setname\' (string expected)', 2) end
  local blip_id = self.id
  local key = 'BLIP_'..blip_id
  add_label(key, name)
  BeginTextCommandSetBlipName(key)
  EndTextCommandSetBlipName(blip_id)
  self.options.name = name
  return self
end

function blip:getname()
  if not blip.get(self.id) then error('bad argument #1 to \'blip.getname\' (invalid blip)', 2) end
  return self.options.name
end

function blip:setplayername(player_id)
  if not blip.get(self.id) then error('bad argument #1 to \'blip.setplayername\' (invalid blip)', 2) end
  if not player_id or type(player_id) ~= 'number' or not IsPlayerPlaying(player_id) then error('bad argument #2 to \'blip.setplayername\' (player id not valid)', 2) end
  local blip_id = self.id
  SetBlipNameToPlayerName(blip_id, player_id)
  self.options.name = GetPlayerName(player_id)
  return self
end

function blip:setrange(range)
  if not blip.get(self.id) then error('bad argument #1 to \'blip.setrange\' (invalid blip)', 2) end
  if not range or type(range) ~= 'number' then error('bad argument #2 to \'blip.setrange\' (number expected)', 2) end
  self.options.distance = range
  return self
end

function blip:getrange()
  if not blip.get(self.id) then error('bad argument #1 to \'blip.getrange\' (invalid blip)', 2) end
  return self.options.distance
end

function blip:setoptions(options)
  if not blip.get(self.id) then error('bad argument #1 to \'blip.setoptions\' (invalid blip)', 2) end
  if not options or type(options) ~= 'table' then error('bad argument #2 to \'blip.setoptions\' (table expected)', 2) end
  local coords = options.coords
  local sprite = options.sprite
  local primary = options.primary
  local secondary = options.secondary
  local opacity = options.opacity
  local category = options.category
  local display = options.display
  local priority = options.priority
  local style = options.style
  local indicators = options.indicators
  local flashes = options.flashes
  local name = options.name
  local player_id = options.player_id
  local distance = options.distance
  if coords then self:setcoords(coords, coords.w) end
  if sprite then self:setsprite(sprite) end
  if primary then
    if type(primary) == 'number' then
      self:setcolour(primary)
      if secondary then self:setsecondary(secondary) end
    else
      self:setcustomcolour(primary)
    end
  end
  if (not primary or type(primary) == 'number') and secondary then self:setsecondary(secondary) end
  if opacity then self:setopacity(opacity) end
  if category then self:setcategory(category) end
  if display then self:setdisplay(display) end
  if priority then self:setpriority(priority) end
  if style then self:setstyle(style) end
  if indicators then self:setindicators(indicators) end
  if flashes then self:setflashes(flashes) end
  if name and not player_id then self:setname(name)
  elseif player_id then self:setplayername(player_id) end
  if distance then self:setrange(distance) end
  return self
end

function blip:setcreator(toggle)
  if not blip.get(self.id) then error('bad argument #1 to \'blip.setcreator\' (invalid blip)', 2) end
  toggle = toggle or false
  SetBlipAsMissionCreatorBlip(self.id, toggle)
  self.options.is_creator = toggle
  self.creator = toggle and (self.creator or {
    title = '',
    verified = 0,
    image = '',
    rp = '',
    money = '',
    ap = '',
    info = {}
  }) or nil
  return self
end

function blip:iscreator()
  if not blip.get(self.id) then error('bad argument #1 to \'blip.iscreator\' (invalid blip)', 2) end
  return self.options.is_creator
end

function blip:setcreatortitle(title, verified)
  if not blip.get(self.id) then error('bad argument #1 to \'blip.setcreatortitle\' (invalid blip)', 2) end
  if not self:iscreator() then error('bad argument #1 to \'blip.setcreatortitle\' (blip is not a creator blip)', 2) end
  if not title or type(title) ~= 'string' then error('bad argument #2 to \'blip.setcreatortitle\' (string expected)', 2) end
  if verified and type(verified) ~= 'string' then error('bad argument #3 to \'blip.setcreatortitle\' (string or nil expected)', 2) end
  self.creator.title = title
  self.creator.verified = verified and VERIFIED_TYPES[verified:lower()] or 0
  return self
end

function blip:getcreatortitle()
  if not blip.get(self.id) then error('bad argument #1 to \'blip.getcreatortitle\' (invalid blip)', 2) end
  if not self:iscreator() then error('bad argument #1 to \'blip.getcreatortitle\' (blip is not a creator blip)', 2) end
  return self.creator.title, self.creator.verified
end

function blip:setcreatorimage(image)
  if not blip.get(self.id) then error('bad argument #1 to \'blip.setcreatorimage\' (invalid blip)', 2) end
  if not self:iscreator() then error('bad argument #1 to \'blip.setcreatorimage\' (blip is not a creator blip)', 2) end
  if not image or type(image) ~= 'string' then error('bad argument #2 to \'blip.setcreatorimage\' (string expected)', 2) end
  self.creator.image = image
  return self
end

function blip:getcreatorimage()
  if not blip.get(self.id) then error('bad argument #1 to \'blip.getcreatorimage\' (invalid blip)', 2) end
  if not self:iscreator() then error('bad argument #1 to \'blip.getcreatorimage\' (blip is not a creator blip)', 2) end
  return self.creator.image
end

function blip:setcreatoreconomy(rp, money, ap)
  if not blip.get(self.id) then error('bad argument #1 to \'blip.setcreatoreconomy\' (invalid blip)', 2) end
  if not self:iscreator() then error('bad argument #1 to \'blip.setcreatoreconomy\' (blip is not a creator blip)', 2) end
  if rp and type(rp) ~= 'string' then error('bad argument #2 to \'blip.setcreatoreconomy\' (string expected)', 2) end
  if money and type(money) ~= 'string' then error('bad argument #3 to \'blip.setcreatoreconomy\' (string expected)', 2) end
  if ap and type(ap) ~= 'string' then error('bad argument #4 to \'blip.setcreatoreconomy\' (string expected)', 2) end
  self.creator.rp = rp or ''
  self.creator.money = money or ''
  self.creator.ap = ap or ''
  return self
end

function blip:getcreatoreconomy()
  if not blip.get(self.id) then error('bad argument #1 to \'blip.getcreatoreconomy\' (invalid blip)', 2) end
  if not self:iscreator() then error('bad argument #1 to \'blip.getcreatoreconomy\' (blip is not a creator blip)', 2) end
  return self.creator.rp, self.creator.money, self.creator.ap
end

function blip:addinfotitle(title)
  if not blip.get(self.id) then error('bad argument #1 to \'blip.addinfotitle\' (invalid blip)', 2) end
  if not self:iscreator() then error('bad argument #1 to \'blip.addinfotitle\' (blip is not a creator blip)', 2) end
  if not title or type(title) ~= 'string' then error('bad argument #2 to \'blip.addinfotitle\' (string expected)', 2) end
  local key = #self.creator.info + 1
  self.creator.info[key] = {title = title, _type = 0}
  return self, key
end

function blip:addinfotitleandtext(title, text)
  if not blip.get(self.id) then error('bad argument #1 to \'blip.addinfotitleandttext\' (invalid blip)', 2) end
  if not self:iscreator() then error('bad argument #1 to \'blip.addinfotitleandttext\' (blip is not a creator blip)', 2) end
  if not title or type(title) ~= 'string' then error('bad argument #2 to \'blip.addinfotitleandttext\' (string expected)', 2) end
  if not text or type(text) ~= 'string' then error('bad argument #3 to \'blip.addinfotitleandttext\' (string expected)', 2) end
  local key = #self.creator.info + 1
  self.creator.info[key] = {title = title, text = text, _type = 1}
  return self, key
end

function blip:addinfoicon(icon, colour, checked)
  if not blip.get(self.id) then error('bad argument #1 to \'blip.addinfoicon\' (invalid blip)', 2) end
  if not self:iscreator() then error('bad argument #1 to \'blip.addinfoicon\' (blip is not a creator blip)', 2) end
  if not icon or type(icon) ~= 'number' then error('bad argument #2 to \'blip.addinfoicon\' (number expected)', 2) end
  if not colour or type(colour) ~= 'number' then error('bad argument #3 to \'blip.addinfoicon\' (number expected)', 2) end
  local key = #self.creator.info + 1
  self.creator.info[key] = {icon = icon, colour = colour, checked = checked == true or false, _type = 2}
  return self, key
end

function blip:addinfoplayer(title, name, crew, is_social)
  if not blip.get(self.id) then error('bad argument #1 to \'blip.addinfoplayer\' (invalid blip)', 2) end
  if not self:iscreator() then error('bad argument #1 to \'blip.addinfoplayer\' (blip is not a creator blip)', 2) end
  if title and type(title) ~= 'string' then error('bad argument #2 to \'blip.addinfoplayer\' (string or nil expected)', 2) end
  if name and type(name) ~= 'string' then error('bad argument #3 to \'blip.addinfoplayer\' (string or nil expected)', 2) end
  if crew and type(crew) ~= 'string' then error('bad argument #4 to \'blip.addinfoplayer\' (string or nil expected)', 2) end
  local key = #self.creator.info + 1
  self.creator.info[key] = {title = title, name = name, crew = format_crew_tag(crew), social = is_social == true or false, _type = 3}
  return self, key
end

function blip:addinfoheader(title)
  if not blip.get(self.id) then error('bad argument #1 to \'blip.addinfoheader\' (invalid blip)', 2) end
  if not self:iscreator() then error('bad argument #1 to \'blip.addinfoheader\' (blip is not a creator blip)', 2) end
  if not title or type(title) ~= 'string' then error('bad argument #2 to \'blip.addinfoheader\' (string expected)', 2) end
  local key = #self.creator.info + 1
  self.creator.info[key] = {title = title, _type = 4}
  return self, key
end

function blip:addinfotext(text)
  if not blip.get(self.id) then error('bad argument #1 to \'blip.addinfotext\' (invalid blip)', 2) end
  if not self:iscreator() then error('bad argument #1 to \'blip.addinfotext\' (blip is not a creator blip)', 2) end
  if not text or type(text) ~= 'string' then error('bad argument #2 to \'blip.addinfotext\' (string expected)', 2) end
  local key = #self.creator.info + 1
  self.creator.info[key] = {text = text, _type = 5}
  return self, key
end

function blip:updateinfo(key, info)
  if not blip.get(self.id) then error('bad argument #1 to \'blip.updateinfo\' (invalid blip)', 2) end
  if not self:iscreator() then error('bad argument #1 to \'blip.updateinfo\' (blip is not a creator blip)', 2) end
  -- if not self.creator.info[key] then error('bad argument #2 to \'blip.updateinfo\' (key doesn\'t exist)', 2) end
  if not info or type(info) ~= 'table' then error('bad argument #3 to \'blip.updateinfo\' (table expected)', 2) end
  local _type = info._type
  local title = info.title
  local text = info.text
  if (_type == 0 or _type == 1 or _type == 4) and (not title or type(title) ~= 'string') then error('bad argument #3 to \'blip.updateinfo\' (title key expected)', 2) end
  if (_type == 1 or _type == 5) and (not text or type(text) ~= 'string') then error('bad argument #3 to \'blip.updateinfo\' (text key expected)', 2) end
  if _type == 0 then
    self.creator.info[key] = {title = title, _type = 0}
  elseif _type == 1 then
    self.creator.info[key] = {title = title, text = text, _type = 1}
  elseif _type == 2 then
    local icon = info.icon
    local colour = info.colour
    local checked = info.checked
    if not icon or type(icon) ~= 'number' then error('bad argument #3 to \'blip.updateinfo\' (icon key expected)', 2) end
    if not colour or type(colour) ~= 'number' then error('bad argument #3 to \'blip.updateinfo\' (colour key expected)', 2) end
    self.creator.info[key] = {icon = icon, colour = colour, checked = checked == true or false, _type = 2}
  elseif _type == 3 then
    local name = info.name
    local crew = info.crew
    local is_social = info.social
    if title and type(title) ~= 'string' then error('bad argument #3 to \'blip.updateinfo\' (title key or nil expected)', 2) end
    if name and type(name) ~= 'string' then error('bad argument #3 to \'blip.updateinfo\' (name key or nil expected)', 2) end
    if crew and type(crew) ~= 'string' then error('bad argument #3 to \'blip.updateinfo\' (crew key or nil expected)', 2) end
    self.creator.info[key] = {title = title, name = name, crew = format_crew_tag(crew), social = is_social == true or false, _type = 3}
  elseif _type == 4 then
    self.creator.info[key] = {title = title, _type = 4}
  elseif _type == 5 then
    self.creator.info[key] = {text = text, _type = 5}
  end
end

function blip:clearinfo(key)
  if not blip.get(self.id) then error('bad argument #1 to \'blip.clearinfo\' (invalid blip)', 2) end
  if not self:iscreator() then error('bad argument #1 to \'blip.clearinfo\' (blip is not a creator blip)', 2) end
  if key and type(key) ~= 'number' then error('bad argument #2 to \'blip.clearinfo\' (number or nil expected)', 2) end
  if key then
    table.remove(self.creator.info, key)
  else
    self.creator.info = {}
  end
end

function blip:setcreatoroptions(options)
  if not blip.get(self.id) then error('bad argument #1 to \'blip.setcreatoroptions\' (invalid blip)', 2) end
  if not self:iscreator() then error('bad argument #1 to \'blip.setcreatoroptions\' (blip is not a creator blip)', 2) end
  if not options or type(options) ~= 'table' then error('bad argument #2 to \'blip.setcreatoroptions\' (table expected)', 2) end
  local title = options.title
  local verified = options.verified
  local image = options.image
  local rp = options.rp
  local money = options.money
  local ap = options.ap
  local info = options.info
  if title then self:setcreatortitle(title, verified) end
  if image then self:setcreatorimage(image) end
  if rp or money or ap then self:setcreatoreconomy(rp, money, ap) end
  if info then
    self.creator.info = {}
    for i = 1, #info do
      local item = info[i]
      if item._type == 0 then
        self:addinfotitle(item.title)
      elseif item._type == 1 then
        self:addinfotitleandtext(item.title, item.text)
      elseif item._type == 2 then
        self:addinfoicon(item.icon, item.colour, item.checked)
      elseif item._type == 3 then
        self:addinfoplayer(item.title, item.name, item.crew, item.social)
      elseif item._type == 4 then
        self:addinfoheader(item.title)
      elseif item._type == 5 then
        self:addinfotext(item.text)
      end
    end
  end
  return self
end

function blip:__tostring()
  if not blip.get(self.id) then error('bad argument #1 to \'blip.__tostring\' (invalid blip)', 2) end
  local name = self.options.name or 'Unnamed Blip'
  return ('Blip %d (%s): %s'):format(self.id, self._type, name)
end

--------------------- THREADS ---------------------

CreateThread(function()
  SetThisScriptCanRemoveBlipsCreatedByAnyScript(true)
  repeat Wait(100) until LocalPlayer.state.isLoggedIn or NetworkIsSessionStarted()
  while blips do
    local ped = PlayerPedId()
    if DoesEntityExist(ped) then
      local player_coords = GetEntityCoords(ped)
      for _, obj in pairs(blips) do
        if obj.options.distance then
          if #(player_coords - obj.options.coords) > obj.options.distance and obj.options.display ~= 'nothing' then
            obj:setdisplay('nothing')
          elseif obj.options.display ~= 'marker' then
            obj:setdisplay('marker')
          end
        end
      end
    end
    Wait(500)
  end
end)

--------------------- OBJECT ---------------------

return blip --[[@as blip]]