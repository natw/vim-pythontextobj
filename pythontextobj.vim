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


" In certain situations, it allows you to echo something without 
" having to hit Return again to do exec the command.
function! s:Echo(msg)
  let x=&ruler | let y=&showcmd
  set noruler noshowcmd
  redraw
  echo a:msg
  let &ruler=x | let &showcmd=y
endfun

" Select an object ("class"/"function")
function! s:PythonSelectObject(obj, inner)
  " Go to the object declaration
  normal $
  let rev = s:FindPythonObject(a:obj)
  if (! rev)
    return
  endif

  "TODO: af/ac should include decorators

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
 

function! s:FindPythonObject(obj)
  if (a:obj == "class")
    let objregexp = "^\\s*class\\s\\+[a-zA-Z0-9_]\\+"
        \ . "\\s*\\((\\([a-zA-Z0-9_,. \\t\\n]\\)*)\\)\\=\\s*:"
  else
    let objregexp = "^\\s*def\\s\\+[a-zA-Z0-9_]\\+\\s*(\\_[^:#]*)\\s*:"
  endif
  let flag = "Wb"
  let result = search(objregexp, flag)
  if result
      return line('.') 
  else 
      return 
  endif
endfunction


function! FunctionTextObject(inner)
    call s:PythonSelectObject('function', a:inner)
endfunction


function! ClassTextObject(inner)
    call s:PythonSelectObject('class', a:inner)
endfunction
