for _gp in \
    "${HOMEBREW_PREFIX:-/opt/homebrew}/etc/bash_completion.d/git-prompt.sh" \
    /etc/bash_completion.d/git-prompt; do
    if ! declare -f __git_ps1 > /dev/null 2>&1; then
        if [ -f "$_gp" ]; then
            . "$_gp"
        fi
    fi
done
unset _gp

GIT_PS1_SHOWDIRTYSTATE=1
GIT_PS1_SHOWSTASHSTATE=1
GIT_PS1_SHOWUNTRACKEDFILES=1
GIT_PS1_SHOWUPSTREAM=auto

# ~/.host_label があればホスト名の代わりに表示する（リモートサーバーの識別用）。
# 1 行目だけを読み、英数と . _ - 以外は捨てる。
# 下で作る文字列は PROMPT_COMMAND / PS1 としてプロンプト毎に評価されるため、
# $( ) やバッククォートが混ざるとその都度実行されてしまう。
# ファイルが無ければ hostname、あって使える文字が残らなければ unknown を使う
if [ -r "$HOME/.host_label" ]; then
    IFS= read -r _hn < "$HOME/.host_label"
else
    _hn=$(hostname -s)
fi
_hn=${_hn//[^A-Za-z0-9._-]/}
_hn=${_hn:-unknown}

if declare -f __git_ps1 > /dev/null 2>&1; then
    _gp_cmd="__git_ps1 \"\[\e[32m\]\u@${_hn}\[\e[0m\] \[\e[34m\]\w\[\e[0m\]\" \" \[\e[2m\]\D{%m/%d %H:%M}\[\e[0m\]\n\$ \" \" \[\e[35m\](%s)\[\e[0m\]\""
    PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND; }$_gp_cmd"
    unset _gp_cmd
else
    PS1="\[\e[32m\]\u@${_hn}\[\e[0m\] \[\e[34m\]\w\[\e[0m\] \[\e[2m\]\D{%m/%d %H:%M}\[\e[0m\]\n\$ "
fi
unset _hn
