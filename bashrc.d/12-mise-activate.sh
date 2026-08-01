# mise は 01-set-variables.sh が PATH に入れた ~/.local/bin から見つかる。
# brew などで入れた mise でも同じように拾える
if command -v mise > /dev/null 2>&1; then
    eval "$(mise activate bash)"
fi
