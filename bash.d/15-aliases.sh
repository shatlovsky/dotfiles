# User specific aliases and functions
alias who='who -H -u -T'
alias root='root_login'
alias c="contents"
# Get Aliases
alias gg='git grep'
# SSH-ADD
alias ssh-add='ssh-add -t $(($(date --date "$(date --date tomorrow +%Y-%m-%d) 3:00:00" +%s) - $(date +%s)))'

# Hive
command -v rlwrap &> /dev/null
rc=$?
if [[ "$rc" -eq "0" ]]; then
        alias rlhive='rlwrap -i --prompt-colour=yellow -f ~/.hive_completion -a hive $*'
fi;

if [ "$HOSTOS" == "OpenBSD" ]; then
    alias ls='gls --time-style=long-iso -F --color'
else
    alias ls='ls --time-style=long-iso -F --color'
fi

