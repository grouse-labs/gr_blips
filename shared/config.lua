---@diagnostic disable-next-line: undefined-global
local ivec3 = ivec3 --[[@as fun(x: number, y: number, z: number): vector3]] -- Applies integer-casting rules to the input values
---@type {[string]: {_type: BLIP_TYPES, options: blip_options, creator: blip_creator_options}}[]
return {
  ['Jobs'] =  {
    {
      _type = 'coord',
      options = {
        sprite = 1,
        name = 'Default Job',
        coords = vector3(-353.9, -1520.62, 27.73),
        display = 'marker',
        priority = 2,
        primary = 1,
        opacity = 150,
        flashes = {
          enable = true,
          interval = 500,
          colour = 12
        },
        style = {
          scale = 2.0,
          friendly = false,
          bright = false,
          hidden = false,
          hd = false,
          show_cone = false,
          short_range = false,
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
          tick = false
        },
      },
      creator = {
        title = 'Default Job',
        verified = 'none',
        rp = '1000',
        money = '56',
        ap = '100',
        info = {
          {
            title = 'Info Title',
            _type = 0
          },
          {
            title = 'Info Title and Text - Title',
            text = 'Info Title and Text - Text',
            _type = 1
          },
          {
            icon = 1,
            colour = 12,
            checked = true,
            _type = 2
          },
          {
            crew = 'ECIK',
            social = false,
            _type = 3
          },
          {
            title = 'Info Header',
            _type = 4
          },
          {
            text = 'Info Text',
            _type = 5
          }
        }
      }
    },
  },
  ['Mission'] = {},
  ['Activity'] = {},
  ['Shops'] = {},
  ['Races'] = {},
  ['Property'] = {},
  ['Other'] = {}
}