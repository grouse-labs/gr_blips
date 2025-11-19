---@meta

-- Classes --

---@class blip_options
---@field sprite integer?
---@field name string?
---@field player_id integer?
---@field coords vector3|vector4?
---@field distance number?
---@field category string?
---@field display string?
---@field priority integer?
---@field primary integer|vector3|{r: integer, g: integer, b: integer}?
---@field secondary vector3|{r: integer, g: integer, b: integer}?
---@field opacity integer?
---@field flashes {enable: boolean, interval: integer?, duration: integer?, colour: integer?}?
---@field style {scale: number|vector2?, friendly: boolean?, bright: boolean?, hidden: boolean?, hd: boolean?, show_cone: boolean?, short_range: boolean?, shrink: boolean?, edge: boolean?}?
---@field indicators {crew: boolean?, friend: boolean?, completed: boolean?, heading: boolean?, height: boolean?, count: integer|false?, outline: boolean?, tick: boolean?}?

---@class blip_creator_options
---@field title string
---@field verified VERIFIED_TYPES?
---@field image string|{resource: string, path: string, name: string, width: integer, height: integer}?
---@field rp string?
---@field money string?
---@field ap string?
---@field info {title: string?, text: string?, name: string?, icon: integer?, colour: integer?, checked: boolean?, crew: string?, social: boolean?, _type: 0|1|2|3|4|5}[]?

---@class blip
---@field id integer
---@field _type BLIP_TYPES
---@field options blip_options
---@field creator blip_creator_options?
---@field getall fun(): table<string, blip>
---@field getonscreen fun(): table<string, blip>
---@field remove fun(handle: integer)
---@field clearall fun()
---@field togglepolice fun(toggle: boolean): active: boolean
---@field createcategory fun(name: string): id: integer
---@field get fun(handle: integer): blip
---@field new fun(_type: BLIP_TYPES, data: {coords: vector3|vector4, width: number?, height: number?, entity: integer?, ped: integer?, vehicle: integer?, object: integer?, pickup: integer?, radius: number?}, options: blip_options?, creator_options: blip_creator_options?): blip
---@field create fun(self: blip, _type: BLIP_TYPES, data: {coords: vector3|vector4, width: number?, height: number?, entity: integer?, ped: integer?, vehicle: integer?, object: integer?, pickup: integer?, radius: number?}): blip
---@field destroy fun(self: blip)
---@field setcoords fun(self: blip, coords: vector3, heading: number?): blip
---@field setcategory fun(self: blip, category: string): blip
---@field setdisplay fun(self: blip, display: eBlipDisplay): blip
---@field setpriority fun(self: blip, priority: integer): blip
---@field setcolour fun(self: blip, primary: integer): blip
---@field setsecondary fun(self: blip, secondary: vector3|{r: integer, g: integer, b: integer}): blip
---@field setcustomcolour fun(self: blip, colour: vector3|{r: integer, g: integer, b: integer}): blip
---@field setopacity fun(self: blip, opacity: integer): blip
---@field setflashes fun(self: blip, flashes: {enable: boolean, interval: integer?, duration: integer?, colour: integer?}): blip
---@field setstyle fun(self: blip, style: {scale: number|vector2, friendly: boolean?, bright: boolean?, hidden: boolean?, hd: boolean?, show_cone: boolean?, short_range: boolean?, shrink: boolean?, edge: boolean?}): blip
---@field setindicators fun(self: blip, indicators: {crew: boolean?, friend: boolean?, completed: boolean?, heading: boolean?, height: boolean?, count: integer?, outline: boolean?, tick: boolean?}): blip
---@field setname fun(self: blip, name: string): blip
---@field setplayername fun(self: blip, player_id: integer): blip
---@field setrange fun(self: blip, distance: number): blip
---@field setoptions fun(self: blip, options: blip_options): blip
---@field setcreator fun(self: blip, toggle: boolean): blip
---@field setcreatortitle fun(self: blip, title: string, verified: VERIFIED_TYPES?): blip
---@field setcreatorimage fun(self: blip, image: string|{resource: string, path: string, width: integer, height: integer}): blip
---@field setcreatoreconomy fun(self: blip, rp: string?, money: string?, ap: string?): blip
---@field addinfotitle fun(self: blip, title: string): self: blip, key: integer
---@field addinfotitleandtext fun(self: blip, title: string, text: string): self: blip, key: integer
---@field addinfoicon fun(self: blip, icon: integer, colour: integer, checked: boolean?): self: blip, key: integer
---@field addinfoplayer fun(self: blip, title: string?, name: string?, crew: string, is_social: boolean?): self: blip, key: integer
---@field addinfoheader fun(self: blip, title: string): self: blip, key: integer
---@field addinfotext fun(self: blip, text: string): self: blip, key: integer
---@field updateinfo fun(self: blip, key: integer, info: {title: string?, text: string?, name: string?, icon: integer?, colour: integer?, checked: boolean?, crew: string?, social: boolean?, _type: 0|1|2|3|4|5})
---@field setcreatoroptions fun(self: blip, options: blip_creator_options): blip

