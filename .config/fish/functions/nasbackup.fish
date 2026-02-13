function nasbackup
    set -l repo

    switch (uname)
        case Darwin
            set repo /Volumes/restic
        case Linux
            set repo /mnt/restic

            # Try to mount if not already there
            if not test -f $repo/config
                mkdir -p $repo
                echo "Enter NAS password:"
                sudo mount -t cifs //10.0.7.13/restic $repo \
                    -o username=ryan,vers=3.0,uid=1000,gid=1000,nounix \
                    -o password="$(read -s -P "Password: " pw; echo $pw)"
            end
    end

    if not test -d $repo
        echo "Error: $repo not available"
        return 1
    end

    restic -r $repo backup ~/Developer    --cleanup-cache
    restic -r $repo backup ~/Pictures     --cleanup-cache
    restic -r $repo backup ~/Music        --cleanup-cache
    restic -r $repo backup ~/Downloads    --cleanup-cache

    restic -r $repo forget --keep-daily 7 --keep-weekly 5 --keep-monthly 12 --keep-yearly 2 --prune
end
