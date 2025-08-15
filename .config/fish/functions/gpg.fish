function gpg
    switch (uname -o)
        case Android
            command okc-gpg $argv
        case '*'
            command /usr/bin/env gpg $argv
    end
end
