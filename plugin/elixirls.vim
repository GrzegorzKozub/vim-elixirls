if exists('g:vim_elixirls_plugin_loaded')
  finish
endif

command! ElixirLsCompile call elixirls#compile(0)
command! ElixirLsCompileSync call elixirls#compile(1)

let g:vim_elixirls_plugin_loaded = 1

