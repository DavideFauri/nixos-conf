{ pkgs
, intray
, smos
, ...
}:

# https://docs.smos.online/

let
  username = builtins.getEnv "USER";
  homeDir = builtins.getEnv "HOME";
  workflowDir = "${homeDir}/.smos";
in
{
  imports = [
    smos # see the main flake.nix for how I expose the package
  ];

  home.packages = [
    intray # see the main flake.nix for how I expose the package
    pkgs.tmux
  ];

  programs.smos = {
    enable = true;
    workflowDir = workflowDir;

    config = {
      workflow-dir = workflowDir;
      archive-dir = "${workflowDir}/archive";
      projects-dir = "${workflowDir}/projects";
      #goal = "TESTO DI PROVA - GOAL"; # for initialized projects

      explainer-mode = true; # can only open smos files

      waiting.threshold = "7d";
      stuck.threshold = "4w";

      #scheduler.weekly-review = {
      #  description = "Review settimanale per il capo";
      #  destination = "review-[ %F | friday ].smos";
      #  template = "templates/weekly-review.smos.template";
      #  schedule = "0 13 * * 5"; # At 13.00 on Friday
      #};

      # if notify = enable
      #notify = {
      #  database = "${workflowDir}/notify/notify.db";
      #  notify-send = "${pkgs.libnotify}/bin/notify";
      #};

      # if github = enable
      #github.oauth-token-file = "${workflowDir}/github/GITHUB_TOKEN";

    };

    #scheduler = {
    #  enable = true;
    #  OnCalendar = "hourly";
    #};

    #notify = {
    #  enable = true;
    #  OnCalendar = "minutely";
    #};

    #backup = {
    #  enable = true;
    #  OnCalendar = "daily";
    #  backupDir = "${homeDir}/Dropbox/Workflow";
    #};

    calendar.enable = false;
    github.enable = false;
    jobhunt.enable = false;
    sync.enable = false;

  };

  programs.fish.functions = {

    # ------- INTRAY -------
    "in" = {
      description = "add a new intray item or review the intray";
      body = ''
        if count $argv > /dev/null
          intray add $argv
        else
          intray review
        end
      '';
    };

    # ------- ADD PROJECTS -------
    sm = {
      description = "Add a smos project to the workflow folder";
      body = ''
        set PREV_FOLDER (pwd);
        and set SMOS_FOLDER ${workflowDir};
        and cd $SMOS_FOLDER;
        and smos $argv;
        and cd $PREV_FOLDER
      '';
    };

    sm1 = {
      description = "Quick add a single-task smos project";
      body = ''
        set PREV_FOLDER (pwd);
        and set SMOS_FOLDER ${workflowDir};
        and cd $SMOS_FOLDER;
        and smos-single $argv;
        and cd $PREV_FOLDER
      '';
    };

    # ------- QUERY PROJECTS -------
    smn = {
      description = "Query only the next action items";
      body = ''
        smos-query next $argv
      '';
    };

    smw = {
      description = "Query the overdue tasks";
      body = ''
        smos-query waiting $argv
      '';
    };

    smk = {
      description = "Query all the pending, overdue, and deadline tasks";
      body = ''
        smos-query work $argv
      '';
    };

    # ------- REVIEW PROJECTS -------
    smr = {
      description = "Review tasks done this week";
      body = ''
        smos-query log --this-week --day-block | grep -e "->  DONE\|Monday\|Tuesday\|Wednesday\|Thursday\|Friday" | sed -E 's|[0-9\-]{10} [0-9:]{8}.*->  DONE||'
      '';
    };

    smrr = {
      description = "Review tasks done last week";
      body = ''
        smos-query log --last-week --day-block | grep -e "->  DONE\|Monday\|Tuesday\|Wednesday\|Thursday\|Friday" | sed -E 's|[0-9\-]{10} [0-9:]{8}.*->  DONE||'
      '';
    };

    smrrr = {
      description = "Review tasks done last month";
      body = ''
        smos-query log --this-month --day-block | grep -e "-> DONE\|Monday\|Tuesday\|Wednesday\|Thursday\|Friday" | sed -E 's|[0-9\-]{10} [0-9:]{8}.*-> DONE||'
      '';
    };

    # ------- WORKBENCH ---
    # bash version
    smboard = {
      description = "With tmux, open a multi-pane workbench: intray, a shell, smos, and a self-updating list of pending tasks";
      body = ''
        tmux kill-server
        tmux new-session \; send-keys 'while true; do clear; smos-query work; sleep 15s; done' Enter \; split-window -v \; send-keys 'smos' Enter \; split-window -h \; send-keys 'while true; do intray review; clear; sleep 30; done' Enter \; split-window -v \; send-keys 'fish' Enter \;
      '';
    };
    # fish version
    # tmux new-session \; send-keys 'while true; clear; smos-query work; sleep 10s; end' C-m \; split-window -v \; send-keys 'smos' C-m \; split-window -h \; send-keys 'while true; clear; in; sleep 30s; end' C-m \; split-window -v \; 


  };
}
