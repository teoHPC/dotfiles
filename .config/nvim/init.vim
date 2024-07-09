set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath=&runtimepath
source ~/.vim/vimrc

lua << EOF

-- [[ Configure Completion ]]
--
-- https://github.com/hrsh7th/nvim-cmp/wiki/Example-mappings#no-snippet-plugin
-- :help nvim-cmp
--
-- Set up nvim-cmp.
local has_words_before = function()
  unpack = unpack or table.unpack
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
end

-- Icons for LSP completion menu
local lspkind = require('lspkind')
lspkind.init({}) -- integration with omni menu

local luasnip = require('luasnip')

local cmp = require'cmp'
cmp.setup({
  completion = {
    autocomplete = false
  },
  snippet = {
    -- REQUIRED - a snippet engine must be specified as some LSPs use snippets by default
    expand = function(args)
      require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
    end,
  },
  mapping = {
    ["<CR>"] = cmp.mapping.confirm { select = true },
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    -- super-tab
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif has_words_before() then
        cmp.complete()
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end, { "i", "s" }),
  },
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'path' },
    { name = 'buffer' },
    { name = 'luasnip' },
  }),
  formatting = {
    format = lspkind.cmp_format()
  }
})

cmp.setup.filetype({ "dap-repl", "dapui_watches", "dapui_hover" }, {
  sources = {
    { name = "dap" },
  },
})


-- [[ Configure LuaSnip ]]
--
vim.keymap.set({"i", "s"}, "<C-k>", function()
  if luasnip.expand_or_jumpable() then
    luasnip.expand_or_jump()
  end
end, { silent = true })

vim.keymap.set({"i", "s"}, "<C-j>", function()
  if luasnip.jumpable(-1) then
    luasnip.jump(-1)
  end
end, { silent = true })


require("luasnip.loaders.from_vscode").lazy_load()
require("luasnip.loaders.from_snipmate").lazy_load()


-- [[ Configure LSPs ]]
--
-- require'lspconfig'.clangd.setup{}
local nvim_lsp = require('lspconfig')

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local custom_lsp_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  -- Enable completion triggered by <c-x><c-o>
  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  local opts = { noremap=true, silent=true }

  -- See `:help vim.lsp.*` for documentation on any of the below functions
  buf_set_keymap('n', '<leader>yg', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', '<leader>yh', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', '<leader>yt', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  buf_set_keymap('n', '<leader>yr', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', '<leader>yl', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', '<leader>yd', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
  buf_set_keymap('n', '<leader>yf', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)

end

-- Use a loop to conveniently call 'setup' on multiple servers and
-- map buffer local keybindings when the language server attaches
-- default configuration : https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/server_configurations/clangd.lua
nvim_lsp['clangd'].setup {
  on_attach = custom_lsp_attach,
  cmd = {
        "clangd",
        --"--compile-commands-dir=/home/teonnik/code/drivesim-ov",
        "--log=verbose",
        --"--background-index=0",
        "--background-index",
        -- "-j=1",
        -- "--clang-tidy=0",
  },
  flags = {
    debounce_text_changes = 150,
  },
  filetypes = { "c", "cpp", "cu", "cuda" },
  capabilities = require('cmp_nvim_lsp').default_capabilities(),
}

-- https://github.com/python-lsp/python-lsp-server/issues/120
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#pylsp
-- https://github.com/python-lsp/python-lsp-server/blob/develop/CONFIGURATION.md
nvim_lsp['pylsp'].setup {
  on_attach = custom_lsp_attach,
  capabilities = require('cmp_nvim_lsp').default_capabilities(),
}

-- nvim_lsp['texlab'].setup {
--   on_attach = custom_lsp_attach
-- }


-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
--
require('nvim-treesitter.configs').setup {
  -- Add languages to be installed here that you want installed for treesitter
  ensure_installed = {'markdown', 'markdown_inline', 'cpp', 'cuda', 'vim', 'lua', 'python', 'usd' },
  highlight = { enable = true },
  incremental_selection = {
    enable = true,
    additional_vim_regex_highlighting = false,
  }
}


-- [[ Configure Debugger ]]
--
-- Installation: https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation#ccrust-via-lldb-vscode
-- Documentation: :help dap-{api, adapters, mappings, ...}
-- Logging: ~/.cache/nvim/dap.log
-- Extensions: https://github.com/mfussenegger/nvim-dap/wiki/Extensions
--
-- Note: Completion in REPL seems to not be supported currently : https://github.com/rcarriga/cmp-dap
-- Note: `lldb-vscode` is going to be renamed to `lldb-dap` https://discourse.llvm.org/t/rfc-rename-lldb-vscode-to-lldb-dap/74075/7
local dap = require('dap')
dap.adapters.cpp = {
  name = 'lldb',
  type = 'executable',
  command = '/usr/bin/lldb-vscode', -- adjust as needed, must be absolute path
}

-- https://github.com/mfussenegger/nvim-dap/wiki/Cookbook#pick-a-process
dap.configurations.cpp = {
    {
      -- If you get an "Operation not permitted" error using this, try disabling YAMA:
      --  echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope
      name = "Attach to process",
      type = 'cpp',  -- Adjust this to match your adapter name (`dap.adapters.<name>`)
      request = 'attach',
      pid = require('dap.utils').pick_process,
      args = {},
      -- runInTerminal=true
    },
}

-- dap.adapters.cppdbg = dap.adapters.cpp

-- Use `.vscode/launch.json` for DAP configurations
--
-- :help dap-launch.json
-- require('dap.ext.vscode').load_launchjs(nil, { cppdbg = {'c', 'cpp'} })


-- TODO: Fix / not working?
-- see :help dap-terminal
-- dap.defaults.fallback.external_terminal = {
--   command = '/usr/bin/alacritty';
--   -- command = '/usr/bin/foot';
--   args = {'-e'};
-- }
-- dap.defaults.fallback.force_external_terminal = true

vim.keymap.set('n', '<M-c>', function() require('dap').continue() end)
vim.keymap.set('n', '<M-t>', function() require('dap').terminate() end)
vim.keymap.set('n', '<M-right>', function() require('dap').step_over() end)
vim.keymap.set('n', '<M-down>', function() require('dap').step_into() end)
vim.keymap.set('n', '<M-up>', function() require('dap').step_out() end)
vim.keymap.set('n', '<M-f>', function() require('dap').focus_frame() end)
vim.keymap.set('n', '<M-k>', function() require('dap').up() end)
vim.keymap.set('n', '<M-j>', function() require('dap').down() end)
vim.keymap.set('n', '<M-u>', function() require('dap').run_to_cursor() end)
vim.keymap.set('n', '<M-b>', function() require('dap').toggle_breakpoint() end)
vim.keymap.set('n', '<M-del>', function() require('dap').clear_breakpoints() end)
vim.keymap.set('n', '<M-l>', function() require('dap').list_breakpoints() end)
-- In REPL mode LLDB commands can be run by prefixing with ` : e.g. `bt
--
-- https://github.com/mfussenegger/nvim-dap/discussions/381#discussioncomment-2360181
vim.keymap.set('n', '<M-r>', function() require('dap').repl.toggle() end)


-- [[ Configure Debugger Virtual Text]]
--
require("nvim-dap-virtual-text").setup()

-- [[ Configure fuzzy finder for DAP processes ]]
--
require('fzf-lua').register_ui_select()

-- [[  Configura oil.nvim ]]
--
require("oil").setup()

-- [[  Toggle terminal ]]
--
require("toggleterm").setup{}

EOF
