# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# User specific environment and startup programs
# 読み込み順はファイル名の数値プレフィックスで決まる（詳細は dotfiles の README.md 参照）
# BASHRC_D_VERBOSE=1 を設定すると読み込んだファイル名を表示する
if [ -d "$HOME"/.bashrc.d ]; then
    for f in "$HOME"/.bashrc.d/*.sh; do
        if [ -r "$f" ]; then
            if [ -n "${BASHRC_D_VERBOSE:-}" ]; then
                echo "loading $(basename "$f")"
            fi
            . "$f"
        fi
    done
    unset f
fi
