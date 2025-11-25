<!-- [x] Add All Exported Functions to the meta file -->
<!-- [x] Rewrite Documentation, with better Features and Setup -->
<!-- [x] Add All Exported Functions to the Documentation -->
<!-- [x] Add All Enums to the Documentation -->
<!-- [ ] Update #Image to new function parameters -->
<!-- [ ] Make Discoverable blips that can be hidden until the player is close enough, and save whether the player has discovered them -->
<!-- [ ] Make Toggleable blips that can be turned on and off by the player -->

# Grouse Blips

A framework for creating interactive blips on the map, both static and dynamic, as well as exposing the MissionCreator scaleform, attaching UI prompts to blips for players to interact with.

## Features

- Optimised code, resmon of 0.0~0.02ms. Peaking whilst initialising MissionCreator scaleform prompts.
- Create static blips that are always visible on the map.
- Make blips dynamic, so they only appear when the player is close enough, alternate between colours or your own custom logic.
- Add MissionCreator scaleform prompts to blips, allowing more information to be displayed, uniquely.

## Table of Contents

- [Grouse Blips](#grouse-blips)
  - [Features](#features)
  - [Table of Contents](#table-of-contents)
  - [Credits](#credits)
  - [Preview](#preview)
  - [Installation](#installation)
    - [Dependencies](#dependencies)
    - [Initial Setup](#initial-setup)
    - [Annotations](#annotations)
      - [Usage (VS Code)](#usage-vs-code)
    - [Documentation](#documentation)
      - [Enums](#enums)
        - [BLIP\_TYPES](#blip_types)
        - [eBlipDisplay](#eblipdisplay)
        - [VERIFIED\_TYPES](#verified_types)
      - [Classes](#classes)
        - [blip\_options](#blip_options)
        - [blip\_creator\_options](#blip_creator_options)
      - [Images](#images)
      - [blip.new](#blipnew)
      - [Export](#export)
      - [Module](#module)

## Credits

- [glitchdetector](https://github.com/glitchdetector/fivem-blip-info)
- [root-cause](https://github.com/root-cause/ragemp-blip-info)

## Preview

## Installation

### Dependencies

**This script requires the following script to be installed:**

- [gr_lib](https://github.com/grouse-labs/gr_blips)

### Initial Setup

- Always use the reccomended FiveM artifacts, last tested on [7290](https://runtime.fivem.net/artifacts/fivem/build_server_windows/master/).
- Download the latest version from releases.
- Extract the contents of the zip file into your resources folder, into a folder which starts before any script this is a dependency for, or;
- Ensure the script in your `server.cfg` before any script this is a dependency for.

### Annotations

Function completion is available for all functions, enums and classes. This means you can see what parameters a function takes, what an enum value is, or what a class field is. This is done through [Lua Language Server](https://github.com/LuaLS/lua-language-server).

#### Usage (VS Code)

- Install [cfxlua-vscode](https://marketplace.visualstudio.com/items?itemName=overextended.cfxlua-vscode).
- Open your settings (Ctrl + ,) and add the following:
  - Search for `Lua.workspace.library`, and create a new entry pointing to the root of the resource, for example:

```json
"Lua.workspace.library": ["F:/resources/[gr]/gr_blips/src/meta"],
```

### Documentation

#### Enums

##### BLIP_TYPES

A string (not case sensitive) representing the type of blip to be created.

```lua
{
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
```

- `area`
- `coord`
- `entity`
- `ped`
- `vehicle`
- `object`
- `pickup`
- `radius`
- `race`

##### eBlipDisplay

A string (not case sensitive) representing where the blip is displayed.

```lua
{
  'NOTHING',
  'MARKER',
  'BLIP',
  'MAP',
  'BOTH',
  'RADAR_ONLY',
  'MAP_ZOOMED',
  'BIGMAP_FULL_ONLY',
  'MINIMAP_OR_BIGMAP'
}
```

- `NOTHING`
- `MARKER`
- `BLIP`
- `MAP`
- `BOTH`
- `RADAR_ONLY`
- `MAP_ZOOMED`
- `BIGMAP_FULL_ONLY`
- `MINIMAP_OR_BIGMAP`

##### VERIFIED_TYPES

A string (not case sensitive) representing different tags on MissionCreator scaleforms,

```lua
{
  none = 0,
  verified = 1,
  created = 2
}
```

- `none`
- `verified`
- `created`

#### Classes

##### blip_options

Options are the base configuration for a blip, this is where you define the blip's properties.

```lua
---@class blip_options
---@field sprite integer?
---@field name string?
---@field player_id integer?
---@field coords vector3|vector4?
---@field distance number?
---@field category string?
---@field display eBlipDisplay?
---@field priority integer?
---@field primary integer|vector3|{r: integer, g: integer, b: integer}?
---@field secondary vector3|{r: integer, g: integer, b: integer}?
---@field opacity integer?
---@field flashes {enable: boolean, interval: integer?, duration: integer?, colour: integer?}?
---@field style {scale: number|vector2?, friendly: boolean?, bright: boolean?, hidden: boolean?, hd: boolean?, show_cone: boolean?, short_range: boolean?, shrink: boolean?, edge: boolean?}?
---@field indicators {crew: boolean?, friend: boolean?, completed: boolean?, heading: boolean?, height: boolean?, count: integer?, outline: boolean?, tick: boolean?}?
```

- `sprite: integer?` - A list of all game blips as of [build 3258](https://docs.fivem.net/docs/game-references/blips/#blips)
- `name: string?`
- `player_id: integer?`
- `coords: vector3|vector4?`
- `distance: number?`
- `category: string?`
- `display: string?` - See [eBlipDisplay](#eblipdisplay)
- `priority: integer?` - See [vhub wiki](https://vhub.wiki/enums/BLIP_PRIORITY)
- `primary: integer|vector3|{r: integer, g: integer, b: integer}?` - A list of all [blip colours](https://docs.fivem.net/docs/game-references/blips/#blip-colors)
- `secondary: vector3|{r: integer, g: integer, b: integer}?`
- `opacity: integer?` - Ranges from `0 - 255`
- `flashes: table?`
  - `enable: boolean`
  - `interval: integer?`
  - `duration: integer?`
  - `colour: integer?`
- `style: table?`
  - `scale: number|vector2?`
  - `friendly: boolean?`
  - `bright: boolean?`
  - `hidden: boolean?`
  - `hd: boolean?`
  - `show_cone: boolean?`
  - `short_range: boolean?`
  - `shrink: boolean?`
  - `edge: boolean?`
- `indicators: table?`
  - `crew: boolean?`
  - `friend: boolean?`
  - `completed: boolean?`
  - `heading: boolean?`
  - `height: boolean?`
  - `count: integer?`
  - `outline: boolean?`
  - `tick: boolean?`

```lua
options = {
  sprite = 1,
  name = 'Default Job',
  coords = vector3(-74.735076904297, -2033.3594970703, 15.7),
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
    scale = 2.0,
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
    tick = false
  }
}
```

##### blip_creator_options

Creator options are the configuration for the MissionCreator scaleform, this is where you define the blip's creator properties.

```lua
---@class blip_creator_options
---@field title string
---@field verified VERIFIED_TYPES?
---@field image string|{resource: string, path: string, name: string, width: integer, height: integer}?
---@field rp string?
---@field money string?
---@field ap string?
---@field info {title: string?, text: string?, name: string?, icon: integer?, colour: integer?, checked: boolean?, crew: string?, social: boolean?, _type: 0|1|2|3|4|5}[]?
```

- `title: string`
- `verified: string` - See [VERIFIED_TYPES](#verified_types)
- `image: string|{resource: string, path: string, name: string, width: integer, height: integer}?` - See [Images](#images)
  - `resource: string`
  - `path: string`
  - `name: string`
  - `width: integer`
  - `height: integer`
- `rp: string?`
- `money: string?`
- `ap: string?`
- `info: {title: string?, text: string?, icon: integer?, colour: integer?, checked: boolean?, crew: string?, social: boolean?, _type: 0|1|2|3|4|5}[]?`:
  - `type: integer`
    - `0` - The info is a title info with just a title
    - `1` - The info is a title and text info with a title and text
    - `2` - The info is an icon info with a colour and checkmark
    - `3` - The info is a player info with a crew tag or social club checkmark
    - `4` - The info is a header info (dividing line) with a title and text
    - `5` - The info is a text info with just text
  - `title: string?`
  - `text: string?`
  - `name: string?`
  - `icon: integer?`
  - `colour: integer?`
  - `checked: boolean?`
  - `crew: string?` - A four letter crew tag
  - `social: boolean?`

```lua
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
```

#### Images

Each Creator Blip can have a header image, these can either be stored in this resource or another resource.

- If the image is stored in this resource;
  - The image should be placed in the `images` folder.
  - When setting the image, the image name is the file name (ie. `image`).
- If the image is stored in another resource;
  - When setting the image, pass a table with the resource name, path, the file name and optionally, width and height (ie. `{resource = 'resource', path = 'images/' name = 'image', width = 128, height = 128}`).

#### blip.new

A blip creation super function, this function will create a blip with the specified options and creator options.

#### Export

```lua
---@param _type BLIP_TYPES
---@param data {coords: vector3|vector4?, width: number?, height: number?, entity: integer?, ped: integer?, vehicle: integer?, object: integer?, pickup: integer?, radius: number?}
---@param options blip_options
---@param creator_options blip_creator_options
---@return integer handle
function exports.gr_blips:new(_type, data, options, creator_options) end
```

#### Module

```lua
---@param _type BLIP_TYPES
---@param data {coords: vector3|vector4?, width: number?, height: number?, entity: integer?, ped: integer?, vehicle: integer?, object: integer?, pickup: integer?, radius: number?}
---@param options blip_options
---@param creator_options blip_creator_options
---@return blip
function blip.new(_type, data, options, creator_options) end
```

- `_type: string` - See [BLIP_TYPES](#blip_types)
- `data: table`
  - `coords: vector3|vector4?`
  - `width: number?`
  - `height: number?`
  - `entity: integer?`
  - `ped: integer?`
  - `vehicle: integer?`
  - `object: integer?`
  - `pickup: integer?`
  - `radius: number?`
- `options: blip_options` - See [blip_options](#blip_options)
- `creator_options: blip_creator_options` - See [blip_creator_options](#blip_creator_options)
- `return: integer|blip` - Export return blip handle, library function returns blip object
