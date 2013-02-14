" This line should not be removed as it ensures that various options are
" properly set to work with the Vim-related packages available in Debian.
runtime! debian.vim

syntax on

set nomodeline
let g:secure_modelines_verbose = 0
let g:secure_modelines_modelines = 15

set background=dark

" Needed on some linux distros.
" " see
" http://www.adamlowe.me/2009/12/vim-destroys-all-other-rails-editors.html
"filetype off 
call pathogen#infect()
call pathogen#helptags()

filetype on
filetype plugin on
if has("autocmd")
  filetype indent on
endif

set showcmd			" Show (partial) command in status line.
set showmatch		" Show matching brackets.
set ignorecase	" Do case insensitive matching
set smartcase		" Do smart case matching
set incsearch		" Incremental search
set autowrite		" Automatically save before commands like :next and :make
set hidden      " Hide buffers when they are abandoned
"set mouse=a			" Enable mouse usage (all modes) in terminals

"set cindent
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

" ****************************
" FOLDING
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

" Map space to toggle fold 
nnoremap  <silent>  <space> :exe 'silent! normal! za'.(foldlevel('.')?'':'l')<cr>

" ****************************
" Abbreviations
iab  ,d  <c-r>=strftime("%Y-%m-%d")<cr>
iab  ,-  ------------------------------------------------------------

colorscheme koehler

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

"augroup filetypedetect
" au! BufRead,BufNewFile *.otl          setfiletype vo_base
"	au! BufRead,BufNewFile *.oln          setfiletype xoutliner
"augroup END

" TVO
"au BufNewFile,BufRead,BufEnter *.txt  let g:otl_bold_headers=0
"au BufNewFile,BufRead,BufEnter *.txt  let g:otl_use_viki=1
"au BufNewFile,BufRead,BufEnter *.txt  setfiletype txt
"au BufNewFile,BufRead,BufEnter *.txt  set smartindent
"au BufNewFile,BufRead,BufEnter *.txt  set tabstop=2
"au BufNewFile,BufRead,BufEnter *.txt  set shiftwidth=2
"au BufNewFile,BufRead,BufEnter *.txt  set noexpandtab

"augroup filetypedetect
"  au BufNewFile,BufRead *.txt setfiletype markdown
"  au BufNewFile,BufRead *.txt set formatoptions=tqwan
"  au BufNewFile,BufRead,BufEnter *.txt  set smartindent
"  au BufNewFile,BufRead,BufEnter *.txt  set tabstop=2
"  au BufNewFile,BufRead,BufEnter *.txt  set shiftwidth=2
"  "au BufNewFile,BufRead,BufEnter *.txt  set expandtab
"augroup END


" OMNIFUNC

if has("autocmd")
  " Ruby
  autocmd FileType ruby set omnifunc=rubycomplete#Complete
  autocmd FileType ruby let g:rubycomplete_buffer_loading=1
  autocmd FileType ruby let g:rubycomplete_classes_in_global=1
  autocmd FileType ruby set makeprg=ruby\ %

  " JS
  autocmd FileType javascript set omnifunc=javascriptcomplete#CompleteJS
  autocmd FileType html set omnifunc=htmlcomplete#CompleteTags
  autocmd FileType css set omnifunc=csscomplete#CompleteCSS

  " Misc
  autocmd FileType python set omnifunc=pythoncomplete#Complete
  autocmd FileType xml set omnifunc=xmlcomplete#CompleteTags
  autocmd FileType php set omnifunc=phpcomplete#CompletePHP
  autocmd FileType c set omnifunc=ccomplete#Complete
endif
