{
  lib,
  config,
  comfyUi,
  ...
}:
let
  homeDir = builtins.getEnv "HOME";
in
{
  options = {

    my-comfy = with lib.types; {
      enable = lib.mkEnableOption "Comfy UI setup";

      krita = lib.mkEnableOption "Krita setup";

      comfy-path = lib.mkOption {
        default = "${homeDir}/Apps/ComfyUI";
        type = uniq str;
        description = "Path to ComfyUI installation";
      };
    };
  };

  config = lib.mkIf config.my-comfy.enable {

    home.packages = [
      comfyUi.rocm-comfyui-with-extensions
    ]
    ++ (if config.my-comfy.krita then [ comfyUi.krita-with-extensions ] else [ ]);

    nixpkgs.overlays = [
      (final: _prev: {
        comfyui = _prev.comfy-ui.overrideAttrs (oldAttrs: {
          postinstall = (oldAttrs.postinstall or "") + ''
            wrapprogram $out/bin/comfyui --set HSA_OVERRIDE_GFX_VERSION 11.0.0"
          '';
        });
      })
    ];
  };
}
