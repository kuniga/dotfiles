# Only for local machine (macOS)
if [ "$(uname)" = "Darwin" ]; then
    if command -v keychain > /dev/null 2>&1; then
        _kc_init() {
          local lockdir="${TMPDIR:-/tmp}/keychain-${USER}.lock"
          local askpass="$HOME/.local/bin/ssh-askpass-osx"
          local locked=0
          local i

          # シェルが異常終了して残ったロックを回収する。
          # 5 分より古いものは持ち主がいないと判断してよい
          if [ -d "$lockdir" ]; then
              find "$lockdir" -maxdepth 0 -mmin +5 -exec rmdir {} + 2>/dev/null
          fi

          # 排他ロック取得（最大 2 分待機）。mkdir は原子的なので競合しない。
          # 目的は、複数のターミナルを同時に開いたときにパスフレーズ入力の
          # ダイアログが何枚も出るのを防ぐこと
          for (( i = 0; i < 600; i++ )); do
            if mkdir "$lockdir" 2>/dev/null; then
              locked=1
              break
            fi
            sleep 0.2
          done

          # macOS GUI ダイアログでパスフレーズ入力（どのターミナルからでも見える）
          # DISPLAY のダミー値が必要: 未設定だと keychain が SSH_ASKPASS を unset する
          # export で先に設定しないと $(keychain ...) のサブプロセスに渡らない
          # askpass が無いマシンでは設定しない（force のまま欠落すると認証が失敗する）
          if [ -x "$askpass" ]; then
            export DISPLAY=:0
            export SSH_ASKPASS="$askpass"
            export SSH_ASKPASS_REQUIRE=force
          fi

          # ロックが取れなかった場合もここに来る。先行シェルが鍵を登録済みなら
          # keychain は何も聞かずに終わる
          eval "$(keychain --eval --quiet id_rsa id_ed25519)"
          unset DISPLAY SSH_ASKPASS SSH_ASKPASS_REQUIRE

          # 自分が取ったロックだけを外す（他プロセスのロックを消さない）
          if [ "$locked" = 1 ]; then
            rmdir "$lockdir" 2>/dev/null
          fi
        }

        _kc_init
        unset -f _kc_init
    fi
fi
