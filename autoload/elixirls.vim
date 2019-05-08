if exists('g:vim_elixirls_loaded') | finish | endif

if !exists('*job_start')
  echoerr 'The vim-elixirls plugin requires Vim 8 with job_start()'
  finish
endif

let s:repo = expand('<sfile>:p:h:h') . '/elixir-ls'
if exists('s:job_id') | unlet s:job_id | endif

function! elixirls#compile(wait) abort
  if exists('s:job_id')
    echomsg 'ElixirLS is already currently compiling in the background'
    return
  endif
  let l:script = 'mix deps.get && mix compile && mix elixir_ls.release -o release'
  let l:command = has('win32') ? 'cmd /c ' . l:script : ['/bin/sh', '-c', l:script]
  let s:job_id = job_start(l:command, { 'cwd': s:repo, 'exit_cb': function('s:exit_cb') })
  if job_status(s:job_id) ==# 'run'
    echomsg 'ElixirLS compilation started'
    while a:wait && exists('s:job_id') && job_status(s:job_id) ==# 'run' | sleep 1000m | endwhile
  else
    echoerr 'ElixirLS compilation failed to start'
    unlet s:job_id
  endif
endfunction

function! s:exit_cb(job, exit_status) abort
  if a:exit_status == 0
    echomsg 'ElixirLS compiled successfully'
  else
    echoerr 'ElixirLS compilation failed (' . a:exit_status . ')'
  endif
  unlet s:job_id
endfunction

let g:vim_elixirls_loaded = 1

