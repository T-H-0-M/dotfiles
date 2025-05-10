{
  description = "Thomas' nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
      nix-homebrew,
    }:
    let
      configuration =
        { pkgs, config, ... }:
        {
          nixpkgs.config.allowUnfree = true;
          environment.systemPackages = [
            pkgs.neovim
            pkgs.tmux
            pkgs.ffmpeg_6-full
            pkgs.git
            pkgs.fzf
            pkgs.ripgrep
            pkgs.nodejs_22
            pkgs.lazygit
            pkgs.zsh-powerlevel10k
            pkgs.qmk
            pkgs.zoxide
            pkgs.cargo
            pkgs.nixfmt-rfc-style
            pkgs.cocoapods
            pkgs.fastlane
            pkgs.claude-code
            pkgs.gemini-cli
            pkgs.nodePackages_latest.aws-cdk
            pkgs.findutils
          ];

          homebrew = {
            enable = true;
            brews = [
              "mas"
              "openjdk@17"
              "gradle"
              "maven"
              "awscli"
              "go"
              "gh"
            ];
            casks = [
              "firefox"
              "chatgpt"
              "alacritty"
              "google-chrome"
              "obs"
              "drawio"
              "postman"
              "karabiner-elements"
              "spotify"
              "whatsapp"
              "1password"
              "zoom"
              "trezor-suite"
              "visual-studio-code"
              "nikitabobko/tap/aerospace"
              "lm-studio"
              "alfred"
              "tg-pro"
              "discord"
              "microsoft-word"
              "gimp"
              "steam"
              "android-studio"
              "docker-desktop"
              "font-monaspace"
              "drawio"
              "iterm2"
              "mullvad-vpn"
              "mactex"
              "skim"
              "claude-code"
            ];
            masApps = {
              "TestFlight" = 899247664;
              "Transporter" = 1450874784;
              "Xcode" = 497799835;
              "FinalCutPro" = 424389933;
              "Motion" = 434290957;
            };
            onActivation.cleanup = "zap";
            onActivation.autoUpdate = true;
            onActivation.upgrade = true;
          };

          fonts.packages = [
            pkgs.nerd-fonts.jetbrains-mono
          ];

          # Read username from environment variable, fallback to "thomas"
          system.primaryUser =
            let
              envUser = builtins.getEnv "DOTFILES_USER";
            in
            if envUser != "" then envUser else "thomas";
          system.defaults = {
            dock.autohide = true;
            dock.persistent-apps = [
              "/Applications/iTerm.app"
              "/Applications/Firefox.app"
              "/Applications/Spotify.app"
            ];
            finder.FXPreferredViewStyle = "clmv";
            loginwindow.GuestEnabled = false;
            NSGlobalDomain.AppleICUForce24HourTime = true;
            NSGlobalDomain.AppleInterfaceStyle = "Dark";
            NSGlobalDomain.KeyRepeat = 2;
          };

          nix.settings.experimental-features = "nix-command flakes";
          system.configurationRevision = self.rev or self.dirtyRev or null;
          system.stateVersion = 6;
          nixpkgs.hostPlatform = "aarch64-darwin";
        };
      # Read hostname from environment variable, fallback to "Thomas-MacBook-Pro"
      hostname =
        let
          envHostname = builtins.getEnv "DOTFILES_HOSTNAME";
        in
        if envHostname != "" then envHostname else "Thomas-MacBook-Pro";

      # Read username from environment variable, fallback to "thomas"
      username =
        let
          envUser = builtins.getEnv "DOTFILES_USER";
        in
        if envUser != "" then envUser else "thomas";
    in
    {
      darwinConfigurations.${hostname} = nix-darwin.lib.darwinSystem {
        modules = [
          configuration
          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              enable = true;
              enableRosetta = true;
              user = username;
              autoMigrate = true;
            };
          }
        ];
      };
      darwinPackages = self.darwinConfigurations.${hostname}.pkgs;
    };
}
