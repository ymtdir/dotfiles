---
name: resolve-issue
description: Resolve a GitHub Issue by creating a branch and making atomic commits. Use when told "resolve Issue #42", "do Issue 42", etc. Analyzes the Issue, asks clarifying questions if ambiguous, then creates a branch, commits per task, and runs quality checks. Stops before push.
argument-hint: '#<Issue番号>'
---

# Issue解決スキル

GitHub Issueを読み取り、専用ブランチ上で解決する。コミットはローカルのチェックポイントとして作業単位ごとに作り、push・PR作成は行わない。

## 入力仕様

- **Issue番号**: 必須。引数またはユーザーの発話から `#\d+` または数字で取得する。取得できない場合はユーザーに尋ねる。

## 手順

### ステップ1: Issueの分析

`gh issue view [番号]` で本文を読む。本文だけで判断できない場合のみ `--comments` でコメントも読む。

読んだ上で、**実装方針が一意に決まるか**を確認する。以下のような曖昧さが残る場合は、着手前にユーザーに問い直す:

- 期待される動作が複数解釈できる
- 影響範囲（どのファイル・機能まで手を入れてよいか）が不明
- Issueに書かれていない設計判断が必要

問い直しの流儀:

- **1問ずつ**聞き、回答を待ってから次へ進む。まとめて並べない
- 各質問には**自分の推奨回答を添える**
- コードやリポジトリを調べれば分かる**事実は自分で調べる**。ユーザーに聞くのは**判断**だけ
- 方針が一意に決まるまで続ける。決まったら打ち切って着手する

方針が最初から明確なら質問せず進む。

### ステップ2: ブランチの作成

ブランチ名は `<type>/<説明>` 形式。

- `<type>`: バグ修正は `fix/`、新規機能は `feature/`、その他は `refactor/` / `docs/` / `chore/` など
- `<説明>`: kebab-case で2〜4語（例: `empty-email`、`mau-chart`）

同名ブランチを確認してから作成する:

```bash
git branch --list "<type>/<説明>"   # 既存なら中断し、再利用か別名かをユーザーに確認
git checkout -b <type>/<説明>
```

### ステップ3: 作業単位での解決

**各タスク完了ごとにすぐコミットする。** コミット規約は [references/commit-conventions.md](references/commit-conventions.md) に従う。

コミットはローカルのチェックポイントであり、push しない限り `rebase` / `amend` で修正できる。承認を求めず淡々と刻む。

### ステップ4: 品質チェック

プロジェクトの構成ファイルからチェックコマンドを検出し、存在するもののみ実行する（テスト → リント → 型チェックの順）:

| 構成ファイル | 実行するもの |
|--------------|--------------|
| `package.json` | `scripts` にある `test` / `lint` / `typecheck`（パッケージマネージャは lockfile から判定: `npm` / `pnpm` / `yarn`） |
| `pyproject.toml` | `pytest` / `ruff check`（設定があるもののみ） |
| `Cargo.toml` | `cargo test` / `cargo clippy` |
| `go.mod` | `go test ./...` / `go vet ./...` |
| `Makefile` | `test` / `lint` ターゲット（上記より優先） |

どれにも該当しない場合はチェックをスキップし、その旨を報告する。

失敗した場合は原因を修正して再実行する。修正しても失敗が続く場合はユーザーに詳細を提示し、修正方針の承認を待つ。

## 責任範囲

このスキルは**品質チェックまで**。`git push` やPR作成は含まず、PRは `create-pr` スキルに委譲する。未確認のコードがリポジトリ外に出ることはない。

## 出力仕様

完了後、簡潔に報告する:

- **成功**: `Issue #[番号] を解決しました。ブランチ: <type>/[説明] / コミット [n]件 / チェック OK。git log -p で各コミットを確認できます。PRは create-pr で作成できます。`
- **チェック失敗**: 失敗したチェック（test / lint / typecheck）と要点を伝え、修正方針の承認を待つ。
