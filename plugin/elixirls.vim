if exists('g:vim_elixirls_plugin_loaded')
  finish
endif

command! ElixirLsCompile call elixirls#compile()

let g:vim_elixirls_plugin_loaded = 1

