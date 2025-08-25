function gssh -d "wrapper for gcloud compute ssh with TERM"
    if count $argv >/dev/null
        set machine $argv[1]
    else
        echo "you must provide a machine name, e.g. gssh v05"
        return 2
    end

    if test (count $argv) -ge 2
        set zone $argv[2]
    else
        set zone us-central1-b
    end

    TERM=xterm-256color gcloud compute ssh --zone $zone $machine --ssh-flag="-A -o ConnectTimeout=10"
end
