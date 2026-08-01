# 00-path-helpers.sh で定義したヘルパを片付ける。
# 読み込みの最後になるよう、番号は 99 にしてある。
unset -f _prepend_path _append_path
