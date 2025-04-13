# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
    imports =
        [ # Include the results of the hardware scan.
          ./hardware-configuration.nix
          ./nvidia.nix
        ];

    nix.settings.experimental-features = [ "flakes" "nix-command" ];

    # Bootloader.
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    virtualisation.virtualbox.host.enable = true;
    nixpkgs.config.virtualbox.host.enableExtensionPack = true;
    virtualisation.virtualbox.guest.enable = true;

    networking.hostName = "nixos"; # Define your hostname.
    # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
    networking = {
        
	networkmanager.enable = true;
		#firewall = {
		#	enable = true;
		#	allowedTCPPorts = [ 5900  5901  5902 9993 ];
		#	extraInputRules = '' '';

		#};
	  firewall = {
		enable = true;

		allowedTCPPorts = [ 5900  5901  5902 6969];
		extraInputRules = ''
        # allow from docker nets to host
		ip saddr 172.0.0.0/8 accept
		'';
	  };
	};

	programs.nix-ld.enable = true;

	programs.nix-ld.libraries = with pkgs; [
		# Add any missing dynamic libraries for unpackaged programs
		# here, NOT in environment.systemPackages
		cypress
	];
  
# Enable networking
    # networking.networkmanager.enable = true;
    networking.extraHosts =
        ''
        127.0.0.1 pve
        127.0.0.1 datomic
        '';
    systemd.services.NetworkManager-wait-online.enable = false;


# Set your time zone.
  time.timeZone = "Africa/Johannesburg";

# Select internationalisation properties.
  i18n.defaultLocale = "en_ZA.UTF-8";

# Enable the X11 windowing system.
	services.xserver.enable = true;

# Enable the GNOME Desktop Environment.
	# use lightdm for x11vncserver
	# still need to check if lightdm is 100% needed
	services.xserver.displayManager.lightdm.enable = true;
#        services.xserver.displayManager.gdm.enable = true;
	services.xserver.desktopManager.gnome.enable = true;
	services.xserver.displayManager.gdm.wayland = false;


  # Disable the GNOME3/GDM auto-suspend feature that cannot be disabled in GUI!
  # If no user is logged in, the machine will power down after 20 minutes.

	systemd.targets.sleep.enable = false;
	systemd.targets.suspend.enable = false;
	systemd.targets.hibernate.enable = false;
	systemd.targets.hybrid-sleep.enable = false;

# compositor
    services.picom.enable = false;


# SHEBANGS IN SH SCRIPTS ARE A NIGHTMARE!
	services.envfs.enable = true;


# Configure keymap in X11
    services.xserver = {
	xkb.layout = "us";
	xkb.variant = "";
    };

    fonts.fontconfig.antialias = true;
    fonts.packages = with pkgs; [
        # https://nixos.wiki/wiki/Fonts
        #(nerd-fonts.override { fonts = [ "nerd-fonts.fira-code" "nerd-fonts.source-code-pro" ]; })
         nerd-fonts.fira-mono
         nerd-fonts.fira-code
         nerd-fonts.roboto-mono
    ];

# Virtualisation
    virtualisation.docker.enable = true;

# Enable CUPS to print documents.
    services.printing.enable = true;

# Enable sound with pipewire.
    hardware.pulseaudio.enable = false;
    security.rtkit.enable = true;

    services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        # If you want to use JACK applications, uncomment this
        #jack.enable = true;

        # use the example session manager (no others are packaged yet so this is enabled by default,
        # no need to redefine it in your config for now)
        #media-session.enable = true;
    };

# Enable touchpad support (enabled default in most desktopManager).
    # services.xserver.libinput.enable = true;

# Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.carl = {
        isNormalUser = true;
        description = "Carl";
        extraGroups = [ "networkmanager" "wheel" "docker" "vboxusers"];
        packages = with pkgs; [
            anydesk
            (wineWowPackages.full.override {
                wineRelease = "staging";
                mingwSupport = true;
            })
        ];
    };

# +++++++++++++++++++++ PROGRAMS ++++++++++++++++++++++++++++++++++++
# Install firefox.
    programs.firefox.enable = true;
  
# Install tailscale
    services.tailscale.enable = true;

    programs.dconf = {
        enable = true;
    };

# Install 1pass
    programs._1password.enable = true;
    programs._1password-gui = {
        enable = true;
        # Certain features, including CLI integration and system authentication support,
        # require enabling PolKit integration on some desktop environments (e.g. Plasma).
        polkitPolicyOwners = [ "carl" ];
    };


    # Install zsh
    programs.zsh = {
        enable = true;
        autosuggestions.enable = true;
        zsh-autoenv.enable = true;
        syntaxHighlighting.enable = true;
        ohMyZsh = {
            enable = true;
            theme = "af-magic";
            plugins = [
                "git"
                "npm"
                "history"
                "node"
                "rust"
                "deno"
            ];
        };
    };

# Set Default Shell
    users.defaultUserShell = pkgs.zsh;


# Install steam
    programs.steam = {
        enable = true;
        remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
        dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    };
  
# Allow unfree packages
    nixpkgs.config.allowUnfree = true;
    nixpkgs.config.allowBroken = true;
    nixpkgs.config.nvidia.acceptLicense = true;


# List packages installed in system profile. To search, run:
# $ nix search wget

    environment.systemPackages = with pkgs; [
        wget
        qemu
        neovim
        docker
        curl
        git
        zsh
        anydesk
        slack
        jetbrains.idea-community
        gitui
        clojure-lsp
        clojure
        leiningen
        cljfmt
        libreoffice
        gnomeExtensions.notification-timeout
        gnomeExtensions.system-monitor
        gnomeExtensions.notification-banner-reloaded
	dconf
        home-manager
        packer
        #vagrant
        docker-compose
        python3
        jetbrains.gateway
        jetbrains.clion
        jetbrains-toolbox
        OVMFFull
	clockify
	nodejs_22
	insomnia
	rustc
	cargo
	maven
	yarn
	cider
	torrential
	vscode
	ardour
	busybox
	gnome-remote-desktop
	xorg.xinit
	ruby
	jq
	gpu-viewer
	inspector
	code-cursor

	# VNC server
	x11vnc
	
	#AI tools
	lmstudio

	#lastapp
	
		

#WINE
# support both 32- and 64-bit applications
        wineWowPackages.stable

# support 32-bit only
        #wine

# support 64-bit only
        (wine.override { wineBuild = "wine64"; })

# support 64-bit only
        wine64

# wine-staging (version with experimental features)
        wineWowPackages.staging

# winetricks (all versions)
        winetricks

# native wayland support (unstable)
        wineWowPackages.waylandFull

  ]; # END OF SYSTEM PACKAGES

# List services that you want to enable:

# Enable the OpenSSH daemon.

    
	services.openssh = {
		enable = true;
		ports = [22];
		settings.PasswordAuthentication = false;
	};
	
	#services.mysql = {
	#	enable = true;
	#	package = pkgs.mariadb;
	#};
	
  	system.stateVersion = "24.11"; # Did you read the comment?


}
