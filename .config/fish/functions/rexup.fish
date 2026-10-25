function rexup --description 'Create the cedar and caster rex sessions with their tabs and panes'
    set -l src ~/Developer/src/github.com

    # Print the project directory for a tab label. Falls back to $HOME with a
    # warning if the mapped directory is missing.
    function __rexup_dir -a label -V src
        set -l dir
        switch $label
            case cedar
                set dir $HOME
            case webshipful
                set dir $src/webshipful/webshipful
            case astrolical
                set dir $src/cedarinventive/Astrolical
            case glasshouseherbs
                set dir $src/cedarinventive/glasshouseherbs.com
            case esm
                set dir $src/cedarinventive/earthspiritmedicine.ca
            case edgehill
                set dir $src/cedarinventive/edgehillschool.org
            case caster
                set dir $src/init4tech/caster
            case '*'
                set dir $HOME
        end
        if not test -d "$dir"
            echo "rexup: no directory for '$label' at $dir, using ~" >&2
            set dir $HOME
        end
        echo $dir
    end

    # Create a session (skipped if one with that label already exists) and
    # print its session_id. The first tab is labelled $first_tab and starts
    # in that tab's project directory.
    function __rexup_session -a label first_tab
        if rex ls --json | jq -e --arg l "$label" '.sessions | map(select(.label == $l)) | length > 0' >/dev/null
            echo "rexup: session '$label' already exists, skipping" >&2
            return 1
        end
        set -l out (rex new "$label" --window "$first_tab" --cwd (__rexup_dir $first_tab) --json); or return 1
        echo "$out" | jq -r '.session_id'
    end

    # Split the first tab of session $sid into two side-by-side panes, with
    # the new pane starting in the project directory for $label.
    function __rexup_split_first -a sid label
        set -l block (rex session inspect "$sid" --json | jq -r '.windows[0].focused_block_id')
        rex split -s "$sid" -b "$block" --split=right --cwd (__rexup_dir $label) >/dev/null
    end

    # --- cedar: first tab has two panes, then five single-pane tabs ---
    if set -l sid (__rexup_session cedar cedar)
        __rexup_split_first "$sid" cedar
        for tab in webshipful astrolical glasshouseherbs esm edgehill
            rex window new -s "$sid" "$tab" --cwd (__rexup_dir $tab) >/dev/null
        end
        rex focus -s "$sid" 1 >/dev/null
        echo "rexup: created session 'cedar'"
    end

    # --- caster: one tab with two panes ---
    if set -l sid (__rexup_session caster caster)
        __rexup_split_first "$sid" caster
        echo "rexup: created session 'caster'"
    end

    functions -e __rexup_dir __rexup_session __rexup_split_first
end
