{ config, pkgs, lib, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "riorio";
  home.homeDirectory = "/home/riorio";

# 触るな危険
  home.stateVersion = "26.05"; # Please read the comment before changing.
# 触るな危険

  # Nixpkgs
  home.packages = with pkgs; [
    nautilus
    wl-clipboard
    microsoft-edge
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

  # Permitted proprietary softwares
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "microsoft-edge"
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
    nixvim.enable = true;
    waybar.enable = true;
  };

  services = {
    # notification daemon
    dunst.enable = true;
    hyprlauncher.enable = true;
    hyprpolkitagent.enable = true;
  };

  # 日本語Keylayout
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-mozc
    ];
    # Generate .config/fcitx5/profile
    fcitx5.settings.inputMethod = {
      "Groups/0" = {
        Name = "Default";
	"Default Layout" = "us";
	DefaultIM = "mozc";
      };
      "Groups/0/Items/0".Name = "keyboard-us";
      "Groups/0/Items/0".Layout = "";
      "Groups/0/Items/1".Name = "mozc";
      "Groups/0/Items/1".Layout = "";
      "GroupOrder"."0" = "Default";
    };
    # Generate .config/fcitx5/config
    fcitx5.settings.globalOptions = {
      Hotkey = {
        EnumarateWithTriggerKeys = "True";
	EnumerateForwardKeys = "";
	EnumerateBackwardKeys = "";
	EnnumerateSkipFirst = "False";
	ModifierOnlyKeyTimeout = "250";
      };
      "Hotkey/TriggerKeys" = {
        "0" = "Zenkaku_Hankaku";
      };
      "Hotkey/ActivateKeys" = {
        "0" = "Hangul";
      };
      "Hotkey/DeactivateKeys" = {
        "0" = "Hangul_Romaja";
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
    fcitx5.ignoreUserConfig = true;
  };
}
