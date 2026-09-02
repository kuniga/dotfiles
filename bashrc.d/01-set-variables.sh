# _prepend_path は 00-path-helpers.sh で定義している（存在チェック + 重複チェック付き）
_prepend_path "$HOME/bin"
_prepend_path "$HOME/.local/bin"
# Homebrew: macOS (Apple Silicon) と Linuxbrew の両方を見る。
# brew が PATH に入って初めて 11-brew.sh の shellenv が走る
_prepend_path /opt/homebrew/bin
_prepend_path /home/linuxbrew/.linuxbrew/bin
_prepend_path "$HOME/.linuxbrew/bin"
export PATH

EDITOR="vim"
export EDITOR

GPG_TTY=$(tty)
export GPG_TTY

# -R: カラーのエスケープシーケンスをそのまま解釈させる
# -F: 出力が 1 画面に収まるならページャを起動せず、cat のように表示して終了する
#     （less 530 より古い環境では -F だけだと短い出力が消えるので -X も足す）
LESS="-R -F"
export LESS

LESSCHARSET="utf-8"
export LESSCHARSET

MANWIDTH="108"
export MANWIDTH

PIPENV_VENV_IN_PROJECT=t
export PIPENV_VENV_IN_PROJECT

# LANG=en_US.UTF-8
if locale -a 2>/dev/null | grep -qix 'ja_JP\.utf-\?8'; then
    LANG=ja_JP.UTF-8
    export LANG
fi

HISTCONTROL=ignoreboth
HISTFILESIZE=65536
HISTSIZE=65536
HISTTIMEFORMAT="%F %T "
