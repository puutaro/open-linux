
set tabstop=4       " タブの幅を4に設定
set shiftwidth=4    " 自動インデントの幅を4に設定
set expandtab       " タブをスペースに展開する (インデントをスペースで行う)
set noexpandtab     "タブをスペースに展開しない設定 (タブ文字を使う)
set encoding=utf-8
set fileencodings=iso-2022-jp,euc-jp,sjis,utf-8
set fileformats=unix,dos,mac

"タブをスペースではなくタブ文字で表示したい場合は、set
"noexpandtabを使用してください
""タブをスペースで表示したい場合は、set expandtabを使用してください

" タブバーの設定
" set showtabline=1   " タブバーを表示 (0: 表示しない, 1: 常に表示, 2:
" 複数のタブがある時のみ表示)
"
" " 新しいタブを開く
" nnoremap <C-t> :tabnew<CR>
"
" " 次のタブへ移動
" nnoremap <C-n> :tabnext<CR>
"
" " 前のタブへ移動
" nnoremap <C-p> :tabprev<CR>
"
" " カレントバッファを新しいタブで開く
" nnoremap <C-s> :tabedit <C-r>=expand("%:p")<CR><CR>
"
" " タブを閉じる
" nnoremap <C-w> :tabclose<CR>

function! ImInActivate()
  call system('fcitx5-remote -c')
endfunction
inoremap <silent> <C-[> <ESC>:call ImInActivate()<CR>

set clipboard=unnamedplus

"
" 通常のオプション
"

" lightlime利用のためにステータスラインを2行にする
set laststatus=2

" ビープ音を消します
set belloff=all

" コメントを灰色へ変更
hi Comment ctermfg=gray

let mapleader = "\<space>"

"
" 以降、Pluginのための記述
"
call plug#begin('~/.vim/plugged')

" ステータスラインをかっこよくします
Plug 'itchyny/lightline.vim'

" coc
Plug 'neoclide/coc.nvim', {'branch': 'release'}

Plug 'kqito/vim-easy-replace'

Plug 'obcat/vim-hitspop'

Plug 'tpope/vim-surround'

Plug 'dominikduda/vim_current_word'

Plug 'ntpeters/vim-better-whitespace'

Plug 'obcat/vim-sclow'

Plug 'luochen1990/rainbow'

Plug 'rhysd/vim-operator-surround'

Plug 'kana/vim-operator-user'


call plug#end()


" for ntpeters/vim-better-whitespace
let g:vim_current_word#highlight_current_word = 0
let g:vim_current_word#highlight_delay = 500


" for nobcat/vim-sclow
let g:sclow_block_buftypes = ['terminal', 'prompt']
let g:sclow_hide_full_length = 1
let g:sclow_sbar_text = '┃'

" for luochen1990/rainbow
let g:rainbow_conf = {
      \'guifgs': ['orange', 'magenta', 'cyan'],
      \'ctermfgs': ['yellow', 'magenta', 'cyan'],
      \'guis': ['bold'],'cterms': ['bold']
      \}
" リネーム関数呼び出し
" vim上で「スペースキー + n」でリネーム処理が行えるようにする。
map <leader>n :call RenameCurrentFile()<cr>

" リネーム関数定義
function! RenameCurrentFile()
  let old = expand('%')
  let new = input('新規ファイル名: ', old , 'file')
  if new != '' && new != old
    exec ':saveas ' . new
    exec ':silent !rm ' . old
    redraw!
  endif
endfunction

" この行はお使いの.vimrcにまだ書いていないのなら、これを追加してください

" Spaceを押した後にrを押すと :%s/// が自動で入力される
nnoremap <Leader>r :%s///g<Left><Left><Left>
nnoremap <Leader><CR> a<CR><Esc>
nnoremap <S-CR> J
nnoremap <Leader>n A<CR><Esc>
nnoremap <Leader>a ggVG
nnoremap <Leader>y yiw
nnoremap <Leader>p viwpyiw
nnoremap <Leader>s" ciw""<Esc>P
nnoremap <Leader>s' ciw''<Esc>P
nnoremap <Leader>s` ciw``<Esc>P
nnoremap <Leader>s( ciw()<Esc>P
nnoremap <Leader>s{ ciw{}<Esc>P
nnoremap <Leader>s[ ciw[]<Esc>P
map <Leader>s <Plug>(operator-surround-append)
nnoremap U <c-r>
nnoremap <Leader>m `

