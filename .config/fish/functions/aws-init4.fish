function aws-init4 --wraps='aws sso login --profile prod; and aws sso login --profile dev;' --description 'alias aws-init4 aws sso login --profile prod; and aws sso login --profile dev;'
    aws sso login --profile prod; and aws sso login --profile dev; $argv
end
