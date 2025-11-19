
local handle = exports.gr_blips:new('coord', {
    coords = vector3(106.22, -1941.44, 20.8)
  },
  {
    sprite = 188,
    name = 'Save Your Breath',
    coords = vector3(106.22, -1941.44, 20.8),
    distance = 250.0,
    display = 'both',
    priority = 2,
    primary = 1,
    opacity = 150,
    flashes = {
      enable = true,
      interval = 500,
      colour = 12
    },
    style = {
      scale = 1.0,
      friendly = false,
      bright = false,
      hidden = false,
      hd = false,
      show_cone = false,
      short_range = true,
      shrink = false,
      edge = false
    },
    indicators = {
      crew = false,
      friend = false,
      completed = false,
      heading = false,
      height = false,
      count = false,
      outline = false,
      tick = true
    },
  },
  {
    title = 'They Got Him',
    verified = 'verified',
    image = 'save_your_breath',
    info = {
      {
        title = 'Feathered Man Caught',
        name = 'GrouseMan',
        crew = 'DONE',
        social = false,
        _type = 3
      }
    }
  }
)

SetTimeout(5000, function()
  exports.gr_blips:updateinfo(handle, 1, {
    title = 'Feathered Man Escaped',
    name = 'GrouseMan',
    crew = 'RUN',
    social = false,
    _type = 3
  })

  exports.gr_blips:addinfotitleandtext(handle, 'Last Seen', GetStreetNameFromHashKey(GetStreetNameAtCoord(106.22, -1941.44, 20.8)))
end)