# bash の補完設定をまとめる。
# gh / op は bash-completion の旧 API（_init_completion, _get_comp_words_by_ref,
# _filedir）、mise は 2.12 以降の新 API（_comp_initialize, _comp_compgen,
# _comp_ltrim_colon_completions）に依存する。いずれもフレームワーク本体が先に
# 読まれている必要があるため、本体と各ツールの補完を同じファイルに置いて順序を固定する。

# bash-completion 2.x は bash 4.2 以降が必要。
# 候補を順に試し、読み込めた時点で BASH_COMPLETION_VERSINFO が立つので以降はスキップされる。
# macOS の brew 版ラッパは PS1 が空（非対話シェル）だと何もしないため、
# その場合はどの候補でも読み込まれない（想定どおり）。
if [ "${BASH_VERSINFO[0]}" -gt 4 ] ||
    { [ "${BASH_VERSINFO[0]}" -eq 4 ] && [ "${BASH_VERSINFO[1]}" -ge 2 ]; }; then
    for _bc in \
        "${HOMEBREW_PREFIX:-/opt/homebrew}/etc/profile.d/bash_completion.sh" \
        /usr/share/bash-completion/bash_completion \
        /etc/profile.d/bash_completion.sh; do
        if [ -z "${BASH_COMPLETION_VERSINFO:-}" ] && [ -r "$_bc" ]; then
            . "$_bc"
        fi
    done
    unset _bc
fi

if command -v gh > /dev/null 2>&1; then
    eval "$(gh completion -s bash)"
fi

if command -v op > /dev/null 2>&1; then
    eval "$(op completion bash)"
fi

# mise 本体の PATH 追加は 12-mise-activate.sh で行い、補完はここで登録する
if command -v mise > /dev/null 2>&1; then
    eval "$(mise completion bash)"
fi
