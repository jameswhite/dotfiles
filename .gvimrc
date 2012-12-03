" Make external commands work through a pipe instead of a pseudo-tty
"set noguipty

" You can also specify a different font, overriding the default font
if has("win32")
  set guifont=Andale_Mono:h10:cANSI
else
  set guifont=Terminus\ 12
endif

" If you want to run gvim with a dark background, try using a different
" colorscheme or running 'gvim -reverse'.
" http://www.cs.cmu.edu/~maverick/VimColorSchemeTest/ has examples and
" downloads for the colorschemes on vim.org

" Source a global configuration file if available
" XXX Deprecated, please move your changes here in /etc/vim/gvimrc
if filereadable("/etc/vim/gvimrc.local")
  source /etc/vim/gvimrc.local
endif

set guioptions-=T

:map <A-x> :simalt ~x<CR>
