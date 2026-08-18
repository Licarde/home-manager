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

    # 複数のコーディングエージェントを 1 つの端末で束ねる TUI（https://herdr.dev）。
    # claude-code のセッションを並べて回すために入れる。
    herdr
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

  # herdr のキーバインドを tmux 風に寄せる。
  # ~/.config/herdr/ には socket・ログ・session.json といった実行時状態も
  # 同居するので、ディレクトリごとではなく config.toml だけを張る。
  xdg.configFile."herdr/config.toml".text = ''
      # herdr のキーバインドを tmux の既定に寄せる。
      # 差分の全体像は ~/memo/knowledges/herdr.md を参照。

      # herdr 自身が初回起動時に書き込む値。ここが store の読み取り専用
      # シンボリックリンクになるので、あらかじめ書いておかないと
      # オンボーディング画面が毎回出る。
      onboarding = false

      [keys]
      # prefix は ctrl+b ではなく ctrl+q。tmux と herdr の既定が同じ ctrl+b だと
      # 入れ子にしたときに食い合うので、herdr 側をずらして ctrl+b を tmux に譲る。
      # detach は下で prefix+d に移してあるので、既定の prefix+q との
      # 「ctrl+q → q」の押し間違えは起きない。
      # 注意: ctrl+q は端末のフロー制御（XON）のキー。herdr の中で動かす他の TUI に
      # ctrl+q を渡したい場合は prefix に食われる。
      prefix = "ctrl+q"

      # --- tmux に合わせて変更したもの ---

      # 最重要。herdr の既定では prefix+q がデタッチで、tmux の癖で
      # 「ペイン番号を表示」のつもりに押すとセッションから抜けてしまう。
      detach = "prefix+d"

      # herdr の workspace は tmux の session に当たるので、
      # tmux の choose-session と同じ prefix+s に置く。
      workspace_picker = "prefix+s"
      # prefix+s を空けるため、設定画面はシフト付きへ退避。
      settings = "prefix+shift+s"

      # tmux の choose-window に一番近いのは herdr の goto（横断ジャンプ）。
      # workspace_picker が prefix+s へ移った分、空いた prefix+w に置く。
      goto = "prefix+w"

      # tmux の prefix , （rename-window）。
      rename_tab = "prefix+comma"

      # tmux の prefix o （次のペイン）。既定の prefix+tab も
      # cycle_pane_previous 側の prefix+shift+tab が残るので巡回はできる。
      cycle_pane_next = "prefix+o"
      # prefix+o を明け渡すため、通知先を開く操作をシフト付きへ退避。
      open_notification_target = "prefix+shift+o"

      # tmux の prefix ; （直前のペイン）。herdr の既定は未割り当て。
      last_pane = "prefix+semicolon"

      # --- 既定のままで tmux と一致しているもの（確認用に明示） ---
      # new_tab      = "prefix+c"
      # next_tab     = "prefix+n"
      # previous_tab = "prefix+p"
      # switch_tab   = "prefix+1..9"   # tmux と違い 0 は無い
      # close_pane   = "prefix+x"
      # zoom         = "prefix+z"
      # コピーモードの prefix+[ は設定不可（固定）。貼り付けの prefix+] は herdr に無い。

      # --- 揃えられなかったもの ---
      # prefix+&（close_tab）と prefix+%／prefix+"（分割）は
      # シフト付き記号で、herdr 自身が「端末依存」と警告しているため既定のまま。
      #   close_tab        = "prefix+shift+x"
      #   split_vertical   = "prefix+v"      （右に分割）
      #   split_horizontal = "prefix+minus"  （下に分割）
      # tmux の prefix+l（直前の window）に相当する操作は herdr に無い。
      # prefix+h/j/k/l はペインのフォーカス移動として既定のまま使う。
  '';

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
