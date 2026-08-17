{
  config,
  lib,
  pkgs,
  ...
}:

# niri の設定。コンポジタ本体の有効化は /etc/nixos の programs.niri。
#
# home-manager にも niri 本体にも programs.niri の HM モジュールが無いので、
# 設定ファイル（KDL）を直接置く。`niri validate -c <file>` で検証できる。

let
  cfg = config.desktop;
  noctalia = lib.getExe config.programs.noctalia.package;
in

{
  xdg.configFile."niri/config.kdl".text = ''
    // このファイルは home-manager が生成している。直接編集しても
    // 次の switch で上書きされるので desktop/niri.nix を編集すること。

    input {
        keyboard {
            xkb {
                layout "us"
            }
        }
        touchpad {
            tap
            natural-scroll

            // タイピング中は無効にする。libinput の既定も有効だが、
            // この機能が実際に働くには /etc/nixos の hardware/touchpad.nix が
            // 要る（T2 のトラックパッドは外付け扱いにされていて、そのままだと
            // 設定項目自体が libinput 側に作られない）。
            dwt

            // 指の本数でボタンを決める（1=左 / 2=右 / 3=中）。
            // libinput は Apple のタッチパッドなら既定で clickfinger にするが、
            // hyprland と mango は明示的に button-areas を渡してしまうので、
            // 3 つのコンポジタで挙動を揃えるためここでも明示する。
            click-method "clickfinger"
        }
    }

    prefer-no-csd

    // XWayland。niri 自身が xwayland-satellite を起動し、DISPLAY の設定と
    // 終了時の後始末まで面倒を見る。spawn-at-startup で自前に起動する必要は
    // ない（その場合 DISPLAY は自分で設定することになる）。
    // ここで store パスを直書きしているので、home.packages に足す必要もない。
    xwayland-satellite {
        path "${lib.getExe pkgs.xwayland-satellite}"
    }

    // アプリは作業領域いっぱいの幅で開く。noctalia のバーとギャップは残り、
    // タイル配置のままなので、通常幅に戻したいときは Mod+R で切り替える。
    window-rule {
        open-maximized true
    }

    binds {
        Mod+Shift+Slash { show-hotkey-overlay; }

        // 起動系
        Mod+Return { spawn "${cfg.terminal}"; }
        Mod+D { spawn "${noctalia}" "msg" "panel-toggle" "launcher"; }
        Mod+B { spawn "${cfg.browser}"; }
        Mod+E { spawn "${cfg.fileManager}"; }

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
}
