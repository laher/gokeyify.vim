" don't spam the user when Vim is started in Vi compatibility mode
let s:cpo_save = &cpo
set cpo&vim

function! s:gokeyify()
  " Needs: https://github.com/dominikh/go-tools/pull/272
  let l:cmd = printf('keyify -json %s:#%s', shellescape(expand('%:p')), s:bytes_offset(line('.'), col('.')))
  let l:out = system(l:cmd)
  if v:shell_error != 0
    call s:handle_errors(l:out)
  endif
  silent! let result = json_decode(l:out)

  " We want to output the error message in case the result isn't a JSON
  if type(result) != type({})
    call s:handle_errors(s:chomp(l:out))
    return
  endif

  " Because keyify returns the byte before the region we want, we goto the
  " byte after that
  execute "goto" result.start + 1
  let start = getpos('.')
  execute "goto" result.end
  let end = getpos('.')

  let vis_start = getpos("'<")
  let vis_end = getpos("'>")

  " Replace contents between start and end with `replacement`
  call setpos("'<", start)
  call setpos("'>", end)

  let select = 'gv'

  " Make sure the visual mode is 'v', to avoid some bugs
  normal! gv
  if mode() !=# 'v'
    let select .= 'v'
  endif

  silent! execute "normal!" select."\"=result.replacement\<cr>p"

  " Replacement text isn't aligned, so it needs fix
  normal! '<v'>=

  call setpos("'<", vis_start)
  call setpos("'>", vis_end)
endfunction

function! s:output_handler(job_id, data, event_type)
    if a:event_type == "exit"
      echom 'Done. Exit code: ' . a:data
    else
      echo a:job_id . ' ' . a:event_type
      echo join(a:data, "; ")
    endif
endfunction

function! s:run_maybe_async(argv)
  if &rtp =~ 'async.vim'
    let jobid = async#job#start(a:argv, {
        \ 'on_stdout': function('s:output_handler'),
        \ 'on_stderr': function('s:output_handler'),
        \ 'on_exit': function('s:output_handler'),
    \ })
    if jobid > 0
        echom 'job started'
    else
        echom 'job failed to start'
    endif
  else
    echom 'async.vim not available. Running synchronously: ' . join(a:argv)
    let l:out = system(join(a:argv, ' '))
    echo l:out
  endif
endfunction

function! s:gokeyifyinstall()
  let argv = ['go', 'get', '-u', 'honnef.co/go/tools/cmd/keyify']
  call s:run_maybe_async(argv)
endfunction

function! s:chomp(string)
    return substitute(a:string, '\n\+$', '', '')
endfunction

function! s:bytes_offset(line, col) abort
  if &encoding !=# 'utf-8'
    let l:sep = "\n"
    if &fileformat ==# 'dos'
      let l:sep = "\r\n"
    elseif &fileformat ==# 'mac'
      let l:sep = "\r"
    endif
    let l:buf = a:line ==# 1 ? '' : (join(getline(1, a:line-1), l:sep) . l:sep)
    let l:buf .= a:col ==# 1 ? '' : getline('.')[:a:col-2]
    return len(iconv(l:buf, &encoding, 'utf-8'))
  endif
  return line2byte(a:line) + (a:col-2)
endfunction
function! s:handle_errors(content) abort
  let l:lines = split(a:content, '\n')
  let l:errors = []
  for l:line in l:lines
    let l:tokens = matchlist(l:line, '^\(.\{-}\):\(\d\+\):\(\d\+\)\s*\(.*\)')
    if empty(l:tokens)
      continue
    endif
    call add(l:errors,{
          \'filename': l:tokens[1],
          \'lnum':     l:tokens[2],
          \'col':      l:tokens[3],
          \'text':     l:tokens[4],
          \ })
  endfor

  if len(l:errors)
    call setloclist(0, l:errors, 'r')
    call setloclist(0, [], 'a', {'title': 'Format'})
    lopen
  else
    echomsg join(l:lines, "\n")
  endif
endfunction
" restore Vi compatibility settings
let &cpo = s:cpo_save
unlet s:cpo_save

" vim: sw=2 ts=2 et
command! -nargs=0 GoKeyify call s:gokeyify()
command! -nargs=0 GoKeyifyInstall call s:gokeyifyinstall()
