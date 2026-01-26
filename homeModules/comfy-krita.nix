{
  pkgs,
  lib,
  config,
  home,
  ...
}:

{
  options = {
    my-comfy-krita = with lib.types; {
      enable = lib.mkEnableOption "Comfy Krita setup";

      comfy-path = lib.mkOption {
        default = "${home.homeDirectory}/Apps/ComfyUI";
        type = uniq str;
        description = "Path to ComfyUI installation";
      };
    };
  };

  config = lib.mkIf config.my-comfy-krita.enable {

    home.packages = with pkgs; [
      krita
    ];
  };
}
