cat ~/.config/fish/functions/worktree-clean.fish
function worktree-clean --description "Clean up worktrees whose remote tracking branch no longer exists"
    argparse f/force r/recursive -- $argv
    or return 1

    set -l base_path $argv[1]
    if test -z "$base_path"
        set base_path (pwd)
    end

    if not test -d "$base_path"
        echo "Error: $base_path is not a directory"
        return 1
    end

    set -l repos
    if set -q _flag_recursive
        for dir in $base_path/*/
            # .git is a file in linked worktrees, a directory in normal repos
            if test -e "$dir/.git"
                set -a repos (string trim -r -c / "$dir")
            end
        end
        if test (count $repos) -eq 0
            echo "No git repos found in $base_path"
            return 1
        end
    else
        set repos $base_path
    end

    set -l remove_args
    if set -q _flag_force
        set remove_args --force
    end

    for repo_path in $repos
        pushd "$repo_path"
        or continue

        if set -q _flag_recursive
            echo "=== $repo_path ==="
        end

        git fetch --prune

        set -l main_wt (git worktree list --porcelain | awk '/^worktree / { print $2; exit }')

        git worktree list --porcelain | awk '
            /^worktree / { wt = $2 }
            /^branch /   { branch = $2; print wt "\t" branch }
        ' | while read -l -d \t wt_path branch_ref
            # Skip the main worktree
            if test "$wt_path" = "$main_wt"
                continue
            end

            # Extract short branch name from refs/heads/...
            set -l branch (string replace 'refs/heads/' '' "$branch_ref")

            # Check if the remote tracking branch still exists
            if not git ls-remote --exit-code --heads origin "$branch" &>/dev/null
                echo "Removing worktree: $wt_path (branch: $branch — remote branch gone)"
                git worktree remove $remove_args "$wt_path"
            end
        end

        popd
    end

    echo "Worktree cleanup complete."
end
