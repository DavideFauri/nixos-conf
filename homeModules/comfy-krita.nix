{ lib
, config
, comfyUi
, pkgs
, ...
}:
let
  homeDir = builtins.getEnv "HOME";
in
{
  options = {

    my-comfy = with lib.types; {
      enable = lib.mkEnableOption "Comfy UI setup";

      extensions = lib.mkEnableOption "Build ComfyUI extensions too";
      krita = lib.mkEnableOption "Install Krita integration";

      comfy-path = lib.mkOption {
        default = "${homeDir}/Apps/comfyUI";
        type = uniq str;
        description = "Path to ComfyUI installation";
      };
    };
  };

  config = lib.mkIf config.my-comfy.enable {

    home.file."${config.my-comfy.comfy-path}/extra_model_paths.yaml".text = ''
      comfyui:
           base_path: ${config.my-comfy.comfy-path}
           # You can use is_default to mark that these folders should be listed first, and used as the default dirs for eg downloads
           is_default: true
           checkpoints: models/checkpoints/
           clip: models/clip/
           clip_vision: models/clip_vision/
           configs: models/configs/
           controlnet: models/controlnet/
           diffusion_models: |
                        models/diffusion_models
                        models/unet
           embeddings: models/embeddings/
           loras: models/loras/
           upscale_models: models/upscale_models/
           vae: models/vae/
    '';

    home.packages =
      let
        comfyBase = if config.my-comfy.extensions then comfyUi.rocm-comfyui-with-extensions else comfyUi.rocm-comfyui;

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
            "--extra-model-paths-config"
            "${config.my-comfy.comfy-path}/extra_model_paths.yaml"
          ];
        };
      in
      [
        comfyWithArgs
      ]
      ++ (if config.my-comfy.krita then [ comfyUi.krita-with-extensions ] else [ ]);

  };
}
