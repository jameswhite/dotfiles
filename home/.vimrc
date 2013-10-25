set nocompatible               " be iMproved
filetype off                   " required!

" ****************************
" Vundle package management
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

Bundle 'gmarik/vundle'

Bundle 'airblade/vim-gitgutter.git'
Bundle 'arafatm/todohabit.vim.git'
Bundle 'mattn/gist-vim.git'
Bundle 'msanders/snipmate.vim.git'
Bundle 'scottmcginness/vim-jquery.git'
Bundle 'thinca/vim-ft-markdown_fold.git'
Bundle 'tpope/vim-fugitive.git'
Bundle 'tpope/vim-rails.git'
Bundle 'tpope/vim-bundler.git'
Bundle 'vim-ruby/vim-ruby.git'
Bundle 'vim-scripts/JavaScript-Indent.git'
Bundle 'vim-scripts/Markdown.git'
Bundle 'rodjek/vim-puppet.git'

filetype plugin indent on
syntax on

" ****************************
" Common settings
set showcmd			" Show (partial) command in status line.
set showmatch		" Show matching brackets.
set ignorecase	" Do case insensitive matching
set smartcase		" Do smart case matching
set incsearch		" Incremental search
set autowrite		" Automatically save before commands like :next and :make
set hidden      " Hide buffers when they are abandoned

set smartindent
set autoindent
set shiftwidth=2
set tabstop=2
set softtabstop=2
set expandtab

set visualbell
set hls
set dir=~/tmp
set backupcopy=yes
set nobackup writebackup
map <BS> bdw
set foldmethod=indent
set foldlevel=99

set cot=menuone
set cot+=preview

set nomodeline
let g:secure_modelines_verbose = 0
let g:secure_modelines_modelines = 15

" ****************************
" Colors
set background=dark
colorscheme koehler

" ****************************
" FOLDING
" Map space to toggle fold 
nnoremap  <silent>  <space> :exe 'silent! normal! za'.(foldlevel('.')?'':'l')<cr>

map ,,0 :set foldlevel=0<cr>
map ,,1 :set foldlevel=1<cr>
map ,,2 :set foldlevel=2<cr>
map ,,3 :set foldlevel=3<cr>
map ,,4 :set foldlevel=4<cr>
map ,,5 :set foldlevel=5<cr>
map ,,6 :set foldlevel=6<cr>
map ,,7 :set foldlevel=7<cr>
map ,,8 :set foldlevel=8<cr>
map ,,9 :set foldlevel=9<cr>


" ****************************
" Abbreviations
iab  ,d  <c-r>=strftime("%Y-%m-%d")<cr>
iab  ,-  ------------------------------------------------------------


" ****************************
" Conditional syntax highlighting
function! TextEnableCodeSnip(filetype,start,end) abort
  let ft=toupper(a:filetype)
  let group='textGroup'.ft
  execute 'syntax include @'.group.' syntax/'.a:filetype.'.vim'
  unlet b:current_syntax
  execute 'syntax region textSnip'.ft.'
        \ matchgroup=textSnip
        \ start="'.a:start.'" end="'.a:end.'"
        \ contains=@'.group
  hi link textSnip SpecialComment
endfunction

call TextEnableCodeSnip('c'   ,'@begin=c@'   ,'@end=c@'  ) 
call TextEnableCodeSnip('cs'   ,'@begin=cs@'   ,'@end=cs@'  ) 
call TextEnableCodeSnip('java'   ,'@begin=java@'   ,'@end=java@'  ) 
call TextEnableCodeSnip('ruby'   ,'@begin=ruby@'   ,'@end=ruby@'  ) 

au BufNewFile,BufRead .bashrc,.bash/* call SetFileTypeSH("bash")

augroup filetypedetect
  au BufNewFile,BufRead *.txt setfiletype markdown
  au BufNewFile,BufRead *.txt set formatoptions=tqwan
  au BufNewFile,BufRead,BufEnter *.txt  set smartindent
  au BufNewFile,BufRead,BufEnter *.txt  set tabstop=2
  au BufNewFile,BufRead,BufEnter *.txt  set shiftwidth=2
  au BufNewFile,BufRead,BufEnter *.txt  set expandtab
augroup END
