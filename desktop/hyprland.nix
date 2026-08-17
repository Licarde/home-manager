{ config, lib, ... }:

# Hyprland の設定。コンポジタ本体は /etc/nixos の programs.hyprland が
# flake input 版を入れているので、こちらは package = null にして
# 設定だけを受け持つ（両方が入れると衝突する）。
#
# systemd.enable は既定 true。hyprland-session.target を立てて
# graphical-session.target に繋ぐので、noctalia の user service が
# 自動起動するようになる。UWSM を経由せず Hyprland を直接起動しても効く。

let
  cfg = config.desktop;

  inherit (lib.generators) mkLuaInline;

  # hl.bind の第 1 引数。settings.mod が吐く local と連結する Lua 式にする。
  modKey = key: mkLuaInline ''mod .. " + ${key}"'';

  # hl.bind(<キー>, <ディスパッチャ>, <オプション>) の引数を組み立てる。
  # ディスパッチャは文字列ではなく Lua の式なので mkLuaInline で生のまま埋める。
  mkBind = key: dispatcher: opts: {
    _args = [
      key
      (mkLuaInline dispatcher)
    ]
    ++ lib.optional (opts != null) opts;
  };

  # mod 付き。修飾キーを足すときは "SHIFT + F" のように key 側に書く。
  bind = key: dispatcher: mkBind (modKey key) dispatcher null;
  bind' =
    key: dispatcher: opts:
    mkBind (modKey key) dispatcher opts;

  # mod 無し（メディアキーや Print）。
  bare =
    key: dispatcher: opts:
    mkBind key dispatcher opts;

  # シェルに渡すコマンドは "" を含むことがあるので Lua の長括弧文字列で囲む。
  exec = command: "hl.dsp.exec_cmd([[${command}]])";

  # 押しっぱなしで連続的に効かせたいもの（旧 binde）。
  repeating = {
    repeating = true;
  };

  # ロック中でも効かせたいもの（旧 bindl）。
  locked = {
    locked = true;
  };

  # フォーカス移動。矢印キーと vim 風キーの両方を同じ向きに割り当てる。
  focusKeys = [
    {
      key = "left";
      dir = "left";
    }
    {
      key = "right";
      dir = "right";
    }
    {
      key = "up";
      dir = "up";
    }
    {
      key = "down";
      dir = "down";
    }
    {
      key = "H";
      dir = "left";
    }
    {
      key = "L";
      dir = "right";
    }
    {
      key = "K";
      dir = "up";
    }
    {
      key = "J";
      dir = "down";
    }
  ];

  moveKeys = [
    {
      key = "left";
      dir = "left";
    }
    {
      key = "right";
      dir = "right";
    }
    {
      key = "up";
      dir = "up";
    }
    {
      key = "down";
      dir = "down";
    }
  ];
in

