[[ -f ~/.bash-preexec.sh ]] && source ~/.bash-preexec.sh

## atuin
eval "$(atuin init bash)"

## rust
. "$HOME/.cargo/env"

## starship
eval "$(starship init bash)"
