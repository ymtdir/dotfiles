# dotfiles

このリポジトリは設定ファイル（dotfiles）を管理するためのものです。
以下のコマンドを実行することで、各設定ファイルへのショートカット（シンボリックリンク）を適切なディレクトリに配置します。

## nvim

```bash
ln -s ~/dotfiles/nvim ~/.config/nvim
```

## tmux

```bash
ln -s ~/dotfiles/tmux/.tmux.conf ~/.tmux.conf
```

## bin

```bash
ln -s ~/dotfiles/bin ~/bin
```

## ghostty

```bash
ln -s ~/dotfiles/ghostty/config ~/Library/Application\ Support/com.mitchellh.ghostty/config
```

## vscode

```bash
ln -s ~/dotfiles/vscode/settings.json ~/Library/Application\ Support/Code/User/settings.json
```
