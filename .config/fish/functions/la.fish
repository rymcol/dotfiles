function la --wraps=ls --wraps='eza --long --icons --git' --wraps='eza --long --icons --git --all' --description 'alias la=eza --long --icons --git --all'
  eza --long --icons --git --all $argv
        
end
