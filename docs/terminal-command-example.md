# 🖥️ Writing Terminal Commands in OpenComputers

This guide shows how to use OpenComputers’ standard Lua APIs (like `shell`, `os`, etc.) to write scripts that can be executed as terminal commands.

---

## 📂 1. Script Placement

- Place your Lua script in `/bin` to make it available as a terminal command.

---

## 🛠️ 2. Using Standard APIs

OpenComputers provides several useful APIs for scripting:

- `shell`: For argument parsing, resolving paths, running other commands.
- `os`: For environment variables, exiting, sleeping, etc.
- `io`, `fs` (filesystem): For file operations.
- `component`: For hardware access (robot, geolyzer, etc.).

---

## 📝 3. Example: Simple Echo Command

Create `/bin/echo.lua`:

```lua
local shell = require("shell")

local args, options = shell.parse(...)

if #args == 0 then
  print("Usage: echo <text>")
  os.exit(1)
end

print(table.concat(args, " "))
```

**Usage:**
```sh
echo Hello, OpenComputers!
```

---

## 📝 4. Example: File Listing Command

Create `/bin/ls.lua`:

```lua
local shell = require("shell")
local fs = require("filesystem")

local args = {...}
local path = args[1] or "."

for name in fs.list(shell.resolve(path)) do
  io.write(name .. "  ")
end
print()
```

**Usage:**
```sh
ls /usr/lib
```

---

## 📝 5. Example: Running Another Command

You can run other commands from your script:

```lua
local shell = require("shell")

local result, reason, code = shell.execute("ls /bin")
if not result then
  print("Command failed: " .. tostring(reason))
end
```

---

## 📝 6. Example: Using `os` API

```lua
print("Sleeping for 2 seconds...")
os.sleep(2)
print("Done!")
```

---

## 📝 7. Example: Parsing Options

```lua
local shell = require("shell")
local args, options = shell.parse(...)

if options.h or options.help then
  print("Usage: mycmd [--help] [--foo]")
  os.exit()
end

if options.foo then
  print("Foo option enabled!")
end
```

**Usage:**
```sh
mycmd --foo
```

---

## 📚 References

- [OpenComputers Documentation: shell API](https://ocdoc.cil.li/api:shell)
- [OpenComputers Documentation: os API](https://ocdoc.cil.li/api:os)
- [OpenComputers Documentation: filesystem API](https://ocdoc.cil.li/api:filesystem)
- [OpenComputers Documentation: component API](https://ocdoc.cil.li/api:component)

---

*With these APIs, you can create powerful custom commands for your OpenComputers environment!*
