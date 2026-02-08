function set-init4 -a env
    if test "$env" != "dev" -a "$env" != "prod"
        echo "Usage: switch_env dev|prod"
        return 1
    end
    set -gx AWS_PROFILE $env
    aws sts get-caller-identity --profile $AWS_PROFILE > /dev/null 2>&1
    if test $status -ne 0
        aws sso login --profile $AWS_PROFILE
    end
    set -gx PULUMI_CONFIG_PASSPHRASE_FILE /Users/ryan/.pulumi/config.$env
    aws eks update-kubeconfig --name the-$env-cluster --profile $AWS_PROFILE
    kubectl config use-context $env-cluster
end