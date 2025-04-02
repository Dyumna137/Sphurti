-- Import lspconfig
local lspconfig = require "lspconfig"

-- Define `on_attach` and `capabilities`
local function on_attach(client, bufnr)
  client.server_capabilities.signatureHelpProvider = false

  -- Keybindings for LSP
  local opts = { noremap = true, silent = true, buffer = bufnr }
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts) -- Jump to definition
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts) -- Show hover documentation

  -- Debugging message
  print("LSP started: " .. client.name .. " (buffer " .. bufnr .. ")")
  -- Add more customization here if needed
end

local capabilities = vim.lsp.protocol.make_client_capabilities()

-- Utility function to set up LSPs properly
local function setup_lsp(server, config)
  config = config or {}
  config.on_attach = config.on_attach or on_attach
  config.capabilities = config.capabilities or capabilities
  lspconfig[server].setup(config)
end

-- C/C++ LSP (clangd)
setup_lsp("clangd", {
  cmd = {
    "C:/msys64/mingw64/bin/clangd.exe",
    "--query-driver=C:/msys64/mingw64/bin/g++.exe",
    "--header-insertion=never",
    "--all-scopes-completion",
    "--background-index",
    "--clang-tidy",
    "--completion-style=detailed",
    "--pch-storage=memory",
    "--fallback-style=llvm",
    "--log=verbose",
  },
  filetypes = { "c", "cpp", "cuda", "cc", "h", "hpp", "objc", "objcpp" },
  root_dir = lspconfig.util.root_pattern("compile_commands.json", ".git", "CMakeLists.txt") or vim.fn.getcwd(),
})

-- Python (Pyright)
setup_lsp("pyright", {
  filetypes = { "python" },
})

-- Rust (Rust Analyzer)
setup_lsp("rust_analyzer", {
  filetypes = { "rust" },
})

-- JavaScript/TypeScript (TS Server)
setup_lsp("ts_ls", {
  filetypes = { "javascript", "typescript" },
})

-- Java (JDTLS)
setup_lsp("jdtls", {
  filetypes = { "java" },
})

