# dotfiles

## 概要

個人の開発環境の設定ファイルを管理するリポジトリです。

セットアップは必要なフォルダのシンボリックリンクを個別に貼る方式を採用しています。
現状の規模ではインストールスクリプトを用意するほどでもないため、環境ごとに必要なものだけを選んでリンクできる柔軟さを優先しています。

## シンボリックリンク

### zsh

[zsh/README.md](zsh/README.md) を参照してください。

### ghostty

```bash
ln -s ~/dotfiles/ghostty/config ~/Library/Application\ Support/com.mitchellh.ghostty/config
```

### vscode

```bash
ln -s ~/dotfiles/vscode/settings.json ~/Library/Application\ Support/Code/User/settings.json
```

### nvim

```bash
ln -s ~/dotfiles/nvim ~/.config/nvim
```
