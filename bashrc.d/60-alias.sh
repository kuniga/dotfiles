# Only for local machine (macOS)
if [ "$(uname)" = "Darwin" ]; then
    # alias docker='/opt/homebrew/bin/nerdctl.lima'
    # alias docker='/opt/homebrew/bin/docker.lima'
    # alias docker='/opt/homebrew/bin/podman.lima'
    # alias docker='/opt/homebrew/bin/podman'
    # alias sse='open /System/Library/CoreServices/ScreenSaverEngine.app'
    alias google-meet='open "$HOME/Applications/Chrome Apps.localized/Google Meet.app"'

    if command -v gls > /dev/null 2>&1; then
        alias ls='gls -F --color=auto --hide="*.pyc"'
        alias ll='gls -l -F --color=auto --hide="*.pyc"'
    fi

    if command -v ggrep > /dev/null 2>&1; then
        alias grep="ggrep --color=auto"
    fi
fi
