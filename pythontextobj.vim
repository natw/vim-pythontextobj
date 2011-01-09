"============================================================================
" File:        pythontextobj.vim
" Author:      Nat Williams
" License:     I dunno
" Description: Adds text objects for Python classes and functions.
" Credits:     Most code pretty much copied straight out of Alfredo Deza's
"              chapa.vim (https://github.com/alfredodeza/chapa.vim)
"              Also Austin Taylor's indentobj
"              (https://github.com/austintaylor/vim-indentobject)
"============================================================================

if (exists("g:loaded_pythontextobj") && g:loaded_pythontextobj)
  finish
endif
let g:loaded_pythontextobj = 1

onoremap <silent>af :<C-u>call FunctionTextObject(0)<CR>
onoremap <silent>if :<C-u>call FunctionTextObject(1)<CR>
vnoremap <silent>af :<C-u>call FunctionTextObject(0)<CR><Esc>gv
vnoremap <silent>if :<C-u>call FunctionTextObject(1)<CR><Esc>gv
onoremap <silent>ac :<C-u>call ClassTextObject(0)<CR>
onoremap <silent>ic :<C-u>call ClassTextObject(1)<CR>
vnoremap <silent>ac :<C-u>call ClassTextObject(0)<CR><Esc>gv
vnoremap <silent>ic :<C-u>call ClassTextObject(1)<CR><Esc>gv


function! IndentTextObject(inner)
  if index(g:indentobject_meaningful_indentation, &filetype) >= 0
    let meaningful_indentation = 1
  else
    let meaningful_indentation = 0
  endif
  let curline = line(".")
  let lastline = line("$")
  let i = indent(line(".")) - &shiftwidth * (v:count1 - 1)
  let i = i < 0 ? 0 : i
  if getline(".") =~ "^\\s*$"
    return
  endif
  let p = line(".") - 1
  let nextblank = getline(p) =~ "^\\s*$"
  while p > 0 && (nextblank || indent(p) >= i )
    -
    let p = line(".") - 1
    let nextblank = getline(p) =~ "^\\s*$"
  endwhile
  if (!a:inner)
    -
  endif
  normal! 0V
  call cursor(curline, 0)
  let p = line(".") + 1
  let nextblank = getline(p) =~ "^\\s*$"
  while p <= lastline && (nextblank || indent(p) >= i )
    +
    let p = line(".") + 1
    let nextblank = getline(p) =~ "^\\s*$"
  endwhile
  if (!a:inner && !meaningful_indentation)
    +
  endif
  normal! $
endfunction


" In certain situations, it allows you to echo something without 
" having to hit Return again to do exec the command.
function! s:Echo(msg)
  let x=&ruler | let y=&showcmd
  set noruler noshowcmd
  redraw
  echo a:msg
  let &ruler=x | let &showcmd=y
endfun

"}}}

"{{{ Main Functions 

" Select an object ("class"/"function")
function! s:PythonSelectObject(obj)
  " Go to the object declaration
  normal $
  let rev = s:FindPythonObject(a:obj, -1)
  if (! rev)
    let fwd = s:FindPythonObject(a:obj, 1)
    if (! fwd)
      return
     endif
   endif

  let beg = line('.')
  exec beg

  let until = s:NextIndent(1)
  let line_moves = until - beg
  
  if line_moves > 0
    execute "normal V" . line_moves . "j"
  else
    execute "normal VG" 
  endif
endfunction


function! s:NextIndent(fwd)
  let line = line('.')
  let column = col('.')
  let lastline = line('$')
  let indent = indent(line)
  let stepvalue = a:fwd ? 1 : -1

  while (line > 0 && line <= lastline)
    let line = line + stepvalue

    if (indent(line) <= indent && strlen(getline(line)) > 0)
      return line - 1
    endif
  endwhile
endfunction
 

" Go to previous (-1) or next (1) class/function definition
" return a line number that matches either a class or a function
" to call this manually:
" Backwards:
"     :call FindPythonObject("class", -1)
" Forwards:
"     :call FindPythonObject("class")
" Functions Backwards:
"     :call FindPythonObject("function", -1)
" Functions Forwards:
"     :call FindPythonObject("function")
function! s:FindPythonObject(obj, direction)
  if (a:obj == "class")
    let objregexp = "^\\s*class\\s\\+[a-zA-Z0-9_]\\+"
        \ . "\\s*\\((\\([a-zA-Z0-9_,. \\t\\n]\\)*)\\)\\=\\s*:"
  else
    let objregexp = "^\\s*def\\s\\+[a-zA-Z0-9_]\\+\\s*(\\_[^:#]*)\\s*:"
  endif
  let flag = "W"
  if (a:direction == -1)
    let flag = flag."b"
  endif
  let result = search(objregexp, flag)
  if result
      return line('.') 
  else 
      return 
  endif
endfunction
"}}}

"{{{ Misc 
"command! -nargs=0 ChapaVisualFunction call s:PythonSelectObject("function")
"command! -nargs=0 ChapaVisualClass call s:PythonSelectObject("class")
"}}}

function! FunctionTextObject(inner)
    call s:PythonSelectObject('function')
endfunction


function! ClassTextObject(inner)
    call s:PythonSelectObject('class')
endfunction
