# What is it

Vim plugin that integrates [elixir-ls](https://github.com/JakeBecker/elixir-ls) with Vim through [ALE](https://github.com/w0rp/ale). It will download and compile [elixir-ls](https://github.com/JakeBecker/elixir-ls) upon installation. I also provided Vim configuration instructions for integrating with [ALE](https://github.com/w0rp/ale) and a command for on-demand compilation.

# How to install

Use your favorite plugin manager. I prefer [vim-plug](https://github.com/junegunn/vim-plug):

```
Plug 'prabirshrestha/async.vim'
Plug 'Kuret/vim-elixirls', { 'do': ':ElixirLsCompileSync' }
```

Note that we're using [post-update hooks](https://github.com/junegunn/vim-plug#post-update-hooks) to automatically compile [elixir-ls](https://github.com/JakeBecker/elixir-ls) after this plugin has been installed or updated.

# How to integrate with ALE

At the minimum, you will need to tell [ALE](https://github.com/w0rp/ale) where the compiled [elixir-ls](https://github.com/JakeBecker/elixir-ls) sits and enable it as linter:

```
" Vim
let s:user_dir = has('win32') ? expand('~/vimfiles/') : expand('~/.vim/')

" NeoVim
let s:user_dir = has('win32') ? expand('~/AppData/Local/nvim') : expand('~/.config/nvim')

" Location of your elixir-ls release, for vim-plug the plugins directory is usually 'plugged'
let g:ale_elixir_elixir_ls_release = s:user_dir . 'plugged/vim-elixirls/elixir-ls/release'

" https://github.com/JakeBecker/elixir-ls/issues/54
let g:ale_elixir_elixir_ls_config = { 'elixirLS': { 'dialyzerEnabled': v:false } }

let g:ale_linters = {}
let g:ale_linters.elixir = [ 'credo', 'elixir-ls' ]
```

I'm using the following Vim key mappings for quick code navigation:

```
nnoremap <C-]> :ALEGoToDefinition<CR>
nnoremap <C-\> :ALEFindReferences<CR>
nnoremap <Leader>d :ALEHover<CR>
```

I'm using `mix format` to format my [elixir](https://elixir-lang.org/) code with this config:

```
let g:ale_fixers = {}
let g:ale_fixers.elixir = [ 'mix_format' ]

augroup UseALEToFormatElixirFiles
  autocmd FileType elixir,eelixir nnoremap <Leader>f :ALEFix<CR>
augroup END
```

The `:ALEInfo` command is useful for figuring out why things are not working.

# Compiling elixir-ls manually

For [elixir-ls](https://github.com/JakeBecker/elixir-ls) to work, it needs to be compiled with the same [elixir](https://elixir-lang.org/) version as your code. Here's a handy command:

```
:ElixirLsCompile
```
