{ config, lib, pkgs, ... }:

# デスクトップ層の共通部分。コンポジタ固有の設定は同階層のファイルに分ける。
# 将来 dendritic pattern に寄せる前提で、各コンポジタが自分のファイルだけを
# 見ればよい形にしてある。
#
# 欲しいのは 4 つ:
#   ブラウザ      google-chrome
#   ランチャー    noctalia のランチャーパネル
#   ターミナル    foot
#   ステータスバー noctalia のバー
#
# コンポジタ側は desktop.* を参照するだけでよく、アプリを変えるときは
# ここ 1 箇所を直せば 3 つとも追従する。

let
  cfg = config.desktop;
in

{
  imports = [
    ./hyprland.nix
    ./mango.nix
    ./niri.nix
  ];

  options.desktop = {
    terminal = lib.mkOption {
      type = lib.types.str;
      description = "ターミナルを起動するコマンド";
    };

    browser = lib.mkOption {
      type = lib.types.str;
      description = "ブラウザを起動するコマンド";
    };

    launcher = lib.mkOption {
      type = lib.types.str;
      description = "ランチャーを開くコマンド";
    };

    fileManager = lib.mkOption {
      type = lib.types.str;
      description = "ファイルマネージャを起動するコマンド";
    };

    screenshot = lib.mkOption {
      type = lib.types.str;
      description = ''
        領域を選択してスクリーンショットを撮るコマンド。
        niri は組み込みの screenshot アクションを持つので使わない。
      '';
    };
  };

  config = {
    desktop = {
      terminal = "foot";
      browser = "google-chrome-stable";
      fileManager = "nautilus";

      # 走っている noctalia に IPC でパネルを開かせる。
      # 実行ファイル名は noctalia-shell ではなく noctalia。
      launcher = "${lib.getExe config.programs.noctalia.package} msg panel-toggle launcher";

      screenshot = "${lib.getExe pkgs.grim} -g \"$(${lib.getExe pkgs.slurp})\"";
    };

    home.packages = [
      pkgs.grim
      pkgs.slurp
    ];

    # ステータスバー・ランチャー・通知をまとめて担当する。
    # graphical-session.target 紐付けの systemd user service で起動するので、
    # どのコンポジタでも同じものが上がる。コンポジタ側の自動起動には書かない
    # （二重起動になるため）。
    programs.noctalia = {
      enable = true;
      systemd.enable = true;
    };

    # polkit 認証エージェント。NixOS 側にこのオプションは無く home-manager 専用。
    services.hyprpolkitagent.enable = true;
  };
}
