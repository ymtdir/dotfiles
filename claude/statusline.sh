#!/usr/bin/env bash
# statusline.sh — Claude Code ステータスライン
#
# コンテキストウィンドウの使用率を可視化する。

set -euo pipefail

input=$(cat)

# jq が無い環境向けのフォールバック
if ! command -v jq >/dev/null 2>&1; then
  echo "(jq 未インストールのためステータスライン簡易表示)"
  exit 0
fi

# 1 回の jq 呼び出しでまとめて取り出し、欠落フィールドは // で既定値に落とす。
IFS=$'\t' read -r MODEL PCT HAS_USAGE < <(
  printf '%s' "$input" | jq -r '
    .context_window as $cw
    | $cw.current_usage as $u
    | [
        (.model.display_name // "Claude"),
        (($cw.used_percentage // 0) | floor),
        (if $u == null then 0 else 1 end)
      ] | @tsv
  '
)

MODEL=${MODEL:-Claude}
PCT=${PCT:-0}
HAS_USAGE=${HAS_USAGE:-0}

GREEN=$'\033[32m'; YELLOW=$'\033[33m'; RED=$'\033[31m'
ORANGE=$'\033[38;5;208m'; RESET=$'\033[0m'
SEP=" "

if [ "$HAS_USAGE" = "1" ]; then
  [ "$PCT" -gt 100 ] && PCT=100

  if   [ "$PCT" -ge 90 ]; then BAR_COLOR=$RED
  elif [ "$PCT" -ge 70 ]; then BAR_COLOR=$YELLOW
  else                         BAR_COLOR=$GREEN
  fi

  BAR_WIDTH=10
  FILLED=$((PCT * BAR_WIDTH / 100))
  EMPTY=$((BAR_WIDTH - FILLED))
  BAR=""
  [ "$FILLED" -gt 0 ] && { printf -v F "%${FILLED}s"; BAR="${F// /█}"; }
  [ "$EMPTY"  -gt 0 ] && { printf -v E "%${EMPTY}s";  BAR="${BAR}${E// /░}"; }
  GAUGE="${BAR_COLOR}${BAR} ${PCT}%${RESET}"
else
  GAUGE="${DIM}コンテキスト計測待ち${RESET}"
fi

LINE1="${ORANGE}${MODEL}${RESET}${SEP}${GAUGE}"
printf '%s\n' "$LINE1"

