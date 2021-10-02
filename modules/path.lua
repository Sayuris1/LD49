local M = {}

M.map = {} -- A* extension map
M.tile_map = {} -- tilemap.get_bounds
M.nears = {{}, {}} -- Walkable tiles

function M.map_changed(tile)
    M.map[(M.tile_map.w * (tile.y - 1)) + tile.x] = tilemap.get_tile("/map#map", "1", tile.x, tile.y)
    astar.set_map(M.map)
end

function M.find_path(current_tile, destination_tile)
    -- -1 coz array start from 0
    local result, size, total_cost, path =
        astar.solve(current_tile.x - 1, current_tile.y - 1, destination_tile.x - 1, destination_tile.y - 1)

    if result == 0 then
        -- +1 coz array start from 0
        for k, v in pairs(path) do
            v.x = v.x + 1
            v.y = v.y + 1
            v.no = tilemap.get_tile("/map#map", "1", v.x, v.y)
        end

        return result, size, total_cost, path

    elseif result == 1 then
        print("can't find road")
        return 1

    else
        print("clicked to same pos or arrived")
        return 2
    end
end

function M.reset_underline(is_main)
    for i, v in ipairs(M.nears[is_main]) do
        tilemap.set_tile("/map#map", "2", v.x, v.y, 4)
    end

    M.nears[is_main] = {}
end

function M.underline_nears(current_tile, max_cost, tile, is_main)
    local result, size, nears =
        astar.solve_near(current_tile.x - 1, current_tile.y - 1, max_cost)

    if result == 0 then
        -- +1 coz array start from 0
        for i, v in ipairs(nears) do
            v.x = v.x + 1
            v.y = v.y + 1

            M.nears[is_main][i] = v

            tilemap.set_tile("/map#map", "2", v.x, v.y, tile)
        end
    end
end

function M.is_near(clicked_tile)
    for i, v in ipairs(M.nears[1]) do
        if v.x == clicked_tile.x and v.y == clicked_tile.y then
            return true
        end
    end

    return false
end

-- Create A* map from a tile map
local function tile_to_astar()
    local map = {}
    local counter = 1
    for h = 1, M.tile_map.h do
        for w = 1, M.tile_map.w do
            map[counter] = tilemap.get_tile("/map#map", "1", w, h)
            counter = counter + 1
        end
    end

    return map
end

function M.setup_astar()
    M.tile_map.x, M.tile_map.y, M.tile_map.w, M.tile_map.h = tilemap.get_bounds("/map#map")
    astar.setup(M.tile_map.w, M.tile_map.h, 4, M.tile_map.w * M.tile_map.h, 8, true)

    M.map = tile_to_astar()
    astar.set_map(M.map)

    local costs = {
        [1] = {
            1,
            1,
            1,
            1
        },
    }

    astar.set_costs(costs) 
end

return M