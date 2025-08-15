function nukepnpm --wraps='rm -r /Users/(whoami)/Library/pnpm/store/v3' --wraps='rm -r /Users/(whoami)/Library/pnpm/store/v10' --wraps='rm -r /Users/(whoami)/Library/pnpm/store/*' --description 'alias nukepnpm rm -r /Users/(whoami)/Library/pnpm/store/*'
  rm -r /Users/(whoami)/Library/pnpm/store/* $argv
        
end
