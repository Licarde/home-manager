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
        Mod+Return { spawn "${terminal}"; }
        Mod+D { spawn "${lib.getExe config.programs.noctalia.package}" "msg" "panel-toggle" "launcher"; }
        Mod+B { spawn "${browser}"; }

        Mod+Q { close-window; }
        Mod+Shift+E { quit; }

        // ウィンドウ移動
        Mod+Left  { focus-column-left; }
        Mod+Right { focus-column-right; }
        Mod+Up    { focus-window-up; }
        Mod+Down  { focus-window-down; }

        Mod+Shift+Left  { move-column-left; }
        Mod+Shift+Right { move-column-right; }
        Mod+Shift+Up    { move-window-up; }
        Mod+Shift+Down  { move-window-down; }

        Mod+F { maximize-column; }
        Mod+Shift+F { fullscreen-window; }

        // ワークスペース
        Mod+1 { focus-workspace 1; }
        Mod+2 { focus-workspace 2; }
        Mod+3 { focus-workspace 3; }
        Mod+4 { focus-workspace 4; }

        Print { screenshot; }
    }
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
