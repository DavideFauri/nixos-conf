{config, lib, pkgs, ...}:
{
  programs.starship = {
    settings = {
      # Allow for more time when executing commands, particularly on first console boot
      command_timeout = 1000;

      # Print a new line at the start of the prompt
      add_newline = true;

      # Change formatting because I want the chevrons to display after the symbol
      format = lib.concatStrings [
        "$username$hostname$shlvl"
        "$kubernetes"
        "$directory"
        "$git_branch$git_commit$git_state$git_status"
        "docker_context"
        "$package"
        "$cmake"
        "$dart$dotnet$elixir$elm$erlang$golang$helm$java$julia$kotlin$lua$nimnodejs$ocaml$perl$php$purescript$ruby$rust$swift$terraform$zig"
        "$python$conda"
        "$nix_shell"
        "$memory_usage"
        "$aws$gcloud$openstack"
        "$env_var"
        "$crystal"
        "$cmd_duration"
        "$line_break"
        "$jobs"
        "$battery"
        "$time"
        "$status"
        "$character"
        "$custom "
      ];

      # Don't split into two lines
      # line_break.disabled = true;

      # Disable number of jobs running (interferes with autojump)
      # jobs.disabled = true;

      # Remove space after character
      character = {
        success_symbol = "[❯](fg:green bg:black)"; # #❯
        error_symbol = "[❯](fg:red bg:black)"; # #❯
        format = "$symbol";
      };

      # Chevron that lists the number of clutter in download folder # #❯
      custom.countdownloads = {
        when = true;
        shell = "bash";
        format = "[$output](3)";
        command = ''
          COUNT_DOWNLOADS=$(ls $HOME/Downloads | wc -l | tr -d ' ')
          if [ $COUNT_DOWNLOADS -ge 10 ]; then
            TEXT_C_DOWN=''${COUNT_DOWNLOADS}❯
          fi
          echo ''${TEXT_C_DOWN}
        ''; 
      };

      # Chevron that lists the number of clutter on desktop # #❯
      custom.countdesktop = {
        when = false;
        shell = "bash";
        format = "[$output](3)";
        command = ''
          COUNT_DESKTOP=$(ls $HOME/Desktop | grep -v -E '\\.(lnk|ini|bat)$' | wc -l | tr -d ' ')
          if [ $COUNT_DESKTOP -ge 10 ]; then
            TEXT_C_DESK=''${COUNT_DESKTOP}❯
          fi
          echo ''${TEXT_C_DESK}
        ''; 
      };

      # Chevron that lists the number of todo items on smos # #❯
      custom.todoitems = {
        when = true;
        shell = "bash";
        format = "[$output](3)";
        command = ''
          NEXT_ITEMS=$(smos-query next | wc -l | tr -d ' ')
          if [ $NEXT_ITEMS -ge 0 ]; then
            TEXT_TODO=''${NEXT_ITEMS}❯
          fi
          echo ''${TEXT_TODO}
        ''; 
      };

      # Chevron that lists the number of unreviewed intray items # #❯
      custom.intrayitems = {
        when = true;
        shell = "bash";
        format = "[$output](red)";
        command = ''
          INTRAY_SIZE=$(intray size)
          if [ $INTRAY_SIZE -ge 0 ]; then
            TEXT_INTRAY=''${INTRAY_SIZE}❯
          fi
          echo ''${TEXT_INTRAY}
        ''; 
      };
    };
  };
}
