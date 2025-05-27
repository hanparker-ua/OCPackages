local component = require("component")
local robot = component.robot
local geolyzer = component.geolyzer
local sides = require("sides")
local map = require("miner-map")

local api = {}

-- Robot state
local pos = { x = 0, y = 0, z = 0 }
local facing = 0 -- 0=N, 1=E, 2=S, 3=W (relative to start)

-- Side to vector mapping (relative to facing)
local sideVectors = {
    [sides.front] = { dx = 0, dy = 0, dz = -1 },
    [sides.back] = { dx = 0, dy = 0, dz = 1 },
    [sides.left] = { dx = -1, dy = 0, dz = 0 },
    [sides.right] = { dx = 1, dy = 0, dz = 0 },
    [sides.top] = { dx = 0, dy = 1, dz = 0 },
    [sides.bottom] = { dx = 0, dy = -1, dz = 0 }
}

-- Facing to world vector
local facingVectors = {
    [0] = { dx = 0, dz = -1 }, -- North
    [1] = { dx = 1, dz = 0 }, -- East
    [2] = { dx = 0, dz = 1 }, -- South
    [3] = { dx = -1, dz = 0 } -- West
}

function api.reset()
    pos.x, pos.y, pos.z = 0, 0, 0
    facing = 0
    -- Optionally, reset the map as well for full isolation:
    if map.reset then map.reset() end
end

-- Utility: rotate facing
local function turnLeft()
    robot.turn(false)
    facing = (facing + 3) % 4
end
local function turnRight()
    robot.turn(true)
    facing = (facing + 1) % 4
end

-- Utility: get world offset for a side
local function sideToWorldOffset(side)
    if side == sides.front then
        local f = facingVectors[facing]
        return f.dx, 0, f.dz
    elseif side == sides.back then
        local f = facingVectors[(facing + 2) % 4]
        return f.dx, 0, f.dz
    elseif side == sides.left then
        local f = facingVectors[(facing + 3) % 4]
        return f.dx, 0, f.dz
    elseif side == sides.right then
        local f = facingVectors[(facing + 1) % 4]
        return f.dx, 0, f.dz
    elseif side == sides.top then
        return 0, 1, 0
    elseif side == sides.bottom then
        return 0, -1, 0
    end
end

-- Analyze and update the map for a single adjacent block at the given side
local function analyzeBlockAtSide(side)
    local dx, dy, dz = sideToWorldOffset(side)
    local wx, wy, wz = pos.x + dx, pos.y + dy, pos.z + dz

    -- Detect
    local detected, desc = robot.detect(side)
    local blockType = desc or (detected and "solid" or "air")

    -- Analyze
    local ok, geo = pcall(geolyzer.analyze, side)
    if not ok or not geo then
        error(string.format("analyzeBlockAtSide: geolyzer failed at (%d,%d,%d)", wx, wy, wz))
    end

    -- Update map
    map.setBlock(wx, wy, wz, {
        type = blockType,
        geolyzer = geo,
        visits = map.getBlock(wx, wy, wz) and map.getBlock(wx, wy, wz).visits or 0
    })
end

-- Detect and analyze all adjacent blocks, update map
function api.detectAndAnalyze()
    local sidesToCheck = {
        sides.front, sides.back, sides.left, sides.right, sides.top, sides.bottom
    }
    for _, side in ipairs(sidesToCheck) do
        analyzeBlockAtSide(side)
    end
end

-- Move robot in a direction, update pos/facing, increment visit count
local function move(side)
    if robot.move(side) then
        local dx, dy, dz = sideToWorldOffset(side)
        pos.x = pos.x + dx
        pos.y = pos.y + dy
        pos.z = pos.z + dz
        map.incrementVisit(pos.x, pos.y, pos.z)
        return true
    end
    return false
end

