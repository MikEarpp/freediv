#!/bin/bash

FILE=./pdnsutil_$(pdnsutil --version | awk '{print $2}')_.bash_completion

_PDNS_HELP=$(pdnsutil --help | sed -n '/^Commands:/,$p' | sed '/:/d' | sed '/^$/d' | sed '/^[[:space:]]/d' | awk '{print $1}' | sort -u)
PDNS_HELP=""
echo 'have pdnsutil && {'                                                     >  $FILE
echo '  pdnsutil_helper() {'                                                  >> $FILE
echo '    local cur prev cmd'                                                 >> $FILE
ADD0='    local options="'
ADD1=$(printf "%*s" ${#ADD0} "")
for CMD in $_PDNS_HELP; do
    CURR_LENGTH=$(echo -n "$PDNS_HELP" | wc -c)
    if [ $(($CURR_LENGTH + ${#CMD} + 1)) -le 168 ]; then
        [ -z "$PDNS_HELP" ] && PDNS_HELP="$ADD0$CMD" || PDNS_HELP="$PDNS_HELP $CMD"
    else
        echo "$PDNS_HELP"                                                     >> $FILE
        PDNS_HELP="$ADD0$CMD"
    fi
    ADD0=$ADD1
done
echo "$PDNS_HELP\""                                                           >> $FILE
echo '    COMPREPLY=()'                                                       >> $FILE
echo '    cur="${COMP_WORDS[COMP_CWORD]}"'                                    >> $FILE
echo '    prev="${COMP_WORDS[COMP_CWORD-1]}"'                                 >> $FILE
echo '    if [[ $prev == "pdnsutil" ]]; then'                                 >> $FILE
echo '      COMPREPLY=($(compgen -W "$options" -- "$cur"))'                   >> $FILE
echo '      return 0'                                                         >> $FILE
echo '    fi'                                                                 >> $FILE
echo '    if [[ "$options" == *"$prev"* ]]; then'                             >> $FILE
echo '      prevprev="${COMP_WORDS[COMP_CWORD-2]}"'                           >> $FILE
echo '      COMPREPLY=($(compgen -W "$(pdnsutil list-all-zones)" -- "$cur"))' >> $FILE
echo '      return 0'                                                         >> $FILE
echo '    fi'                                                                 >> $FILE
echo '  }'                                                                    >> $FILE
echo '  complete -o default -F pdnsutil_helper pdnsutil'                      >> $FILE
echo '}'                                                                      >> $FILE
