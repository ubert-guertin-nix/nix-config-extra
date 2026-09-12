{ pkgs
, lib
, username
, gitName
, gitEmail
, config
, ...
}:
{

  imports = [ ./lazyvim.nix ];

  stylix.targets = {
    kitty.enable = true;
    hyprlock.enable = true;
    gtk.enable = true;
    firefox.enable = true;
  };

  programs.chromium = {
    enable = true;
    package = pkgs.chromium.override { enableWideVine = true; };
  };

  home = {
    username = username;
    homeDirectory = "/home/${username}";
    stateVersion = "26.05";

    pointerCursor = {
      gtk.enable = true;
      x11.enable = true;
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 24;
    };

    sessionPath = [
      "$HOME/.local/bin"
    ];

    packages = with pkgs; [
      # Icons + Fonts
      font-awesome
      papirus-icon-theme
      adwaita-icon-theme

      # TUI
      gh-dash
      lazygit
      kiro-cli

      # GUI
      libnotify
      spotify
      swaybg
      shotcut

      # Audio, brightness
      wl-clipboard
      brightnessctl
      wireplumber

      # Utils
      gh
      zip
      eza
      acpi

      # Screenshot
      grim
      slurp
    ];

    activation.reloadServices = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      ${pkgs.hyprland}/bin/hyprctl reload 2>/dev/null || true
    '';

    activation.fixNvimPermissions = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p $HOME/.cache/nvim $HOME/.local/share/nvim $HOME/.local/state/nvim
      chmod -R u+rwX $HOME/.cache/nvim $HOME/.local/share/nvim $HOME/.local/state/nvim 2>/dev/null || true
      rm -rf $HOME/.cache/nvim/luac 2>/dev/null || true
    '';
  };

  programs = {
    fuzzel = {
      enable = true;

      settings = {
        main = {
          terminal = "${pkgs.kitty}/bin/kitty";
          prompt = "': '";
          layer = "overlay";
          dpi-aware = "no";
          width = 35;
          lines = 8;
          horizontal-pad = 20;
          vertical-pad = 16;
          inner-pad = 8;
          image-size-ratio = 0.2;
        };

        border = {
          width = 2;
          radius = 12;
        };
      };
    };

    fish = {
      enable = true;

      interactiveShellInit = ''
        set -g fish_greeting

        function fish_prompt
          set_color normal
          echo -n (prompt_pwd)
          set_color brred
          echo -n ' ▸ '
          set_color normal
        end
      '';

      shellInit = ''
        set -gx EDITOR nvim
        set -gx VISUAL nvim
        set -gx NNN_OPTS e
      '';

      shellAbbrs = {
        cd = "z";
        ls = "eza --group-directories-first";
        l = "eza -lh --git --group-directories-first";
        la = "eza -lah --git";
        lg = "lazygit";
        c = "clear";
        rebuild = "sudo nixos-rebuild switch --flake /etc/nixos#${username}";
        off = "shutdown now";
        svim = "sudo -E nvim";
        vim = "nvim";
      };
    };

    hyprlock = {
      enable = true;
      settings = {
        general = {
          disable_loading_bar = true;
          grace = 0;
          hide_cursor = true;
        };

        input-field = {
          size = "260, 50";
          outline_thickness = 2;
          dots_size = 0.2;
          dots_spacing = 0.2;
          dots_center = true;
          fade_on_empty = false;
          rounding = 0;
          placeholder_text = "<i>Password...</i>";
          position = "0, -50";
          halign = "center";
          valign = "center";
        };

        label = [
          {
            text = "$TIME";
            font_size = 64;
            position = "0, 80";
            halign = "center";
            valign = "center";
          }
        ];
      };
    };

    git = {
      enable = true;

      settings = {
        user = {
          name = gitName;
          email = gitEmail;
        };

        core = {
          autocrlf = false;
          editor = "nvim";
          fsync = "none";
        };

        push.autoSetupRemote = true;
        pull.rebase = true;
        rebase.autoStash = true;
        fetch.prune = true;
        diff.algorithm = "histogram";
        merge.conflictstyle = "zdiff3";
      };
    };

    kitty = {
      enable = true;

      shellIntegration.mode = "no-rc";

      settings = {
        confirm_os_window_close = "0";
        shell = "${pkgs.fish}/bin/fish";
        window_padding_width = 0;
        cursor_shape = "underline";
        enable_audio_bell = false;
      };
    };
  };

  services.wayle = {
    enable = true;
    settings = {
      styling = {
        palette = {
          bg = "#${config.lib.stylix.colors.base00}";
          surface = "#${config.lib.stylix.colors.base01}";
          elevated = "#${config.lib.stylix.colors.base02}";
          fg = "#${config.lib.stylix.colors.base05}";
          fg-muted = "#${config.lib.stylix.colors.base04}";
          primary = "#${config.lib.stylix.colors.base0D}";
          red = "#${config.lib.stylix.colors.base08}";
          yellow = "#${config.lib.stylix.colors.base0A}";
          green = "#${config.lib.stylix.colors.base0B}";
          blue = "#${config.lib.stylix.colors.base0C}";
        };
      };

      bar = {
        scale = 0.800000011920929;
        layer = "bottom";
        button-label-size = 1.2000000476837158;
        button-label-weight = "bold";
        dropdown-shadow = false;

        layout = [
          {
            monitor = "*";
            show = true;
            left = [ "dashboard" ];
            center = [ "clock" ];
            right = [
              "keyboard-input"
              "separator"
              "battery"
              "bluetooth"
              "network"
              "volume"
              "brightness"
            ];
          }
        ];
      };

      modules = {
        battery.label-show = false;
        bluetooth.label-show = false;
        brightness.label-show = false;

        clock = {
          icon-show = false;
          label-color = "fg-default";
          button-bg-color = "transparent";
          dropdown-show-seconds = true;
        };

        hyprland-workspaces.app-icons-show = true;

        keyboard-input = {
          icon-show = false;
          label-color = "bg-active";
          button-bg-color = "transparent";
        };

        network.label-show = false;
        volume.label-show = false;
      };

      wallpaper = {
        engine-enabled = false;
        transition-type = "none";
      };
    };
  };

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || ${pkgs.hyprlock}/bin/hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };

      listener = [
        {
          timeout = 300;
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 330;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
      ];
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    configType = "hyprlang";

    settings = {
      dwindle = {
        force_split = 2;
        preserve_split = true;
      };

      env = [
        "ADW_DISABLE_PORTAL,1"
      ];

      monitor = [
        ", preferred, auto, 1"
      ];

      animations = {
        enabled = true;

        bezier = [
          "snappy, 0.2, 1, 0.2, 1"
        ];

        animation = [
          "windows, 1, 1.5, snappy, popin 90%"
          "windowsOut, 1, 1.5, snappy, popin 90%"
          "windowsMove, 1, 1.5, snappy"
          "fade, 1, 1.5, snappy"
          "workspaces, 1, 2, snappy, slidefade 20%"
        ];
      };

      "$mod" = "SUPER";

      exec-once = [
        "${pkgs.hypridle}/bin/hypridle"
        "hyprlock"
      ];

      input = {
        kb_layout = "us,ca";
        kb_options = "grp:alt_shift_toggle";
        follow_mouse = 1;
      };

      general = {
        gaps_in = 0;
        gaps_out = 0;
        border_size = 0;
      };

      decoration = {
        rounding = 0;

        blur = {
          enabled = false;
        };

        dim_inactive = true;
        dim_strength = 0.10;
      };

      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
      };

      cursor = {
        hide_on_key_press = false;
      };

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      bind = [
        ", XF86AudioRaiseVolume, exec, ${pkgs.wireplumber}/bin/wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86AudioMute, exec, ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioMicMute, exec, ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ", XF86MonBrightnessUp, exec, ${pkgs.brightnessctl}/bin/brightnessctl set +5%"
        ", XF86MonBrightnessDown, exec, ${pkgs.brightnessctl}/bin/brightnessctl set 5%-"

        "$mod, A, exec, fuzzel"
        "$mod, Return, exec, kitty"
        "$mod, Q, killactive"
        "$mod, W, exec, chromium"
        "$mod, S, exec, grim -g \"$(slurp)\" - | wl-copy"
        "$mod, Escape, exec, loginctl lock-session"

        "$mod, F, fullscreen, 0"
        "$mod, M, fullscreen, 1"

        "$mod, H, movefocus, l"
        "$mod, J, movefocus, d"
        "$mod, K, movefocus, u"
        "$mod, L, movefocus, r"

        "$mod SHIFT, H, movewindow, l"
        "$mod SHIFT, J, movewindow, d"
        "$mod SHIFT, K, movewindow, u"
        "$mod SHIFT, L, movewindow, r"

        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"

        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
      ];
    };
  };
}