-- Try to mine all mineable blocks in front, top-front, bottom-front, but only if they match the target
function api.mineAdjacent(targetBlockName)
    local mined = false
    local function tryMine(side)
        local dx, dy, dz = sideToWorldOffset(side)
        local wx, wy, wz = pos.x + dx, pos.y + dy, pos.z + dz
        local info = map.getBlock(wx, wy, wz)
        if info and info.geolyzer and info.geolyzer.name == targetBlockName then
            if robot.swing(side) then
                -- After mining, update the map for that block
                analyzeBlockAtSide(side)
                mined = true
            end
        end
    end
    tryMine(sides.front)
    tryMine(sides.top)
    tryMine(sides.bottom)
    return mined
end

-- Find nearest target block in map
function api.findNearestTarget(targetName)
    local candidates = map.findBlocksByName(targetName)
    if #candidates == 0 then return nil end
    table.sort(candidates, function(a, b)
        return map.manhattan(pos.x, pos.y, pos.z, a.x, a.y, a.z) <
            map.manhattan(pos.x, pos.y, pos.z, b.x, b.y, b.z)
    end)
    return candidates[1]
end

-- Find nearest unexplored/passable position
function api.findNearestUnexplored()
    local candidates = map.findUnexploredOrPassable()
    if #candidates == 0 then return nil end
    table.sort(candidates, function(a, b)
        return map.manhattan(pos.x, pos.y, pos.z, a.x, a.y, a.z) <
            map.manhattan(pos.x, pos.y, pos.z, b.x, b.y, b.z)
    end)
    return candidates[1]
end

-- Simple BFS pathfinding (returns list of moves: {side, ...})
function api.findPath(goal)
    local queue = {}
    local visited = {}
    local function key(x, y, z) return x .. "," .. y .. "," .. z end
    table.insert(queue, { x = pos.x, y = pos.y, z = pos.z, path = {} })
    visited[key(pos.x, pos.y, pos.z)] = true

    while #queue > 0 do
        local node = table.remove(queue, 1)
        if node.x == goal.x and node.y == goal.y and node.z == goal.z then
            return node.path
        end
        for side, vec in pairs(sideVectors) do
            local nx, ny, nz = node.x + vec.dx, node.y + vec.dy, node.z + vec.dz
            local nkey = key(nx, ny, nz)
            if not visited[nkey] then
                local info = map.getBlock(nx, ny, nz)
                if info and (info.type == "air" or info.type == "passable") then
                    local newPath = { table.unpack(node.path) }
                    table.insert(newPath, side)
                    table.insert(queue, { x = nx, y = ny, z = nz, path = newPath })
                    visited[nkey] = true
                end
            end
        end
    end
    return nil -- No path found
end

-- Move along a path (list of sides)
function api.followPath(path)
    for _, side in ipairs(path) do
        if side == sides.front then
            move(sides.front)
        elseif side == sides.left then
            turnLeft(); move(sides.front)
        elseif side == sides.right then
            turnRight(); move(sides.front)
        elseif side == sides.back then
            turnRight(); turnRight(); move(sides.front)
        elseif side == sides.top then
            move(sides.top)
        elseif side == sides.bottom then
            move(sides.bottom)
        end
        api.detectAndAnalyze()
    end
end

-- Main mining/exploration loop
function api.run(targetBlockName)
    -- Mark starting position as visited
    map.incrementVisit(pos.x, pos.y, pos.z)
    while true do
        api.detectAndAnalyze()
        api.mineAdjacent(targetBlockName)
        -- 1. Search for target
        local goal = api.findNearestTarget(targetBlockName)
        if goal then
            local path = api.findPath(goal)
            if path then
                api.followPath(path)
            else
                -- Can't reach, mark as visited to avoid infinite loop
                map.incrementVisit(goal.x, goal.y, goal.z)
            end
        else
            -- 2. Explore nearest unexplored/passable
            local exploreGoal = api.findNearestUnexplored()
            if exploreGoal then
                local path = api.findPath(exploreGoal)
                if path then
                    api.followPath(path)
                else
                    -- Dead end, break
                    break
                end
            else
                -- All explored!
                break
            end
        end
    end
end

return api
