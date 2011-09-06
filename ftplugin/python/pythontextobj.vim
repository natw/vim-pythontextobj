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

onoremap <buffer> <silent>af :<C-u>call FunctionTextObject(0)<CR>
onoremap <buffer> <silent>if :<C-u>call FunctionTextObject(1)<CR>
vnoremap <buffer> <silent>af :<C-u>call FunctionTextObject(0)<CR><Esc>gv
vnoremap <buffer> <silent>if :<C-u>call FunctionTextObject(1)<CR><Esc>gv
onoremap <buffer> <silent>ac :<C-u>call ClassTextObject(0)<CR>
onoremap <buffer> <silent>ic :<C-u>call ClassTextObject(1)<CR>
vnoremap <buffer> <silent>ac :<C-u>call ClassTextObject(0)<CR><Esc>gv
vnoremap <buffer> <silent>ic :<C-u>call ClassTextObject(1)<CR><Esc>gv


" Select an object ("class"/"function")
function! s:PythonSelectObject(obj, inner)

  " find definition line
  let start_line = s:FindPythonObjectStart(a:obj)
  if (! start_line)
    return
  endif
  
  " get end (w/ or w/out whitespace)
  let until = s:ObjectEnd(start_line, a:inner)

  " include decorators
  if (! a:inner)
    let start_line = s:StartDecorators(start_line)
  endif

  " select range
  let line_moves = until - start_line
  exec start_line
  if line_moves > 0
    execute "normal V" . line_moves . "j"
  else
    execute "normal VG" 
  endif

endfunction


function! s:ObjectEnd(start, inner)
  let objend = s:NextIndent(a:start)
  if a:inner
    let objend = prevnonblank(objend)
  endif
  return objend
endfunction


function! s:NextIndent(start)
  let line = a:start
  let lastline = line('$')
  let indent = indent(line)
  while (line > 0 && line <= lastline)
    let line = line + 1
    if (indent(line) <= indent && getline(line) !~ '^\s*$')
      return line - 1
    endif
  endwhile
  return lastline
endfunction
 

function! s:StartDecorators(start)
  " get def/class start pos
  " move upwards, breaking on first line of different indent that doesn't
  " start w/ @
  exec a:start
  normal ^
  let def_indent = indent(line("."))
  let found = 0
  while (! found)
    normal k
    let ln = line(".")
    if (ln == 1)
      return ln
    endif
    if (indent(ln) != def_indent || getline(ln) =~ '\v^\s*[^@].+$')
      return line(".") + 1
    endif
  endwhile
endfunction


function! s:FindPythonObjectStart(obj)
  " TODO: don't match definitions at equal or greater indent unless it matches
  " at cursor position
  let cursor_start_pos = line(".")
  let cursor_indent = indent(cursor_start_pos)
  if (a:obj == "class")
    let objregexp = "^\\s*class\\s\\+[a-zA-Z0-9_]\\+"
        \ . "\\s*\\((\\([a-zA-Z0-9_,. \\t\\n]\\)*)\\)\\=\\s*:"
  else
    let objregexp = "^\\s*def\\s\\+[a-zA-Z0-9_]\\+\\s*(\\_[^:#]*)\\s*:"
  endif
  let found = 0
  while (! found)
    normal $
    let result = search(objregexp, "Wbcn")
    if (! result)
      return
    endif
    if indent(result) < cursor_indent || (indent(result) == cursor_indent && result == cursor_start_pos)
      let found = 1
    else
      exec line(".") - 1
    endif
  endwhile
  exec cursor_start_pos
  return result
endfunction


function! FunctionTextObject(inner)
    call s:PythonSelectObject('function', a:inner)
endfunction


function! ClassTextObject(inner)
    call s:PythonSelectObject('class', a:inner)
endfunction
