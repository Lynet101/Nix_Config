# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      #./hardened.nix
    ];

   



  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.kernelPackages = pkgs.linuxPackages_zen;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;
  networking.firewall.enable = true;




virtualisation.docker.enable = true;
#virtualisation.docker.storageDriver = "btrfs";
users.extraGroups.docker.members = [ "slindau" ];


nixpkgs.config.packageOverrides = self : rec {
    blender = self.blender.override {
      cudaSupport = true;
    };
  };


# AMD settings
  boot.initrd.kernelModules = [ "amdgpu"];
  programs.corectrl.enable = true;
  services.auto-cpufreq.enable = true;
  services.qemuGuest.enable = true;
  services.asusd.enable = true;
  services.auto-cpufreq.settings =
    let
        MHz = x: x * 1000;
    in
      {
        battery = {
          governor = "ondemand";
          scaling_min_freq = (MHz 400);
          scaling_max_freq = (MHz 3300);
          turbo = "never";
        };
        charger = {
          # governor = "performance";
          governor = "ondemand";
          scaling_min_freq = (MHz 400);
          scaling_max_freq = (MHz 4600);
          turbo = "auto";
        };
      };
  services.thermald.enable = true;


# Set your time zone.
  time.timeZone = "Europe/Copenhagen";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "da_DK.UTF-8";
    LC_IDENTIFICATION = "da_DK.UTF-8";
    LC_MEASUREMENT = "da_DK.UTF-8";
    LC_MONETARY = "da_DK.UTF-8";
    LC_NAME = "da_DK.UTF-8";
    LC_NUMERIC = "da_DK.UTF-8";
    LC_PAPER = "da_DK.UTF-8";
    LC_TELEPHONE = "da_DK.UTF-8";
    LC_TIME = "da_DK.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.clamav.daemon.enable = true;
  services.clamav.updater.frequency = 15;
  services.clamav.updater.enable = true;

  services.tailscale.enable = true;
  networking.firewall.trustedInterfaces = ["tailscale0"];
  services.colord.enable = true;
  services.blueman.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.flatpak.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "dk";
    xkbVariant = "nodeadkeys";
    videoDrivers = [
 "nvidia"
];
  };

  # Configure console keymap
  console.keyMap = "dk-latin1";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  hardware.system76.power-daemon.enable = false;
  hardware.xone.enable = true;
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  hardware.nvidia.nvidiaPersistenced = false;
  hardware.nvidia.nvidiaSettings = true;
  hardware.nvidia.forceFullCompositionPipeline = false;
  hardware.nvidia.powerManagement.enable = false;
  hardware.nvidia.powerManagement.finegrained = false;
  hardware.nvidia.modesetting.enable = false;
  hardware.nvidia.prime.amdgpuBusId = "PCI:4:0:0";
  hardware.nvidia.prime.sync.enable = false;
  hardware.nvidia.prime.nvidiaBusId = "PCI:1:0:0";
  hardware.nvidia.prime.offload.enable = false;
  hardware.nvidia.prime.offload.enableOffloadCmd = false;
  security.rtkit.enable = true;
  security.doas.enable = true;
  security.sudo.enable = false;
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
  users.users.slindau = {
    isNormalUser = true;
    description = "Sebastian Lindau-Skands";
    extraGroups = [ "dialout" "networkmanager" "wheel" "vboxusers" "docker" ];
    packages = with pkgs; [
      firefox
      flatpak
      gnome.gnome-software
      #  thunderbird
    ];
  };

  virtualisation.virtualbox.host.enable = false;
  virtualisation.virtualbox.guest.x11 = false;
  virtualisation.virtualbox.guest.enable = false;
  users.extraGroups.vboxusers.members = [ "slindau" ];


  users.defaultUserShell = pkgs.fish;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    gnome.gnome-software
    git
    onlyoffice-bin
    flatpak
    gnome-extension-manager
    gnomeExtensions.blur-my-shell
    gnomeExtensions.just-perfection
    gnomeExtensions.quick-settings-tweaker
    gnomeExtensions.user-avatar-in-quick-settings
    gnomeExtensions.tophat
    gnomeExtensions.arcmenu
    gnomeExtensions.coverflow-alt-tab
    gnomeExtensions.dash-to-dock
    gnomeExtensions.dash2dock-lite
    gnomeExtensions.gesture-improvements
    gnomeExtensions.tailscale-status
    pfetch
    neofetch
    btop
    fish
    kitty
    guake
    geekbench
    amdvlk
    powerstat
    powertop
    doas
    neovim
    bumblebee
    kexec-tools
    blender
    tailscale
    steam-run
    geekbench_5    
    python311Packages.pip
    python311
    steam-run
    gnome.dconf-editor
    ldacbt
    virtualbox
    ryzenadj
    steamPackages.steam
    wine
    distrobox
    linuxKernel.packages.linux_6_1.xone
    nvtop
    obsidian
    cpupower-gui
    gnomeExtensions.dash-to-dock-animator
    jdk8
    tree
    dolphin-emu
    ntfs3g
    cups
    cups-pdf-to-pdf
    audacity
    docker
    usbutils
    kdiskmark
    nvidia-docker
    python311Packages.pytube
    clamav
    webcord
    auto-cpufreq
    corectrl
    thermald
    touchegg
    gnomeExtensions.x11-gestures
    asusctl
    linuxKernel.packages.linux_zen.xone
    vmtouch
    
  ];
  environment.gnome.excludePackages = [  pkgs.epiphany pkgs.gnome.geary];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
  programs.fish.enable = true;
  programs.xwayland.enable = false;

  nix.settings.allowed-users = ["root"];
}
