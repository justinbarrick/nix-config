{ config, pkgs, ... }:

with pkgs;
let
  hostname = "box";
  user = "justin";
  github = {
    user = "justinbarrick";
    email = "justin.m.barrick@gmail.com";
  };
  layout = "dvorak";
  timezone = "America/Los_Angeles";
  packages = with pkgs; [ firefox kubernetes-helm kubectl qrencode zbar gnupg jq tcpdump openssl tree ];
  my-python-packages = python-packages: with python-packages; [
    setuptools
    virtualenvwrapper
  ]; 
  python-with-my-packages = python3.withPackages my-python-packages;
in {
  imports = [
    ./hardware-configuration.nix
    "${builtins.fetchTarball https://github.com/rycee/home-manager/archive/master.tar.gz}/nixos"
  ];

  networking = {
    hostName = hostname;
    wireless = {
      enable = true;
      networks = (import ./networks.nix);
    };
    extraHosts = ''
      192.168.1.240 unifi.home
      192.168.1.242 httpbin.home ca.home
    '';
  };

  environment = {
    systemPackages = with pkgs; [
      (pass.withExtensions (exts: [ exts.pass-otp ]))
      curl vim git dmenu i3lock xdotool (rofi-pass.overrideAttrs (attrs: {
        fixupPhase = "";
      })) python-with-my-packages
    ] ++ packages;
  };

  fonts.fonts = with pkgs; [
    terminus_font unifont font-awesome_4 material-design-icons dejavu_fonts noto-fonts
  ];
 
  users.users."${user}" = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "docker" ];
  };

  home-manager.users.${user} = {
    home.sessionVariables = {
      EDITOR = "vim";
      PATH = "/home/${user}/.krew/bin:$PATH";
    };

    home.keyboard.layout = "${layout}";
    home.file.".backgrounds/net.jpg".source = ./net.jpg;

    programs.firefox = {
      enable = true;
      profiles."default" = {
        isDefault = true;
        userChrome = builtins.readFile ./userChrome.css;
      };
    };

    programs.rofi = {
      enable = true;
      location = "top";
      theme = "Paper";
      borderWidth = 0;
      font = "DejaVu Sans Mono 8";
    };

    programs.git = {
      enable = true;
      userName = github.user;
      userEmail = github.email;
    };

    programs.vim = {
      enable = true;
      plugins = [ "vim-nix" ];

      settings = {
        background = "dark";
        expandtab = true;
        shiftwidth = 4;
        tabstop = 4;
        number = true;
      };

      extraConfig = ''
        colorscheme elflord
        syntax on

        set list
        set pastetoggle=<F10>
        set smartindent

        inoremap {       {}<Left>
        inoremap {<CR>   {<CR>}<Esc>O
        inoremap {<Left> {
        inoremap {}      {}
        inoremap (       ()<Left>
        inoremap (<Left> (
        inoremap ()      ()
        inoremap [       []<Left>
        inoremap [<Left> [
        inoremap []      []
        inoremap '       \'\'<Left>
        inoremap '<Left> '
        inoremap \'\'      \'\'
        inoremap "       ""<Left>
        inoremap "<Left> "
        inoremap ""      ""
      '';
    };

    programs.zsh = {
      enable = true;

      oh-my-zsh = {
        enable = true;
        plugins = [ "git" "python" "man" ];
        theme = "robbyrussell";
      };
    };

    programs.urxvt = {
      enable = true;

      fonts = [ "xft:DejaVu Sans Mono:pixelsize=10" ];
      extraConfig = {
        loginShell = true;
        depth = 32;
        termName = "xterm-256color";
        metaSendsEscape = true;
        saveLines = 4096;
        scrollBar = false;
        internalBorder = 15;
        transparent = true;
        shading = 30;
        blurRadius = 10;
        perl-ext-common = "default,matcher,osc-xterm-clipboard";
        url-launcher = "/usr/bin/firefox";
        "matcher.button" = 1;
        background = "#1D1F28";
        foreground = "#FDFDFD";
        cursorColor = "#C574DD";
        color0 = "#282A36";
        color1 = "#F37F97";
        color2 = "#5ADECD";
        color3 = "#F2A272";
        color4 = "#8897F4";
        color5 = "#C574DD";
        color6 = "#79E6F3";
        color7 = "#FDFDFD";
        color8 = "#414458";
        color9 = "#FF4971";
        color10 = "#18E3C8";
        color11 = "#FF8037";
        color12 = "#556FFF";
        color13 = "#B043D1";
        color14 = "#3FDCEE";
        color15 = "#BEBEC1";
      };

    };

    services.compton = {
      enable = true;
      menuOpacity = "0.8";
    };

    services.random-background = {
      enable = true;
      imageDirectory = "%h/.backgrounds";
    };

    services.polybar = {
      enable = true;

      package = pkgs.polybar.override {
        i3GapsSupport = true;
      };

      script = "PATH=$PATH:${pkgs.i3-gaps}/bin polybar -r top &";

      config = {
        "bar/top" = {
          "monitor" = "LVDS-1";
          "width" = "100%";
          "height" = 34;

          "background" = "#88000000";
          "foreground" = "#ccffffff";

          "line-color" = "\${bar/top.background}";
          "line-size" = "2";

          "spacing" = "2";
          "padding-right" = "5";
          "module-margin" = "4";

          "font-0" = "Noto Sans:size=8;-1";
          "font-1" = "Material Icons:size=10;0";
          "font-2" = "Misc Termsynu:size=8:antialias=false;-2";
          "font-3" = "FontAwesome:size=10;0";

          "modules-left" = "i3 cpu memory";
          "modules-right" = "alsa wireless-network battery date";
        };

        "module/battery" = {
          "type" = "internal/battery";
          "full-at" = 98;

          "format-charging" = "<animation-charging> <label-charging>";
          "format-discharging" = "<ramp-capacity> <label-discharging>";
          "format-full" = "<ramp-capacity> <label-full>";

          "ramp-capacity-0" = "";
          "ramp-capacity-0-foreground" = "#f53c3c";
          "ramp-capacity-1" = "";
          "ramp-capacity-1-foreground" = "#ffa900";
          "ramp-capacity-2" = "";
          "ramp-capacity-3" = "";
          "ramp-capacity-4" = "";

          "bar-capacity-width" = 10;
          "bar-capacity-format" = "%{+u}%{+o}%fill%%empty%%{-u}%{-o}";
          "bar-capacity-fill" = "█";
          "bar-capacity-fill-foreground" = "#ddffffff";
          "bar-capacity-fill-font" = 3;
          "bar-capacity-empty" = "█";
          "bar-capacity-empty-font" = 3;
          "bar-capacity-empty-foreground" = "#44ffffff";

          "animation-charging-0" = "";
          "animation-charging-1" = "";
          "animation-charging-2" = "";
          "animation-charging-3" = "";
          "animation-charging-4" = "";
          "animation-charging-framerate" = 750;
        };

        "module/i3" = {
          "type" = "internal/i3";

          "ws-icon-0" = "1;";
          "ws-icon-1" = "2;";
          "ws-icon-2" = "10;";
          "ws-icon-default" = "";

          "format" = "<label-state> <label-mode>";

          "label-dimmed-underline" = "\${BAR.background}";

          "label-focused" = "%icon%";
          "label-focused-foreground" = "#fff";
          "label-focused-underline" = "#c9665e";
          "label-focused-font" = 4;
          "label-focused-padding" = 4;

          "label-unfocused" = "%icon%";
          "label-unfocused-foreground" = "#dd";
          "label-unfocused-underline" = "#666";
          "label-unfocused-font" = 4;
          "label-unfocused-padding" = 4;

          "label-urgent" = "%icon%";
          "label-urgent-foreground" = "#000000";
          "label-urgent-underline" = "#9b0a20";
          "label-urgent-font" = 4;
          "label-urgent-padding" = 4;

          "label-empty" = "%icon%";
          "label-empty-foreground" = "#55";
          "label-empty-font" = 4;
          "label-empty-padding" = 4;

          "label-monocle" = "";
          "label-monocle-underline" = "\${module/i3.label-active-underline}";
          "label-monocle-font" = 4;
          "label-monocle-padding" = 2;

          "label-locked" = "";
          "label-locked-foreground" = "#bd2c40";
          "label-locked-underline" = "\${module/i3.label-monocle-underline}";
          "label-locked-padding" = "\${module/i3.label-monocle-padding}";
          "label-locked-font" = 4;

          "label-sticky" = "";
          "label-sticky-foreground" = "#fba922";
          "label-sticky-underline" = "\${module/i3.label-monocle-underline}";
          "label-sticky-padding" = "\${module/i3.label-monocle-padding}";
          "label-sticky-font" = 4;

          "label-private" = "";
          "label-private-foreground" = "#bd2c40";
          "label-private-underline" = "\${module/i3.label-monocle-underline}";
          "label-private-padding" = "\${module/i3.label-monocle-padding}";
          "label-private-font" = 4;
        };

        "module/cpu" = {
          "type" = "internal/cpu";
          "interval" = "0.5";
          "format" = "<label> <ramp-coreload>";
          "label" = "CPU";

          "ramp-coreload-0" = "▁";
          "ramp-coreload-0-font" = 2;
          "ramp-coreload-0-foreground" = "#aaff77";
          "ramp-coreload-1" = "▂";
          "ramp-coreload-1-font" = 2;
          "ramp-coreload-1-foreground" = "#aaff77";
          "ramp-coreload-2" = "▃";
          "ramp-coreload-2-font" = 2;
          "ramp-coreload-2-foreground" = "#aaff77";
          "ramp-coreload-3" = "▄";
          "ramp-coreload-3-font" = 2;
          "ramp-coreload-3-foreground" = "#aaff77";
          "ramp-coreload-4" = "▅";
          "ramp-coreload-4-font" = 2;
          "ramp-coreload-4-foreground" = "#fba922";
          "ramp-coreload-5" = "▆";
          "ramp-coreload-5-font" = 2;
          "ramp-coreload-5-foreground" = "#fba922";
          "ramp-coreload-6" = "▇";
          "ramp-coreload-6-font" = 2;
          "ramp-coreload-6-foreground" = "#ff5555";
          "ramp-coreload-7" = "█";
          "ramp-coreload-7-font" = 2;
          "ramp-coreload-7-foreground" = "#ff5555";
        };

        "module/date" = {
          "type" = "internal/date";
          "date" = "   %%{F#99}%Y-%m-%d%%{F-}  %%{F#fff}%H:%M%%{F-}";
          "date-alt" = "%%{F#fff}%A, %d %B %Y  %%{F#fff}%H:%M%%{F#666}:%%{F#fba922}%S%%{F-}";
        };

        "module/memory" = {
          "type" = "internal/memory";
          "format" = "<label> <bar-used>";
          "label" = "RAM";

          "bar-used-width" = 30;
          "bar-used-foreground-0" = "#aaff77";
          "bar-used-foreground-1" = "#aaff77";
          "bar-used-foreground-2" = "#fba922";
          "bar-used-foreground-3" = "#ff5555";
          "bar-used-indicator" = "|";
          "bar-used-indicator-font" = 6;
          "bar-used-indicator-foreground" = "#ff";
          "bar-used-fill" = "─";
          "bar-used-fill-font" = 6;
          "bar-used-empty" = "─";
          "bar-used-empty-font" = 6;
          "bar-used-empty-foreground" = "#444444";
        };

        "module/wireless-network" = {
          "type" = "internal/network";
          "interface" = "wlp3s0";
          "interval" = 3;
          "ping-interval" = 10;

          "format-connected" = "<ramp-signal> <label-connected>";
          "label-connected" = "%essid%";
          "label-disconnected" = "   not connected";
          "label-disconnected-foreground" = "#66";

          "ramp-signal-0" = "";
          "ramp-signal-1" = "";
          "ramp-signal-2" = "";
          "ramp-signal-3" = "";
          "ramp-signal-4" = "";

          "animation-packetloss-0" = "";
          "animation-packetloss-0-foreground" = "#ffa64c";
          "animation-packetloss-1" = "";
          "animation-packetloss-1-foreground" = "\${bar/top.foreground}";
          "animation-packetloss-framerate" = 500;
        };

        "module/clock" = {
          "type" = "internal/date";
          "interval" = 2;
          "date" = "%{F#999}%Y-%m-%d%{F-}  %{F#999}%H:%M%{F-}";
        };
      };
    };

    xsession.enable = true;

    xsession.windowManager.i3 = {
      enable = true;
      package = pkgs.i3-gaps;

      extraConfig = ''
        set $mod Mod4
        exec firefox
        exec --no-startup-id i3-msg workspace 1
      '';

      config = {
        assigns."1" = [{ class = "^Firefox$"; }];

        bars = [];

        gaps.inner = 9;
        gaps.outer = 5;

        fonts = [ "pango:monospace 8" ];

        window.commands = [
          {
            command = "border none";
            criteria = { class = "^.*$"; };
          }
        ];

        startup = [
          { command = "systemctl --user restart polybar"; always = true; notification = false; }
        ];

        keybindings = let
          modifier = "$mod";
        in {
          "${modifier}+Return" = "exec urxvt";
          "${modifier}+x" = "kill";

          "${modifier}+Left" = "focus left";
          "${modifier}+Down" = "focus down";
          "${modifier}+Up" = "focus up";
          "${modifier}+Right" = "focus right";

          "${modifier}+Shift+Left" = "move left";
          "${modifier}+Shift+Down" = "move down";
          "${modifier}+Shift+Up" = "move up";
          "${modifier}+Shift+Right" = "move right";

          "${modifier}+d" = "split h";
          "${modifier}+k" = "split v";

          "${modifier}+u" = "fullscreen toggle";

          "${modifier}+space" = "exec dmenu_run";

          "${modifier}+1" = "workspace 1";
          "${modifier}+2" = "workspace 2";
          "${modifier}+3" = "workspace 3";
          "${modifier}+4" = "workspace 4";
          "${modifier}+5" = "workspace 5";
          "${modifier}+6" = "workspace 6";
          "${modifier}+7" = "workspace 7";
          "${modifier}+8" = "workspace 8";
          "${modifier}+9" = "workspace 9";
          "${modifier}+0" = "workspace 10";

          "${modifier}+Shift+1" = "move container to workspace 1";
          "${modifier}+Shift+2" = "move container to workspace 2";
          "${modifier}+Shift+3" = "move container to workspace 3";
          "${modifier}+Shift+4" = "move container to workspace 4";
          "${modifier}+Shift+5" = "move container to workspace 5";
          "${modifier}+Shift+6" = "move container to workspace 6";
          "${modifier}+Shift+7" = "move container to workspace 7";
          "${modifier}+Shift+8" = "move container to workspace 8";
          "${modifier}+Shift+9" = "move container to workspace 9";
          "${modifier}+Shift+10" = "move container to workspace 10";

          "${modifier}+Shift+j" = "reload";
          "${modifier}+Shift+p" = "restart";
          "${modifier}+Shift+period" = "exec \"i3-nagbar -t warning -m 'You pressed the exit shortcut. Do you really want to exit i3? This will end your X session.' -b 'Yes, exit i3' 'i3-msg exit'\"";

          "${modifier}+p" = "mode \"resize\"";

          "${modifier}+l" = "exec i3lock -c 000000 -f";
          "${modifier}+Shift+l" = "exec systemctl hibernate";

          "${modifier}+ctrl+space" = "exec rofi-pass";
        };
      };
    };
  };

  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
  };

  services.xserver = {
    enable = true;
    layout = "${layout}";
    libinput.enable = true;
    displayManager.auto = {
      enable = true;
      user = "justin";
    };
  };

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    initrd.luks.devices = [
      {
        name = "root";
        device = "/dev/sda2";
        preLVM = true;
        allowDiscards = true;
      }
    ];
  };

  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "${layout}";
    defaultLocale = "en_US.UTF-8";
  };

  time.timeZone = timezone;

  hardware.pulseaudio.enable = true;
  sound.enable = true;
  system.stateVersion = "19.03";
}
