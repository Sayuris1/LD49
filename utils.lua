local M = {}

local camera = require "orthographic.camera"

local pre_hash = {}

function M.sign(number)
    return (number > 0 and 1) or (number == 0 and 0) or -1
end

-- Return 1 if number == 0
function M.sign_no_zero(number)
    return (number >= 0 and 1) or -1
end

function M.screen_to_tile(pos, size)
    local pos = camera.screen_to_world(nil, pos)

    local tile_x = math.floor(pos.x / size) + 1 
    local tile_y = math.floor(pos.y  / size) + 1

    return tile_x, tile_y
end

function M.world_to_tile(pos, size)
    local tile_x = math.floor(pos.x / size) + 1 
    local tile_y = math.floor(pos.y  / size) + 1

    return tile_x, tile_y
end

function M.tile_to_world(tile, size)
    local pos_x = ((tile.x - 1) * size) + (size / 2)
    local pos_y = ((tile.y - 1) * size) + (size / 2)

    return pos_x, pos_y
end

-- Astar map
function M.tile_to_map(tile_x, tile_y, tile_map)
    local map_x = tile_x
    local map_y = tile_y

    return map_x + ((map_y - 1) * tile_map.w)
end

-- Send worldPos to cursor
function M.cursor_update(action, action_id)
	local cursorScreen = vmath.vector3(action.x, action.y, 0)
	local cursorWorld = camera.screen_to_world(nil, cursorScreen)

	action.x = cursorWorld.x
	action.y = cursorWorld.y

	msg.post("/cursor#cursor", "input", { action_id = action_id, action = action })
end

function M.pre_hash(string)
    if not pre_hash[string] then
        pre_hash[string] = hash(string)
    end

    return pre_hash[string]
end

return M