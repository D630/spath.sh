#!/usr/bin/env bash

# spath.sh
# Copyright (C) 2015 D630, AGPLv3
# <https://github.com/D630/spath.sh>

# Fork of _lp_shorten_path() from liquidprompt
# <https://github.com/nojhan/liquidprompt/blob/master/liquidprompt>

# -- DEBUGGING.

#printf '%s (%s)\n' "$BASH_VERSION" "${BASH_VERSINFO[5]}" && exit 0
#set -o errexit
#set -o errtrace
#set -o noexec
#set -o nounset
#set -o pipefail
#set -o verbose
#set -o xtrace
#trap '(read -p "[$BASH_SOURCE:$LINENO] $BASH_COMMAND?")' DEBUG
#exec 2>> ~/spath.sh.log
#typeset vars_base=$(set -o posix ; set)
#fgrep -v -e "$vars_base" < <(set -o posix ; set) |
#egrep -v -e "^BASH_REMATCH=" \
#         -e "^OPTIND=" \
#         -e "^REPLY=" \
#         -e "^BASH_LINENO=" \
#         -e "^BASH_SOURCE=" \
#         -e "^FUNCNAME=" |
#less

# -- FUNCTIONS.

__spath_do ()
{
    (($# == 2)) || return 1;

    unset -v \
        spath_base \
        spath_delims \
        spath_dir \
        spath_left \
        spath_length \
        spath_len_left \
        spath_mask \
        spath_max_len \
        spath_name \
        spath_prompt \
        spath_ret \
        spath_tmp;

    typeset \
        spath_base= \
        spath_left= \
        spath_mask="${SPATH_MARK:- ... }" \
        spath_name= \
        spath_prompt="$2" \
        spath_ret= \
        spath_tmp=;

    typeset -i \
        spath_delims= \
        spath_dir= \
        spath_len_left= \
        spath_length="${SPATH_LENGTH:-35}";

    typeset -i spath_max_len="$((${COLUMNS:-$(__spath_get_cols :)} * $spath_length / 100))";

    ((${#spath_prompt} > spath_max_len)) && {
        spath_tmp="${spath_prompt//\//}";
        spath_delims="$((${#spath_prompt} - ${#spath_tmp}))";
        while ((spath_dir < 2)); do
            ((spath_dir == spath_delims)) && break;
            spath_left="${spath_prompt#*/}";
            spath_name="${spath_prompt:0:${#spath_prompt}-${#spath_left}}";
            spath_prompt="$spath_left";
            spath_ret="${spath_ret}${spath_name%/}/";
            ((spath_dir++));
        done;
        if ((spath_delims <= 2)); then
            spath_ret="${spath_ret}${spath_prompt##*/}";
        else
            spath_base="${spath_prompt##*/}";
            spath_prompt="${spath_prompt:0:${#spath_prompt}-${#spath_base}}";
            [[ "$spath_ret" == \/ ]] || spath_ret="${spath_ret%/}";
            spath_len_left="$((spath_max_len - ${#spath_ret} - ${#spath_base} - ${#spath_mask}))";
            spath_ret="${spath_ret}${spath_mask}${spath_prompt:${#spath_prompt}-${spath_len_left}}${spath_base}";
        fi;
        spath_prompt="$spath_ret"
    };

    if [[ "$1" == \: ]]; then
        printf '%s\n' "$spath_prompt";
    else
        eval "${1}=\$spath_prompt";
        __spath_upvar "$1" "${!1}"
    fi
}

__spath_get_cols ()
if [[ "$1" == \: ]]; then
    tput cols;
else
    typeset -i $1="$(tput cols)";
    __spath_upvar "$1" "${!1}";
fi

__spath_upvar ()
if unset -v "$1"; then
    if (($# == 2)); then
        eval "${1}=\${2}";
    else
        eval "${1}"'=("${@:2}")';
    fi;
fi
