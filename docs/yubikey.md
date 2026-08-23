# YubiKey: SSH auth + GPG signing architecture

**One rule: gpg-agent is the only thing that talks to the card.**

The YubiKey 5C NFC FIPS (serial 28887536) carries two applets:

| Applet | Holds | Used for |
|---|---|---|
| OpenPGP | sign / encrypt / auth RSA keys (sign key `2745210F…8B655205`) | git commit signing, decryption |
| PIV, slot 9a | ECDSA P-384, `CN=SSH PIV 9a` (pubkey `~/.ssh/id_5cnfc.pub`) | SSH auth everywhere: Mac, Linux, iOS (Prompt 3) |

GnuPG ≥ 2.3 reads the PIV application natively, so gpg-agent's ssh socket
serves **both** the OpenPGP auth key and the PIV 9a key. `SSH_AUTH_SOCK`
points at `$(gpgconf --list-dirs agent-ssh-socket)` (set in
`.config/fish/config.fish`). No other agent (yubikey-agent, ssh-agent +
PKCS#11, Secretive) may run: a second CCID consumer clobbers applet
selection mid-read and corrupts scdaemon's view of the card — this is what
broke commit signing in Aug 2026.

End state for `authorized_keys` / GitHub: the single PIV key
(`id_5cnfc.pub`). PIV 9a policy: PIN once per session, touch cached.

## iOS (Prompt 3)

Prompt 3 reads PIV slot 9a directly (RSA/ECDSA), over NFC or USB-C.
Server settings → tap the key icon → YubiKey. Independent of all desktop
agent config.

## New machine bootstrap

macOS: `brew install gnupg pinentry-mac ykman`
Linux: `apt/dnf install gnupg pcscd pinentry-gnome3 && systemctl enable --now pcscd.socket`
(needs GnuPG ≥ 2.3 for the PIV key: Ubuntu 24.04+/Debian 13+/Fedora/Arch)

```
install -d -m 700 ~/.gnupg
# ~/.gnupg/gpg-agent.conf
enable-ssh-support
pinentry-program /opt/homebrew/bin/pinentry-mac   # Linux: distro pinentry path
default-cache-ttl 60
max-cache-ttl 120
# ~/.gnupg/scdaemon.conf
disable-ccid          # use PC/SC (macOS ctkpcscd / Linux pcscd), exclusive
```

Import the public key (`gpg --locate-keys ry@rycollins.com` or
keys.openpgp.org), insert the card, `gpg --card-status` to create stubs.
The fish config's shared block wires up `SSH_AUTH_SOCK` when `gpgconf`
exists.

## Known quirk: stale `gpg --card-status` after SSH use

scdaemon (observed on 2.5.21) leaves the card on the PIV application after
serving SSH operations; `gpg --card-status` then misreports the OpenPGP
app (`Version 1.0 / Manufacturer ? / PIN 0 0 0 / keys [none]`). **This is
cosmetic** — signing still routes by keygrip and works. To get a clean
read:

```
gpg-connect-agent 'scd switchapp openpgp' /bye   # instant
gpgconf --reload scdaemon                        # heavier alternative
```

## Troubleshooting

- Card wedged / sharing violation: `gpgconf --kill all`, replug key,
  `gpgconf --launch gpg-agent`. If persistent, check nothing else touches
  the card (`pgrep -fl 'yubikey-agent|ssh-agent -D'`).
- If exclusive PC/SC ever fights macOS CryptoTokenKit: re-add
  `pcsc-shared` to scdaemon.conf (second choice), or disable the OS PIV
  token: `sudo defaults write /Library/Preferences/com.apple.security.smartcard
  DisabledTokens -array com.apple.CryptoTokenKit.pivtoken`.
- Inbound SSH to the Mac: pinentry-mac pops on the console GUI, so card
  operations from an ssh session appear to hang.
- GUI apps (VS Code git-over-ssh): don't inherit fish's `SSH_AUTH_SOCK`;
  gpg signing is unaffected, ssh auth needs
  `launchctl setenv SSH_AUTH_SOCK ~/.gnupg/S.gpg-agent.ssh`.

## Retired (Aug 2026)

`docs/retired-2026-08/` archives the failed PIV-via-ssh-agent attempt:
yubikey-agent + Homebrew ssh-agent plists, `piv-ensure`/`piv-askpass`
helpers, `piv.fish`, and the pre-change agent key list. Old-YubiKey
(`cardno:000610335511`, `id_ryan.pub`) authorized_keys lines should be
pruned everywhere along with the OpenPGP-auth-key line once the PIV key is
verified from every device.

Follow-up (optional): `~/.ssh` and `~/.gnupg` are real directories, not
managed by this repo. If they ever move in, use a strict `.gitignore`
allowlist (only `config`, `*.pub`, `*.conf`) — never track private key
material.
