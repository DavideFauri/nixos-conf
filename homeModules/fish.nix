{ ... }:

let
  username = builtins.getEnv "USER";
  homeDir = builtins.getEnv "HOME";
  nixosConfFolder = "${homeDir}/Documents/Git/Nixos-conf";
in
{
  programs.fish = {
    enable = true;

    interactiveShellInit = ''
      set fish_greeting # Disable greeting
      starship init fish | source
    '';

    loginShellInit = ''
      set fish_greeting # Disable greeting
      starship init fish | source
    '';

    # plugins = [
    #   { name = "done"; src = pkgs.fishPlugins.done.src; }
    # ];

    # shellInit = ''
    #   #set __done_notification_command '${pkgs.libnotify}/bin/notify-send Done! Check the terminal for output' #
    #   set -q GHCUP_INSTALL_BASE_PREFIX[1]; or set GHCUP_INSTALL_BASE_PREFIX $HOME; set -gx PATH $HOME/.cabal/bin $PATH $HOME/.ghcup/bin
    # '';

    shellAliases = {
      lt = "du -sh * | sort -h";
      #      kondo = "$EDITOR ${homeDir}/.config/home-manager/home.nix && home-manager switch --flake /etc/nixos --impure --show-trace";
      #warhol = "cd ${homeDir}/comfyUI; and env HSA_OVERRIDE_GFX_VERSION=11.0.0 nix shell ${comfyuiDir}#rocm.comfyui-with-extensions --command comfyui";
      #dali = "cd ${homeDir}/comfyUI; and nix run ${comfyuiDir}#rocm.krita-with-extensions";
      nolan = "RUSTICL_ENABLE=amdgpu DRI_PRIME=1 QT_QPA_PLATFORM=xcb davinci-resolve";
      # piano = "sudo nix flake update --flake $nixosConfFolder; and sudo nixos-rebuild switch --flake $nixosConfFolder/#(hostname) --impure ; and home-manager switch --flake $nixosConfFolder/#(whoami) --impure";
      #test = "sudo wg show-conf  | qrencode -t ansiutf8"
      #alert = "notify-send --urgency=low -i (if test $status -eq 0; echo terminal; else; echo error; end) (history | head -n1)"
    };

    # To see how to build functions, see:
    # https://github.com/nix-community/home-manager/blob/af2beae5f0fae0a4310cc0e6aef2572f56090353/modules/programs/fish.nix#L43
    functions = {
      piano = {
        description = "build NixOS and Home Manager, does not switch";
        body = ''
          sudo nixos-rebuild build --show-trace --impure --flake ${nixosConfFolder}/#(hostname)
          home-manager build --show-trace --impure --flake ${nixosConfFolder}/#(whoami)
        '';
      };

      forte = {
        description = "update flake and switch NixOS and Home Manager";
        body = ''
          sudo nix flake update --flake ${nixosConfFolder}
          sudo nixos-rebuild switch --impure --flake ${nixosConfFolder}/#(hostname)
          home-manager switch --impure --flake ${nixosConfFolder}/#(whoami)
        '';
      };

      stringsort = {
        description = "sort strings by length";
        body = ''
          strings $argv[1] | awk '{ print length(), $0 | "sort -n" }'
        '';
      };

      pandocx = {
        description = "convert markdown argument to docx";
        body = ''
          set newname (echo $argv[1] | sed 's/\.md$/\.docx/')
          pandoc --from=markdown --to=docx -o $newname $argv[1]
        '';
      };
    };

    # To see how to build completions, see:
    # general description: https://fishshell.com/docs/current/completions.html
    # accepted arguments: https://fishshell.com/docs/current/cmds/complete.html
    # nix code: https://github.com/nix-community/home-manager/blob/af2beae5f0fae0a4310cc0e6aef2572f56090353/modules/programs/fish.nix#L156
    completions = {
      my-pandocx = ''
        complete -c pandocx -d "Markdown file"-a "(ls *.md)"
      '';
    };
  };
}
