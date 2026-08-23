function piv --description "(Re)load the YubiKey PIV key into ssh-agent (pinentry-mac prompt)"
    # Drop any stale provider registration first (needed after unplug/replug),
    # then add it back, prompting for the PIN via pinentry-mac.
    /opt/homebrew/bin/ssh-add -e /usr/local/lib/libykcs11.dylib >/dev/null 2>&1
    SSH_ASKPASS=$HOME/.local/bin/piv-askpass SSH_ASKPASS_REQUIRE=force /opt/homebrew/bin/ssh-add -s /usr/local/lib/libykcs11.dylib </dev/null
end
