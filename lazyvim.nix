{ config
, pkgs
, lib
, ...
}:
let
  c = config.lib.stylix.colors;
in
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    extraPackages = with pkgs; [
      git
      gcc
      ripgrep
      fd
    ];
  };

  xdg.configFile."nvim/colors/stylix.vim".force = true;
  xdg.configFile."nvim/colors/stylix.vim".text = ''
    highlight clear
    if exists("syntax_on")
      syntax reset
    endif
    let g:colors_name = "stylix"
    set termguicolors

    hi Normal guifg=#${config.lib.stylix.colors.base05} guibg=#${config.lib.stylix.colors.base00}
    hi NormalNC guifg=#${config.lib.stylix.colors.base05} guibg=#${config.lib.stylix.colors.base00}
    hi NormalFloat guifg=#${config.lib.stylix.colors.base05} guibg=#${config.lib.stylix.colors.base01}
    hi FloatBorder guifg=#${config.lib.stylix.colors.base04} guibg=#${config.lib.stylix.colors.base01}
    hi LineNr guifg=#${config.lib.stylix.colors.base03} guibg=#${config.lib.stylix.colors.base00}
    hi CursorLine guibg=#${config.lib.stylix.colors.base01}
    hi CursorLineNr guifg=#${config.lib.stylix.colors.base0A} guibg=#${config.lib.stylix.colors.base01}
    hi Visual guibg=#${config.lib.stylix.colors.base02}
    hi Search guifg=#${config.lib.stylix.colors.base01} guibg=#${config.lib.stylix.colors.base0A}
    hi IncSearch guifg=#${config.lib.stylix.colors.base01} guibg=#${config.lib.stylix.colors.base09}
    hi StatusLine guifg=#${config.lib.stylix.colors.base04} guibg=#${config.lib.stylix.colors.base02}
    hi VertSplit guifg=#${config.lib.stylix.colors.base02} guibg=#${config.lib.stylix.colors.base00}
    hi Pmenu guifg=#${config.lib.stylix.colors.base05} guibg=#${config.lib.stylix.colors.base01}
    hi PmenuSel guifg=#${config.lib.stylix.colors.base01} guibg=#${config.lib.stylix.colors.base0D}

    hi Comment guifg=#${config.lib.stylix.colors.base03} gui=italic
    hi String guifg=#${config.lib.stylix.colors.base0B}
    hi Number guifg=#${config.lib.stylix.colors.base09}
    hi Boolean guifg=#${config.lib.stylix.colors.base09}
    hi Identifier guifg=#${config.lib.stylix.colors.base08}
    hi Function guifg=#${config.lib.stylix.colors.base0D}
    hi Statement guifg=#${config.lib.stylix.colors.base0E}
    hi Keyword guifg=#${config.lib.stylix.colors.base0E}
    hi Type guifg=#${config.lib.stylix.colors.base0A}
    hi Constant guifg=#${config.lib.stylix.colors.base09}
    hi Special guifg=#${config.lib.stylix.colors.base0C}
    hi Delimiter guifg=#${config.lib.stylix.colors.base05}

    hi! link @variable Identifier
    hi! link @variable.builtin Special
    hi! link @variable.parameter Identifier
    hi! link @variable.member Identifier
    hi! link @function Function
    hi! link @function.builtin Function
    hi! link @function.call Function
    hi! link @function.method Function
    hi! link @keyword Keyword
    hi! link @keyword.function Keyword
    hi! link @keyword.return Keyword
    hi! link @string String
    hi! link @number Number
    hi! link @boolean Boolean
    hi! link @type Type
    hi! link @type.builtin Type
    hi! link @comment Comment
    hi! link @constant Constant

    hi SnacksPickerInput guibg=#${c.base00} guifg=#${c.base05}
    hi SnacksPickerInputTitle guibg=#${c.base00} guifg=#${c.base0A} gui=bold
    hi SnacksPickerBox guibg=#${c.base00}
    hi SnacksPickerList guibg=#${c.base00}
    hi SnacksPickerBorder guifg=#${c.base03} guibg=#${c.base00}
    hi SnacksPickerPrompt guifg=#${c.base0D} guibg=#${c.base00}
    hi SnacksPickerMatch guifg=#${c.base0A} gui=bold
    hi SnacksPickerTree guifg=#${c.base03} guibg=#${c.base00}

    " Nettoyage Neo-tree / SignColumn / Indent Markers
    hi SignColumn guibg=#${c.base00}
    hi NeoTreeIndentMarker guifg=#${c.base03} guibg=#${c.base00}
    hi NeoTreeExpander guifg=#${c.base03} guibg=#${c.base00}
    hi NeoTreeNormal guibg=#${c.base00} guifg=#${c.base05}
    hi NeoTreeNormalNC guibg=#${c.base00} guifg=#${c.base05}
    hi NeoTreeWinSeparator guifg=#${c.base02} guibg=#${c.base00}
  '';

  xdg.configFile."nvim/init.lua".force = true;
  xdg.configFile."nvim/init.lua".text = ''
    local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
    if not vim.loop.fs_stat(lazypath) then
      vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
      })
    end
    vim.opt.rtp:prepend(lazypath)

    require("lazy").setup({
      spec = {
        {
          "LazyVim/LazyVim",
          import = "lazyvim.plugins",
          opts = {
            colorscheme = function()
              vim.cmd.colorscheme("stylix")
            end,
          },
        },
        { "folke/tokyonight.nvim", enabled = false },
        { import = "plugins" },
      },
      defaults = { lazy = false, version = false },
    })
  '';

  xdg.configFile."nvim/lua/plugins/stylix.lua".text = lib.mkForce ''
    return {}
  '';
}
