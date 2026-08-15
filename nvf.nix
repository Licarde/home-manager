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
        tabstop = 2;
        shiftwidth = 2;
        expandtab = true;
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
    };
  };
}
