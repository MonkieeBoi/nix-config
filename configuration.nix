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
            "nowatchdog"
        ];
        loader = {
            efi.canTouchEfiVariables = true;
            systemd-boot.enable = true;
            timeout = 1;
        };
        extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
        extraModprobeConfig = ''
            options v4l2loopback devices=1 video_nr=1 card_label="OBS Cam" exclusive_caps=1
        '';
    };

    networking.hostName = "nixbtw";
    # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

    # Enable networking
    networking.networkmanager.enable = true;
    networking.networkmanager.insertNameservers = [ "1.1.1.1" "8.8.8.8" ];
    networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];

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
        extraGroups = [ "adbusers" "networkmanager" "wheel" "input" "storage" "video" "optical" "keyd" "docker" ];
        packages = with pkgs; [];
    };

    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;

    # List packages installed in system profile
    environment.systemPackages = with pkgs; [
        # --------- My Packages ---------
        (callPackage ./pkgs/ninb.nix {})
        (callPackage ./pkgs/wordle-helper.nix {})
        # -------------------------------
        (lib.hiPrio clang-tools)
        (mpv.override {scripts = [mpvScripts.mpris];})
        (pass.withExtensions (exts: [exts.pass-otp]))
        (wrapOBS { plugins = with obs-studio-plugins; [ obs-pipewire-audio-capture ]; })
        (qutebrowser.override { enableWideVine = true; })
        (python3.withPackages(ps: with ps; [ python-lsp-server ] ++ python-lsp-server.optional-dependencies.all ))
        alsa-utils
        anki
        anyrun
        auto-cpufreq
        blobdrop
        brightnessctl
        cava
        chafa
        chatterino2
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
        gdb
        git
        gnumake
        gnupg
        gopls
        grim
        hyprlock
        hyprpicker
        imagemagick
        imv
        java-language-server
        jdk
        jq
        kdePackages.qt6ct
        keyd
        killall
        lazydocker
        lazygit
        libclang
        libnotify
        libsForQt5.qt5ct
        lua-language-server
        lxqt.lxqt-policykit
        man-pages
        man-pages-posix
        mmv-go
        mongodb-compass
        networkmanagerapplet
        ngrok
        nixd
        nixfmt-rfc-style
        nnn
        nodejs_22
        nordic
        nordzy-cursor-theme
        onlyoffice-desktopeditors
        # orca-slicer
        osu-lazer-bin
        papirus-nord
        pinentry-curses
        pinta
        playerctl
        prismlauncher
        ps_mem
        pulsemixer
        qmk
        qpwgraph
        qrcp
        quickshell
        ripgrep
        satty
        simple-mtpfs
        slurp
        sqls
        sshfs
        swaybg
        techmino
        thermald
        tldr
        tmux
        tofi
        tor-browser
        transmission_4
        trash-cli
        tray-tui
        tty-clock
        typst
        udisks
        unzip
        upower
        vesktop
        vim
        waybar
        (waywall.overrideAttrs (old: {
            src = old.src.override {
                rev = "ad569de1ddae6b034c7095795a42f044746a55a7";
                hash = "sha256-CzP6PFYC6yVxUAxkJ4Zhm4Zf4Qt8u4WjXUYfkgc6nyU=";
            };
          })
        )
        wget
        wl-clipboard
        wl-screenrec
        xdg-desktop-portal-hyprland
        xdg-user-dirs
        xdg-utils
        yambar
        yt-dlp
        zathura
        zip
        zoxide
        # TMP JUST FOR SCHOOL
        # zoom-us
        # drawio
    ];

    fonts.packages = with pkgs; [
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-color-emoji
        nerd-fonts.jetbrains-mono
        carlito
    ];

    documentation.dev.enable = true;

    programs = {
        hyprland.enable = true;
        dconf.enable = true;
        direnv.enable = true;
        gamemode.enable = true;
        adb.enable = true;
        neovim = {
            enable = true;
            defaultEditor = true;
        };
        appimage = {
            enable = true;
            binfmt = true;
        };
        steam = {
            enable = true;
            remotePlay.openFirewall = true;
            dedicatedServer.openFirewall = true;
            localNetworkGameTransfers.openFirewall = true;
        };
    };

    boot.loader.systemd-boot.configurationLimit = 5;
    nix.gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
    };
    nix.settings.auto-optimise-store = true;

    programs.nix-ld = {
        enable = true;
        # libraries = pkgs.steam-run.fhsenv.args.multiPkgs pkgs;
        libraries = with pkgs; [
            # glfw3-minecraft
            (glfw3.overrideAttrs (old: {
                patches = [
                    (fetchpatch2 {
                      url = "https://raw.githubusercontent.com/tesselslate/waywall/be3e018bb5f7c25610da73cc320233a26dfce948/contrib/glfw.patch";
                      hash = "sha256-2PYmEUJVO9WrTbvnZp+RgJ9tTIqB9q4QVeABplH0tQY=";
                    })
                ];
            }))
        ];
    };

    environment.etc."keyd/keyd.conf".text = builtins.readFile ./keyd.conf;

    hardware.graphics = {
        enable = true;
        extraPackages = with pkgs; [
            intel-media-driver # LIBVA_DRIVER_NAME=iHD
            intel-vaapi-driver # LIBVA_DRIVER_NAME=i965
            libvdpau-va-gl
            vpl-gpu-rt
        ];
    };

    # Environment variables
    environment = {
        wordlist.enable = true;
        sessionVariables = {
            LIBVA_DRIVER_NAME = "iHD";
            NIX_SHELL_PRESERVE_PROMPT = 1;
        };
    };

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
        # printing = {
        #     enable = true;
        #     drivers = with pkgs; [ gutenprint brlaser ];
        # };
        # avahi = {
        #   enable = true;
        #   nssmdns4 = true;
        #   openFirewall = true;
        # };
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
            wireplumber = {
                enable = true;
                extraConfig = {
                    "10-disable-camera" = {
                        "wireplumber.profiles" = {
                            main."monitor.libcamera" = "disabled";
                        };
                    };
                };
            };
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
        flatpak.enable = true;
    };

    i18n.inputMethod = {
        enable = true;
        type = "fcitx5";
        fcitx5.addons = with pkgs; [
            fcitx5-anthy
            fcitx5-gtk
            fcitx5-nord
            libsForQt5.fcitx5-qt
            kdePackages.fcitx5-unikey
        ];
        fcitx5.waylandFrontend = true;
    };

    virtualisation.docker = {
        enable = true;
        enableOnBoot = false;
    };

    # Some programs need SUID wrappers, can be configured further or are
    # started in user sessions.
    programs.mtr.enable = true;
    services.pcscd.enable = true;
    programs.gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
        pinentryPackage = pkgs.pinentry-curses;
    };

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

    services.systembus-notify.enable = true;
    systemd.user.services.fnotify = {
        script = ''
            ${pkgs.libnotify}/bin/notify-send "f"
            '';
        serviceConfig = {
            Type = "oneshot";
        };
    };
    systemd.user.timers.fnotify = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
            OnCalendar = "*-*-* 23:59:00";
            Unit = "fnotify.service";
            Persistent = true;
        };
    };

    system.stateVersion = "24.05";
}
