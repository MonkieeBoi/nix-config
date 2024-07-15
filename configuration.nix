# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
    imports = [
        ./hardware-configuration.nix
    ];

    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    # # Bootloader.
    boot = {
        kernelPackages = pkgs.linuxPackages_latest;
        consoleLogLevel = 0;
        initrd.verbose = false;
        kernelParams = [
            "quiet"
            "splash"
            "rd.udev.log_level=3"
            "boot.shell_on_fail"
            "i915.enable_guc=2"
        ];
        loader = {
            efi.canTouchEfiVariables = true;
            systemd-boot.enable = true;
        };
    };

    networking.hostName = "nixbtw";
    # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

    # Enable networking
    networking.networkmanager.enable = true;

    time.timeZone = "Australia/Sydney";
    i18n.defaultLocale = "en_AU.UTF-8";
    i18n.extraLocaleSettings = {
        LC_ADDRESS = "en_AU.UTF-8";
        LC_IDENTIFICATION = "en_AU.UTF-8";
        LC_MEASUREMENT = "en_AU.UTF-8";
        LC_MONETARY = "en_AU.UTF-8";
        LC_NAME = "en_AU.UTF-8";
        LC_NUMERIC = "en_AU.UTF-8";
        LC_PAPER = "en_AU.UTF-8";
        LC_TELEPHONE = "en_AU.UTF-8";
        LC_TIME = "en_AU.UTF-8";
    };

    # Configure keymap in X11
    services.xserver.xkb = {
        layout = "us";
        variant = "";
    };

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.monke = {
        isNormalUser = true;
        description = "monke";
        extraGroups = [ "networkmanager" "wheel" "input" "storage" "video" "optical" "keyd" ];
        packages = with pkgs; [];
    };

    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;

    # List packages installed in system profile
    environment.systemPackages = with pkgs; [
        (hiPrio clang-tools)
        (mpv.override {scripts = [mpvScripts.mpris];})
        (wrapOBS { plugins = with obs-studio-plugins; [ obs-pipewire-audio-capture ]; })
        alsa-utils
        auto-cpufreq
        brightnessctl
        cargo
        chafa
        clipse
        dotool
        dunst
        entr
        fastfetch
        fbcat
        ffmpeg
        firefox
        foot
        fzf
        gcc
        git
        grim
        hyprlock
        hyprpicker
        imagemagick
        imv
        jdk
        jq
        kdePackages.qt6ct
        keyd
        killall
        libclang
        libnotify
        libsForQt5.qt5ct
        lua-language-server
        lxqt.lxqt-policykit
        mmv-go
        nnn
        nodejs_22
        nordic
        nordzy-cursor-theme
        playerctl
        prismlauncher
        ps_mem
        pulsemixer
        python3
        qmk
        qrcp
        qutebrowser
        ripgrep
        rustc
        satty
        simple-mtpfs
        slurp
        swaybg
        thermald
        tmux
        tofi
        tor-browser
        transmission_4
        trash-cli
        tty-clock
        typst
        udisks
        unzip
        upower
        vesktop
        vim
        waybar
        wget
        wl-clipboard
        wl-screenrec
        xdg-desktop-portal-hyprland
        xdg-user-dirs
        xdg-utils
        xdragon
        yambar
        yazi
        yt-dlp
        zathura
        zip
    ];

    fonts.packages = with pkgs; [
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-color-emoji
        (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    ];

    programs = {
        hyprland.enable = true;
        dconf.enable = true;
        neovim = {
            enable = true;
            defaultEditor = true;
        };
        steam = {
            enable = true;
            remotePlay.openFirewall = true;
            dedicatedServer.openFirewall = true;
            localNetworkGameTransfers.openFirewall = true;
        };
    };

    boot.loader.systemd-boot.configurationLimit = 10;
    nix.gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
    };
    nix.settings.auto-optimise-store = true;

    programs.nix-ld = {
        enable = true;
        libraries = pkgs.steam-run.fhsenv.args.multiPkgs pkgs;
    };

    environment.etc."keyd/keyd.conf".text = builtins.readFile ./keyd.conf;

    hardware.graphics = {
        enable = true;
        extraPackages = with pkgs; [
            intel-media-driver # LIBVA_DRIVER_NAME=iHD
            libvdpau-va-gl
            vpl-gpu-rt
        ];
    };
    environment.sessionVariables = { LIBVA_DRIVER_NAME = "iHD"; };

    # XDG Portals
    xdg = {
        autostart.enable = true;
        portal = {
            enable = true;
            extraPortals = [
                pkgs.xdg-desktop-portal
                pkgs.xdg-desktop-portal-gtk
            ];
        };
    };

    security.rtkit.enable = true;

    services = {
        udisks2.enable = true;
        upower.enable = true;
        printing.enable = true;
        thermald.enable = true;
        getty = {
            loginOptions = "-p -- monke";
            extraArgs = [ "--skip-login" ];
            greetingLine = ''[0mNixOS ${config.system.nixos.release} - \l'';
            helpLine = lib.mkForce "";
        };
        # This allows users in group input to use dotool without root permissions.
        udev.extraRules = ''
            KERNEL=="uinput", GROUP="input", MODE="0660", OPTIONS+="static_node=uinput"
        '';
        pipewire = {
            enable = true;
            alsa.enable = true;
            alsa.support32Bit = true;
            pulse.enable = true;
            jack.enable = true;
        };
        auto-cpufreq = {
            enable = true;
            settings = {
                battery = {
                    governor = "powersave";
                    turbo = "never";
                };
                charger = {
                    governor = "performance";
                    turbo = "auto";
                };
            };
        };
        transmission = {
            enable = true;
            user = "monke";
            package = pkgs.transmission_4;
            settings = {
                incomplete-dir-enabled = false;
                download-dir = "/home/${config.services.transmission.user}/Downloads/.torrent";
                blocklist-enabled = true;
                blocklist-url = "https://github.com/Naunter/BT_BlockLists/raw/master/bt_blocklists.gz";
            };
        };
    };

    i18n.inputMethod = {
        enabled = "fcitx5";
        fcitx5.addons = with pkgs; [
            fcitx5-anthy
            fcitx5-gtk
            fcitx5-nord
            libsForQt5.fcitx5-qt
        ];
        fcitx5.waylandFrontend = true;
    };

    # Some programs need SUID wrappers, can be configured further or are
    # started in user sessions.
    # programs.mtr.enable = true;
    # programs.gnupg.agent = {
    #   enable = true;
    #   enableSSHSupport = true;
    # };

    services.openssh = {
        enable = true;
        ports = [ 6942 ];
    };

    environment.pathsToLink = [ "/share/fcitx5" ];

    systemd.services = {
        keyd = {
            description = "key remapping daemon";
            enable = true;
            serviceConfig = {
                Type = "simple";
                ExecStart = "${pkgs.keyd}/bin/keyd";
            };
            wantedBy = [ "sysinit.target" ];
            requires = [ "local-fs.target" ];
            after = [ "local-fs.target" ];
        };
        transmission.wantedBy = lib.mkForce [];
    };

    system.stateVersion = "24.05";
}
