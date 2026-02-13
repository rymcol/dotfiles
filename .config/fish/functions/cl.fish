function cl
    if test (count $argv) -lt 1
        echo "Usage: cl <profile> [args...]"
        return 1
    end

    set profile $argv[1]
    set config_dir ~/.claude/$profile

    mkdir -p $config_dir
    env CLAUDE_CONFIG_DIR=$config_dir claude $argv[2..-1]
end
