{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "conor";
  home.homeDirectory = "/home/conor";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.

  # I don't know how to straighten out this error:
  #
  #   trace: warning: You are using
  #   Home Manager version 24.05 and
  #   Nixpkgs version 24.11.
  #
  #   Using mismatched versions is likely to cause errors and unexpected
  #   behavior. It is therefore highly recommended to use a release of Home
  #   Manager that corresponds with your chosen release of Nixpkgs.
  #
  # so we're disabling it.
  home.enableNixpkgsReleaseCheck = false;

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello
    pkgs.age
    pkgs.bat
    pkgs.bottom
    pkgs.byobu
    pkgs.curl
    pkgs.diceware
    pkgs.direnv
    pkgs.dunst
    pkgs.fd
    pkgs.fzf
    pkgs.git
    pkgs.gum
    pkgs.htop
    pkgs.neovim
    # pkgs.ntfy-sh conflicts with home-manager-path/bin/fbsen
    pkgs.ripgrep
    pkgs.sops
    pkgs.starship
    pkgs.zellij
    pkgs.gifski

    # temporary dev cruft
    pkgs.pnpm
    pkgs.nodejs_22
    pkgs.wasm-pack

    # graphical workstation packages
    # TODO: make this inclusion conditional
    pkgs.alacritty
    # pkgs.moc # throws libasound/pipewire errors
    # pkgs.redshift # idk how to do user systemd services on non-nixos for nixpkgs
    pkgs.rofi
    # pkgs.xrandr
    # pkgs.xset
 
    # cargo pkgs
    pkgs.bottom
    pkgs.cargo-watch
    pkgs.du-dust
    # pkgs.etym
    # pkgs.exa
    pkgs.hyperfine
    pkgs.just
    pkgs.oha
    pkgs.tokei
    pkgs.toml-cli
    pkgs.watchexec

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
  #  /etc/profiles/per-user/conor/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

}
