" just in case
set nocompatible
scriptencoding utf-8
set encoding=utf-8

" pathogen
runtime bundle/vim-pathogen/autoload/pathogen.vim
call pathogen#infect('bundle/{}/', 'bundle/{}/vim')
call pathogen#helptags()
filetype plugin on

" load sensible now, so we can override options after
runtime! plugin/sensible.vim

" plugin options

let g:ackhighlight = 1
let g:ack_autofold_results = 1

if executable('ag')
  let g:ackprg = 'ag --vimgrep'
  let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
else
  let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files . -co --exclude-standard', 'find %s -type f']
  let g:ctrlp_prompt_mappings = {
    \ 'AcceptSelection("e")': ['<space>', '<cr>', '<2-LeftMouse>'],
    \ }
endif

let g:lightline = {
    \ 'colorscheme': 'wombat',
    \ 'mode_map': { 'c': 'NORMAL' },
    \ 'active': {
    \   'left': [ [ 'mode', 'paste' ], [ 'fugitive', 'filename',  'gitgutter' ] ]
    \ },
    \ 'component_function': {
    \   'modified': 'LightLineModified',
    \   'readonly': 'LightLineReadonly',
    \   'fugitive': 'LightLineFugitive',
    \   'gitgutter': 'LightLineGitGutter',
    \   'filename': 'LightLineFilename',
    \   'fileformat': 'LightLineFileformat',
    \   'filetype': 'LightLineFiletype',
    \   'fileencoding': 'LightLineFileencoding',
    \   'mode': 'LightLineMode',
    \ },
    \ 'separator': { 'left': '', 'right': '' },
    \ 'subseparator': { 'left': '|', 'right': '|' }
    \ }

function! LightLineModified()
  return &ft =~ 'help\|gundo' ? '' : &modified ? '+' : &modifiable ? '' : '-'
endfunction

function! LightLineReadonly()
  return &ft !~? 'help\|gundo' && &readonly ? 'RO' : ''
endfunction

function! LightLineFilename()
  return ('' != LightLineReadonly() ? LightLineReadonly() . ' ' : '') .
        \ (&ft == 'vimfiler' ? vimfiler#get_status_string() :
        \  &ft == 'unite' ? unite#get_status_string() :
        \  &ft == 'vimshell' ? vimshell#get_status_string() :
        \ '' != expand('%:r') ? expand('%:r') : '[No Name]') .
        \ ('' != LightLineModified() ? ' ' . LightLineModified() : '')
endfunction

function! LightLineFugitive()
  if &ft !~? 'vimfiler\|gundo' && exists("*fugitive#head")
    let _ = fugitive#head()
    return strlen(_) ? ''._ : ''
  endif
  return ''
endfunction

function! LightLineGitGutter()
  if !exists('*GitGutterGetHunkSummary')
    return ''
  endif
  let hunks = GitGutterGetHunkSummary()
  let string = ''
  if !empty(hunks)
    let string .= AddGitGutterHunks('+', hunks[0])
    let string .= AddGitGutterHunks('~', hunks[1])
    let string .= AddGitGutterHunks('-', hunks[2])
  endif
  return string
endfunction

function! AddGitGutterHunks(symbol, hunks)
  if a:hunks > 0
    return printf('%s%s ', a:symbol, a:hunks)
  endif
  return ''
endfunction

function! LightLineFileformat()
  return winwidth(0) > 70 ? &fileformat : ''
endfunction

function! LightLineFiletype()
  return winwidth(0) > 70 ? (strlen(&filetype) ? &filetype : 'no ft') : ''
endfunction

function! LightLineFileencoding()
  return winwidth(0) > 70 ? (strlen(&fenc) ? &fenc : &enc) : ''
endfunction

function! LightLineMode()
  return winwidth(0) > 60 ? lightline#mode() : ''
endfunction

let g:BufstopSpeedKeys = ["<F1>", "<F2>", "<F3>", "<F4>", "<F5>", "<F6>"]
let g:BufstopLeader = ""
let g:BufstopAutoSpeedToggle = 1

" make CtrlP open files in current window

let g:ctrlp_open_new_file = 'r'
let g:ctrlp_working_path_mode = 'raw'
let g:ctrlp_match_window ='bottom,order:btt,min:1,max:10,results:100'

" ALE options
let g:ale_python_flake8_options = '--ignore=E501'

" colors
colorscheme dracula

" global options
set updatetime=250
set visualbell
set hidden
set laststatus=2
set nostartofline
set history=1000
set whichwrap=b,s,<,>,[,]
set number
set relativenumber
set list
set listchars=tab:▸-,trail:·,nbsp:·
set wrap
set linebreak
set wildmenu
set wildmode=longest,list:full
set noshowmode
set mouse=a

if v:version >= 703
    set undodir=~/.vim/undo
    if !isdirectory(expand(&undodir))
      call mkdir(expand(&undodir), "p")
    endif
    set undofile

    set colorcolumn=+1
endif

set directory=~/.vim/swaps//
if !isdirectory(expand(&directory))
  call mkdir(expand(&directory), "p")
endif

set shiftwidth=4
set softtabstop=4
set expandtab
set autoindent

set scrolloff=3
set sidescrolloff=7
set sidescroll=1

set hlsearch
set ignorecase
set smartcase

set foldmethod=syntax

set synmaxcol=250

set splitbelow
set splitright

set viewoptions=cursor,folds,unix,slash
set viewdir=~/.vim/views//
if !isdirectory(expand(&viewdir))
  call mkdir(expand(&viewdir), "p")
endif

let g:skipview_files = [
            \ '[EXAMPLE PLUGIN BUFFER]'
            \ ]
augroup AutoView
    autocmd!
    " Autosave & Load Views.
    autocmd BufWritePost,BufWinLeave,BufLeave,WinLeave *
          \   if expand('%') != '' && &buftype !~ 'nofile'
          \|      mkview
          \|  endif
    autocmd BufRead *
          \   if expand('%') != '' && &buftype !~ 'nofile'
          \|      silent! loadview
          \|  endif
augroup end

let mapleader="\<Space>"

nnoremap <Leader>s :source ~/.vimrc<CR>:echo 'Configuration reloaded.'<CR>
nnoremap <Leader>o :CtrlPMixed<CR>
nnoremap <Leader>w :w<CR>
nnoremap <Leader>q :q<CR>
nnoremap <Leader>f :Ack!<Space>

" copy/paste
vmap <Leader>y "+y
vmap <Leader>d "+d
nmap <Leader>p "+p
nmap <Leader>P "+P
vmap <Leader>p "+p
vmap <Leader>P "+P

" jump to end pasted text
vnoremap <silent> y y`]
vnoremap <silent> p p`]
nnoremap <silent> p p`]

" BufStop mappings
map <leader>b :Bufstop<CR>
map <leader>a :BufstopModeFast<CR>
map <C-tab>   :BufstopBack<CR>
map <S-tab>   :BufstopForward<CR>


