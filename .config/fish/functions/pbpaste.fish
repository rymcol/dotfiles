function pbpaste --description 'xclip -selection clipboard -o on Linux; native pbpaste on macOS'
  if test (uname) = Linux
    xclip -selection clipboard -o $argv
  else
    command pbpaste $argv
  end
end
