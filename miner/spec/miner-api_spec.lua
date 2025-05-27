-- Mock OpenComputers modules BEFORE requiring your code
package.loaded["component"] = {
    robot = {
        detect = function(side)
            -- front=3 is solid, others are air
            if side == 3 then return true, "solid" else return false, "air" end
        end,
        move = function() return true end,
        swing = function() return true end,
    },
    geolyzer = {
        analyze = function(side)
            if side == 3 then
                return {name="minecraft:stone", hardness=1.5}
            else
                return {name="minecraft:air", hardness=0}
            end
        end
    }
}
package.loaded["sides"] = {front=3, back=2, left=4, right=5, top=1, bottom=0}

-- Now require your modules
local map = require("miner-map")
local miner_api = require("miner-api")

before_each(function()
    -- Option 1: If you add a reset() to your modules
    map.reset()
    miner_api.reset()
    -- Option 2: Reload modules (if you don't have reset)
    -- package.loaded["miner-map"] = nil
    -- package.loaded["miner-api"] = nil
    map = require("miner-map")
    miner_api = require("miner-api")
end)

describe("miner-map", function()
    it("setBlock and getBlock should store and retrieve block info", function()
        map.setBlock(1,2,3, {type="solid", geolyzer={name="minecraft:stone"}, visits=0})
        local b = map.getBlock(1,2,3)
        assert.is_not_nil(b)
        assert.are.equal("solid", b.type)
        assert.are.equal("minecraft:stone", b.geolyzer.name)
    end)

    it("incrementVisit should increase visits, error if block not mapped", function()
        map.setBlock(1,1,1, {type="air", geolyzer={name="minecraft:air"}, visits=0})
        map.incrementVisit(1,1,1)
        local b = map.getBlock(1,1,1)
        assert.are.equal(1, b.visits)
        assert.has_error(function() map.incrementVisit(9,9,9) end)
    end)

    it("findBlocksByName should find all blocks with given name", function()
        map.setBlock(0,0,0, {type="solid", geolyzer={name="minecraft:stone"}, visits=0})
        map.setBlock(1,0,0, {type="solid", geolyzer={name="minecraft:stone"}, visits=0})
        map.setBlock(2,0,0, {type="solid", geolyzer={name="minecraft:air"}, visits=0})
        local found = map.findBlocksByName("minecraft:stone")
        assert.are.equal(2, #found)
    end)

    it("findUnexploredOrPassable should find adjacent unexplored and passable blocks", function()
        map.setBlock(0,0,0, {type="solid", geolyzer={name="minecraft:stone"}, visits=0})
        map.setBlock(1,0,0, {type="air", geolyzer={name="minecraft:air"}, visits=0})
        local results = map.findUnexploredOrPassable()
        -- Should include unexplored blocks adjacent to (0,0,0) and (1,0,0)
        local foundUnexplored = false
        local foundPassable = false
        for _, r in ipairs(results) do
            if r.reason == "unexplored" then foundUnexplored = true end
            if r.reason == "passable" then foundPassable = true end
        end
        assert.is_true(foundUnexplored)
        assert.is_true(foundPassable)
    end)

    it("manhattan should compute correct distance", function()
        assert.are.equal(6, map.manhattan(0,0,0, 1,2,3))
    end)
end)

describe("miner-api", function()
    it("detectAndAnalyze should update the map for all adjacent blocks", function()
        miner_api.detectAndAnalyze()
        -- Check front block
        local front = map.getBlock(0, 0, -1)
        assert.is_not_nil(front)
        assert.are.equal("solid", front.type)
        assert.are.equal("minecraft:stone", front.geolyzer.name)
        -- Check top block
        local top = map.getBlock(0, 1, 0)
        assert.is_not_nil(top)
        assert.are.equal("air", top.type)
        assert.are.equal("minecraft:air", top.geolyzer.name)
    end)

    it("mineAdjacent should only mine the target block and update map", function()
        miner_api.detectAndAnalyze()
        local mined = miner_api.mineAdjacent("minecraft:stone")
        assert.is_true(mined)
        -- After mining, the front block should be air
        local front = map.getBlock(0, 0, -1)
        assert.are.equal("air", front.type)
        assert.are.equal("minecraft:air", front.geolyzer.name)
    end)

    it("findNearestTarget should find the closest target block", function()
        map.setBlock(0,0,-1, {type="solid", geolyzer={name="minecraft:stone"}, visits=0})
        map.setBlock(0,0,-2, {type="solid", geolyzer={name="minecraft:stone"}, visits=0})
        local nearest = miner_api.findNearestTarget("minecraft:stone")
        assert.is_not_nil(nearest)
        assert.are.equal(-1, nearest.z)
    end)

    it("findNearestUnexplored should find an adjacent unexplored or passable block", function()
        map.setBlock(0,0,0, {type="solid", geolyzer={name="minecraft:stone"}, visits=0})
        local res = miner_api.findNearestUnexplored()
        assert.is_not_nil(res)
    end)

    it("findPath should return a path to a reachable goal", function()
        map.setBlock(0,0,0, {type="air", geolyzer={name="minecraft:air"}, visits=0})
        map.setBlock(0,0,-1, {type="air", geolyzer={name="minecraft:air"}, visits=0})
        local path = miner_api.findPath({x=0, y=0, z=-1})
        assert.is_table(path)
        assert.are.equal(1, #path)
    end)

    it("followPath should move the robot and update position", function()
        map.setBlock(0,0,0, {type="air", geolyzer={name="minecraft:air"}, visits=0})
        map.setBlock(0,0,-1, {type="air", geolyzer={name="minecraft:air"}, visits=0})
        local path = {package.loaded["sides"].front}
        miner_api.followPath(path)
        -- The robot should now be at (0,0,-1)
        -- (You may want to expose pos for testing, or add a getter)
        -- For now, check that the new position is visited
        assert.are.equal(1, map.getBlock(0,0,-1).visits)
    end)
end)
