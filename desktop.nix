{ config, pkgs, lib, ... }:

# niri と mango の設定。コンポジタ本体の有効化は /etc/nixos 側
# （programs.niri / programs.mango）で、ここに書くのはユーザー設定だけ。
#
# 欲しいのは 4 つ:
#   ブラウザ      google-chrome
#   ランチャー    noctalia のランチャーパネル
#   ターミナル    foot
#   ステータスバー noctalia のバー
#
# noctalia は systemd user service（graphical-session.target 紐付け）で
# 起動するので、どちらのコンポジタでも同じものが上がる。コンポジタ側の
# 自動起動には書かない（二重起動になるため）。

let
  terminal = "foot";
  browser = "google-chrome-stable";

  # ランチャーは走っている noctalia に IPC でパネルを開かせる。
  # 実行ファイル名は noctalia-shell ではなく noctalia。
  launcher = "${lib.getExe config.programs.noctalia.package} msg panel-toggle launcher";
in

{
  # ステータスバー・ランチャー・通知をまとめて担当する。
  programs.noctalia = {
    enable = true;
    systemd.enable = true;
  };

  #
  # niri
  #
  # home-manager にも niri 本体にも programs.niri の HM モジュールが無いので、
  # 設定ファイル（KDL）を直接置く。niri validate で検証できる。
  xdg.configFile."niri/config.kdl".text = ''
    // このファイルは home-manager が生成している。直接編集しても
    // 次の switch で上書きされるので desktop.nix を編集すること。

    input {
        keyboard {
            xkb {
                layout "us"
            }
        }
        touchpad {
            tap
            natural-scroll
        }
    }

    prefer-no-csd

    binds {
        Mod+Shift+Slash { show-hotkey-overlay; }

        // 起動系
        Mod+Return { spawn "${terminal}"; }
        Mod+D { spawn "${lib.getExe config.programs.noctalia.package}" "msg" "panel-toggle" "launcher"; }
        Mod+B { spawn "${browser}"; }

        // 音量・マイク
        XF86AudioRaiseVolume allow-when-locked=true { spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+ -l 1.0"; }
        XF86AudioLowerVolume allow-when-locked=true { spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-"; }
        XF86AudioMute        allow-when-locked=true { spawn-sh "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"; }
        XF86AudioMicMute     allow-when-locked=true { spawn-sh "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"; }

        // メディア
        XF86AudioPlay allow-when-locked=true { spawn-sh "playerctl play-pause"; }
        XF86AudioStop allow-when-locked=true { spawn-sh "playerctl stop"; }
        XF86AudioPrev allow-when-locked=true { spawn-sh "playerctl previous"; }
        XF86AudioNext allow-when-locked=true { spawn-sh "playerctl next"; }

        // 輝度
        XF86MonBrightnessUp   allow-when-locked=true { spawn "brightnessctl" "--class=backlight" "set" "+10%"; }
        XF86MonBrightnessDown allow-when-locked=true { spawn "brightnessctl" "--class=backlight" "set" "10%-"; }

        // ウィンドウ操作
        Mod+Q repeat=false { close-window; }
        Mod+O repeat=false { toggle-overview; }

        Mod+Left  { focus-column-left; }
        Mod+Down  { focus-window-down; }
        Mod+Up    { focus-window-up; }
        Mod+Right { focus-column-right; }
        Mod+H     { focus-column-left; }
        Mod+J     { focus-window-down; }
        Mod+K     { focus-window-up; }
        Mod+L     { focus-column-right; }

        Mod+Ctrl+Left  { move-column-left; }
        Mod+Ctrl+Down  { move-window-down; }
        Mod+Ctrl+Up    { move-window-up; }
        Mod+Ctrl+Right { move-column-right; }
        Mod+Ctrl+H     { move-column-left; }
        Mod+Ctrl+J     { move-window-down; }
        Mod+Ctrl+K     { move-window-up; }
        Mod+Ctrl+L     { move-column-right; }

        Mod+Home { focus-column-first; }
        Mod+End  { focus-column-last; }

        // 列の結合と分離
        Mod+BracketLeft  { consume-or-expel-window-left; }
        Mod+BracketRight { consume-or-expel-window-right; }
        Mod+Comma  { consume-window-into-column; }
        Mod+Period { expel-window-from-column; }

        // 幅と高さ
        Mod+R { switch-preset-column-width; }
        Mod+Shift+R { switch-preset-column-width-back; }
        Mod+F { maximize-column; }
        Mod+Shift+F { fullscreen-window; }
        Mod+M { maximize-window-to-edges; }
        Mod+C { center-column; }
        Mod+Minus { set-column-width "-10%"; }
        Mod+Equal { set-column-width "+10%"; }
        Mod+Shift+Minus { set-window-height "-10%"; }
        Mod+Shift+Equal { set-window-height "+10%"; }

        // フローティングとタブ表示
        Mod+V       { toggle-window-floating; }
        Mod+Shift+V { switch-focus-between-floating-and-tiling; }
        Mod+W       { toggle-column-tabbed-display; }

        // ワークスペース
        Mod+Page_Down { focus-workspace-down; }
        Mod+Page_Up   { focus-workspace-up; }
        Mod+U         { focus-workspace-down; }
        Mod+I         { focus-workspace-up; }
        Mod+Ctrl+U    { move-column-to-workspace-down; }
        Mod+Ctrl+I    { move-column-to-workspace-up; }

        Mod+1 { focus-workspace 1; }
        Mod+2 { focus-workspace 2; }
        Mod+3 { focus-workspace 3; }
        Mod+4 { focus-workspace 4; }
        Mod+5 { focus-workspace 5; }
        Mod+6 { focus-workspace 6; }
        Mod+7 { focus-workspace 7; }
        Mod+8 { focus-workspace 8; }
        Mod+9 { focus-workspace 9; }
        Mod+Ctrl+1 { move-column-to-workspace 1; }
        Mod+Ctrl+2 { move-column-to-workspace 2; }
        Mod+Ctrl+3 { move-column-to-workspace 3; }
        Mod+Ctrl+4 { move-column-to-workspace 4; }

        Mod+WheelScrollDown cooldown-ms=150 { focus-workspace-down; }
        Mod+WheelScrollUp   cooldown-ms=150 { focus-workspace-up; }

        // スクリーンショット
        Print { screenshot; }
        Ctrl+Print { screenshot-screen; }
        Alt+Print { screenshot-window; }

        // 終了とモニタ電源
        Mod+Escape allow-inhibiting=false { toggle-keyboard-shortcuts-inhibit; }
        Mod+Shift+E { quit; }
        Mod+Shift+P { power-off-monitors; }
    }

    screenshot-path "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"
  '';

  #
  # mango
  #
  # bind の書式は "修飾キー,キー,アクション[,引数]"。
  wayland.windowManager.mango = {
    enable = true;
    systemd.enable = true;

    settings = {
      bind = [
        "SUPER,Return,spawn,${terminal}"
        "SUPER,d,spawn,${launcher}"
        "SUPER,b,spawn,${browser}"

        "SUPER,q,killclient,"
        "SUPER,r,reload_config"

        # 音量・メディア・輝度。niri 側と揃えてある。
        "NONE,XF86AudioRaiseVolume,spawn,wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+ -l 1.0"
        "NONE,XF86AudioLowerVolume,spawn,wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-"
        "NONE,XF86AudioMute,spawn,wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        "NONE,XF86AudioMicMute,spawn,wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        "NONE,XF86AudioPlay,spawn,playerctl play-pause"
        "NONE,XF86AudioPrev,spawn,playerctl previous"
        "NONE,XF86AudioNext,spawn,playerctl next"
        "NONE,XF86MonBrightnessUp,spawn,brightnessctl --class=backlight set +10%"
        "NONE,XF86MonBrightnessDown,spawn,brightnessctl --class=backlight set 10%-"

        # 一覧表示（mango は overview を持つ）
        "SUPER,o,toggleoverview,"

        # ウィンドウ移動
        "SUPER,Left,focusdir,left"
        "SUPER,Right,focusdir,right"
        "SUPER,Up,focusdir,up"
        "SUPER,Down,focusdir,down"

        "SUPER,f,togglefullscreen,"

        # タグ（mango は dwl 系なのでワークスペースではなくタグ）。
        # view / tag は引数が 2 つで、2 番目はモニタ番号。
        "SUPER,1,view,1,0"
        "SUPER,2,view,2,0"
        "SUPER,3,view,3,0"
        "SUPER,4,view,4,0"

        "SUPER+SHIFT,1,tag,1,0"
        "SUPER+SHIFT,2,tag,2,0"
        "SUPER+SHIFT,3,tag,3,0"
        "SUPER+SHIFT,4,tag,4,0"
      ];
    };
  };
}