-- Exports --

---@return table<string, blip>
function exports.gr_blips:getall() end

---@return table<string, blip>
function exports.gr_blips:getonscreen() end

---@param handle integer
function exports.gr_blips:remove(handle) end

function exports.gr_blips:clearall() end

---@param toggle boolean
---@return boolean active
function exports.gr_blips:togglepolice(toggle) end

---@param name string
---@return integer id
function exports.gr_blips:createcategory(name) end

---@param handle integer
---@return blip
function exports.gr_blips:get(handle) end

---@param _type BLIP_TYPES
---@param data {coords: vector3|vector4?, width: number?, height: number?, entity: integer?, ped: integer?, vehicle: integer?, object: integer?, pickup: integer?, radius: number?}
---@param options blip_options
---@param creator_options blip_creator_options
---@return integer handle
function exports.gr_blips:new(_type, data, options, creator_options) end

---@param handle integer
---@param _type BLIP_TYPES
---@param data {coords: vector3|vector4?, width: number?, height: number?, entity: integer?, ped: integer?, vehicle: integer?, object: integer?, pickup: integer?, radius: number?}
---@return integer handle
function exports.gr_blips:create(handle, _type, data) end

---@param handle integer
function exports.gr_blips:destroy(handle) end

---@param handle integer
---@param coords vector3
---@param heading number?
function exports.gr_blips:setcoords(handle, coords, heading) end

---@param handle integer
---@param category string
function exports.gr_blips:setcategory(handle, category) end

---@param handle integer
---@param display eBlipDisplay
function exports.gr_blips:setdisplay(handle, display) end

---@param handle integer
---@param priority integer
function exports.gr_blips:setpriority(handle, priority) end

---@param handle integer
---@param primary integer
function exports.gr_blips:setcolour(handle, primary) end

---@param handle integer
---@param secondary vector3|{r: integer, g: integer, b: integer}
function exports.gr_blips:setsecondary(handle, secondary) end

---@param handle integer
---@param colour vector3|{r: integer, g: integer, b: integer}
function exports.gr_blips:setcustomcolour(handle, colour) end

---@param handle integer
---@param opacity integer
function exports.gr_blips.setopacity(handle, opacity) end

---@param handle integer
---@param flashes {enable: boolean, interval: integer?, duration: integer?, colour: integer?}
function exports.gr_blips:setflashes(handle, flashes) end

---@param handle integer
---@param style {scale: number|vector2, friendly: boolean?, bright: boolean?, hidden: boolean?, hd: boolean?, show_cone: boolean?, short_range: boolean?, shrink: boolean?, edge: boolean?}
function exports.gr_blips:setstyle(handle, style) end

---@param handle integer
---@param indicators {crew: boolean?, friend: boolean?, completed: boolean?, heading: boolean?, height: boolean?, count: integer?, outline: boolean?, tick: boolean?}
function exports.gr_blips:setindicators(handle, indicators) end

---@param handle integer
---@param name string
function exports.gr_blips:setname(handle, name) end

---@param handle integer
---@param player_id integer
function exports.gr_blips:setplayername(handle, player_id) end

---@param handle integer
---@param distance number
function exports.gr_blips:setrange(handle, distance) end

---@param handle integer
---@param options blip_options
function exports.gr_blips:setoptions(handle, options) end

---@param handle integer
---@param toggle boolean
function exports.gr_blips:setcreator(handle, toggle) end

---@param handle integer
---@param title string
---@param verified VERIFIED_TYPES
function exports.gr_blips:setcreatortitle(handle, title, verified) end

---@param handle integer
---@param image string|{resource: string, path: string, width: integer, height: integer}
function exports.gr_blips:setcreatorimage(handle, image) end

---@param handle integer
---@param rp string?
---@param money string?
---@param ap string?
function exports.gr_blips:setcreatoreconomy(handle, rp, money, ap) end

---@param handle integer
---@param title string
---@return integer key
function exports.gr_blips:addinfotitle(handle, title) end

---@param handle integer
---@param title string
---@param text string
---@return integer key
function exports.gr_blips:addinfotitleandtext(handle, title, text) end

---@param handle integer
---@param icon integer
---@param colour integer
---@param checked boolean?
---@return integer key
function exports.gr_blips:addinfoicon(handle, icon, colour, checked) end

---@param handle integer
---@param crew string
---@param is_social boolean?
---@return integer key
function exports.gr_blips:addinfoplayer(handle, crew, is_social) end

---@param handle integer
---@param title string
---@return integer key
function exports.gr_blips:addinfoheader(handle, title) end

---@param handle integer
---@param text string
---@return integer key
function exports.gr_blips:addinfotext(handle, text) end

---@param handle integer
---@param key integer
---@param info {title: string?, text: string?, name: string?, icon: integer?, colour: integer?, checked: boolean?, crew: string?, social: boolean?, _type: 0|1|2|3|4|5}
function exports.gr_blips:updateinfo(handle, key, info) end

---@param handle integer
---@param options blip_creator_options
function exports.gr_blips:setcreatoroptions(handle, options) end
