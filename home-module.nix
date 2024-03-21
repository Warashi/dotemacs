packages: {
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) types;

  cfg = config.programs.emacs-twist;
in {
  options = {
    programs.emacs-twist.settings = {
      extraFeatures = lib.mkOption {
        type = types.listOf types.str;
        description = "List of options";
        default = [];
      };
    };
  };

  config = lib.mkIf cfg.enable {
    programs.emacs-twist = {
      emacsclient.enable = true;
      directory = ".local/share/emacs";
      earlyInitFile = ./early-init.el;
      createInitFile = true;
      config = packages.emacs-config.override {
        inherit (cfg.settings) extraFeatures;
        prependToInitFile = ''
          ;; -*- lexical-binding: t; no-byte-compile: t; -*-
          (setq use-package-ensure-function #'ignore)
        '';
      };
      serviceIntegration.enable = lib.mkDefault false;
      createManifestFile = true;
    };

    # Generate a desktop file for emacsclient
    services.emacs.client.enable = cfg.serviceIntegration.enable;
  };
}
