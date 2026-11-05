# /etc/zprofile runs path_helper, which moves the system directories (/usr/bin
# etc.) in front of everything .zshenv added. Put Homebrew back in front.
path=(/opt/homebrew/bin /opt/homebrew/sbin /opt/homebrew/opt/unzip/bin $path)
