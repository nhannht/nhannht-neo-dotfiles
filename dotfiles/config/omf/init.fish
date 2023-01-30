# [[file:../../.doom.d/dot.org::*Init.fish][Init.fish:1]]
# fish_vi_key_bindings
fish_default_key_bindings
if status is-interactive
    # Commands to run in interactive sessions can go here
end
bass source $HOME/.profile
bass source $HOME/.bash_profile
bass source $HOME/.bashrc
function fuck -d "Correct your previous console command"
  set -l fucked_up_command $history[1]
  env TF_SHELL=fish TF_ALIAS=fuck PYTHONIOENCODING=utf-8 thefuck $fucked_up_command THEFUCK_ARGUMENT_PLACEHOLDER $argv | read -l unfucked_command
  if [ "$unfucked_command" != "" ]
    eval $unfucked_command
    builtin history delete --exact --case-sensitive -- $fucked_up_command
    builtin history merge
  end
end

# source $HOME/.config/fish/hugo.fish

# With vterm_cmd you can execute Emacs commands directly from the shell.
# For example, vterm_cmd message "HI" will print "HI".
# To enable new commands, you have to customize Emacs's variable
# vterm-eval-cmds.
function vterm_cmd --description 'Run an Emacs command among the ones defined in vterm-eval-cmds.'
    set -l vterm_elisp ()
    for arg in $argv
        set -a vterm_elisp (printf '"%s" ' (string replace -a -r '([\\\\"])' '\\\\\\\\$1' $arg))
    end
    vterm_printf '51;E'(string join '' $vterm_elisp)
end
source (/usr/bin/starship init fish --print-full-init | psub)
# Init.fish:1 ends here
