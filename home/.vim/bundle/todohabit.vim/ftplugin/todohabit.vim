if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1

setlocal foldmethod=expr
setlocal foldexpr=TodoHabitFold(v:lnum)


if exists('*TodoHabitFold')
  finish
endif

function! TodoHabitFold(lnum)
  let head = s:head(a:lnum)
  if head
    return head
  elseif a:lnum != line('$')
    let next = s:head(a:lnum + 1)
    if next
      return '<' . next
    endif
  endif
  return '='
endfunction


function! s:head(lnum)
  let current = getline(a:lnum)
  let sharps = strlen(matchstr(current, '^#*'))
  if sharps
    return sharps
  endif

  if current =~ '\S'
    let next = getline(a:lnum + 1)
    if next =~ '^=\+$'
      return 1
    elseif next =~ '^-\+$'
      return 2
    endif
  endif
  return 0
endfunction

function! s:TodoDone(done)
  let when = 3600 * 24 * a:0
  let format = "%Y-%m-%d "
  let doneDate = strftime(format, localtime() - when)

  execute "normal 0I" . a:done . " " . doneDate
endfunction 

"map ,x to DONE and ,z to WONTDO
map ,x :call <SID>TodoDone('x')<CR>
map ,z :call <SID>TodoDone('z')<CR>

"move current line to archive
map ,a kmajddGp'azz
"sort block of todo items
map ,r {j!1}sort<CR>
