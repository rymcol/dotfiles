function set-init4 -a env
    if test "$env" != "dev" -a "$env" != "prod"
        echo "Usage: set-init4 dev|prod"
        return 1
    end

    set -gx AWS_PROFILE $env

    aws sts get-caller-identity --profile $AWS_PROFILE > /dev/null 2>&1
    or aws sso login --profile $AWS_PROFILE

    set -gx PULUMI_CONFIG_PASSPHRASE_FILE /Users/ryan/.pulumi/config.$env

    if test "$env" = "dev"
        aws eks update-kubeconfig --name the-dev-cluster --profile $AWS_PROFILE --region us-east-1
        kubectl config use-context arn:aws:eks:us-east-1:637423570300:cluster/the-dev-cluster
    else
        aws eks update-kubeconfig --name the-prod-cluster --profile $AWS_PROFILE --region us-east-1
        kubectl config use-context arn:aws:eks:us-east-1:381492309153:cluster/the-prod-cluster
    end
end
