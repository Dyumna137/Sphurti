# Documentation Audit

**Verified:** 2026-11-09 on Windows with Neovim 0.11.6. This is a
documentation-only audit: no Lua module, plugin specification, or lockfile was
changed.

## Configuration observed

`init.lua` enables the Lua loader, applies a Windows PowerShell shell policy,
loads `core.options` and `core.keymaps`, bootstraps stable `lazy.nvim`, then
passes explicit plugin specs to lazy. `core.keymaps` registers the embedded,
Git, diagnostics, and terminal modules. LSP UI policy lives in
`lua/plugins/lsp.lua`; Mason server definitions are in
`lua/plugins/lsp/mason.lua`; buffer-local formatting behavior is in
`lua/plugins/lsp/on_attach.lua`.

The lockfile pins the plugin revisions. The installed editor is **0.11.6**;
the lockfile does not record the Neovim version or a date, so it cannot prove
which upstream release each pin corresponds to without a separate Git lookup.

## Findings

| Status | Finding | Evidence / action |
|---|---|---|
| Updated | The README advertised `nvim >= 0.9.0`. | The configuration calls `vim.lsp.config`, introduced in 0.11; current `nvim-lspconfig` requires 0.11.3+. The prerequisite now says 0.11.3+. |
| Updated | The README and usage guide documented the wrong DAP keys. | `plugins/debug.lua` binds `<F5>`, `<F1>`, `<F2>`, `<F3>`, `<leader>b`, and `<leader>B`, not `<F9>`–`<F12>`. |
| Updated | `USAGE.md` listed `<Space>et` / `:EmbeddedToolReport`. | Neither mapping nor command exists in `core/embedded.lua` or `core/keymaps.lua`; both references were removed. |
| Updated | The README claimed Bufferline and HTML/Markdown live preview. | No Bufferline or preview plugin/spec is loaded. The configured related feature is `inccommand=split`, which previews substitutions. |
| Updated | Performance figures were written as current facts. | Existing 48–53 ms figures are historical measurements, not reproduced during this audit. The README now tells readers to measure locally. |
| Needs verification | The documented smoke-test command is not portable as written. | `nvim --headless -u init.lua -l tests/smoke.lua` failed in this audit because `-u init.lua` did not put the configuration's `lua/` directory on `runtimepath`. Test it from a normal installation or revise the test invocation separately. |
| Needs verification | Several historical refactor documents claim `:make` is asynchronous. | The configuration maps to `:make`, but normal `:make` runs `'makeprg'` through the shell; it provides quickfix integration, not a general non-blocking guarantee. Historical logs were retained as history rather than silently rewritten. |
| Needs verification | Cross-platform claims are too broad. | `init.lua` selects PowerShell on Windows; `options.lua` runs `cls` on `VimLeave`; embedded flashing only looks for Windows script names. Linux is not equally exercised by this audit. |
| Needs verification | README generic LSP navigation mappings are not explicitly set by this configuration. | `on_attach.lua` explicitly creates format mappings only when formatting is supported. Effective navigation mappings can come from Neovim defaults or another runtime component, so the README now labels configuration-owned mappings precisely. |
| Intentionally retained | Refactor logs, roadmap, deployment status, and diagrams retain old version/performance claims. | They are historical records. `docs/README.md` now labels the most easily confused entries as historical; changing the history would make it less useful. |

## Compatibility notes

The configuration already uses the 0.11-style `vim.lsp.config` API in
`plugins/lsp/mason.lua`, so it avoids the deprecated
`require('lspconfig').…setup()` path. Upstream documents `vim.lsp.config` and
`vim.lsp.enable` as the 0.11+ model. The upstream `nvim-treesitter` main branch
is now a rewrite requiring Neovim 0.12/nightly; this configuration pins a
specific commit on `main` while using 0.11.6. Do not update that plugin blindly:
test the lockfile revision and parsers together, then run `:TSUpdate` if the
upgrade is intentional.

## Files inspected

`init.lua`; every Lua module under `lua/core` and `lua/plugins`; the LSP helper
modules; `lazy-lock.json`; `tests/smoke.lua`; root `README.md`; and Markdown
under `docs/`. The `lua/docs/` material was treated as notes/examples, not as
active configuration, because nothing imports it.

## Sources

Checked 2026-11-09:

- [Neovim LSP documentation](https://neovim.io/doc/user/lsp/)
- [nvim-lspconfig upstream README](https://github.com/neovim/nvim-lspconfig)
- [nvim-treesitter upstream README](https://github.com/nvim-treesitter/nvim-treesitter)
- [Neovim quickfix documentation](https://neovim.io/doc/user/quickfix/)

These sources establish API and support-policy context. They do not establish
that a particular executable or hardware toolchain is installed on every host.
