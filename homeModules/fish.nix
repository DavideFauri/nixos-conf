{ ... }:

let
  username = builtins.getEnv "USER";
  homeDir = builtins.getEnv "HOME";
in
{
  programs.fish = {

    interactiveShellInit = ''
      set fish_greeting # Disable greeting
    '';

    # plugins = [
    #   { name = "done"; src = pkgs.fishPlugins.done.src; }
    # ];

    # shellInit = ''
    #   #set __done_notification_command '${pkgs.libnotify}/bin/notify-send Done! Check the terminal for output' #
    #   set -q GHCUP_INSTALL_BASE_PREFIX[1]; or set GHCUP_INSTALL_BASE_PREFIX $HOME; set -gx PATH $HOME/.cabal/bin $PATH $HOME/.ghcup/bin
    # '';

    shellAliases = {
      kondo = "$EDITOR ${homeDir}/.config/home-manager/home.nix && home-manager switch --flake /etc/nixos --impure --show-trace";
      #warhol = "cd ${homeDir}/comfyUI; and env HSA_OVERRIDE_GFX_VERSION=11.0.0 nix shell ${comfyuiDir}#rocm.comfyui-with-extensions --command comfyui";
      #dali = "cd ${homeDir}/comfyUI; and nix run ${comfyuiDir}#rocm.krita-with-extensions";
      nolan = "RUSTICL_ENABLE=amdgpu DRI_PRIME=1 QT_QPA_PLATFORM=xcb davinci-resolve";
      piano = "sudo nix flake update --flake .; and sudo nixos-rebuild switch --flake ./#(hostname) --impure ; and home-manager switch --flake ./#(whoami) --impure";
      #test = "sudo wg show-conf  | qrencode -t ansiutf8"
      #alert = "notify-send --urgency=low -i (if test $status -eq 0; echo terminal; else; echo error; end) (history | head -n1)"
    };
  };
}
