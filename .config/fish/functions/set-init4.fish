function set-init4 -a env
    if not contains -- "$env" dev prod caster
        echo "Usage: set-init4 dev|prod|caster"
        return 1
    end

    set -gx AWS_PROFILE $env

    aws sts get-caller-identity --profile $AWS_PROFILE >/dev/null 2>&1; or aws sso login --profile $AWS_PROFILE

    switch $env
        case dev
            set -gx PULUMI_CONFIG_PASSPHRASE_FILE ~/.pulumi/config.$env
            set -gx PULUMI_BACKEND_URL "s3://init4-pulumi-state-backend?region=us-east-1&awssdk=v2&profile=$AWS_PROFILE"
            aws eks update-kubeconfig --name the-dev-cluster --profile $AWS_PROFILE --region us-east-1
            kubectl config use-context arn:aws:eks:us-east-1:637423570300:cluster/the-dev-cluster
            aws ecr get-login-password --region us-east-1 --profile $AWS_PROFILE | docker login --username AWS --password-stdin 637423570300.dkr.ecr.us-east-1.amazonaws.com
        case prod
            set -gx PULUMI_CONFIG_PASSPHRASE_FILE ~/.pulumi/config.$env
            set -gx PULUMI_BACKEND_URL "s3://init4-prod-pulumi-state?region=us-east-1&awssdk=v2&profile=$AWS_PROFILE"
            aws eks update-kubeconfig --name the-prod-cluster --profile $AWS_PROFILE --region us-east-1
            kubectl config use-context arn:aws:eks:us-east-1:381492309153:cluster/the-prod-cluster
            aws ecr get-login-password --region us-east-1 --profile $AWS_PROFILE | docker login --username AWS --password-stdin 381492309153.dkr.ecr.us-east-1.amazonaws.com
        case caster
            set -gx PULUMI_CONFIG_PASSPHRASE_FILE ~/.pulumi/config.$env
            set -gx PULUMI_BACKEND_URL "s3://caster-pulumi-state-637423570300?region=us-east-1&awssdk=v2&profile=$AWS_PROFILE"
            aws eks update-kubeconfig --name caster-dev --profile $AWS_PROFILE --region us-east-1
            kubectl config use-context arn:aws:eks:us-east-1:637423570300:cluster/caster-dev
            aws ecr get-login-password --region us-east-1 --profile $AWS_PROFILE | docker login --username AWS --password-stdin 637423570300.dkr.ecr.us-east-1.amazonaws.com
    end
end
