function gcpbackup
set -lx GOOGLE_APPLICATION_CREDENTIALS /Users/ryan/.config/gcloud/eighth-study-dd3ce8ff3a84.json
restic backup ~/Developer --cleanup-cache
restic backup ~/Pictures --cleanup-cache
restic backup ~/Music --cleanup-cache
restic forget --keep-daily 2 --keep-weekly 2 --keep-monthly 6 --keep-yearly 1 --prune
end
