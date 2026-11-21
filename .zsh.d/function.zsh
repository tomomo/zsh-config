function dcc() {
  local env_type=$1
  local compose_file="compose.dev.yml"

  # 環境判定
  if [[ "$env_type" == "prod" ]]; then
    compose_file="compose.yml"
    shift
  elif [[ "$env_type" == "dev" ]]; then
    shift
  fi

  _run_compose() {
    docker compose -f "$compose_file" "$@"
  }

  _run_compose "$@"
  local ret=$?

  # エラー時かつ Docker デーモンが未起動の場合
  if [[ $ret -ne 0 ]] && ! docker info >/dev/null 2>&1; then
    echo -n "⚠️  Docker daemon が停止しています。起動しますか？ (y/N): "
    read -k 1 "answer"
    echo ""

    if [[ "$answer" =~ ^[Yy]$ ]]; then
      # 判定ロジック: $commands 配列を使用
      if (( $+commands[colima] )); then
        echo "🚀 Colima を起動中..."
        colima start
      elif [[ -d "/Applications/Docker.app" ]] || mdfind "kMDItemBundleIdentifier == 'com.docker.docker'" >/dev/null 2>&1; then
        echo "🚀 Docker Desktop を起動中..."
        docker desktop start
      else
        echo "❌ 起動できるツールが見つかりませんでした (colima or docker desktop)"
        return $ret
      fi

      echo "⏳ 接続確認中..."
      until docker info >/dev/null 2>&1; do sleep 1; done

      echo "✅ 準備完了。再実行します。"
      _run_compose "$@"
    fi
  fi
}

function pxcp() {
  if [ $# -lt 2 ]; then
    echo "Usage: pxcp <src> <dest>"
    return 1
  fi

  # 末尾スラッシュの処理
  local src="${1%/}/"
  local dest="${2%/}"

  # rsyncの魔法のオプション
  # --filter=':- .gitignore' : Gitが無視するものはコピーしない
  # -C : RCS(CVS等)の無視ルールを適用（.DS_Storeなどを賢く除外）
  rsync -av --progress \
    --filter=':- .gitignore' \
    -C \
    --exclude={'.git/','node_modules/','vendor/','.pnpm-store/','*.log'} \
    "$src" "$dest"
}
