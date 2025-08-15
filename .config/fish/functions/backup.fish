function backup

    if count $argv >/dev/null
        set drive $argv[1]
    else
        echo "You must provide the external drive as an argument… `localbackup [drive]`"
        return 2
    end
    
    switch (uname)
        case Darwin
            set path /Volumes
        case Linux
            set path /run/media/ryan
    end


    restic -r $path/$drive/restic backup ~/Developer --cleanup-cache
    restic -r $path/$drive/restic backup ~/Pictures --cleanup-cache
    restic -r $path/$drive/restic backup ~/Music --cleanup-cache
    restic -r $path/$drive/restic backup ~/.config --cleanup-cache
    restic -r $path/$drive/restic forget --keep-daily 7 --keep-weekly 5 --keep-monthly 12 --keep-yearly 2 --prune

end
