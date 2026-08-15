{ config, ... }:

# mango の設定。コンポジタ本体の有効化は /etc/nixos の programs.mango。
#
# bind の書式は "修飾キー,キー,アクション[,引数]"。
# home-manager モジュールがビルド時に `mango -c <config> -p` で
# 構文チェックするので、書式を間違えるとビルドが落ちる。

let
  cfg = config.desktop;
in

{
  wayland.windowManager.mango = {
    enable = true;
    systemd.enable = true;

    settings = {
      bind = [
        # 起動系
        "SUPER,Return,spawn,${cfg.terminal}"
        "SUPER,d,spawn,${cfg.launcher}"
        "SUPER,b,spawn,${cfg.browser}"
        "SUPER,e,spawn,${cfg.fileManager}"

        "SUPER,q,killclient,"
        "SUPER,r,reload_config"

        # 音量・メディア・輝度。niri / hyprland 側と揃えてある。
        "NONE,XF86AudioRaiseVolume,spawn,wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+ -l 1.0"
        "NONE,XF86AudioLowerVolume,spawn,wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-"
        "NONE,XF86AudioMute,spawn,wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        "NONE,XF86AudioMicMute,spawn,wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        "NONE,XF86AudioPlay,spawn,playerctl play-pause"
        "NONE,XF86AudioPrev,spawn,playerctl previous"
        "NONE,XF86AudioNext,spawn,playerctl next"
        "NONE,XF86MonBrightnessUp,spawn,brightnessctl --class=backlight set +10%"
        "NONE,XF86MonBrightnessDown,spawn,brightnessctl --class=backlight set 10%-"

        # 一覧表示
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
