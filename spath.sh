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

Spath::Do ()
{
        (( $# == 2 )) || builtin return 1

        builtin typeset \
                spath_base \
                spath_left \
                spath_mask="${SPATH_MARK:- ... }" \
                spath_name \
                spath_prompt="$2" \
                spath_ret \
                spath_ref \
                spath_status \
                spath_tmp;

        builtin typeset -i \
                spath_delims= \
                spath_dir= \
                spath_len_left= \
                spath_length="${SPATH_LENGTH:-35}";

        builtin typeset -i \
                spath_max_len="${COLUMNS:-$(Spath::GetCols :)} * spath_length / 100"

        (( ${#spath_prompt} > spath_max_len )) && {
                spath_tmp=${spath_prompt//\//}
                spath_delims="${#spath_prompt} - ${#spath_tmp}"

                while
                        (( spath_dir < 2 ))
                do
                        (( spath_dir == spath_delims )) && builtin break
                        spath_left=${spath_prompt#*/}
                        spath_name=${spath_prompt:0:${#spath_prompt}-${#spath_left}}
                        spath_prompt=$spath_left
                        spath_ret=${spath_ret}${spath_name%/}/
                        (( spath_dir++ ))
                done

                if
                        (( spath_delims <= 2 ))
                then
                        spath_ret=${spath_ret}${spath_prompt##*/}
                else
                        spath_base=${spath_prompt##*/}
                        spath_prompt=${spath_prompt:0:${#spath_prompt}-${#spath_base}}
                        [[ $spath_ret == \/ ]] || spath_ret=${spath_ret%/}
                        spath_len_left="spath_max_len - ${#spath_ret} - ${#spath_base} - ${#spath_mask}"
                        spath_ret=${spath_ret}${spath_mask}${spath_prompt:${#spath_prompt}-${spath_len_left}}${spath_base}
                fi

                spath_prompt=$spath_ret
        }

        spath_status=$?

        if
                [[ $1 == \: ]]
        then
                builtin printf '%s\n' "$spath_prompt"
        else
                builtin typeset -n spath_ref="$1"
                spath_ref=$spath_prompt
                builtin unset -n spath_ref
        fi

        builtin return $spath_status
}

Spath::GetCols ()
if
        (( $# )) || builtin return 1
        [[ $1 == \: ]]
then
        command tput cols
else
        builtin typeset -n spath_ref="$1"
        spath_ref=$(command tput cols)
        builtin unset -n spath_ref
fi

# vim: set ts=8 sw=8 tw=0 et :
