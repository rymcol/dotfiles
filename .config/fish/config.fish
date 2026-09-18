# The following lines were added by Docker Desktop to add commands to your PATH.
export PATH="$PATH:/Users/ryan/.docker/bin"
# End of Docker Desktop section.

# Android
if set -q TERMUX_VERSION

    if status is-interactive
        # Commands to run in interactive sessions can go here
    end

    eval (okc-ssh-agent -c)

    # The next line updates PATH for the Google Cloud SDK.
    if [ -f '/data/data/com.termux/files/home/Developer/pkg/google-cloud-sdk/path.fish.inc' ]
        . '/data/data/com.termux/files/home/Developer/pkg/google-cloud-sdk/path.fish.inc'
    end

    # pnpm (Android)
    set -gx PNPM_HOME "/data/data/com.termux/files/home/.local/share/pnpm"
    if not string match -q -- $PNPM_HOME $PATH
        set -gx PATH "$PNPM_HOME" $PATH
    end # pnpm end

else

    switch (uname)
        case Darwin
            # gcloud macOS (`gcloud-cli` cask): gcloud/gsutil/bq are already linked
            # into /opt/homebrew/bin; this adds the SDK bin dir for `gcloud components`
            fish_add_path -g /opt/homebrew/share/google-cloud-sdk/bin

            # Fix ruby path
            fish_add_path -g /opt/homebrew/lib/ruby/gems/3.3.0/bin

            # Compilers
            # set -gx LDFLAGS "-L/usr/local/opt/llvm@5/lib"
            # set -gx CPPFLAGS "-I/usr/local/opt/llvm@5/include"
            # if which swiftenv > /dev/null; status --is-interactive; and source (swiftenv init -|psub); end
            # set -gx SWIFTENV_ROOT "$HOME/.swiftenv"

            fish_add_path -g --append ~/.foundry/bin

            # pnpm (macOS)
            set -gx PNPM_HOME /Users/ryan/Library/pnpm
            if not string match -q -- $PNPM_HOME $PATH
                set -gx PATH "$PNPM_HOME" $PATH
            end
            # pnpm end
        case Linux
            set -gx SIGNAL_PASSWORD_STORE gnome-libsecret
    end

    ## both macOS & Linux
    # gpg-agent is the sole smart-card consumer AND the ssh agent
    # (serves both the OpenPGP auth key and the PIV 9a key over its ssh socket)
    if command -q gpgconf
        set -gx SSH_AUTH_SOCK (gpgconf --list-dirs agent-ssh-socket)
        # autostarts gpg-agent like `gpgconf --launch gpg-agent`, but ~10ms instead of ~300ms
        command gpg-connect-agent /bye &>/dev/null
    end
    status is-interactive; and set -gx GPG_TTY (tty)

end

### Every Platform ###

# Fix for fish prompt backwards
set -g fish_key_bindings fish_hybrid_key_bindings

# Restic
set -gx RESTIC_PASSWORD_FILE "$HOME/.restic"
set -gx RESTIC_REPOSITORY /Volumes/restic

# Path
# fish_add_path -g skips missing dirs and dirs already in $PATH, so nested shells don't grow it
fish_add_path -g ~/Developer/bin
set -gx GOPATH ~/Developer

# Rust
if test -f "$HOME/.cargo/env.fish"
    source "$HOME/.cargo/env.fish"
end

# Fix git
set -gx GIT_TERMINAL_PROMPT 1

# bun
set --export BUN_INSTALL "$HOME/.bun"
fish_add_path -g $BUN_INSTALL/bin

# starship
if status is-interactive; and command -q starship
    starship init fish | source
end

fish_add_path -g ~/.groundcover/bin
fish_add_path -g ~/.local/bin


# >>> grok installer >>>
fish_add_path $HOME/.grok/bin
# <<< grok installer <<<
