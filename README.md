# dotfiles

bash の設定を `~/.bashrc.d/` に分割して管理するための dotfiles。
macOS（ローカルマシン）と Linux サーバーの両方で同じリポジトリを使えるようにしてある。

## インストール

```sh
git clone https://github.com/kuniga/dotfiles.git ~/work/dev/dotfiles
cd ~/work/dev/dotfiles
./install.sh --dry-run   # 何が起きるか確認
./install.sh
exec bash -l
```

`install.sh` の挙動:

- `bashrc` → `~/.bashrc`、`bash_profile` → `~/.bash_profile` をシンボリックリンク
- `bashrc.d/*` を `~/.bashrc.d/` にシンボリックリンク
- `bashrc.d/*.example` は拡張子を外した名前で**コピー**（既存ファイルがあれば維持）
- 既存の実ファイルはタイムスタンプ付き（`~/.bashrc.20260801120000` 等）で退避
- リポジトリ側で削除・リネームされたファイルへの壊れたリンクは掃除
- [seebi/dircolors-solarized](https://github.com/seebi/dircolors-solarized) を
  `~/.local/share/dircolors-solarized` にクローン（2 回目以降は `git pull`）

冪等なので、リポジトリを更新したあと何度でも実行してよい。

シンボリックリンクは `install.sh` を実行した場所を指す。git worktree の中から実行すると
worktree を消したときにシェル設定が壊れるので、必ず本体のチェックアウトから実行する。

### 既に ~/.bashrc.d/ を手で作っていた場合

`install.sh` はリポジトリにあるファイルだけを管理し、リポジトリに無い実ファイルは
触らない（壊れたシンボリックリンクの掃除のみ行う）。
そのため、リポジトリ側で名前が変わった・削除されたファイルは手で消す必要がある。

```sh
rm ~/.bashrc.d/20-bash-completion.sh   # 20-completion.sh に統合
rm ~/.bashrc.d/21-mise-completion.sh   # 同上
rm ~/.bashrc.d/dircolors.ansi-light    # dircolors-solarized のクローンを使う
```

## 構成

`~/.bashrc` が `~/.bashrc.d/*.sh` を名前順に読み込む。番号は読み込み順の依存関係を表す。

| ファイル | 内容 |
|---|---|
| `00-path-helpers.sh` | `_prepend_path` / `_append_path`（存在チェック + 重複チェック付き） |
| `01-set-variables.sh` | PATH, EDITOR, LANG, HIST* などの基本的な環境変数 |
| `02-set-variables.sh` | **マシン固有**（`.example` からコピー。lima / kubeconfig / 1Password） |
| `11-brew.sh` | `brew shellenv` — 以降で `$HOMEBREW_PREFIX` が使えるようになる |
| `12-mise-activate.sh` | `mise activate` — shim を PATH に追加 |
| `13-lmstudio.sh` | LM Studio CLI の PATH（ディレクトリがあるときだけ） |
| `20-completion.sh` | bash-completion@2 本体 + gh / op / mise の補完 |
| `30-prompt.sh` | `PROMPT_COMMAND` / git-prompt |
| `40-dircolors.sh` | dircolors-solarized のテーマを適用（既定 `dircolors.ansi-light`） |
| `41-git.sh` | `GIT_COMPLETION_SHOW_ALL_COMMANDS` |
| `50-keychain.sh` | ssh keychain（macOS のみ） |
| `60-alias.sh` | macOS 専用のエイリアスと関数 |
| `61-copilot.sh` | copilot CLI のエイリアス |
| `62-gemini.sh` | **マシン固有**（`.example` からコピー。Gemini CLI / Vertex AI） |
| `99-cleanup.sh` | `00-path-helpers.sh` のヘルパを `unset -f` する |

依存関係で特に注意する点:

- `00-path-helpers.sh` が最初に PATH 操作のヘルパを定義し、`01` / `11` / `13` が使い、
  `99-cleanup.sh` が片付ける
- `01-set-variables.sh` が Homebrew（`/opt/homebrew/bin`、Linuxbrew の 2 箇所）と
  `~/.local/bin` を PATH に入れるので、それ以降で `brew` / `mise` が `command -v` で見つかる
- `11-brew.sh` が `$HOMEBREW_PREFIX` を決めるので、それを使う `20`, `30` より前に読む
- 補完は `20-completion.sh` に集約してある。gh / op（旧 API）と mise（2.12 以降の新 API）は
  どれも bash-completion 本体の関数に依存するので、本体 → 各ツールの順序を
  ファイル内で固定している。ファイルを分けて番号で順序を表すより壊れにくい
- mise は PATH への shim 追加（`12-mise-activate.sh`）と補完（`20-completion.sh`）で
  別ファイルになっている。activate は補完より前に済ませたいため

デバッグ用に `BASHRC_D_VERBOSE=1` を設定すると、読み込んだファイル名が表示される。

## 外部リポジトリ

`ls` のカラー定義はリポジトリに同梱せず、install.sh が
[seebi/dircolors-solarized](https://github.com/seebi/dircolors-solarized) を
`${XDG_DATA_HOME:-$HOME/.local/share}/dircolors-solarized` に浅いクローンで取得する。

使うテーマは `DIRCOLORS_THEME` で切り替える（既定は `dircolors.ansi-light`）。
マシンごとに変えたいので `02-set-variables.sh` に書くとよい。

```sh
DIRCOLORS_THEME=dircolors.ansi-dark
```

## マシン固有・組織固有の設定

このリポジトリは public なので、メールアドレスや GCP プロジェクト名などは含めない。
該当するファイルは `*.example` をテンプレートとして置き、実ファイルは `.gitignore` してある。

- `bashrc.d/02-set-variables.sh.example`
- `bashrc.d/62-gemini.sh.example`

`install.sh` が実ファイルとしてコピーするので、初回インストール後に中身を編集する。
2 回目以降の `install.sh` はコピー済みのファイルを上書きしない。

## Linux サーバーへの展開

- ホスト名の表示を分かりやすくしたい場合は `~/.host_label` を置く
  （例: `echo "batch-stg" > ~/.host_label`）。なければ `hostname -s` を使う。
  プロンプト毎に評価される文字列に入るので、英数と `.` `_` `-` 以外は捨てられる
- `50-keychain.sh` / `60-alias.sh` は `uname` が Darwin でなければ
  何もしないので、そのまま置いてよい
- git-prompt は macOS の `$HOMEBREW_PREFIX/etc/bash_completion.d/git-prompt.sh` と
  Linux の `/etc/bash_completion.d/git-prompt` の両方を探す（`30-prompt.sh`）
- bash-completion 本体も brew 版・`/usr/share/bash-completion/bash_completion`・
  `/etc/profile.d/bash_completion.sh` の順に探す（`20-completion.sh`）。
  bash 4.2 以降なら読み込むので、古い Linux サーバーでも効く
- Linuxbrew を使っている場合は `/home/linuxbrew/.linuxbrew/bin` か `~/.linuxbrew/bin` が
  自動で PATH に入る（存在するときだけ）

## 書き方の方針

- **早期 `return` を使わない。** ガード節ではなく `if` ブロックでネストさせる。
  ネストが深くなってもよい。`~/.bashrc.d/` のファイルは source されるため、
  `return`（source されたファイルの中断）と `exit`（シェルの終了）を
  読むたびに区別しなければならず、そのコストを避けたい
- **コマンドの存在チェックは `command -v foo > /dev/null 2>&1` に統一する。**
  `type` や `which` は使わない。`command -v` は POSIX で出力形式まで規定されており、
  bash 以外のシェルでも同じ挙動になる
- 外部コマンドやファイルに依存する処理は `command -v` / `[ -d ... ]` / `[ -r ... ]` で
  存在確認してから使う。どのマシンでもエラーを出さずに読み込めることを優先する
