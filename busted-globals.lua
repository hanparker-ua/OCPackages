---@meta

--- Busted test suite
---@param name string
---@param body fun()
function describe(name, body) end

--- Busted test case
---@param name string
---@param body fun()
function it(name, body) end

--- Busted setup (runs once before all tests in suite)
---@param body fun()
function setup(body) end

--- Busted teardown (runs once after all tests in suite)
---@param body fun()
function teardown(body) end

--- Busted before_each (runs before each test in suite)
---@param body fun()
function before_each(body) end

--- Busted after_each (runs after each test in suite)
---@param body fun()
function after_each(body) end

---@class assertlib
local assert = {}

---@param value any
function assert.is_not_nil(value) end

---@param value any
function assert.is_true(value) end

---@param value any
function assert.is_false(value) end

---@param func fun()
function assert.has_error(func) end

---@class assertlib_are
local are = {}

---@param expected any
---@param actual any
function are.equal(expected, actual) end

assert.are = are

_G.assert = assert
