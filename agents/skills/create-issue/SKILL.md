---
name: create-issue
description: Create a GitHub Issue from a free-form description. Use when told "create an issue", "file a bug", or "request a feature". Classifies as Bug/Feature/Task, interviews the user one question at a time until key details are clear, drafts a title and body from a template, confirms with the user, then creates it via gh api with issue types when available.
argument-hint: <Issue説明>
---

# Issue作成スキル

自由形式の説明からGitHub Issueを作成する。ドラフトを提示し、ユーザーの承認を得てから作成する。

## 入力仕様

- **Issue説明**: 必須。ユーザーの自由形式の入力をそのままIssue内容として扱う。

## Issue作成プロセス

### ステップ1: 分類とテンプレート選択

Issue説明の内容を判定し、[references/templates.md](references/templates.md) からテンプレートを選ぶ:

| 内容 | 種別 | テンプレート |
|------|------|--------------|
| エラー・不具合・意図しない動作 | Bug | Bug Report |
| 新機能・改善・追加要望 | Feature | Feature Request |
| 上記以外の作業・リファクタリング・更新など | Task | Task |

### ステップ2: 不明点の聞き直し

ドラフトを書く前に、選んだテンプレートの主要セクションをIssue説明と突き合わせ、埋められない箇所を特定する:

- **Bug**: 再現手順は分かるか。期待される動作と実際の動作は区別できるか
- **Feature**: 動機（なぜ必要か）は明らかか。完成の判断基準はあるか
- **Task**: 何をもって完了とするかは明らかか

埋められない主要セクションがあれば、ユーザーに問い直す:

- **1問ずつ**聞き、回答を待ってから次へ進む。まとめて並べない
- 各質問には**自分の推奨回答を添える**
- コードやリポジトリを調べれば分かる**事実は自分で調べる**。ユーザーに聞くのは**判断**だけ
- ユーザーが「分からない」「任せる」と答えた項目は、推測で埋めずセクションごと省略する
- 主要セクションが埋まったら打ち切ってドラフトに進む。説明だけで全部埋まるなら質問せずステップ3へ進む

### ステップ3: Issue Typeの確認

リポジトリ情報を取得し、利用可能なIssue Typeを調べる:

```bash
gh repo view --json nameWithOwner,owner --jq '{repo: .nameWithOwner, owner: .owner.login}'
gh api graphql -f query='{ organization(login: "<owner>") { issueTypes(first: 20) { nodes { name } } } }' \
  --jq '.data.organization.issueTypes.nodes[].name' 2>/dev/null
```

- Issue Typeが取得できた場合（org リポジトリ等）: ステップ1の種別に対応するtype（Bug / Feature / Task）を使う
- 取得できない・存在しない場合（個人リポジトリ等）: typeなしで作成する。ラベルでの代替はしない

### ステップ4: ドラフトの作成

テンプレートのプレースホルダー（`[...]`）を実際の値に置き換え、タイトルと本文のドラフトを作成する。

タイトルの指針:

- 具体的かつ実行可能に。72文字以内の1行
- Issue Typeを設定する場合、`[Bug]` のような冗長なプレフィックスは付けない
- 例: `Login fails with SSO enabled`（type=Bug）、`Add dark mode support`（type=Feature）

本文の指針:

- 情報がないセクション（ステップ2で「任せる」とされた項目を含む）は省略してよい。埋められない項目を推測で書かない
- 関連Issueが分かっていれば `Related to #123` を入れる

### ステップ5: ユーザー確認

ドラフト（タイトル・本文・type）をそのまま提示し、ユーザーの承認を待つ。修正依頼があれば反映して再提示する。承認が得られるまで作成コマンドは実行しない。

### ステップ6: GitHub Issueの作成

`gh auth status` が未認証の場合は `gh auth login` を促して終了する。

認証済みの場合、承認されたドラフトで作成する。Issue Typeは `gh issue create` が非対応のため `gh api` を使う:

```bash
gh api repos/{owner}/{repo}/issues \
  -X POST \
  -f title="<issueタイトル>" \
  -f type="<Bug|Feature|Task>" \
  -f body="$(cat <<'EOF'
<承認されたIssue本文>
EOF
)" \
  --jq '{number, html_url}'
```

Issue Typeが利用できないリポジトリでは `-f type=...` を外す。ラベル・アサイン・マイルストーンは付けない（ユーザーが明示的に指定した場合のみ `-f labels[]=...` / `-f assignees[]=...` / `-f milestone=...` を追加する）。

## 出力仕様

作成結果のURLを1行で報告する:

```
Issue #[番号] を作成しました: [GitHub Issue URL]
```
