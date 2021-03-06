" Tslime.vim. Send portion of buffer to tmux instance
" Maintainer: C.Coutinho <kikijump [at] gmail [dot] com>
" Licence:    DWTFYWTPL

if exists("g:tslime_loaded")
  finish
endif

let g:tslime_loaded = 1
let g:tslime_send_prefix = ""

" Main function.
" Use it in your script if you want to send text to a tmux session.
function! Send_to_Tmux(text)
  if !exists("b:tmux_sessionname") || !exists("b:tmux_windowname") || !exists("b:tmux_panenumber")
    if exists("g:tmux_sessionname") && exists("g:tmux_windowname") && exists("g:tmux_panenumber")
      let b:tmux_sessionname = g:tmux_sessionname
      let b:tmux_windowname = g:tmux_windowname
      let b:tmux_panenumber = g:tmux_panenumber
    else
      call <SID>Tmux_Vars()
    end
  end

  let target = b:tmux_sessionname . ":" . b:tmux_windowname . "." . b:tmux_panenumber

  call system("tmux set-buffer '" . substitute(a:text, "'", "'\\\\''", 'g') . "'" )
  call system("tmux paste-buffer -t " . target)
endfunction

" Session completion
function! Tmux_Session_Names(A,L,P)
  return system("tmux list-sessions | cat")
endfunction

" Window completion
function! Tmux_Window_Names(A,L,P)
  return system("tmux list-windows -t" . b:tmux_sessionname . " | cat")
endfunction

" Pane completion
function! Tmux_Pane_Numbers(A,L,P)
  return system("tmux list-panes -t" . b:tmux_sessionname . ":" . b:tmux_windowname . " | cat")
endfunction

" set tslime.vim variables
function! s:Tmux_Vars()
  let b:tmux_sessionname = substitute(input("session name: ", "", "custom,Tmux_Session_Names"), ":.*$", '', 'g')
  let b:tmux_windowname = substitute(input("window name: ", "", "custom,Tmux_Window_Names"), ":.*$" , '', 'g')
  let b:tmux_panenumber = substitute(input("pane number: ", "", "custom,Tmux_Pane_Numbers"), ":.*$", '', 'g')

  if !exists("g:tmux_sessionname") || !exists("g:tmux_windowname") || !exists("g:tmux_panenumber")
    let g:tmux_sessionname = b:tmux_sessionname
    let g:tmux_windowname = b:tmux_windowname
    let g:tmux_panenumber = b:tmux_panenumber
  end
endfunction

function! To_Tmux()
  let b:text = input("tmux: ", "", "custom,")
  call Send_to_Tmux(g:tslime_send_prefix . b:text . "\n")
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

nmap <C-c>v :call <SID>Tmux_Vars()<CR>
vnoremap <silent> <C-c><C-c> "ry :call Send_to_Tmux(@r)<CR>
nmap <C-c><C-c> vip<C-c><C-c>
nnoremap :tt :call To_Tmux()<CR>
