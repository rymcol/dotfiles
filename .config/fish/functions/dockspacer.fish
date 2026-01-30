function dockspacer
    set type '{"tile-type"="small-spacer-tile";}'
    if test "$argv" = "--wide"
        set type '{"tile-data"={};"tile-type"="spacer-tile";}'
    end
    defaults write com.apple.dock persistent-apps -array-add $type && killall Dock
end
