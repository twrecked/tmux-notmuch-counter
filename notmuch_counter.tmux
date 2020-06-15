#!/usr/bin/env bash

set -e

# Place holder for status left/right
place_holder="\#{notmuch_N}"

# Possible configurations.
# MUST contain the list of notmuch search-terms separated by |
notmuch_searches='@notmuch_searches'

interpolate() {
    local -r status="$1"
    local -r counter="${place_holder/N/$2}"
    local -r config="${3/~\//$HOME\/}"
    local -r count_files="#(notmuch $config count '$4')"
    local -r status_value=$(tmux show-option -gqv "$status")
    tmux set-option -gq "$status" "${status_value/$counter/$count_files}"
}

main() {
    IFS=\|
    local i=1
    for search in $(tmux show-option -gqv "$notmuch_searches"); do
		IFS=';' read -a args <<< "$search"
		if [[ ${#args[*]} == 1 ]]; then
			interpolate "status-left" "$i" "" "$search"
			interpolate "status-right" "$i" "" "$search"
		else
			interpolate "status-left" "$i" "--config=${args[0]}" "${args[1]}"
			interpolate "status-right" "$i" "--config=${args[0]}" "${args[1]}"
		fi
        i=$((i+1))
    done
}

main
