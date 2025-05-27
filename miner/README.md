# 🤖 Parker Mining Bot (OpenComputers)

A configurable mining bot library and command-line tool for OpenComputers robots.

---

## 🚀 Quick Start

```bash
oppm register hanparker-ua/OCPackages
oppm install miner
# miner <block-name>
miner lignite-stone
```

---

## 🧠 How It Works

The Mining Bot is designed to:

1. **Mine Only the Target Block:**
   The bot will exclusively mine blocks that match the specified target (by name). It will ignore all other blocks.

2. **Smart Block Detection:**
   The bot uses its geolyzer to scan the surrounding area and intelligently locate the target block before mining. It will not start mining until it has found a valid target.

3. **Logical Mining Pattern:**
   The bot mines in a logical, line-by-line pattern (not randomly), ensuring efficient and predictable excavation. This helps avoid unnecessary movement and missed blocks.

4. **Automatic Stop on Full Inventory:**
   The bot will automatically stop mining if its inventory becomes full, preventing item loss and allowing for safe unloading before resuming.

---

## 💎 Available Blocks

- **lignite-stone** — Lignite sedimentary stone from Underground Biomes

---

## 📄 Error Logs

Errors are logged to `/home/mining_error.log`

---

## 📖 Documentation

- [Geolyzer API Reference](docs/geolyzer-api.md)
- [Terminal Command Examples](docs/terminal-command-example.md)

## 🧪 Testing

### Prerequisites

Install Lua and the Busted testing framework:

**Ubuntu/Debian:**
```bash
sudo apt-get update
sudo apt-get install lua5.3 luarocks
```

**macOS:**
```bash
brew install lua luarocks
```

**Windows:**
- Download Lua from [lua.org](https://www.lua.org/download.html)
- Install LuaRocks from [luarocks.org](https://luarocks.org/releases/)

### Install Test Dependencies

```bash
luarocks install busted
luarocks install luacov  # For code coverage (optional)
```

### Running Tests

```bash
# Run all tests
busted

# Run tests with verbose output
busted --verbose

# Run specific test file
busted spec/miner_spec.lua

# Run tests with coverage report
busted --coverage
```

### Test Structure

Tests are located in the `spec/` directory and follow the naming convention `*_spec.lua`.
