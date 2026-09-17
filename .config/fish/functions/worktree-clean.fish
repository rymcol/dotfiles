function worktree-clean -a repo_path --description "Clean up worktrees whose remote tracking branch no longer exists"
    if test -z "$repo_path"
        set repo_path (pwd)
    end

    if not test -d "$repo_path"
        echo "Error: $repo_path is not a directory"
        return 1
    end

    pushd "$repo_path"
    or return 1

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
            git worktree remove "$wt_path"
        end
    end

    echo "Worktree cleanup complete."
    popd
end

