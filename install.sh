#!/usr/bin/env bash
# dotfiles を $HOME にシンボリックリンクで配置する。
#
#   ./install.sh            実際に配置する
#   ./install.sh --dry-run  何をするかだけ表示する
#
# 既存のファイル／リンクはタイムスタンプ付きで退避する。
# bashrc.d/*.example はマシン固有設定のテンプレートなので、
# リンクではなくコピーし、既存のコピー先があればそのまま残す。
# ls のカラー定義は外部リポジトリ (dircolors-solarized) をクローンして使う。

set -euo pipefail

DOTFILES_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
BACKUP_SUFFIX="$(date +%Y%m%d%H%M%S)"
DRY_RUN=0

DIRCOLORS_REPO="https://github.com/seebi/dircolors-solarized.git"
DIRCOLORS_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/dircolors-solarized"

usage() {
    cat <<'EOF'
usage: install.sh [-n|--dry-run] [-h|--help]

  -n, --dry-run   ファイルを変更せず、実行内容だけ表示する
  -h, --help      このヘルプを表示する
EOF
}

log() {
    printf '%s\n' "$*"
}

# DRY_RUN のときは実行せず内容を表示するだけ
run() {
    if [ "$DRY_RUN" -eq 1 ]; then
        printf '          (dry-run) %s\n' "$*"
    else
        "$@"
    fi
}

link_file() {
    local src="$1"
    local dst="$2"

    if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
        log "  ok      $dst"
    else
        if [ -e "$dst" ] || [ -L "$dst" ]; then
            log "  backup  $dst -> $(basename "$dst").$BACKUP_SUFFIX"
            run mv -- "$dst" "$dst.$BACKUP_SUFFIX"
        fi
        log "  link    $dst"
        run ln -s -- "$src" "$dst"
    fi
}

copy_example() {
    local src="$1"
    local dst="$2"

    if [ -e "$dst" ]; then
        log "  keep    $dst (既存のローカル設定を維持)"
    else
        log "  copy    $dst  ※中身を自分の環境に合わせて編集する"
        run cp -- "$src" "$dst"
    fi
}

# リンク先が消えた（リポジトリ側でリネーム・削除された）シンボリックリンクを掃除する
prune_stale_links() {
    local dir="$1"
    local link

    for link in "$dir"/*; do
        if [ -L "$link" ] && [ ! -e "$link" ]; then
            case "$(readlink "$link")" in
                "$DOTFILES_DIR"/*)
                    log "  prune   $link (リンク先が存在しない)"
                    run rm -- "$link"
                    ;;
            esac
        fi
    done
}

install_bashrc_d() {
    local dst_dir="$HOME/.bashrc.d"
    local src
    local base

    if [ ! -d "$dst_dir" ]; then
        log "  mkdir   $dst_dir"
        run mkdir -p -- "$dst_dir"
    fi

    if [ -d "$dst_dir" ]; then
        prune_stale_links "$dst_dir"
    fi

    for src in "$DOTFILES_DIR"/bashrc.d/*; do
        base="$(basename "$src")"
        case "$base" in
            *.example)
                copy_example "$src" "$dst_dir/${base%.example}"
                ;;
            *)
                link_file "$src" "$dst_dir/$base"
                ;;
        esac
    done
}

# ls のカラー定義（40-dircolors.sh が参照する）を upstream から取得する。
# 取得できなくても他の設定は使えるので、失敗しても処理は続ける。
install_dircolors() {
    if [ -d "$DIRCOLORS_DIR/.git" ]; then
        # 別のリポジトリに差し替わっていた場合に pull しないよう remote を確認する
        if [ "$(git -C "$DIRCOLORS_DIR" remote get-url origin 2>/dev/null)" != "$DIRCOLORS_REPO" ]; then
            log "  warn    $DIRCOLORS_DIR の origin が $DIRCOLORS_REPO ではない。更新をスキップする"
        elif ! run git -C "$DIRCOLORS_DIR" pull --ff-only --quiet; then
            log "  update  $DIRCOLORS_DIR"
            log "  warn    dircolors-solarized の更新に失敗した（既存のものを使う）"
        else
            log "  update  $DIRCOLORS_DIR"
        fi
    else
        log "  clone   $DIRCOLORS_DIR"
        run mkdir -p -- "$(dirname -- "$DIRCOLORS_DIR")"
        if ! run git clone --depth 1 --quiet "$DIRCOLORS_REPO" "$DIRCOLORS_DIR"; then
            log "  warn    dircolors-solarized の取得に失敗した（ls の色設定はスキップされる）"
        fi
    fi
}

main() {
    log "dotfiles: $DOTFILES_DIR"
    log "target:   $HOME"
    log ""

    link_file "$DOTFILES_DIR/bashrc" "$HOME/.bashrc"
    link_file "$DOTFILES_DIR/bash_profile" "$HOME/.bash_profile"
    install_bashrc_d
    install_dircolors

    log ""
    if [ "$DRY_RUN" -eq 1 ]; then
        log "dry-run のため何も変更していない。"
    else
        log "完了。新しいシェルを開くか 'exec bash -l' で反映される。"
    fi
}

while [ $# -gt 0 ]; do
    case "$1" in
        -n|--dry-run)
            DRY_RUN=1
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            printf 'unknown option: %s\n' "$1" >&2
            usage >&2
            exit 1
            ;;
    esac
    shift
done

main
