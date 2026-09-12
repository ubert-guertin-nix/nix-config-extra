{ pkgs
, username
, ...
}:
{
  imports = [ ./hardware-configuration.nix ];

  nixpkgs.config.allowUnfree = true;

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 3d";
    };
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_zen;
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 3;
        editor = false;
      };
      efi.canTouchEfiVariables = true;
      timeout = 0;
    };
  };

  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
    firewall.enable = true;
  };

  time.timeZone = "America/Toronto";

  stylix = {
    enable = true;
    autoEnable = false;

    polarity = "dark";

    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark.yaml";

    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font";
      };
      sansSerif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Sans";
      };
    };
  };

  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [
      "docker"
      "wheel"
      "video"
      "input"
    ];
    shell = pkgs.fish;
  };

  services.upower.enable = true;

  services.logind.settings.Login = {
    NAutoVTs = 0;
    ReserveVT = 0;
  };

  systemd.services."getty@tty2".enable = false;
  systemd.services."getty@tty3".enable = false;
  systemd.services."getty@tty4".enable = false;
  systemd.services."getty@tty5".enable = false;
  systemd.services."getty@tty6".enable = false;

  programs = {
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };

    fish.enable = true;
    dconf.enable = true;

    nix-ld = {
      enable = true;
      libraries = with pkgs; [
        stdenv.cc.cc
        zlib
        fuse3
        icu
        nss
        openssl
        expat
      ];
    };

    hyprland = {
      enable = true;
      xwayland.enable = true;
    };

    zoxide.enable = true;

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };

  virtualisation.docker.enable = true;

  environment.systemPackages = with pkgs; [
    python3
    mockoon
    file
    neovim
    unzip
    gnutar
    gzip
    git
    gnumake
    gcc
    cargo
    rustc
  ];

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd start-hyprland";
        user = "greeter";
      };
    };
  };

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  system.stateVersion = "26.05";

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
    ];
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-compute-runtime
      libva-vdpau-driver
      libvdpau-va-gl
    ];
  };

  services.tlp = {
    enable = true;
    settings = {
      START_CHARGE_THRESH_BAT0 = 20;
      STOP_CHARGE_THRESH_BAT0 = 80;

      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;

      PCIE_ASPM_ON_BAT = "powersupersave";
      USB_AUTOSUSPEND = 1;
      WIFI_PWR_ON_BAT = "on";
      RUNTIME_PM_ON_BAT = "auto";
    };
  };

  services.thermald.enable = true;
  services.fwupd.enable = true;
  services.hardware.bolt.enable = true;

  services.udev.extraRules = ''
    ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/scheduler}="none"
  '';
}
