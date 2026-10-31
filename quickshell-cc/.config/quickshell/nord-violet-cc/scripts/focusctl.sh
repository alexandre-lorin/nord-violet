#!/usr/bin/env bash
set -euo pipefail

state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/nord-violet"
state_file="$state_dir/focus"
mkdir -p "$state_dir"
# Serialize state changes; workers release this lock before sleeping.
exec 9>"$state_dir/focus.lock"
flock 9

restore_dnd() {
    local previous="${1:-0}"
    if [[ "$previous" == "1" ]]; then
        makoctl mode -a dnd >/dev/null
    else
        makoctl mode -r dnd >/dev/null
    fi
}

finish_if_current() {
    local expected_end="$1"
    [[ -r "$state_file" ]] || return 0
    local current_end previous
    read -r current_end previous < "$state_file"
    [[ "$current_end" == "$expected_end" ]] || return 0
    restore_dnd "$previous"
    rm -f "$state_file"
    notify-send -a "Nord Violet Focus" "Session Focus terminée" "Vous pouvez reprendre les notifications." >/dev/null 2>&1 || true
}

action="${1:-status}"
case "$action" in
    status)
        if [[ ! -r "$state_file" ]]; then
            printf 'inactive|0\n'
            exit 0
        fi
        read -r end previous < "$state_file"
        now="$(date +%s)"
        if (( end < 0 )); then
            printf 'paused|%d\n' "$((-end))"
        elif (( end <= now )); then
            finish_if_current "$end"
            printf 'inactive|0\n'
        else
            printf 'active|%d\n' "$((end - now))"
        fi
        ;;
    start)
        minutes="${2:-50}"
        [[ "$minutes" == "25" || "$minutes" == "50" ]] || { echo "durée attendue: 25 ou 50" >&2; exit 2; }
        command -v makoctl >/dev/null
        mkdir -p "$state_dir"
        previous=0
        if makoctl mode | grep -Fxq dnd; then previous=1; fi
        if [[ -r "$state_file" ]]; then
            read -r _old_end previous < "$state_file"
        fi
        end="$(($(date +%s) + minutes * 60))"
        temporary="$(mktemp "$state_dir/.focus.XXXXXX")"
        printf '%s %s\n' "$end" "$previous" > "$temporary"
        mv -f "$temporary" "$state_file"
        makoctl mode -a dnd >/dev/null
        notify-send -a "Nord Violet Focus" "Focus : ${minutes} minutes" "Notifications coupées pendant la session ; état précédent restauré à la fin." >/dev/null 2>&1 || true
        nohup "$0" worker "$end" 9>&- >/dev/null 2>&1 </dev/null &
        printf 'active|%d\n' "$((minutes * 60))"
        ;;
    cancel)
        if [[ -r "$state_file" ]]; then
            read -r _end previous < "$state_file"
            restore_dnd "$previous"
            rm -f "$state_file"
        fi
        printf 'inactive|0\n'
        ;;
    toggle)
        duration="${2:-50}"
        flock -u 9
        if [[ -r "$state_file" ]]; then
            "$0" cancel >/dev/null
            notify-send -a "Nord Violet Focus" "Focus arrêté" "Les notifications précédentes sont restaurées." >/dev/null 2>&1 || true
            printf 'inactive|0\n'
        else
            "$0" start "$duration" >/dev/null
            printf 'active|%d\n' "$((duration * 60))"
        fi
        ;;
    pause|resume|pause-toggle)
        if [[ -r "$state_file" ]]; then
            read -r end previous < "$state_file"
            if (( end < 0 )) && [[ "$action" != pause ]]; then
                end="$(($(date +%s) - end))"
                makoctl mode -a dnd >/dev/null
                printf '%s %s\n' "$end" "$previous" > "$state_file"
                nohup "$0" worker "$end" 9>&- >/dev/null 2>&1 </dev/null &
            elif (( end > 0 )) && [[ "$action" != resume ]]; then
                remaining="$((end - $(date +%s)))"
                if (( remaining <= 0 )); then
                    finish_if_current "$end"
                else
                    restore_dnd "$previous"
                    printf '%s %s\n' "$((-remaining))" "$previous" > "$state_file"
                fi
            fi
        fi
        flock -u 9
        exec "$0" status
        ;;
    worker)
        expected_end="${2:?}"
        while :; do
            [[ -r "$state_file" ]] || exit 0
            read -r current_end _previous < "$state_file"
            [[ "$current_end" == "$expected_end" ]] || exit 0
            remaining="$((expected_end - $(date +%s)))"
            (( remaining > 0 )) || break
            flock -u 9
            if (( remaining > 15 )); then sleep 15; else sleep "$remaining"; fi
            flock 9
        done
        finish_if_current "$expected_end"
        ;;
    *)
        printf 'usage: %s {status|start {25|50}|pause|resume|pause-toggle|cancel|toggle {25|50}}\n' "$0" >&2
        exit 2
        ;;
esac
