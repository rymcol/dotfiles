function merged

    set branch (git branch | grep \* | cut -d ' ' -f2)
    
    if count $argv > /dev/null
        set base $argv[1]
    else
	echo "You must provide the base branch as an argument… `merged [base]`"
	return 2
    end

    if [ $branch != $base ]
        git checkout $base; and git pull origin $base; and git branch -d $branch; and git remote prune origin;
    end
end