{
  wayland.windowManager.hyprland = {
    enable = true;

    # NixOS 側で入れているので home-manager 側では入れない。
    package = null;
    portalPackage = null;

    # Hyprland 0.56 は設定を hyprland.lua からしか読まない。
    # src/config/supplementary/jeremy/Jeremy.cpp の getMainConfigPath() が
    # findConfig("hyprland", "lua") しか呼ばず、hyprland.conf への
    # フォールバックが無いため。configType = "hyprlang" にすると
    # home-manager は hyprland.conf を書き、それは丸ごと無視されて
    # Hyprland は既定の設定を生成して起動する（＝バインドが効かない）。
    configType = "lua";

    # lua モードでは settings.<名前> が hl.<名前>(...) の呼び出しになる。
    # _var を持つ値だけは local 変数として先頭に吐かれる。
    settings = {
      # local mod = "SUPER"
      mod._var = "SUPER";

      config = {
        general = {
          gaps_in = 4;
          gaps_out = 8;
          border_size = 2;
        };

        input = {
          kb_layout = "us";
          touchpad = {
            natural_scroll = true;

            # lua モードでのキー名は hyprlang のものと綴りが違う。
            # Hyprland は m_configValues を引くときに ':' を '.' に、
            # '-' を '_' に置き換えるので（src/config/lua/ConfigManager.cpp）、
            # hyprlang の input:touchpad:tap-to-click は lua では
            # input.touchpad.tap_to_click になる。ハイフンのまま書くと
            # 「unknown config key」でこの 1 行だけが黙って捨てられる。
            tap_to_click = true;

            # 3 本指ドラッグ（macOS 風にウィンドウやテキストを掴む）。
            # libinput 1.28 の LIBINPUT_CONFIG_3FG_DRAG をそのまま渡す値で、
            # 0 = 無効 / 1 = 3 本指 / 2 = 4 本指。3 本指を掴む方に使うので、
            # スワイプのジェスチャは 4 本指側に寄せてある（下の gesture）。
            drag_3fg = 1;

            # タイピング中は無効にする。Hyprland の既定も true なので値は
            # 変わらないが、3 つのコンポジタで同じことを同じ場所に書いておく。
            # 実際に働くには /etc/nixos の hardware/touchpad.nix が要る。
            disable_while_typing = true;

            # 指の本数でボタンを決める（1=左 / 2=右 / 3=中）。既定は false で、
            # その場合 Hyprland は button-areas を渡す。libinput 自身は Apple の
            # タッチパッドなら clickfinger を既定にするので、これは既定値を
            # 上書きして本来の挙動に戻していることになる。
            #
            # 3 本指の押し込み（＝中クリック）と上の drag_3fg は、libinput 側では
            # 「押し込み」と「3 本指を置いて動かす」で別経路なので両立するはず。
            # 実機で干渉するようなら drag_3fg を 2（4 本指）に寄せる。
            clickfinger_behavior = true;
          };
        };

        misc = {
          # noctalia が壁紙を出すので Hyprland 側のロゴは消す
          disable_hyprland_logo = true;
          disable_splash_rendering = true;
        };
      };

      # トラックパッドのジェスチャ。0.51 で gestures:workspace_swipe が廃止され、
      # gesture（lua では hl.gesture）に本数・方向・動作を 1 件ずつ登録する形に
      # なった。既定のジェスチャは 1 件も登録されないので、書かなければ何本指で
      # 払っても無反応になる。
      #
      # 3 本指は上の drag_3fg がドラッグに使うため、スワイプは 4 本指に寄せる。
      # direction = "horizontal" で左右をまとめて 1 件にできる。向きは
      # gestures:workspace_swipe_invert（既定 true）が決めていて、既定のままで
      # natural_scroll と揃う（左に払うと右のワークスペースへ）。
      gesture = [
        {
          fingers = 4;
          direction = "horizontal";
          action = "workspace";
        }
      ];

      bind =
        # 起動系
        [
          (bind "Return" (exec cfg.terminal))
          (bind "D" (exec cfg.launcher))
          (bind "B" (exec cfg.browser))
          (bind "E" (exec cfg.fileManager))

          # 特殊ワークスペース（旧設定から引き継ぎ）
          (bind "S" ''hl.dsp.workspace.toggle_special("magic")'')
          (bind "SHIFT + S" ''hl.dsp.window.move({ workspace = "special:magic" })'')

          # ウィンドウ操作。fullscreen の mode は
          # maximized が旧 `fullscreen, 1`、fullscreen が旧 `fullscreen, 0`。
          (bind "Q" "hl.dsp.window.close()")
          (bind "F" ''hl.dsp.window.fullscreen({ mode = "maximized" })'')
          (bind "SHIFT + F" ''hl.dsp.window.fullscreen({ mode = "fullscreen" })'')
          (bind "V" ''hl.dsp.window.float({ action = "toggle" })'')
          (bind "SHIFT + E" "hl.dsp.exit()")
        ]

        # フォーカス移動
        ++ map (e: bind e.key ''hl.dsp.focus({ direction = "${e.dir}" })'') focusKeys

        # ウィンドウ移動
        ++ map (e: bind "CTRL + ${e.key}" ''hl.dsp.window.move({ direction = "${e.dir}" })'') moveKeys

        # ワークスペース
        ++ map (i: bind (toString i) "hl.dsp.focus({ workspace = ${toString i} })") (lib.range 1 9)
        ++ map (i: bind "SHIFT + ${toString i}" "hl.dsp.window.move({ workspace = ${toString i} })") (
          lib.range 1 4
        )

        ++ [
          (bind "mouse_down" ''hl.dsp.focus({ workspace = "e+1" })'')
          (bind "mouse_up" ''hl.dsp.focus({ workspace = "e-1" })'')

          # マウスでのウィンドウ移動とリサイズ
          (bind' "mouse:272" "hl.dsp.window.drag()" { mouse = true; })
          (bind' "mouse:273" "hl.dsp.window.resize()" { mouse = true; })

          # スクリーンショット
          (bare "Print" (exec cfg.screenshot) null)

          # 音量・輝度は押しっぱなしで効かせる
          (bare "XF86AudioRaiseVolume" (exec "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+ -l 1.0") repeating)
          (bare "XF86AudioLowerVolume" (exec "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-") repeating)
          (bare "XF86MonBrightnessUp" (exec "brightnessctl --class=backlight set +10%") repeating)
          (bare "XF86MonBrightnessDown" (exec "brightnessctl --class=backlight set 10%-") repeating)

          # ミュートとメディアはロック中でも効かせる
          (bare "XF86AudioMute" (exec "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle") locked)
          (bare "XF86AudioMicMute" (exec "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle") locked)
          (bare "XF86AudioPlay" (exec "playerctl play-pause") locked)
          (bare "XF86AudioPrev" (exec "playerctl previous") locked)
          (bare "XF86AudioNext" (exec "playerctl next") locked)
        ];
    };
  };
}
