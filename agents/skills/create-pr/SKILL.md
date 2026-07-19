---
name: create-pr
description: Create a draft Pull Request from changes on the current branch. Use when asked to "create a PR", "open a pull request", or "submit changes for review". Detects the base branch, drafts a title and body, confirms with the user, then creates it as a draft.
---

# Pull Request作成スキル

現在のブランチの変更を分析してGitHub Pull Requestを作成する。ドラフトを提示し、ユーザーの承認を得てから作成する。PRは常にDraftとして作成する。

## 入力仕様

- 引数なし。現在のブランチを対象に処理する。

## PR作成プロセス

### ステップ1: 事前チェック

```bash
git branch --show-current
git status --short
git remote show origin | grep "HEAD branch"   # baseブランチの検出
gh pr view --json number,url 2>/dev/null      # 既存PRの確認
```

以下に該当する場合は先に解消する:

| 状態 | 対応 |
|------|------|
| baseブランチ（main / master 等）上にいる | 中断し、フィーチャーブランチの作成を促す |
| 未コミットの変更がある | PRに含めてコミットするか、除外（stash）するかをユーザーに聞く |
| このブランチのPRが既に存在する | 中断し、既存PRのURLを提示して更新かどうかを確認する |

baseブランチは検出結果を使う（`main` 決め打ちにしない）。以降 `<base>` と表記する。

### ステップ2: ブランチ情報の収集

```bash
git diff --stat origin/<base>...HEAD
git log origin/<base>..HEAD --oneline
git diff --name-only origin/<base>...HEAD
```

`origin/<base>` との差分がない場合は中断し、ユーザーに知らせる。

関連Issueがあれば番号を検出する: コミットメッセージの `#\d+`。見つからなければ関連Issueなしとして扱う（ステップ4のドラフト確認時にユーザーが追記してもよい）。

### ステップ3: ドラフトの作成

[references/templates.md](references/templates.md) のテンプレートのプレースホルダー（`[...]`）を実際の値に置き換えて、PRタイトルと本文のドラフトを作成する。

- タイトルはコミットプレフィックス付きの50文字以内の1行。プレフィックスはブランチのコミット履歴から支配的なもの（`fix:` / `feat:` など）を選ぶ。
- 概要には「なぜ」を必ず書く。バグ修正なら原因も書く。
- 実施していない動作確認・存在しない関連Issueは、セクションごと削除する。

### ステップ4: ユーザー確認

作成したドラフトをそのまま提示し、ユーザーの承認を待つ。修正依頼があれば反映して再提示する。承認が得られるまでプッシュ・PR作成は行わない。

### ステップ5: プッシュとPRの作成

`gh auth status` が未認証の場合は `gh auth login` を促して終了する。

認証済みの場合、ブランチをプッシュしてDraft PRを作成する:

```bash
git push -u origin HEAD

gh pr create \
  --draft \
  --base <base> \
  --title "<PRタイトル>" \
  --body "$(cat <<'EOF'
<承認されたPR本文>
EOF
)"
```

`--draft` は必須。ユーザーが明示的に指示した場合を除き、Ready for reviewでは作成しない。
ラベルはユーザーが明示的に指定した場合のみ `--label` を追加する（既定はラベルなし）。

失敗時の対応:

| エラー | 対応 |
|--------|------|
| push が拒否される（non-fast-forward 等） | 状況を報告し、無断で `--force` しない |
| base とのコンフリクトが報告される | 中断し、`git merge origin/<base>` での解消をユーザーに提案する |

## 出力仕様

`gh pr create` の出力URLを1行で報告する:

```
Draft PR #[番号] を作成しました: [GitHub PR URL]
```

レビューは `/code-review --comment [番号]` で実行できる。
