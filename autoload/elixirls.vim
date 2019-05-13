if exists('g:vim_elixirls_loaded') | finish | endif

let s:repo = expand('<sfile>:p:h:h') . '/elixir-ls'
if exists('s:job_id') | unlet s:job_id | endif

function! elixirls#compile(wait) abort
  if exists('s:job_id')
    echomsg 'ElixirLS is already currently compiling in the background'
    return
  endif

  let l:script = 'cd ' . s:repo . ' && mix deps.get && mix compile && mix elixir_ls.release -o release'
  let l:command = has('win32') ? 'cmd /c ' . l:script : ['/bin/sh', '-c', l:script]
  let s:job_id = async#job#start(l:command, {
      \ 'on_stdout': function('s:handle_out'),
      \ 'on_stderr': function('s:handle_error'),
      \ 'on_exit': function('s:handle_exit'),
  \ })

  if s:job_id > 0
    echomsg 'ElixirLS compilation started'
    if a:wait
      " Wait for job to finish with a 5 minute timeout
      call async#job#wait([s:job_id], 300000)
    endif
  else
    echoerr 'ElixirLS compilation failed to start'
    unlet s:job_id
  endif
endfunction

function! s:handle_out(job_id, data, event_type) dict abort
  " stdout
endfunction

function! s:handle_error(job_id, data, event_type) dict abort
	let index = 0
	while index < len(a:data)
	   let line = a:data[index]

     " Filter out warnings from the stderr
     if match(line, 'warning: ') == 0
       " Next line is probably a filename, indented with '  ', since this belongs to the warning, skip this line
       if match(a:data[index + 1], '  ') == 0
         let index = index + 1
       endif
     elseif match(line, '^\s*$') == -1
       " Echo the error if it is not a warning and not an empty line
       echoerr 'Error: ' . line
     endif

     " Since we are potentially increasing the index by 2, check if we do not exceed the total length
     if index < len(a:data)
	     let index = index + 1
     endif
	endwhile
endfunction

function! s:handle_exit(job_id, exit_status, event_type) dict abort
  if a:exit_status == 0
    echomsg 'ElixirLS finished compiling'
  else
    echoerr 'ElixirLS compilation failed (' . a:exit_status . ')'
  endif
  unlet s:job_id
endfunction

let g:vim_elixirls_loaded = 1
