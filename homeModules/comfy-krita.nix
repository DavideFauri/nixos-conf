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
        default = "${homeDir}/Apps/comfyUI";
        type = uniq str;
        description = "Path to ComfyUI installation";
      };
    };
  };

  config = lib.mkIf config.my-comfy.enable {

    home.packages =
      let
        comfyBase = comfyUi.rocm-comfyui-with-extensions;
        comfyWrapped = comfyBase.overrideAttrs (
          _: oldAttrs: {
            postInstall =
              (oldAttrs.postInstall or "") + "wrapProgram $out/bin/comfyui --set HSA_OVERRIDE_GFX_VERSION 11.0.0";

          }
        );
        comfyWithArgs = comfyWrapped.override {
          commandLineArgs = [
            "--auto-launch"
            "--user-directory"
            "${config.my-comfy.comfy-path}"
          ];
        };
      in
      [
        comfyWithArgs
      ]
      ++ (if config.my-comfy.krita then [ comfyUi.krita-with-extensions ] else [ ]);

  };
}
