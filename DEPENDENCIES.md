
# Prerequisites for My Neovim Configuration

This config requires the following tools installed on your system:

- **Node.js & npm**  
  For JavaScript-based plugins and tooling.  
  [Node.js download](https://nodejs.org/)

- **LuaRocks**  
  For managing Lua modules.  
  Installation: `sudo apt install luarocks` (Linux) or via [LuaRocks site](https://luarocks.org/)

- **C/C++ Compiler**  
  Required for building native plugins or language servers.  
  Examples: `gcc`, `clang`  
  Install on Debian/Ubuntu: `sudo apt install build-essential`

- **Java JDK**  
  Required for Java LSP support (`jdtls`).  
  Install OpenJDK: `sudo apt install openjdk-17-jdk`

- **Go**  
  For Go language support and Go-based tools.  
  Download from [golang.org](https://golang.org/dl/)

---

**Note:**  
Python dependencies (if any) can be installed with:

```bash
pip install -r requirements.txt
