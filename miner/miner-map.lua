-- miner-map.lua
local map = {}

-- Internal map: map[x][y][z] = {type=..., geolyzer=..., visits=...}
local worldMap = {}

function map.reset()
    -- Clear all keys in worldMap
    for k in pairs(worldMap) do
        worldMap[k] = nil
    end
end

-- Helper: get or create nested table
local function getOrCreate(tbl, key)
    if not tbl[key] then tbl[key] = {} end
    return tbl[key]
end

-- Set block info at (x, y, z)
function map.setBlock(x, y, z, info)
    if not info.geolyzer then
        error(string.format("setBlock: geolyzer data required for block at (%d,%d,%d)", x, y, z))
    end
    local tx = getOrCreate(worldMap, x)
    local ty = getOrCreate(tx, y)
    ty[z] = info
end

-- Get block info at (x, y, z)
function map.getBlock(x, y, z)
    if worldMap[x] and worldMap[x][y] then
        return worldMap[x][y][z]
    end
    return nil
end

-- Increment visit count at (x, y, z)
function map.incrementVisit(x, y, z)
    local info = map.getBlock(x, y, z)
    if info then
        info.visits = (info.visits or 0) + 1
    else
        error(string.format("incrementVisit: map doesn't have block at (%d,%d,%d); can not be visited", x, y, z))
    end
end

-- Get all positions with a given block name
function map.findBlocksByName(name)
    local results = {}
    for x, tx in pairs(worldMap) do
        for y, ty in pairs(tx) do
            for z, info in pairs(ty) do
                if info.geolyzer and info.geolyzer.name == name then
                    table.insert(results, { x = x, y = y, z = z, info = info })
                end
            end
        end
    end
    return results
end

-- Get all unexplored or passable/air positions adjacent to explored area
function map.findUnexploredOrPassable()
    local results = {}
    for x, tx in pairs(worldMap) do
        for y, ty in pairs(tx) do
            for z in pairs(ty) do
                -- For each adjacent position
                local dirs = {
                    { 1, 0, 0 }, { -1, 0, 0 }, { 0, 1, 0 }, { 0, -1, 0 }, { 0, 0, 1 }, { 0, 0, -1 }
                }
                for _, d in ipairs(dirs) do
                    local nx, ny, nz = x + d[1], y + d[2], z + d[3]
                    if not map.getBlock(nx, ny, nz) then
                        table.insert(results, { x = nx, y = ny, z = nz, reason = "unexplored" })
                    else
                        local ninfo = map.getBlock(nx, ny, nz)
                        ---@diagnostic disable-next-line: need-check-nil
                        if ninfo.type == "air" or ninfo.type == "passable" then
                            table.insert(results, { x = nx, y = ny, z = nz, reason = "passable" })
                        end
                    end
                end
            end
        end
    end
    return results
end

-- Utility: Manhattan distance
function map.manhattan(x1, y1, z1, x2, y2, z2)
    return math.abs(x1 - x2) + math.abs(y1 - y2) + math.abs(z1 - z2)
end

return map
