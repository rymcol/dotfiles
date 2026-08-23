function pbcopy --description 'xclip -selection clipboard on Linux; native pbcopy on macOS'
  if test (uname) = Linux
    xclip -selection clipboard $argv
  else
    command pbcopy $argv
  end
end
