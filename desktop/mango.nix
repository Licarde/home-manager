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

    # systemd.enable = true が実際に効くのは autostart_sh を書いたときだけ。
    # モジュールは autostart_sh が空でないときにしか
    # ~/.config/mango/autostart.sh を生成せず、exec-once も足さないので、
    # 空のままだと dbus-update-activation-environment も
    # mango-session.target の起動も一度も走らない。
    #
    # fcitx5 は graphical-session.target 紐付けだが、LightDM が mango を
    # exec する前に nixos-fake-graphical-session.target を上げてしまうため、
    # WAYLAND_DISPLAY が無い状態で起動して waylandim が繋がらない
    # （journal に "Failed to open wayland connection"）。
    # 環境変数を systemd/D-Bus に入れ直した後で起動し直す。
    autostart_sh = ''
      systemctl --user restart fcitx5-daemon.service
    '';

    settings = {
      # 出力スケール。eDP-1 は 13 インチ 2560x1600 の Retina なので等倍だと
      # UI が小さすぎる。scale:2.0 で論理解像度は 1280x800。もっと広く
      # 使いたければ 1.6（=1600x1000）や 1.75 のような小数も指定できる。
      monitorrule = [ "name:eDP-1,scale:2.0" ];

      # トラックパッドのジェスチャ。書式は
      # "修飾キー,方向,指の本数,アクション[,引数]"。
      # 方向は「指を動かす向き」なので、macOS と同じく左に払うと右のタグへ
      # 移る形にしてある。逆にしたければ左右を入れ替える。
      # _have_client 付きは中身のあるタグだけを辿る（9 タグ中 4 つしか
      # 使っていないので空タグを飛ばせる）。
      gesturebind = [
        "NONE,left,4,viewtoright_have_client,0"
        "NONE,right,4,viewtoleft_have_client,0"
      ];

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
