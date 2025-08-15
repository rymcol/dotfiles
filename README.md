# Ryan's Dotfiles

## Install with gnu stow

```bash
stow .
```

## Moving Macs

```bash
# Leaving a machine
brew leaves > leaves.txt

# Fresh installation
xargs brew install < leaves.txt
```

