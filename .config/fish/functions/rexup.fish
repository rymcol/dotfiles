function rexup --description 'Create the cedar and caster rex sessions with their tabs and panes'
    # Create a session (skipped if one with that label already exists) and
    # print its session_id. The first tab is labelled $first_tab.
    function __rexup_session -a label first_tab
        if rex ls --json | jq -e --arg l "$label" '.sessions | map(select(.label == $l)) | length > 0' >/dev/null
            echo "rexup: session '$label' already exists, skipping" >&2
            return 1
        end
        set -l out (rex new "$label" --window "$first_tab" --json); or return 1
        echo "$out" | jq -r '.session_id'
    end

    # Split the first tab of session $sid into two side-by-side panes.
    function __rexup_split_first -a sid
        set -l block (rex session inspect "$sid" --json | jq -r '.windows[0].focused_block_id')
        rex split -s "$sid" -b "$block" --split=right >/dev/null
    end

    # --- cedar: first tab has two panes, then six single-pane tabs ---
    if set -l sid (__rexup_session cedar cedar)
        __rexup_split_first "$sid"
        for tab in webshipful astrolical glasshouseherbs esm edgehill
            rex window new -s "$sid" "$tab" >/dev/null
        end
        rex focus -s "$sid" 1 >/dev/null
        echo "rexup: created session 'cedar'"
    end

    # --- caster: one tab with two panes ---
    if set -l sid (__rexup_session caster caster)
        __rexup_split_first "$sid"
        echo "rexup: created session 'caster'"
    end

    functions -e __rexup_session __rexup_split_first
end
