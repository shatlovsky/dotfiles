# Set up the prompt, and export variables

# Colors:
txtblk='\e[0;30m' # Black - Regular
txtred='\e[0;31m' # Red
txtgrn='\e[0;32m' # Green
txtylw='\e[0;33m' # Yellow
txtblu='\e[0;34m' # Blue
txtpur='\e[0;35m' # Purple
txtcyn='\e[0;36m' # Cyan
txtwht='\e[0;37m' # White
bldblk='\e[1;30m' # Black - Bold
bldred='\e[1;31m' # Red
bldgrn='\e[1;32m' # Green
bldylw='\e[1;33m' # Yellow
bldblu='\e[1;34m' # Blue
bldpur='\e[1;35m' # Purple
bldcyn='\e[1;36m' # Cyan
bldwht='\e[1;37m' # White
unkblk='\e[4;30m' # Black - Underline
undred='\e[4;31m' # Red
undgrn='\e[4;32m' # Green
undylw='\e[4;33m' # Yellow
undblu='\e[4;34m' # Blue
undpur='\e[4;35m' # Purple
undcyn='\e[4;36m' # Cyan
undwht='\e[4;37m' # White
bakblk='\e[40m'   # Black - Background
bakred='\e[41m'   # Red
badgrn='\e[42m'   # Green
bakylw='\e[43m'   # Yellow
bakblu='\e[44m'   # Blue
bakpur='\e[45m'   # Purple
bakcyn='\e[46m'   # Cyan
bakwht='\e[47m'   # White
txtrst='\e[0m'    # Text Reset

# Set Host Coloration based on OS
case `uname -s` in
    "Darwin"    ) host_color="$txtblu";;
    "Linux"     ) host_color="$txtred";;
    *           ) host_color="$bldpur";;
esac;

# Get the /24 we're connected to
case "$(uname -s)" in
    "Darwin"    ) netstat_opts="-rn -f inet";;
    *           ) netstat_opts="-rn";;
esac

LOCAL_NETWORK=$(netstat $netstat_opts |grep -P '^(0.0.0.0|default)'|awk '{print $2}'| awk -F. '{print $1 "." $2 "." $3}')
export LOCAL_NETWORK;

function prompt_extra() {
    addition=$1;
    # Color if not colored
    echo $addition | grep '\\' &> /dev/null;
    if [ "$?" != "0" ]; then
        addition="${bldblk}(${host_color}${addition}${bldblk})$txtrst";
    fi;

    if [ -z $PROMPT_EXTRA ]; then
        PROMPT_EXTRA=$addition;
    else
        PROMPT_EXTRA="$PROMPT_EXTRA$addition"
    fi;
}

function get_user_color() {
    # Set User Color based on Name
    case "$USER" in
        "root"      )   user_color="$bldred";;
        "brad"      )   user_color="$txtgrn";;
        "blhotsky"  )   user_color="$txtcyn";;
        *           )   user_color="$txtpur";;
    esac
    echo $user_color;
}

function before_prompt() {
    # Grab global $?;
    retval=$?

    history -a;     # Record history

    printf "$bldblk[$host_color%s$bldblk] $(get_user_color)%s" "$(date '+%H:%M:%S')" "$PWD"

    if [ -x ~/bin/vcprompt ] && [ "$VCPROMPT" != "disable" ]; then
        vc_out=`~/bin/vcprompt`;
        [ ${#vc_out} -gt 0 ] && printf " $vc_out";
    fi;

    [ ! -z $PROMPT_EXTRA ] && printf " $PROMPT_EXTRA";

    [ $retval -ne 0 ] && printf " $bldred[*${txtred}${retval}${bldred}*]$txtrst";

    printf "\n";
}

function root_login () {
    local timeout=1800;
    local keyActive=`ssh-add -l |grep 'administrator.dsa'|wc -l`;

    local adminKey="$HOME/.ssh/administrator.dsa";

    if [ -f "$adminKey" ] || [ "$keyActive" -gt "0" ]; then

        local hasAgent="$keyActive";
        if [ "$SSH_AUTH_SOCK" ] && [ -e "$SSH_AUTH_SOCK" ]; then
            hasAgent=1;
        fi;

        if [ "$hasAgent" -gt "0" ]; then

            if [ "$keyActive" -eq "0" ]; then
                ssh-add -t $timeout $adminKey;
            fi;

            ssh -l root $*;

        else
            echo ">>> SSH Agent not running";
            ssh -i $adminKey -l root $*;
        fi;
    else
        echo ">>> Admin Key not found: ($adminKey)";
        ssh -l root $*;
    fi;

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

if [ "$PS1" ] && [ "$BASHRC" != 1 ]; then
    . ~/.bashrc
fi;

# User specific environment and startup programs
VCPROMPT_FORMAT="$bldblk[$txtcyn%n$blkblk:$txtgrn%b$bldblk@$txtred%r$txtpur%m%u$bldblk]";
PROMPT_COMMAND=before_prompt
PS1="\[$(get_user_color)\]\u\[$bldblk\]@\[$host_color\]\h \[$(get_user_color)\]\\\$ \[$txtrst\]"
USERNAME=""
EDITOR="vim"
LC_ALL="en_US.UTF-8"

export USERNAME EDITOR VCPROMPT_FORMAT PS1 PROMPT_COMMAND LC_ALL
