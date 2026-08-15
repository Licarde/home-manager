{ config, ... }:

# Hyprland の設定。コンポジタ本体は /etc/nixos の programs.hyprland が
# flake input 版を入れているので、こちらは package = null にして
# 設定だけを受け持つ（両方が入れると衝突する）。
#
# systemd.enable は既定 true。hyprland-session.target を立てて
# graphical-session.target に繋ぐので、noctalia の user service が
# 自動起動するようになる。UWSM を経由せず Hyprland を直接起動しても効く。

let
  cfg = config.desktop;
in

{
  wayland.windowManager.hyprland = {
    enable = true;

    # NixOS 側で入れているので home-manager 側では入れない。
    package = null;
    portalPackage = null;

    settings = {
      "$mod" = "SUPER";

      # 起動系
      bind = [
        "$mod, Return, exec, ${cfg.terminal}"
        "$mod, D, exec, ${cfg.launcher}"
        "$mod, B, exec, ${cfg.browser}"
        "$mod, E, exec, ${cfg.fileManager}"

        # 特殊ワークスペース（旧設定から引き継ぎ）
        "$mod, S, togglespecialworkspace, magic"
        "$mod SHIFT, S, movetoworkspace, special:magic"

        "$mod, Q, killactive,"
        "$mod, F, fullscreen, 1"
        "$mod SHIFT, F, fullscreen, 0"
        "$mod, V, togglefloating,"
        "$mod SHIFT, E, exit,"

        # フォーカス移動
        "$mod, left,  movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up,    movefocus, u"
        "$mod, down,  movefocus, d"
        "$mod, H, movefocus, l"
        "$mod, L, movefocus, r"
        "$mod, K, movefocus, u"
        "$mod, J, movefocus, d"

        # ウィンドウ移動
        "$mod CTRL, left,  movewindow, l"
        "$mod CTRL, right, movewindow, r"
        "$mod CTRL, up,    movewindow, u"
        "$mod CTRL, down,  movewindow, d"

        # ワークスペース
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"

        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"

        "$mod, mouse_down, workspace, e+1"
        "$mod, mouse_up,   workspace, e-1"

        # スクリーンショット
        ", Print, exec, ${cfg.screenshot}"
      ];

      # 押しっぱなしで連続的に効かせたいもの
      binde = [
        ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+ -l 1.0"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-"
        ", XF86MonBrightnessUp,   exec, brightnessctl --class=backlight set +10%"
        ", XF86MonBrightnessDown, exec, brightnessctl --class=backlight set 10%-"
      ];

      # ロック中でも効かせたいもの
      bindl = [
        ", XF86AudioMute,    exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioPrev, exec, playerctl previous"
        ", XF86AudioNext, exec, playerctl next"
      ];

      # マウスでのウィンドウ移動とリサイズ
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      input = {
        kb_layout = "us";
        touchpad = {
          natural_scroll = true;
          tap-to-click = true;
        };
      };

      general = {
        gaps_in = 4;
        gaps_out = 8;
        border_size = 2;
      };

      misc = {
        # noctalia が壁紙を出すので Hyprland 側のロゴは消す
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
      };
    };
  };
}
