if exists('g:vim_elixirls_loaded') | finish | endif

let s:vim = exists('*job_start')
let s:neovim = exists('*jobstart')

if !s:vim && !s:neovim
  echoerr 'The vim-elixirls plugin requires Vim 8 or Neovim'
  finish
endif

let s:repo = substitute(expand('<sfile>:p:h:h') . '/elixir-ls', '\', '/', 'g')
let s:wait_seconds = 120
let s:timeout = 0
if exists('s:job_id') | unlet s:job_id | endif

function! elixirls#compile(wait) abort
  if exists('s:job_id')
    echomsg 'ElixirLS is already currently compiling in the background'
    return
  endif
  call s:start(a:wait)
  call s:handle_start(a:wait)
endfunction

if s:neovim

  function! s:start(wait) abort
    let s:job_id = jobstart(s:get_command(), s:get_options())
  endfunction

  function! s:started() abort
    return s:job_id > 0
  endfunction

  function! s:wait() abort
    if jobwait([ s:job_id ], s:wait_seconds * 1000)[0] < 0
      let s:timeout = 1
    endif
  endfunction

  function! s:get_options() abort
    return { 'cwd': s:repo, 'on_exit': function('s:on_exit') }
  endfunction

  function! s:on_exit(job_id, data, event) abort
    call s:handle_exit(a:data)
  endfunction

else

  function! s:start(wait) abort
    let s:job_id = job_start(s:get_command(), s:get_options())
  endfunction

  function! s:started() abort
    return job_status(s:job_id) ==# 'run'
  endfunction

  function! s:wait() abort
    let l:wait_remaining = s:wait_seconds
    while l:wait_remaining > 0 && exists('s:job_id') && job_status(s:job_id) ==# 'run'
      let l:wait_remaining = l:wait_remaining - 1
      sleep 1000m
    endwhile
    if l:wait_remaining == 0
      let s:timeout = 1
      call job_stop(s:job_id)
    endif
  endfunction

  function! s:get_options() abort
    return { 'cwd': s:repo, 'exit_cb': function('s:on_exit') }
  endfunction

  function! s:on_exit(job, exit_status) abort
    call s:handle_exit(a:exit_status)
  endfunction

endif

function! s:handle_start(wait) abort
  redraw
  if s:started()
    echomsg 'ElixirLS compilation started'
    if a:wait | call s:wait() | endif
  else
    echoerr 'ElixirLS compilation failed to start'
    unlet s:job_id
  endif
endfunction

function! s:handle_exit(exit_code) abort
  redraw
  if s:timeout == 1
    let s:timeout = 0
    echoerr 'ElixirLS compilation timed out'
  else
    if a:exit_code == 0
      echomsg 'ElixirLS compiled successfully'
    else
      echoerr 'ElixirLS compilation failed. See logs in ' . s:repo
    endif
  endif
  unlet s:job_id
endfunction

function! s:get_command() abort
  if exists('g:vim_elixir_ls_elixir_ls_dir')
    let l:change_dir = 'cd ' . g:vim_elixir_ls_elixir_ls_dir
  else
    let l:change_dir = ''
  endif

  let l:commands = [
    \ l:change_dir,
    \ 'mix deps.get > mix-deps.log 2>&1',
    \ 'mix compile > mix-compile.log 2>&1',
    \ 'mix elixir_ls.release -o release > mix-release.log 2>&1',
    \ 'rm *.log'
  \ ]

  let l:script = join(commands, ' && ')
  return has('win32') ? 'cmd /c ' . l:script : [ '/bin/sh', '-c', l:script ]
endfunction

let g:vim_elixirls_loaded = 1

