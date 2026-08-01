if command -v brew > /dev/null 2>&1; then
    eval "$(brew shellenv bash)"

    # _prepend_path は 00-path-helpers.sh で定義している
    _prepend_path "$HOMEBREW_PREFIX/opt/curl/bin"
    _prepend_path "$HOMEBREW_PREFIX/opt/docker/bin"
    _prepend_path "$HOMEBREW_PREFIX/opt/docker-compose/bin"
    _prepend_path "$HOMEBREW_PREFIX/opt/file/bin"
    _prepend_path "$HOMEBREW_PREFIX/opt/sqlite/bin"
    _prepend_path "$HOMEBREW_PREFIX/opt/coreutils/libexec/gnubin"
    _prepend_path "$HOMEBREW_PREFIX/opt/findutils/libexec/gnubin"
    _prepend_path "$HOMEBREW_PREFIX/opt/gnu-sed/libexec/gnubin"
    _prepend_path "$HOMEBREW_PREFIX/opt/gnu-tar/libexec/gnubin"
    _prepend_path "$HOMEBREW_PREFIX/opt/libtool/libexec/gnubin"
    export PATH

    _binutils="$HOMEBREW_PREFIX/opt/binutils"
    if [ -d "$_binutils" ]; then
        export LDFLAGS="-L$_binutils/lib"
        export CPPFLAGS="-I$_binutils/include"
    fi
    unset _binutils

    export HOMEBREW_NO_INSTALL_CLEANUP=t
fi
