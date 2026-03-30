#!/bin/bash

# setup plugin
sudo apt-get install -y nodejs npm
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
git config --global core.editor vim

# paste bellow ~/.vimrc
# 
# let mapleader = "\<space>"
# "
# " 以降、Pluginのための記述
# "
# call plug#begin('~/.vim/plugged')

# " ステータスラインをかっこよくします
# Plug 'itchyny/lightline.vim'

# " coc
# Plug 'neoclide/coc.nvim', {'branch': 'release'}

# Plug 'kqito/vim-easy-replace'

# call plug#end()

# " Spaceを押した後にrを押すと :%s/// が自動で入力される
# nnoremap <Leader>r :%s///g<Left><Left><Left>

# vim +PlugInstall
# vim +PlugInstall +qall

# for markdown
# Vimは標準ではMarkdown形式のシンタックスハイライトを提供していません。 以下のURLからmkd.vimを取得し、~/.vim/syntax/以下に配置しましょう。
# mkd.vim http://www.vim.org/scripts/script.php?script_id=1242

# 次に、拡張子.mkdまたは.mdファイルをMarkdownに関連づけます。 ~/.vim/ftdetect/mkd.vimというファイルを作り、以下の二行を記述します。

# autocmd BufRead,BufNewFile .mkd setfiletype mkd
# autocmd BufRead,BufNewFile .md setfiletype mkd

readonly src_vim_dir_path="${HOME}/Desktop/share/setting/vim"
readonly src_ftdetecth_dir_path="${src_vim_dir_path}/ftdetect"
readonly src_syntax_dir_path="${src_vim_dir_path}/syntax"
readonly vim_dir_path="${HOME}/.vim"
readonly ftdetect_dir_path="${vim_dir_path}/ftdetect"
readonly syntax_dir_path="${vim_dir_path}/syntax"

mkdir -p "${vim_dir_path}"
mkdir -p "${ftdetect_dir_path}"
mkdir -p "${syntax_dir_path}"
ln -s "${src_ftdetecth_dir_path}" "${ftdetect_dir_path}" 
ln -s "${src_syntax_dir_path}" "${syntax_dir_path}" 
