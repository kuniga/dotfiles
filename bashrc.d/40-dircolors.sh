# カラー定義は seebi/dircolors-solarized を install.sh がクローンしたものを使う。
# テーマを変えたい場合は 02-set-variables.sh で DIRCOLORS_THEME を設定する
# （例: dircolors.ansi-dark, dircolors.256dark, dircolors.ansi-universal）。
if command -v dircolors > /dev/null 2>&1; then
    _dircolors_file="${XDG_DATA_HOME:-$HOME/.local/share}/dircolors-solarized/${DIRCOLORS_THEME:-dircolors.ansi-light}"
    if [ -f "$_dircolors_file" ]; then
        eval "$(dircolors -b "$_dircolors_file")"
    fi
    unset _dircolors_file
fi
