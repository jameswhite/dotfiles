"call pathogen#infect()
" Give a shortcut key to NERD Tree
map <C-n> :NERDTreeToggle<CR>
map q hi~~A~~

highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/
syntax on
set background=dark
"set foldmarker=%%%FOLD,%%%END\ FOLD%%%
set foldmarker=</summary>,</details>
set foldmethod=marker
" autocmd BufWritePre *.pl :%s/\s\+$//e
" autocmd BufWritePre *.pp :%s/\s\+$//e
" autocmd BufWritePre *.rb :%s/\s\+$//e
" autocmd BufWritePre *.sh :%s/\s\+$//e
" autocmd BufWritePre * :%s/\s\+$//e
" map q :silent !make

" Transparent editing of gpg encrypted files.
" By Wouter Hanegraaff
augroup encrypted
  au!

  " First make sure nothing is written to ~/.viminfo while editing
  " an encrypted file.
  autocmd BufReadPre,FileReadPre *.gpg set viminfo=
  " We don't want a various options which write unencrypted data to disk
  autocmd BufReadPre,FileReadPre *.gpg set noswapfile noundofile nobackup

  " Switch to binary mode to read the encrypted file
  autocmd BufReadPre,FileReadPre *.gpg set bin
  autocmd BufReadPre,FileReadPre *.gpg let ch_save = &ch|set ch=2
  " (If you use tcsh, you may need to alter this line.)
  autocmd BufReadPost,FileReadPost *.gpg '[,']!gpg --no-tty --decrypt 2> /dev/null

  " Switch to normal mode for editing
  autocmd BufReadPost,FileReadPost *.gpg set nobin
  autocmd BufReadPost,FileReadPost *.gpg let &ch = ch_save|unlet ch_save
  autocmd BufReadPost,FileReadPost *.gpg execute ":doautocmd BufReadPost " . expand("%:r")

  " Convert all text to encrypted text before writing
  " (If you use tcsh, you may need to alter this line.)
  autocmd BufWritePre,FileWritePre *.gpg '[,']!gpg --default-recipient-self --sign -ae 2>/dev/null
  " Undo the encryption so we are back in the normal text, directly
  " after the file has been written.
  autocmd BufWritePost,FileWritePost *.gpg u
augroup END
