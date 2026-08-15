{ ... }:

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
      binds.whichKey.enable = true;
      terminal.toggleterm.enable = true;

      # TODO: platformio.nvim（anurag3301/nvim-platformio.lua）を入れたいが、
      # nixpkgs の vimPlugins に無く、buildVimPlugin の require 検査が
      # サンドボックス内で全モジュール失敗するため保留。
      # pio コマンドと telescope / toggleterm / which-key を読み込み時に
      # 要求するのが原因で、nvimSkipModules で検査を外せば通るはず。
    };
  };
}
