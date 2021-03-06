# Path Injection
function path_inject() {
    (( $DEBUG )) && echo -n "path_inject( $1 )";
    if [ -d "$1" ]; then
        PATH="$1:$PATH";
        (( $DEBUG )) && echo -n " [FOUND]";
    fi;
    (( $DEBUG )) && echo;
}

function contents() {
    if [ -f "$1" ] && [ -r "$1" ]; then
        file_lines=`wc -l $1 | awk '{print $1}'`;
        rc=$?;
        if [[ $rc -ne 0 ]]; then
            echo "error reading file: $1";
            exit $rc;
        fi;
        if [[ $file_lines -gt $LINES ]]; then
            out=`expr $LINES / 2 - 1`;
            head -$out $1
            echo "::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::";
            tail -$out $1
        else
            cat $1;
        fi;
    else
        ls -lhF --color=auto $1
    fi
}

function send_bash_local() {
    host=$1
    if [ -f ~/.distrib_hosts ]; then
        grep "^$host$" ~/.distrib_hosts &> /dev/null
        rc=$?
        if [[ $rc -ne 0 ]]; then
            echo "!! warning : host $host was not found in ~/.distrib_hosts";
        fi;
    fi;
    /usr/bin/scp .bash_local $host:~
}

function _set_win_title() {
    printf "\033k$1\033\\"
}

function tmux_wrapper() {
    version=`tmux -V |cut -d' ' -f 2`

    if [[ "$version" > "1.6" ]]; then
        command tmux -2 new-session -A -s base
    else
        command tmux -2 attach-session -t 0 || tmux new-session
    fi
}

function seconds_til_3am() {
    # Check for GNU Compatibility
    date --date today > /dev/null 2>&1
    rc="$?";
    if [ "$rc" -eq "0" ]; then
        date="GNU";
        expire_at=$(date --date "$(date --date tomorrow +%Y-%m-%d) 3:00:00" +%s);
        expire_seconds=$(($expire_at - $(date +%s)))
    else
        date="BSD";
        expire_at=$(date -j -f "%Y-%m-%dT%H:%M:%S" $(date -v+1d +"%Y-%m-%dT03:00:00") +%s)
        expire_seconds=$(($expire_at - $(date -j +%s)))
    fi

    (($DEBUG)) && echo "[$date] expire_seconds=$expire_seconds" >&2
    echo "$expire_seconds";
}
