# dotfiles

## 概要

個人の開発環境の設定ファイルを管理するリポジトリです。

セットアップは必要なフォルダのシンボリックリンクを個別に貼る方式を採用しています。
現状の規模ではインストールスクリプトを用意するほどでもないため、環境ごとに必要なものだけを選んでリンクできる柔軟さを優先しています。

## シンボリックリンク

### zsh

```bash
ln -s ~/dotfiles/zsh/.zshrc ~/.zshrc
```

### nvim

```bash
ln -s ~/dotfiles/nvim ~/.config/nvim
```

### tmux

```bash
ln -s ~/dotfiles/tmux/.tmux.conf ~/.tmux.conf
```

### bin

```bash
ln -s ~/dotfiles/bin ~/bin
```

### ghostty

```bash
ln -s ~/dotfiles/ghostty/config ~/Library/Application\ Support/com.mitchellh.ghostty/config
```

### vscode

```bash
ln -s ~/dotfiles/vscode/settings.json ~/Library/Application\ Support/Code/User/settings.json
```

### claude

```bash
ln -s ~/dotfiles/claude/settings.json ~/.claude/settings.json
ln -s ~/dotfiles/claude/statusline.sh ~/.claude/statusline.sh
ln -s ~/dotfiles/claude/agents ~/.claude/agents
ln -s ~/dotfiles/claude/commands ~/.claude/commands
ln -s ~/dotfiles/claude/skills ~/.claude/skills
```
