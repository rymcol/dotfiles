function pbcopy --description 'native pbcopy on macOS; wl-copy or xclip on Linux'
  if test (uname) = Darwin
    command pbcopy $argv
  else if command -q wl-copy
    wl-copy $argv
  else
    xclip -selection clipboard $argv
  end
end
