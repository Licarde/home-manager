{ pkgs, ... }:

let
  # platformio.nvim は nixpkgs の vimPlugins に無いので自前で取る。
  # Arduino_nyuumon の devShell が入れる pio コマンドを呼ぶ作りなので、
  # 実際に使うときは同ディレクトリで nix develop / direnv を通すこと。
  platformio-nvim = pkgs.vimUtils.buildVimPlugin {
    pname = "nvim-platformio.lua";
    version = "0-unstable-2026-05-08";
    src = pkgs.fetchFromGitHub {
      owner = "anurag3301";
      repo = "nvim-platformio.lua";
      rev = "e65fd65565da5c1d98c568bd0cdcad16627cdb14";
      hash = "sha256-vIO+Un5BAzVU6JmHueSSRGujaTZcjfVBvh+sq/7CLgk=";
    };
  };
in

{
  programs.nvf = {
    enable = true;

    settings.vim = {
      viAlias = true;
      vimAlias = true;

      # 相対行
      lineNumberMode = "relNumber";

      options = {
        # インデントはスペース 2。ハードTABは入力しない方針なので
        # expandtab で Tab キーもスペースに展開する。softtabstop を
        # 揃えておかないと Backspace が 1 文字ずつしか消さない。
        tabstop = 2;
        softtabstop = 2;
        shiftwidth = 2;
        expandtab = true;
        shiftround = true;

        # 紛れ込んだハードTABを見えるようにする
        list = true;
        listchars = "tab:» ,trail:·,nbsp:␣";

        ignorecase = true;
        smartcase = true;
      };

      # wl-copy 経由でシステムクリップボードと共有
      clipboard = {
        enable = true;
        registers = "unnamedplus";
        providers.wl-copy.enable = true;
      };

      lsp = {
        enable = true;
        formatOnSave = true;
        lspSignature.enable = true;
        trouble.enable = true;
      };

      languages = {
        enableTreesitter = true;
        enableFormat = true;
        enableExtraDiagnostics = true;

        nix.enable = true;
        rust.enable = true;
        haskell.enable = true;
        clang.enable = true; # cpp
        markdown.enable = true;
      };

      # fzf 相当のファジーファインダ
      telescope.enable = true;

      # 最低限の見た目と操作性
      statusline.lualine.enable = true;
      autocomplete.nvim-cmp.enable = true;
      git.gitsigns.enable = true;
      treesitter.context.enable = true;

      # platformio.nvim が依存するもの。telescope と treesitter は上で有効。
      binds.whichKey.enable = true;
      terminal.toggleterm.enable = true;

      extraPlugins = {
        telescope-ui-select = {
          package = pkgs.vimPlugins.telescope-ui-select-nvim;
          setup = "require('telescope').load_extension('ui-select')";
        };
        platformio = {
          package = platformio-nvim;
          setup = "require('platformio').setup({})";
          after = [ "telescope-ui-select" ];
        };
      };
    };
  };
}
