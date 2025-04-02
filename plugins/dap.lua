return {
  "mfussenegger/nvim-dap",
  config = function()
    local dap = require("dap")

    -- C++ & Rust Debugging (CodeLLDB)
    dap.adapters.codelldb = {
      type = "server",
      port = "13000",
      executable = {
        command = "C:/Users/RITABRATA/AppData/Local/nvim-data/mason/packages/codelldb/extension/adapter/codelldb",
        args = { "--port", "13000" },
      },
    }

    -- C++ Configurations
    dap.configurations.cpp = {
      {
        name = "Launch",
        type = "codelldb",
        request = "launch",
        program = function()
          return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
        end,
        cwd = vim.fn.getcwd(),
        stopOnEntry = false,
        terminal = "integrated",
      },
    }

    -- Rust Configurations (Reusing codelldb)
    dap.configurations.rust = dap.configurations.cpp

    -- C++ Adapter (lldb-vscode)
    dap.adapters.lldb = {
      type = "executable",
      command = "C:/msys64/mingw64/bin/lldb-vscode.exe",
      name = "lldb",
    }

    -- Python Adapter (debugpy)
    dap.adapters.python = {
      type = "executable",
      command = "C:/Users/RITABRATA/AppData/Local/nvim-data/mason/packages/debugpy/venv/bin/python",
      args = { "-m", "debugpy.adapter" },
    }

    -- JavaScript/Node Adapter
    dap.adapters.node2 = {
      type = "executable",
      command = "node",
      args = {
        os.getenv("HOME") .. "/.local/share/nvim/mason/packages/node-debug2-adapter/out/src/nodeDebug.js",
      },
    }

    -- DAP Keybindings
    vim.keymap.set("n", "<F5>", ":lua require'dap'.continue()<CR>", { noremap = true, silent = true })
    vim.keymap.set("n", "<F10>", ":lua require'dap'.step_over()<CR>", { noremap = true, silent = true })
    vim.keymap.set("n", "<F11>", ":lua require'dap'.step_into()<CR>", { noremap = true, silent = true })
    vim.keymap.set("n", "<F12>", ":lua require'dap'.step_out()<CR>", { noremap = true, silent = true })
  end,
}

