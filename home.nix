{ config, pkgs, lib, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "riorio";
  home.homeDirectory = "/home/riorio";

# 触るな危険
  home.stateVersion = "26.05";
# 触るな危険

  # パッケージ
  home.packages = with pkgs; [
    # デスクトップ環境
    nautilus
    wl-clipboard
    libnotify # notify-send
    # noctalia は desktop.nix の programs.noctalia が入れる

    google-chrome

    # メディアキー・輝度キー用（niri / mango の bind から呼ぶ）。
    # wpctl は pipewire の wireplumber がシステム側で入れている。
    brightnessctl
    playerctl

    # CLI
    claude-code
    gh
    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # 許可するプロプライエタリソフトウェア
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "google-chrome"
      "claude-code"
    ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/riorio/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  # Let Home Manager install and manage itself.
  programs = {
    home-manager.enable = true;
    foot.enable = true;

    # direnv。nix-direnv が use flake のキャッシュを持つ。
    # bash 側のフック注入には programs.bash.enable が必要。
    bash.enable = true;
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };

  # 日本語Keylayout
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-mozc
    ];
    # .config/fcitx5/profile を生成する
    fcitx5.settings.inputMethod = {
      "Groups/0" = {
        Name = "Default";
        "Default Layout" = "us";
        DefaultIM = "mozc";
      };
      # グループには mozc だけを入れる。keyboard-us も並べていると
      # 「IM の巡回」と「IME の ON/OFF」が同じ操作に見えてしまい、
      # かなキーがトグルとして働く経路が残るため。IME OFF のときの配列は
      # 上の "Default Layout" = "us" が受け持つので、keyboard-us を
      # 項目として持つ必要はない。
      "Groups/0/Items/0".Name = "mozc";
      "Groups/0/Items/0".Layout = "";
      "GroupOrder"."0" = "Default";
    };
    # .config/fcitx5/config を生成する
    fcitx5.settings.globalOptions = {
      Hotkey = {
        # トリガキーを無効にしたので巡回もさせない。グループを mozc 単独に
        # したので巡回する相手もいないが、明示的に落としておく。
        EnumerateWithTriggerKeys = "False";
        EnumerateForwardKeys = "";
        EnumerateBackwardKeys = "";
        EnumerateSkipFirst = "False";
        ModifierOnlyKeyTimeout = "250";
        # 左 Shift 単独で IME を切り替える動作を殺す。fcitx5 の既定値は
        # AltTriggerKeys = Shift_L で、書かないとこれが効いてしまう。
        # 空文字がキーリスト無効の表現（EnumerateForwardKeys と同じ）。
        AltTriggerKeys = "";
      };
      # 半角/全角キーによるトグルは無効にする。押し分け（かな=ON、英数=OFF）が
      # あればトグルの入口は要らず、残しておくと IME の状態がずれる経路になる。
      # 空文字がキーリスト無効の表現（EnumerateForwardKeys と同じ）。
      "Hotkey/TriggerKeys" = {
        "0" = "";
      };
      # かな = IME ON、英数 = IME OFF の押し分け。トグルにはしない。
      #
      # Apple JIS の かな / 英数 は HID の LANG1 / LANG2 で、Linux では
      # KEY_HANGEUL / KEY_HANJA として飛び、XKB の us 配列（symbols/pc）が
      # Hangul / Hangul_Hanja を割り当てる。keyd では付け替えない。
      #
      # 以前 DeactivateKeys が Hangul_Romaja になっていたが、この keysym は
      # どの XKB レイアウトも生成しないので英数キーは未接続だった。
      # 英数キーが実際に出すのは Hangul_Hanja。
      "Hotkey/ActivateKeys" = {
        "0" = "Hangul";
      };
      "Hotkey/DeactivateKeys" = {
        "0" = "Hangul_Hanja";
      };
      "Hotkey/PrevPage" = {
        "0" = "Up";
      };
      "Hotkey/NextPage" = {
        "0" = "Down";
      };
      "Hotkey/PrevCandidate" = {
        "0" = "Shift+Tab";
      };
      "Hotkey/NextCandidate" = {
        "0" = "Tab";
      };
      Behavior = {
        ActiveByDefault = "False";
        resetStateWhenFocusIn = "No";
        ShareInputState = "No";
        PreeditEnabledByDefault = "True";
        ShowInputMethodInformation = "True";
        showInputMethodInformationWhenFocusIn = "False";
        CompactInputMethodInformation = "True";
        ShowFirstInputMethodInformation = "True";
        DefaultPageSize = "5";
        OverrideXkbOption = "False";
        CustomXkbOption = "";
        EnabledAddons = "";
        DisabledAddons = "";
        PreloadInputMethod = "True";
        AllowInputMethodForPassword = "True";
        ShowPreeditForPassword = "False";
        AutoSavePeriod = "30";
      };
    };
    # ignoreUserConfig は有効にしない。
    #
    # このオプションは SKIP_FCITX_USER_PATH=1 を立てるだけで、その効果は
    # 「fcitx5 が ~/.config/fcitx5 を一切読まなくなる」こと。ところが
    # 上の settings.globalOptions / settings.inputMethod は home-manager が
    # xdg.configFile 経由で **まさにその ~/.config/fcitx5 に** 書き出す。
    # つまり true にすると、ここに書いた設定が丸ごと無視され、fcitx5 は
    # 素の既定値で動く。2026-08-17 にこれを踏んだ。
    #
    # 既定値は韓国語 IME 向けで、TriggerKeys に Hangul が、ActivateKeys に
    # Hangul_Hanja が入っている。Apple JIS の かな = Hangul、英数 =
    # Hangul_Hanja なので、かな＝IME 巡回のトグル、英数＝IME ON という
    # ちぐはぐな挙動になっていた。
    #
    # false でも宣言性は失われない。~/.config/fcitx5 は home-manager が
    # 張る読み取り専用の store シンボリックリンクなので、GUI 設定ツールから
    # 書き換えることはできない。加えて mozc のユーザー辞書が保存できる
    # ようになる（true だと保存も読み込みもできない）。
    fcitx5.ignoreUserConfig = false;
  };
}
