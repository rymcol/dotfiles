function aws-init4 --wraps='aws sso login' --description 'Log in to the shared init4 AWS SSO session (covers dev, prod and caster)'
    aws sso login --sso-session init4 $argv
end
