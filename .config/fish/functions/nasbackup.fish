function nasbackup

switch (uname)
    case Darwin
        set path /Volumes
    case Linux
        set path /run/user/1000/gvfs/smb-share:server=10.0.7.7,share=home
end

restic -r $path/restic backup ~/Developer --cleanup-cache
restic -r $path/restic backup ~/Pictures --cleanup-cache
restic -r $path/restic backup ~/Music --cleanup-cache
restic -r $path/restic backup ~/Downloads --cleanup-cache
restic -r $path/restic forget --keep-daily 7 --keep-weekly 5 --keep-monthly 12 --keep-yearly 2 --prune

end
