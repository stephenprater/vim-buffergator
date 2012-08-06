""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""  Buffergator
""
""  Vim document buffer navigation utility
""
""  Copyright 2011 Jeet Sukumaran.
""
""  This program is free software; you can redistribute it and/or modify
""  it under the terms of the GNU General Public License as published by
""  the Free Software Foundation; either version 3 of the License, or
""  (at your option) any later version.
""
""  This program is distributed in the hope that it will be useful,
""  but WITHOUT ANY WARRANTY; without even the implied warranty of
""  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
""  GNU General Public License <http://www.gnu.org/licenses/>
""  for more details.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Reload and Compatibility Guard {{{1
" ============================================================================
" Reload protection.
if (exists('g:did_buffergator') && g:did_buffergator) || &cp || version < 700
    finish
endif
let g:did_buffergator = 1

" avoid line continuation issues (see ':help user_41.txt')
let s:save_cpo = &cpo
set cpo&vim
" 1}}}

" Global Plugin Options {{{1
" =============================================================================
if !exists("g:buffergator_viewport_split_policy")
    let g:buffergator_viewport_split_policy = "L"
endif
if !exists("g:buffergator_move_wrap")
    let g:buffergator_move_wrap = 1
endif
if !exists("g:buffergator_autodismiss_on_select")
    let g:buffergator_autodismiss_on_select = 1
endif
if !exists("g:buffergator_autoupdate")
    let g:buffergator_autoupdate = 0
endif
if !exists("g:buffergator_autoexpand_on_split")
    let g:buffergator_autoexpand_on_split = 1
endif
if !exists("g:buffergator_split_size")
    let g:buffergator_split_size = 40
endif
if !exists("g:buffergator_sort_regime")
    let g:buffergator_sort_regime = "bufnum"
endif
if !exists("g:buffergator_display_regime")
    let g:buffergator_display_regime = "basename"
endif
if !exists("g:buffergator_show_full_directory_path")
    let g:buffergator_show_full_directory_path = 1 
endif
" 1}}}

" Script Key Maps {{{1
" =============================================================================
"

"
let s:_default_keymaps = {
      \ 'buffer_catalog_viewer' : {
        \ 'BuffergatorSelectDefault'    : ['<CR>', 'o'],
        \ 'BuffergatorCycleSort'        : ['cs'],
        \ 'BuffergatorDelete'           : ['d'],
        \ 'BuffergatorForceDelete'      : ['D'],
        \ 'BuffergatorWipe'             : ['x'],
        \ 'BuffergatorForceWipe'        : ['X'],
        \ 'BuffergatorSplitVertSwitch'  : ['s'],
        \ 'BuffergatorSplitHorzSwitch'  : ['i'],
        \ 'BuffergatorNewTabSwitch'     : ['t'],
        \ 'BuffergatorSelectKeep'       : ['po'],
        \ 'BuffergatorSplitVertKeep'    : ['ps'],
        \ 'BuffergatorSplitHorzKeep'    : ['pi'],
        \ 'BuffergatorNewTabKeep'       : ['pt'],
        \ 'BuffergatorPreviewWindow'    : ['O', 'go'],
        \ 'BuffergatorPreviewVertSplit' : ['S', 'gs'],
        \ 'BuffergatorPreviewHorzSplit' : ['I', 'gi'],
        \ 'BuffergatorPreviewTab'       : ['T'],
        \ 'BuffergatorPreviewNext'      : ['<SPACE>', '<C-N>'],
        \ 'BuffergatorPreviewPrevious'  : ['<C-SPACE>', '<C-P>', '<C-@>'],
        \ 'BuffergatorFindOrBust'       : ['E'],
        \ 'BuffergatorFindOrOpen'       : ['eo'],
        \ 'BuffergatorFindOrVSplit'     : ['es'],
        \ 'BuffergatorFindOrHSplit'     : ['ei'],
        \ 'BuffergatorFindOrTab'        : ['et'],
     \ },
     \ 'tab_catalog_viewer': {
        \ 'BuffergatorTabSelect'         : ['<CR>', 'o'],
        \ 'BuffergatorTabNext'           : ['<SPACE>'],
        \ 'BuffergatorTabPrev'           : ['<C-SPACE>', '<C-@>'],
        \ 'BuffergatorTabWinNext'        : ['<C-N>'],
        \ 'BuffergatorTabWinPrev'        : ['<C-P>'],
     \ },
     \ 'global'                         : {
        \ 'BuffergatorCycleDisplay'     : ['cd'],
        \ 'BuffergatorCyclePath'        : ['cp'],
        \ 'BuffergatorZoomWin'          : ['A'],
        \ 'BuffergatorRebuild'          : ['r'],
        \ 'BuffergatorQuit'             : ['q'],
        \ 'BuffergatorShowHelp'         : ['?', '<F1>'],
     \ },
     \ 'help'                           : {
        \ 'BuffergatorCloseHelp'        : ['?', 'q'],
      \},
   \ }

let s:_keymap_help = [
   \ ['BuffergatorSelectDefault', 'Open in previous window'],
   \ ['BuffergatorSplitVert', 'Open in new vertical split'],
   \ ['BuffergatorSplitHorz', 'Open in a new split'],
   \ ['BuffergatorNewTab', 'Open in a new tab'],
   \ ['BuffergatorPreviewWindow', 'Preview in previous window'],
   \ ['BuffergatorPreviewVertSplit', 'Preview in a new vertical split'],
   \ ['BuffergatorPreviewHorzSplit', 'Preview in a new split'],
   \ ['BuffergatorPreviewTab', 'Preview in a new tab'],
   \ ['BuffergatorPreviewNext', 'Go to next buffer and preview in previous window'],
   \ ['BuffergatorPreviewPrevious', 'Go to previus buffer and preview in in previous window'],
   \ ['BuffergatorSelectKeep', 'Open in previous window and keep buffergator open'],
   \ ['BuffergatorSplitVertKeep', 'Open in vertical split and keep buffergator open'],
   \ ['BuffergatorSplitHorzKeep', 'Open in new split and keep buffergator open'],
   \ ['BuffergatorNewTabKeep', 'Open in new tab and keep buffergator open'],
   \ ['BuffergatorFindOrBust', 'Find buffer in an existing window anywhere, and go to it only if it can be found'],
   \ ['BuffergatorFindOrOpen', 'Find buffer in an existing window or open in previous'],
   \ ['BuffergatorFindOrVSplit', 'Find buffer in an existing window or open in new vertical split'],
   \ ['BuffergatorFindOrHSplit', 'Find buffer in an existing window or open in new split'],
   \ ['BuffergatorTabSelect', 'Opens tab page or window'],
   \ ['BuffergatorTabNext', 'Select the next tab page'],
   \ ['BuffergatorTabPrev', 'Select the previous tab page'],
   \ ['BuffergatorTabWinNext', 'Select the next tab page window entry'],
   \ ['BuffergatorTabWinPrev', 'Select the previous tab page window entry'],
   \ ['BuffergatorCycleSort', 'Cycle through sort regime'],
   \ ['BuffergatorCycleDisplay', 'Cycle the display regime'],
   \ ['BuffergatorCyclePath', 'Cycle the full path display'],
   \ ['BuffergatorZoomWin', 'Zoom / unzoom the window'],
   \ ['BuffergatorRebuild', 'Update rebuild / refresh the buffers catalog'],
   \ ['BuffergatorDelete', 'Delete the selected buffer'],
   \ ['BuffergatorForceDelete', 'Uncondtionally delete the selected buffer'],
   \ ['BuffergatorWipe', 'Wipe the selected buffer'],
   \ ['BuffergatorForceWipe', 'Uncondtionally wipe the selected buffer'],
   \ ['BuffergatorQuit', 'Quit the buffergator window']
   \ ]

if exists('g:buffergator_keymaps')
  call extend(s:_default_keymaps, g:buffergator_keymaps, 'force')
endif

" Plugin Scoped Maps {{{1
"""" Catalog management
noremap <Plug>BuffergatorCycleSort         :<C-U>call b:buffergator_catalog_viewer.cycle_sort_regime()<CR>
noremap <Plug>BuffergatorCycleDisplay      :<C-U>call b:buffergator_catalog_viewer.cycle_display_regime()<CR>
noremap <Plug>BuffergatorCyclePath         :<C-U>call b:buffergator_catalog_viewer.cycle_directory_path_display()<CR>
noremap <Plug>BuffergatorRebuild           :<C-U>call b:buffergator_catalog_viewer.rebuild_catalog()<CR>
noremap <Plug>BuffergatorQuit              :<C-U>call b:buffergator_catalog_viewer.close(1)<CR>
noremap <Plug>BuffergatorDelete            :<C-U>call b:buffergator_catalog_viewer.delete_target(0, 0)<CR>
noremap <Plug>BuffergatorForceDelete       :<C-U>call b:buffergator_catalog_viewer.delete_target(0, 1)<CR>
noremap <Plug>BuffergatorWipe              :<C-U>call b:buffergator_catalog_viewer.delete_target(1, 0)<CR>
noremap <Plug>BuffergatorForceWipe         :<C-U>call b:buffergator_catalog_viewer.delete_target(1, 1)<CR>

""""" Selection                                     :show target and switch focus
noremap <Plug>BuffergatorSelectDefault     :<C-U>call b:buffergator_catalog_viewer.visit_target(!g:buffergator_autodismiss_on_select, 0, "")<CR>
noremap <Plug>BuffergatorSplitVert         :<C-U>call b:buffergator_catalog_viewer.visit_target(!g:buffergator_autodismiss_on_select, 0, "vert sb")<CR>
noremap <Plug>BuffergatorSplitHorz         :<C-U>call b:buffergator_catalog_viewer.visit_target(!g:buffergator_autodismiss_on_select, 0, "sb")<CR>
noremap <Plug>BuffergatorNewTab            :<C-U>call b:buffergator_catalog_viewer.visit_target(!g:buffergator_autodismiss_on_select, 0, "tab sb")<CR>



""""" Selection                                     :show target and switch focus, preserving the catalog regardless of the autodismiss setting
noremap <Plug>BuffergatorSelectKeep        :<C-U>call b:buffergator_catalog_viewer.visit_target(1, 0, "")<CR>
noremap <Plug>BuffergatorSplitVertKeep     :<C-U>call b:buffergator_catalog_viewer.visit_target(1, 0, "vert sb")<CR>
noremap <Plug>BuffergatorSplitHorzKeep     :<C-U>call b:buffergator_catalog_viewer.visit_target(1, 0, "sb")<CR>
noremap <Plug>BuffergatorNewTabKeep        :<C-U>call b:buffergator_catalog_viewer.visit_target(1, 0, "tab sb")<CR>


""""" Preview                                      :show target , keeping focus on catalog
noremap <Plug>BuffergatorPreviewWindow     :<C-U>call b:buffergator_catalog_viewer.visit_target(1, 1, "")<CR>
noremap <Plug>BuffergatorPreviewVertSplit  :<C-U>call b:buffergator_catalog_viewer.visit_target(1, 1, "vert sb")<CR>
noremap <Plug>BuffergatorPreviewHorzSplit  :<C-U>call b:buffergator_catalog_viewer.visit_target(1, 1, "sb")<CR>
noremap <Plug>BuffergatorPreviewTab        :<C-U>call b:buffergator_catalog_viewer.visit_target(1, 1, "tab sb")<CR>
noremap <Plug>BuffergatorPreviewNext       :<C-U>call b:buffergator_catalog_viewer.goto_index_entry("n", 1, 1)<CR>
noremap <Plug>BuffergatorPreviewPrevious   :<C-U>call b:buffergator_catalog_viewer.goto_index_entry("p", 1, 1)<CR>


""""" Preview                                       :go to existing window showing target
noremap <Plug>BuffergatorFindOrBust        :<C-U>call b:buffergator_catalog_viewer.visit_open_target(1, !g:buffergator_autodismiss_on_select, "")<CR>
noremap <Plug>BuffergatorFindOrOpen        :<C-U>call b:buffergator_catalog_viewer.visit_open_target(0, !g:buffergator_autodismiss_on_select, "")<CR>
noremap <Plug>BuffergatorFindOrVSplit      :<C-U>call b:buffergator_catalog_viewer.visit_open_target(0, !g:buffergator_autodismiss_on_select, "vert sb")<CR>
noremap <Plug>BuffergatorFindOrHSplit      :<C-U>call b:buffergator_catalog_viewer.visit_open_target(0, !g:buffergator_autodismiss_on_select, "sb")<CR>
noremap <Plug>BuffergatorFindOrTab         :<C-U>call b:buffergator_catalog_viewer.visit_open_target(0, !g:buffergator_autodismiss_on_select, "tab sb")<CR>


""""" Tab Catalog Maps
noremap <Plug>BuffergatorTabSelect         :call b:buffergator_catalog_viewer.visit_target()<CR>
noremap <Plug>BuffergatorTabNext           :<C-U>call b:buffergator_catalog_viewer.goto_index_entry("n")<CR>
noremap <Plug>BuffergatorTabPrev           :<C-U>call b:buffergator_catalog_viewer.goto_index_entry("p")<CR>
noremap <Plug>BuffergatorTabWinNext        :<C-U>call b:buffergator_catalog_viewer.goto_win_entry("n")<CR>
noremap <Plug>BuffergatorTabWinPrev        :<C-U>call b:buffergator_catalog_viewer.goto_win_entry("p")<CR>

""""" Window control
noremap <Plug>BuffergatorZoomWin           :call b:buffergator_catalog_viewer.toggle_zoom()<CR>
noremap <Plug>BuffergatorShowHelp          :call b:buffergator_catalog_viewer.toggle_help()<CR>

""""" Close the help window
noremap <Plug>BuffergatorCloseHelp         :call b:buffergator_catalog_viewer.close_help()<CR>


" Script Data and Variables {{{1
" =============================================================================

" Split Modes {{{2
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" Split modes are indicated by a single letter. Upper-case letters indicate
" that the SCREEN (i.e., the entire application "window" from the operating
" system's perspective) should be split, while lower-case letters indicate
" that the VIEWPORT (i.e., the "window" in Vim's terminology, referring to the
" various subpanels or splits within Vim) should be split.
" Split policy indicators and their corresponding modes are:
"   ``/`d`/`D'  : use default splitting mode
"   `n`/`N`     : NO split, use existing window.
"   `L`         : split SCREEN vertically, with new split on the left
"   `l`         : split VIEWPORT vertically, with new split on the left
"   `R`         : split SCREEN vertically, with new split on the right
"   `r`         : split VIEWPORT vertically, with new split on the right
"   `T`         : split SCREEN horizontally, with new split on the top
"   `t`         : split VIEWPORT horizontally, with new split on the top
"   `B`         : split SCREEN horizontally, with new split on the bottom
"   `b`         : split VIEWPORT horizontally, with new split on the bottom
let s:buffergator_viewport_split_modes = {
            \ "d"   : "sp",
            \ "D"   : "sp",
            \ "N"   : "buffer",
            \ "n"   : "buffer",
            \ "L"   : "topleft vert sbuffer",
            \ "l"   : "leftabove vert sbuffer",
            \ "R"   : "botright vert sbuffer",
            \ "r"   : "rightbelow vert sbuffer",
            \ "T"   : "topleft sbuffer",
            \ "t"   : "leftabove sbuffer",
            \ "B"   : "botright sbuffer",
            \ "b"   : "rightbelow sbuffer",
            \ }
" 2}}}

" Buffer Status Symbols {{{3
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" set the decorations for the buffer line and what column they appear in
" '<buffer_property>' :   ["<symbol>",<column>,<priority>]

function! s:_alternate_arrow(buffer)
  if a:buffer == -1
    return "↓↑"
  endif
  " point toward the current buffer
  let l:current_buffer_index = get(get(s:_catalog_viewer.find_buffer("is_current",1),0,{}),'index',-1)
  let l:alternate_buffer_index = get(get(s:_catalog_viewer.find_buffer("is_alternate",1),0,{}),'index',-1)
  if l:current_buffer_index < l:alternate_buffer_index
    return "↑"
  else
    return "↓"
  endif
endfunction 

function! s:_ontab_number(buffer)
  if a:buffer == -1
    return "[:digit:]"
  else
    for l:tab_page in range(1,tabpagenr('$'))
       if index(tabpagebuflist(l:tab_page), a:buffer) >= 0
         return l:tab_page
       endif
    endfor
  endif
endfunction

function! s:_listed_buffer(buffer)
  if a:buffer == -1
    return '[:space:]'
  else
    return " "
  end
endfunction

function! s:_buffer_line_symbol_list(status)
  try
    let BufferGatorSymbolFunc = function(s:buffergator_buffer_line_symbols[a:status][0])
    let l:symbols = BufferGatorSymbolFunc(-1)
    unlet BufferGatorSymbolFunc
  catch /^Vim\%((\a\+)\)\=:E129/
    " catch the inability to turn that into a function and
    " return the string symbol instead
    let l:symbols = s:buffergator_buffer_line_symbols[a:status][0]
  endtry
  return "[" . l:symbols . "]"
endfunction

" Each buffer has several attributes that are tracked by the buffergator
" you can use different symbols depending on your preferences
" '<buffer_property>' :   ["<symbol>",<column>,<priority>]
" each entry in this table will generate a syntax entry
" that can be used to match the buffer status
" if a function name is given for the symbol status, that function
" is called with the buffer number whenever the symbol would be drawn.
"
" the column is the column in which the symbol should appear
" the priorty is the relative priorty of the symbol for that colum.
" for instance, a readerror has a higher priority than a modified buffer
" so a buffer with readerror will always show the readerror symbol
" even if the buffer was also modified
"
" if the buffernumber is -1 the function should return a character class
" compatible regex fragment of every character it could possibly return.
"
" the buffer options in general correspond to Vim buffer states
" current - the current editing buffer
" alternate - the alternate buffer
" readerror - the buffer could not be read
" modified - the buffer has been modified
" readonly - buffer is readonly
" ontab - buffer is visible on the current tab
" visible - buffer is visible on a different tab
" listed - always true - buffergator does not display unlisted buffers
"
"
if has("multi_byte") && &encoding == 'utf-8'
  let s:buffergator_buffer_line_symbols = {
    \ 'current'  :    ["→"                   , 0 , 1 ] ,
    \ 'alternate':    ["s:_alternate_arrow"  , 0 , 2 ] ,
    \ 'readerror':    ["✗"                   , 1 , 1 ] ,
    \ 'modified' :    ["▪"                   , 1 , 2 ] ,
    \ 'readonly' :    ["⭤"                   , 1 , 3 ] ,
    \ 'ontab'    :    ["⋅"                   , 2 , 1 ] ,
    \ 'visible'  :    ["s:_ontab_number"     , 2 , 2 ] ,
    \ 'listed'   :    ["s:_listed_buffer"    , 3 , 1 ] ,
    \ }
else
  let s:buffergator_buffer_line_symbols = {
    \ 'current'  :    [">"               , 0 , 1] ,
    \ 'alternate':    ["#"               , 0 , 2] ,
    \ 'readerror':    ["x"               , 1 , 1] ,
    \ 'modified' :    ["+"               , 1 , 2] ,
    \ 'readonly' :    ["!"               , 1 , 3] ,
    \ 'on_tab'   :    [":"               , 2 , 1] ,
    \ 'visible'  :    ["-"               , 2 , 2]
    \ 'listed'   :    ["s:_listed_buffer", 3 , 1]
    \ }
endif

" Catalog Sort Regimes {{{2
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
let s:buffergator_catalog_sort_regimes = ['basename', 'filepath', 'extension', 'bufnum', 'mru']
let s:buffergator_catalog_sort_regime_desc = {
            \ 'basename' : ["basename", "by basename (followed by directory)"],
            \ 'filepath' : ["filepath", "by (full) filepath"],
            \ 'extension'  : ["ext", "by extension (followed by full filepath)"],
            \ 'bufnum'  : ["bufnum", "by buffer number"],
            \ 'mru'  : ["mru", "by most recently used"],
            \ }
let s:buffergator_default_catalog_sort_regime = "bufnum"
" 2}}}

" Catalog Display Regimes {{{2
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
let s:buffergator_catalog_display_regimes = ['basename', 'filepath', 'bufname']
let s:buffergator_catalog_display_regime_desc = {
            \ 'basename' : ["basename", "basename (followed by directory)"],
            \ 'filepath' : ["filepath", "full filepath"],
            \ 'bufname'  : ["bufname", "buffer name"],
            \ }
let s:buffergator_default_display_regime = "basename"
" 2}}}

" MRU {{{2
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
let s:buffergator_mru = []
" 2}}}
" 1}}}

" Utilities {{{1
" ==============================================================================

" Text Formatting {{{2
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function! s:_format_align_left(text, width, fill_char)
    let l:fill = repeat(a:fill_char, a:width-len(a:text))
    return a:text . l:fill
endfunction

function! s:_format_align_right(text, width, fill_char)
    let l:fill = repeat(a:fill_char, a:width-len(a:text))
    return l:fill . a:text
endfunction

function! s:_format_align_center(text, width, fill_char)
    let l:text = copy(a:text)
    let l:half_width = a:width / 2
    if len(l:text) % 2
        let l:half_width -= 1
    endif
    let l:fill = repeat(a:fill_char, (l:half_width - (len(l:text) / 2 )))
    return l:fill . l:text . l:fill
endfunction

function! s:_format_time(secs)
    if exists("*strftime")
        return strftime("%Y-%m-%d %H:%M:%S", a:secs)
    else
        return (localtime() - a:secs) . " secs ago"
    endif
endfunction

function! s:_format_escaped_filename(file)
  if exists('*fnameescape')
    return fnameescape(a:file)
  else
    return escape(a:file," \t\n*?[{`$\\%#'\"|!<")
  endif
endfunction

" trunc: -1 = truncate left, 0 = no truncate, +1 = truncate right
function! s:_format_truncated(str, max_len, trunc)
    if len(a:str) > a:max_len
        if a:trunc > 0
            return strpart(a:str, a:max_len - 4) . " ..."
        elseif a:trunc < 0
            return '... ' . strpart(a:str, len(a:str) - a:max_len + 4)
        endif
    else
        return a:str
    endif
endfunction

" Pads/truncates text to fit a given width.
" align: -1 = align left, 0 = no align, 1 = align right
" trunc: -1 = truncate left, 0 = no truncate, +1 = truncate right
function! s:_format_filled(str, width, align, trunc)
    let l:prepped = a:str
    if a:trunc != 0
        let l:prepped = s:_format_truncated(a:str, a:width, a:trunc)
    endif
    if len(l:prepped) < a:width
        if a:align > 0
            let l:prepped = s:_format_align_right(l:prepped, a:width, " ")
        elseif a:align < 0
            let l:prepped = s:_format_align_left(l:prepped, a:width, " ")
        endif
    endif
    return l:prepped
endfunction

" 2}}}

" Messaging {{{2
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function! s:NewMessenger(name)

    " allocate a new pseudo-object
    let l:messenger = {}
    let l:messenger["name"] = a:name
    if empty(a:name)
        let l:messenger["title"] = "buffergator"
    else
        let l:messenger["title"] = "buffergator (" . l:messenger["name"] . ")"
    endif

    function! l:messenger.format_message(leader, msg) dict
        return self.title . ": " . a:leader.a:msg
    endfunction

    function! l:messenger.format_exception( msg) dict
        return a:msg
    endfunction

    function! l:messenger.send_error(msg) dict
        redraw
        echohl ErrorMsg
        echomsg self.format_message("[ERROR] ", a:msg)
        echohl None
    endfunction

    function! l:messenger.send_warning(msg) dict
        redraw
        echohl WarningMsg
        echomsg self.format_message("[WARNING] ", a:msg)
        echohl None
    endfunction

    function! l:messenger.send_status(msg) dict
        redraw
        echohl None
        echomsg self.format_message("", a:msg)
    endfunction

    function! l:messenger.send_info(msg) dict
        redraw
        echohl None
        echo self.format_message("", a:msg)
    endfunction

    return l:messenger

endfunction
" 2}}}

" Catalog, Buffer, Windows, Files, etc. Management {{{2
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" Searches for all buffers that have a buffer-scoped variable `varname`
" with value that matches the expression `expr`. Returns list of buffer
" numbers that meet the criterion.
function! s:_find_buffers_with_var(varname, expr)
    let l:results = []
    for l:bni in range(1, bufnr("$"))
        if !bufexists(l:bni)
            continue
        endif
        let l:bvar = getbufvar(l:bni, "")
        if empty(a:varname)
            call add(l:results, l:bni)
        elseif has_key(l:bvar, a:varname) && empty(a:expr)
            call add(l:results, l:bni)
        elseif has_key(l:bvar, a:varname) && l:bvar[a:varname] =~ a:expr
            call add(l:results, l:bni)
        endif
    endfor
    return l:results
endfunction

" Returns split mode to use for a new Buffergator viewport.
function! s:_get_split_mode()
    if has_key(s:buffergator_viewport_split_modes, g:buffergator_viewport_split_policy)
        return s:buffergator_viewport_split_modes[g:buffergator_viewport_split_policy]
    else
        call s:_buffergator_messenger.send_error("Unrecognized split mode specified by 'g:buffergator_viewport_split_policy': " . g:buffergator_viewport_split_policy)
    endif
endfunction

" Detect filetype. From the 'taglist' plugin.
" Copyright (C) 2002-2007 Yegappan Lakshmanan
function! s:_detect_filetype(fname)
    " Ignore the filetype autocommands
    let old_eventignore = &eventignore
    set eventignore=FileType
    " Save the 'filetype', as this will be changed temporarily
    let old_filetype = &filetype
    " Run the filetypedetect group of autocommands to determine
    " the filetype
    exe 'doautocmd filetypedetect BufRead ' . a:fname
    " Save the detected filetype
    let ftype = &filetype
    " Restore the previous state
    let &filetype = old_filetype
    let &eventignore = old_eventignore
    return ftype
endfunction

function! s:_is_full_width_window(win_num)
    if winwidth(a:win_num) == &columns
        return 1
    else
        return 0
    endif
endfunction!

function! s:_is_full_height_window(win_num)
    if winheight(a:win_num) + &cmdheight + 1 == &lines
        return 1
    else
        return 0
    endif
endfunction!

" Moves (or adds) the given buffer number to the top of the list
function! s:_update_mru(acmd_bufnr)
    let bnum = a:acmd_bufnr + 0
    if bnum == 0
        return
    endif
    call filter(s:buffergator_mru, 'v:val !=# bnum')
    call insert(s:buffergator_mru, bnum, 0)
endfunction

" 2}}}

" Sorting {{{2
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" comparison function used for sorting dictionaries by value
function! s:_compare_dicts_by_value(m1, m2, key)
    if a:m1[a:key] < a:m2[a:key]
        return -1
    elseif a:m1[a:key] > a:m2[a:key]
        return 1
    else
        return 0
    endif
endfunction

function! s:_compare_symbols_by_priorty(s1, s2)
  " 0 - symbol
  " 1 - column 
  " 2 - priorty
  if a:s1[1][1] == a:s2[1][1]
    if a:s1[1][2] == a:s2[1][2]
      throw 'conflicting priorites for buffer symbols'
    endif
    return (a:s1[1][2] > a:s2[1][2] ? 1 : -1)
  else
    return (a:s1[1][1] > a:s2[1][1] ? 1 : -1)
  endif
endfunction


" comparison function used for sorting buffers catalog by buffer number
function! s:_compare_dicts_by_bufnum(m1, m2)
    return s:_compare_dicts_by_value(a:m1, a:m2, "bufnum")
endfunction

" comparison function used for sorting buffers catalog by buffer name
function! s:_compare_dicts_by_bufname(m1, m2)
    return s:_compare_dicts_by_value(a:m1, a:m2, "bufname")
endfunction

" comparison function used for sorting buffers catalog by (full) filepath
function! s:_compare_dicts_by_filepath(m1, m2)
    if a:m1["parentdir"] < a:m2["parentdir"]
        return -1
    elseif a:m1["parentdir"] > a:m2["parentdir"]
        return 1
    else
        if a:m1["basename"] < a:m2["basename"]
            return -1
        elseif a:m1["basename"] > a:m2["basename"]
            return 1
        else
            return 0
        endif
    endif
endfunction

" comparison function used for sorting buffers catalog by extension
function! s:_compare_dicts_by_extension(m1, m2)
    if a:m1["extension"] < a:m2["extension"]
        return -1
    elseif a:m1["extension"] > a:m2["extension"]
        return 1
    else
        return s:_compare_dicts_by_filepath(a:m1, a:m2)
    endif
endfunction

" comparison function used for sorting buffers catalog by basename
function! s:_compare_dicts_by_basename(m1, m2)
    return s:_compare_dicts_by_value(a:m1, a:m2, "basename")
endfunction

" comparison function used for sorting buffers catalog by mru
function! s:_compare_dicts_by_mru(m1, m2)
    let l:i1 = index(s:buffergator_mru, a:m1['bufnum'])
    let l:i2 = index(s:buffergator_mru, a:m2['bufnum'])
    if l:i1 < l:i2
        return -1
    elseif l:i1 > l:i2
        return 1
    else
        return 0
    endif
endfunction

" 2}}}

" 1}}}

" CatalogViewer {{{1
" ============================================================================

function! s:NewCatalogViewer(name, title)

    " initialize
    let l:catalog_viewer = {}
    let l:catalog_viewer["bufname"] = a:name
    let l:catalog_viewer["title"] = a:title
    let l:buffergator_bufs = s:_find_buffers_with_var("is_buffergator_buffer", 1)
    let l:catalog_viewer["jump_map"] = {}
    let l:catalog_viewer["split_mode"] = s:_get_split_mode()
    let l:catalog_viewer["sort_regime"] = g:buffergator_sort_regime
    let l:catalog_viewer["display_regime"] = g:buffergator_display_regime
    let l:catalog_viewer["is_zoomed"] = 0
    let l:catalog_viewer["columns_expanded"] = 0
    let l:catalog_viewer["lines_expanded"] = 0
    let l:catalog_viewer["max_buffer_basename_len"] = 30
    let l:catalog_viewer["buffers_catalog"] = {}
    let l:catalog_viewer["current_buffer_index"] = -1
    let l:catalog_viewer["prototype"] = "catalog_viewer"

    let l:catalog_viewer["symbol_columns"] = max(map(values(s:buffergator_buffer_line_symbols),"v:val[1]")) + 1
    let l:catalog_viewer["symbol_order"] = map(sort(items(s:buffergator_buffer_line_symbols),"s:_compare_symbols_by_priorty"),"v:val[0]")

    " Initialize object state.
    let l:catalog_viewer["bufnum"] = -1

    " Opens the buffer for viewing, creating it if needed.
    " First argument, if given, should be false if the buffers info is *not*
    " to be repopulated; defaults to 1
    " Second argument, if given, should be number of calling window.
    function! l:catalog_viewer.open(...) dict "{{{
        " populate data
        if (a:0 == 0 || a:1 > 0)
            call self.update_buffers_info()
        endif
        " store calling buffer
        if (a:0 >= 2 && a:2)
            let self.calling_view = a:2
        else
            let self.calling_view = bufnr("%")
        endif
        " get buffer number of the catalog view buffer, creating it if neccessary
        if self.bufnum < 0 || !bufexists(self.bufnum)
            " create and render a new buffer
            call self.create_buffer()
        else
            if getbufvar(self.bufnum,"buffergator_catalog_viewer") != self
              call self.initialize_buffer()
            endif
            " buffer exists: activate a viewport on it according to the
            " spawning mode, re-rendering the buffer with the catalog if needed
            call self.activate_viewport()
            call self.render_buffer()
        endif
    endfunction "}}}

    function! l:catalog_viewer.line_symbols(bufinfo) dict
      let l:line_symbols = repeat([" "], self.symbol_columns)
      " so we can control the order they are shown in
      for l:status in reverse(copy(self.symbol_order))
        if a:bufinfo['is_' . l:status]
          let l:line_symbol = " "

          " try to convert the symbol to a function - if unsuccessful,
          " use the symbol as a string
          " as an aside - a pox on whoever thought this was a sensible
          " way to catch exceptions
          try
            let BufferGatorSymbolFunc = function(s:buffergator_buffer_line_symbols[l:status][0])
            let l:line_symbol = BufferGatorSymbolFunc(a:bufinfo["bufnum"])
            unlet BufferGatorSymbolFunc
          catch /^Vim\%((\a\+)\)\=:E129/
            let l:line_symbol = s:buffergator_buffer_line_symbols[l:status][0]
          endtry
          
          let l:line_symbols[s:buffergator_buffer_line_symbols[l:status][1]] = l:line_symbol
        endif
      endfor
      let l:line = s:_format_filled(join(l:line_symbols,""),self.symbol_columns,-1,0)
      return l:line
      return l:line_symbols
    endfunction "}}}

    function! l:catalog_viewer.toggle_help() dict
      let l:help_buffer = bufnr("[[buffergator-help]]", 1)
      if bufwinnr(l:help_buffer) < 0
          let self.split_mode = s:_get_split_mode()
          call self.expand_screen()
          execute("silent keepalt keepjumps " . self.split_mode . " " . l:help_buffer)
          if g:buffergator_viewport_split_policy =~ '[RrLl]' && g:buffergator_split_size
              execute("vertical resize " . g:buffergator_split_size)
              setlocal winfixwidth
          elseif g:buffergator_viewport_split_policy =~ '[TtBb]' && g:buffergator_split_size
              execute("resize " . g:buffergator_split_size)
              setlocal winfixheight
          endif
      else
        execute "bdelete " l:help_buffer
        return
      endif
      
      setlocal modifiable
      let l:window_width = winwidth(0) - 6 
      " adjust the window so it's an even number if the window with is odd 
      let l:window_width += l:window_width % 2 ? 1 : 0
      let l:column_1 = float2nr(floor((l:window_width - 4) * 0.4))
      let l:column_2 = float2nr(ceil((l:window_width - 4) * 0.6))
      let l:help_text = ['']
      let l:help_text += ['┌' . s:_format_align_center('  Buffergator Help  ', l:window_width, '─') . '┐']
      let l:help_text += ['│' . s:_format_align_center('',l:window_width,' ') . '│']
      echomsg string([l:window_width, l:column_1, l:column_2])
      "
      for l:command_set in ['buffer_catalog_viewer', 'tab_catalog_viewer', 'global', 'help'] 
          for l:plug_mapping in keys(s:_default_keymaps[l:command_set])
              if has_key(s:_keymap_help,l:plug_mapping)
                  let l:keys = join(s:_default_keymaps[l:command_set][l:plug_mapping],", ")
                  let l:help = s:_keymap_help[l:plug_mapping] 
                  " ha ha syntax fail.
                  let l:rows_for_columns = [strlen(l:keys) / l:column_1 + 1, strlen(l:help) / l:column_2 + 1]
                  
                  let l:rows = max(l:rows_for_columns)
                  " to divide on the first space before the column break
                  " we split on the last space before our column width
                  " use a zero width match to avoid remove parts of
                  " the string, and to split multiple times
                  " \(\s[^ ]*\%24c\)\@=
                  let l:keys_split = split(l:keys,'\v\s([^ ]*%' . l:column_1 . 'c)@=')
                  let l:help_split = split(l:help,'\v\s([^ ]*%' . l:column_2 . 'c)@=')

                  for l:row in range(l:rows)
                      " use only the matching portion 
                      let l:key_string = s:_format_align_left(get(l:keys_split,l:row,""), l:column_1, ' ')
                      let l:help_string = s:_format_align_right(get(l:help_split,l:row,""), l:column_2, ' ')
                      let l:help_text += ['│ ' . 
                            \ s:_format_align_center(l:key_string . '│ ' . 
                            \ l:help_string, l:window_width, ' ') . ' │']
                  endfor
              endif
          endfor
      endfor
      let l:help_text += ['└' . s:_format_align_center('', l:window_width, '─') . '┘']
      normal Gdgg
      call append(0,l:help_text)
      call self.setup_buffer_opts()
      normal gg 
      syntax clear
      syntax match BuffergatorTitle 'Buffergator Help'
      syntax match BuffergatorKeys  /\v(^│).{-}\ze(\s│)/hs=s+1
      syntax match BuffergatorHelp /\v(\s│).{-}│/ contains=BuffergatorBorder
      syntax match BuffergatorBorder '[─┘┐└┌│]' contains=BuffergatorKeys

      highlight link BuffergatorBorder NonText
      highlight link BuffergatorTitle Title
      highlight link BuffergatorKeys Identifier 
      highlight link BuffergatorHelp String
      setlocal nomodifiable

      mapclear <buffer>
      call self.disable_editing_keymaps()
      for l:command_set in ['help']
        for l:command in keys(s:_default_keymaps[l:command_set])
          for l:sequence in s:_default_keymaps[l:command_set][l:command]
            execute 'nmap <buffer> ' . l:sequence . ' ' . '<Plug>' . l:command
          endfor
        endfor
      endfor
    endfunction


    " find buffers in our catalog with matching properties
    function! l:catalog_viewer.find_buffer(property, value) dict
      let l:results = []

      for l:index in range(0, len(self.buffers_catalog) - 1)
        let l:buffer = self.buffers_catalog[l:index]
        if l:buffer[a:property] == a:value
          let l:r_buffer = copy(l:buffer)
          let l:r_buffer['index'] = l:index
          call add(l:results, l:r_buffer)
        endif
      endfor
      return l:results
    endfunction

    function! l:catalog_viewer.list_buffers() dict
        let bcat = []
        redir => buffers_output
        execute('silent ls')
        redir END
        let self.max_buffer_basename_len = 0
        let l:tab_buffers = tabpagebuflist()
        let l:buffers_output_rows = split(l:buffers_output, "\n")
        for l:buffers_output_row in l:buffers_output_rows
            let l:parts = matchlist(l:buffers_output_row, '^\s*\(\d\+\)\(.....\) "\(.*\)"')
            let l:info = {}
            let l:info["bufnum"] = l:parts[1] + 0
            "is_ontab is set on buffers that are visible on the current tab
            if index(l:tab_buffers,l:info["bufnum"]) >= 0 
                let l:info["is_ontab"] = 1
            else
                let l:info["is_ontab"] = 0
            endif
            if l:parts[2][0] == "u"
                let l:info["is_unlisted"] = 1
                let l:info["is_listed"] = 0
            else
                let l:info["is_unlisted"] = 0
                let l:info["is_listed"] = 1
            endif
            if l:parts[2][1] == "%"
                let l:info["is_current"] = 1
                let l:info["is_alternate"] = 0
            elseif l:parts[2][1] == "#"
                let l:info["is_current"] = 0
                let l:info["is_alternate"] = 1
            else
                let l:info["is_current"] = 0
                let l:info["is_alternate"] = 0
            endif
            if l:parts[2][2] == "a"
                let l:info["is_active"] = 1
                let l:info["is_loaded"] = 1
                let l:info["is_visible"] = 1
            elseif l:parts[2][2] == "h"
                let l:info["is_active"] = 0
                let l:info["is_loaded"] = 1
                let l:info["is_visible"] = 0
            else
                let l:info["is_active"] = 0
                let l:info["is_loaded"] = 0
                let l:info["is_visible"] = 0
            endif
            if l:parts[2][3] == "-"
                let l:info["is_modifiable"] = 0
                let l:info["is_readonly"] = 0
            elseif l:parts[2][3] == "="
                let l:info["is_modifiable"] = 1
                let l:info["is_readonly"] = 1
            else
                let l:info["is_modifiable"] = 1
                let l:info["is_readonly"] = 0
            endif
            if l:parts[2][4] == "+"
                let l:info["is_modified"] = 1
                let l:info["is_readerror"] = 0
            elseif l:parts[2][4] == "x"
                let l:info["is_modified"] = 0
                let l:info["is_readerror"] = 1 
            else
                let l:info["is_modified"] = 0
                let l:info["is_readerror"] = 0
            endif
            let l:info["bufname"] = parts[3]
            let l:info["filepath"] = fnamemodify(l:info["bufname"], ":p")
            " if g:buffergator_show_full_directory_path
            "     let l:info["filepath"] = fnamemodify(l:info["bufname"], ":p")
            " else
            "     let l:info["filepath"] = fnamemodify(l:info["bufname"], ":.")
            " endif
            let l:info["basename"] = fnamemodify(l:info["bufname"], ":t")
            if len(l:info["basename"]) > self.max_buffer_basename_len
                let self.max_buffer_basename_len = len(l:info["basename"])
            endif
            let l:info["parentdir"] = fnamemodify(l:info["bufname"], ":p:h")
            if g:buffergator_show_full_directory_path
                let l:info["parentdir"] = fnamemodify(l:info["bufname"], ":p:h")
            else
                let l:info["parentdir"] = fnamemodify(l:info["bufname"], ":h")
            endif
            let l:info["extension"] = fnamemodify(l:info["bufname"], ":e")
            call add(bcat, l:info)
            " let l:buffers_info[l:info[l:key]] = l:info
        endfor
        let l:sort_func = "s:_compare_dicts_by_" . self.sort_regime
        return sort(bcat, l:sort_func)
    endfunction "}}}

    " Opens viewer if closed, closes viewer if open.
    function! l:catalog_viewer.toggle() dict "{{{
        " get buffer number of the catalog view buffer, creating it if neccessary
        if self.bufnum < 0 || !bufexists(self.bufnum)
            call self.open()
        else
            let l:bfwn = bufwinnr(self.bufnum)
            if l:bfwn >= 0
                call self.close(1)
            else
                call self.open()
            endif
        endif
    endfunction "}}}

    function! l:catalog_viewer.render_entry(bufinfo) dict "{{{
        let l:bufinfo = a:bufinfo

        if l:bufinfo.is_current
          let self.current_buffer_index = line("$")
        endif

        let l:bufnum_str = s:_format_filled(l:bufinfo.bufnum, 3, 1, 0)
        let l:line = "[" . l:bufnum_str . "]"
       
        let l:line .= s:_format_filled(self.line_symbols(l:bufinfo),4,-1,0)
        
        if self.display_regime == "basename"
            let l:line .= s:_format_align_left(l:bufinfo.basename, self.max_buffer_basename_len, " ")
            let l:line .= "	"
            let l:line .= l:bufinfo.parentdir
        elseif self.display_regime == "filepath"
            let l:line .= l:bufinfo.filepath
        elseif self.display_regime == "bufname"
            let l:line .= l:bufinfo.bufname
        else
            throw s:_buffergator_messenger.format_exception("Invalid display regime: '" . self.display_regime . "'")
        endif
        return l:line
    endfunction "}}}

    " Creates a new buffer, renders and opens it.
    function! l:catalog_viewer.create_buffer() dict "{{{
        " get a new buf reference
        let self.bufnum = bufnr(self.bufname, 1)
        " get a viewport onto it
        call self.activate_viewport()
        " initialize it (includes "claiming" it)
        call self.initialize_buffer()
        " render it
        call self.render_buffer()
    endfunction "}}}

    " Opens a viewport on the buffer according, creating it if neccessary
    " according to the spawn mode. Valid buffer number must already have been
    " obtained before this is called.
    function! l:catalog_viewer.activate_viewport() dict
        let l:bfwn = bufwinnr(self.bufnum)
        if l:bfwn == winnr()
            " viewport wth buffer already active and current
            return
        elseif l:bfwn >= 0
            " viewport with buffer exists, but not current
            execute(l:bfwn . " wincmd w")
        else
            " create viewport
            let self.split_mode = s:_get_split_mode()
            call self.expand_screen()
            execute("silent keepalt keepjumps " . self.split_mode . " " . self.bufnum)
            if g:buffergator_viewport_split_policy =~ '[RrLl]' && g:buffergator_split_size
                execute("vertical resize " . g:buffergator_split_size)
                setlocal winfixwidth
            elseif g:buffergator_viewport_split_policy =~ '[TtBb]' && g:buffergator_split_size
                execute("resize " . g:buffergator_split_size)
                setlocal winfixheight
            endif
        endif
    endfunction "}}}

    " Sets up buffer environment.
    function! l:catalog_viewer.initialize_buffer() dict "{{{
        call self.claim_buffer()
        call self.setup_buffer_opts()
        call self.setup_buffer_syntax()
        call self.setup_buffer_commands()
        call self.setup_buffer_keymaps()
        call self.setup_buffer_statusline()
    endfunction "}}}

    " 'Claims' a buffer by setting it to point at self.
    function! l:catalog_viewer.claim_buffer() dict "{{{
        call setbufvar("%", "is_buffergator_buffer", 1)
        call setbufvar("%", "buffergator_catalog_viewer", self)
        call setbufvar("%", "buffergator_last_render_time", 0)
        call setbufvar("%", "buffergator_cur_line", 0)
    endfunction "}}}

    " 'Unclaims' a buffer by stripping all buffergator vars
    function! l:catalog_viewer.unclaim_buffer() dict "{{{
        if self.bufnum = bufnr('%') 
          unlet b:is_buffergator_buffer 
          unlet b:buffergator_catalog_viewer
          unlet b:buffergator_last_render_time
          unlet b:buffergator_cur_line
        endif
    endfunction "}}}

    " Sets buffer options.
    function! l:catalog_viewer.setup_buffer_opts() dict "{{{
        setlocal buftype=nofile
        setlocal noswapfile
        setlocal nowrap
        set bufhidden=hide
        setlocal nobuflisted
        setlocal nolist
        setlocal noinsertmode
        setlocal nonumber
        setlocal cursorline
        setlocal nospell
        setlocal matchpairs=""
        setlocal foldmethod=syntax
        setlocal foldtext=BuffergatorTabsFoldtext()
        setlocal foldlevel=2
    endfunction "}}}

    " Sets buffer commands.
    function! l:catalog_viewer.setup_buffer_commands() dict "{{{
        " command! -bang -nargs=* Bdfilter :call b:buffergator_catalog_viewer.set_filter('<bang>', <q-args>)
        augroup BuffergatorCatalogViewer
            au!
            autocmd BufLeave <buffer> let s:_buffergator_last_catalog_viewed = b:buffergator_catalog_viewer
        augroup END
    endfunction "}}}

    function! l:catalog_viewer.disable_editing_keymaps() dict "{{{
        """" Disabling of unused modification keys
        for key in [".", "p", "P", "C", "x", "X", "r", "R", "i", "I", "a", "A", "D", "S", "U"]
            try
                execute "nnoremap <buffer> " . key . " <NOP>"
            catch //
            endtry
        endfor
    endfunction "}}}

    " Close and quit the viewer.
    function! l:catalog_viewer.close(restore_prev_window) dict "{{{
        if self.bufnum < 0 || !bufexists(self.bufnum)
            return
        endif
        call self.contract_screen()
        if a:restore_prev_window
            if !self.is_usable_viewport(winnr("#")) && self.first_usable_viewport() ==# -1
            else
                try
                    if !self.is_usable_viewport(winnr("#"))
                        execute(self.first_usable_viewport() . "wincmd w")
                    else
                        execute('wincmd p')
                    endif
                catch //
                endtry
            endif
        endif
        execute("bwipe " . self.bufnum)
    endfunction "}}}

    function! l:catalog_viewer.expand_screen() dict "{{{
        if has("gui_running") && g:buffergator_autoexpand_on_split && g:buffergator_split_size
            if g:buffergator_viewport_split_policy =~ '[RL]'
                let self.pre_expand_columns = &columns
                let &columns += g:buffergator_split_size
                let self.columns_expanded = &columns - self.pre_expand_columns
            else
                let self.columns_expanded = 0
            endif
            if g:buffergator_viewport_split_policy =~ '[TB]'
                let self.pre_expand_lines = &lines
                let &lines += g:buffergator_split_size
                let self.lines_expanded = &lines - self.pre_expand_lines
            else
                let self.lines_expanded = 0
            endif
        endif
    endfunction "}}}

    function! l:catalog_viewer.contract_screen() dict "{{{
        if self.columns_expanded
                    \ && &columns - self.columns_expanded > 20
            let new_size  = &columns - self.columns_expanded
            if new_size < self.pre_expand_columns
                let new_size = self.pre_expand_columns
            endif
            let &columns = new_size
        endif
        if self.lines_expanded
                    \ && &lines - self.lines_expanded > 20
            let new_size  = &lines - self.lines_expanded
            if new_size < self.pre_expand_lines
                let new_size = self.pre_expand_lines
            endif
            let &lines = new_size
        endif
    endfunction "}}}

    function! l:catalog_viewer.highlight_current_line() dict "{{{
        if self.current_buffer_index
          execute ":" . self.current_buffer_index
          if self.current_buffer_index < line('w0')
            execute "silent! normal! zt"
          elseif self.current_buffer_index > line('w$')
            execute "silent! normal! zb"
          endif
        endif
    endfunction "}}}

    " Clears the buffer contents.
    function! l:catalog_viewer.clear_buffer() dict "{{{
        call cursor(1, 1)
        exec 'silent! normal! "_dG'
    endfunction "}}}

    " from NERD_Tree, via VTreeExplorer: determine the number of windows open
    " to this buffer number.
    function! l:catalog_viewer.num_viewports_on_buffer(bnum) dict "{{{
        let cnt = 0
        let winnum = 1
        while 1
            let bufnum = winbufnr(winnum)
            if bufnum < 0
                break
            endif
            if bufnum ==# a:bnum
                let cnt = cnt + 1
            endif
            let winnum = winnum + 1
        endwhile
        return cnt
    endfunction "}}}

    " from NERD_Tree: find the window number of the first normal window
    function! l:catalog_viewer.first_usable_viewport() dict "{{{
        let i = 1
        while i <= winnr("$")
            let bnum = winbufnr(i)
            if bnum != -1 && getbufvar(bnum, '&buftype') ==# ''
                        \ && !getwinvar(i, '&previewwindow')
                        \ && (!getbufvar(bnum, '&modified') || &hidden)
                return i
            endif

            let i += 1
        endwhile
        return -1
    endfunction "}}}

    " from NERD_Tree: returns 0 if opening a file from the tree in the given
    " window requires it to be split, 1 otherwise
    function! l:catalog_viewer.is_usable_viewport(winnumber) dict "{{{
        "gotta split if theres only one window (i.e. the NERD tree)
        if winnr("$") ==# 1
            return 0
        endif
        let oldwinnr = winnr()
        execute(a:winnumber . "wincmd p")
        let specialWindow = getbufvar("%", '&buftype') != '' || getwinvar('%', '&previewwindow')
        let modified = &modified
        execute(oldwinnr . "wincmd p")
        "if its a special window e.g. quickfix or another explorer plugin then we
        "have to split
        if specialWindow
            return 0
        endif
        if &hidden
            return 1
        endif
        return !modified || self.num_viewports_on_buffer(winbufnr(a:winnumber)) >= 2
    endfunction "}}}

    " Acquires a viewport to show the source buffer. Returns the split command
    " to use when switching to the buffer.
    function! l:catalog_viewer.acquire_viewport(split_cmd) "{{{
        if self.split_mode == "buffer" && empty(a:split_cmd)
            " buffergator used original buffer's viewport,
            " so the the buffergator viewport is the viewport to use
            return ""
        endif
        if !self.is_usable_viewport(winnr("#")) && self.first_usable_viewport() ==# -1
            " no appropriate viewport is available: create new using default
            " split mode
            " TODO: maybe use g:buffergator_viewport_split_policy?
            if empty(a:split_cmd)
                return "sb"
            else
                return a:split_cmd
            endif
        else
            try
                if !self.is_usable_viewport(winnr("#"))
                    execute(self.first_usable_viewport() . "wincmd w")
                else
                    execute('wincmd p')
                endif
            catch /^Vim\%((\a\+)\)\=:E37/
                echo v:exception
            catch /^Vim\%((\a\+)\)\=:/
                echo v:exception
            endtry
            return a:split_cmd
        endif
    endfunction "}}}

    " Finds next occurrence of specified pattern.
    function! l:catalog_viewer.goto_pattern(pattern, direction) dict range "{{{
        if a:direction == "b" || a:direction == "p"
            let l:flags = "b"
            " call cursor(line(".")-1, 0)
        else
            let l:flags = ""
            " call cursor(line(".")+1, 0)
        endif
        if g:buffergator_move_wrap
            let l:flags .= "w"
        else
            let l:flags .= "W"
        endif
        let l:flags .= "e"
        let l:lnum = -1
        for i in range(v:count1)
            if search(a:pattern, l:flags) < 0
                break
            else
                let l:lnum = 1
            endif
        endfor
        if l:lnum < 0
            if l:flags[0] == "b"
                call s:_buffergator_messenger.send_info("No previous results")
            else
                call s:_buffergator_messenger.send_info("No more results")
            endif
            return 0
        else
            return 1
        endif
    endfunction "}}}

    " Cycles sort regime.
    function! l:catalog_viewer.cycle_sort_regime() dict "{{{
        let l:cur_regime = index(s:buffergator_catalog_sort_regimes, self.sort_regime)
        let l:cur_regime += 1
        if l:cur_regime < 0 || l:cur_regime >= len(s:buffergator_catalog_sort_regimes)
            let self.sort_regime = s:buffergator_catalog_sort_regimes[0]
        else
            let self.sort_regime = s:buffergator_catalog_sort_regimes[l:cur_regime]
        endif
        call self.open(1)
        let l:sort_desc = get(s:buffergator_catalog_sort_regime_desc, self.sort_regime, ["??", "in unspecified order"])[1]
        call s:_buffergator_messenger.send_info("sorted " . l:sort_desc)
    endfunction "}}}

    " Cycles full/relative paths
    function! l:catalog_viewer.cycle_directory_path_display() dict "{{{
        if self.display_regime != "basename"
            call s:_buffergator_messenger.send_info("cycling full/relative directory paths only makes sense when using the 'basename' display regime")
            return
        endif
        if g:buffergator_show_full_directory_path
            let g:buffergator_show_full_directory_path = 0
            call s:_buffergator_messenger.send_info("displaying relative directory path")
            call self.open(1)
        else
            let g:buffergator_show_full_directory_path = 1
            call s:_buffergator_messenger.send_info("displaying full directory path")
            call self.open(1)
        endif
    endfunction "}}}

    " Cycles display regime.
    function! l:catalog_viewer.cycle_display_regime() dict "{{{
        let l:cur_regime = index(s:buffergator_catalog_display_regimes, self.display_regime)
        let l:cur_regime += 1
        if l:cur_regime < 0 || l:cur_regime >= len(s:buffergator_catalog_display_regimes)
            let self.display_regime = s:buffergator_catalog_display_regimes[0]
        else
            let self.display_regime = s:buffergator_catalog_display_regimes[l:cur_regime]
        endif
        call self.open(1)
        let l:display_desc = get(s:buffergator_catalog_display_regime_desc, self.display_regime, ["??", "in unspecified order"])[1]
        call s:_buffergator_messenger.send_info("displaying " . l:display_desc)
    endfunction "}}}

    " Rebuilds catalog.
    function! l:catalog_viewer.rebuild_catalog() dict "{{{
        call self.open(1)
    endfunction "}}}

    " Zooms/unzooms window.
    function! l:catalog_viewer.toggle_zoom() dict "{{{
        let l:bfwn = bufwinnr(self.bufnum)
        if l:bfwn < 0
            return
        endif
        if self.is_zoomed
            " if s:_is_full_height_window(l:bfwn) && !s:_is_full_width_window(l:bfwn)
            if g:buffergator_viewport_split_policy =~ '[RrLl]'
                if !g:buffergator_split_size
                    let l:new_size = &columns / 3
                else
                    let l:new_size = g:buffergator_split_size
                endif
                if l:new_size > 0
                    execute("vertical resize " . string(l:new_size))
                endif
                let self.is_zoomed = 0
            " elseif s:_is_full_width_window(l:bfwn) && !s:_is_full_height_window(l:bfwn)
            elseif g:buffergator_viewport_split_policy =~ '[TtBb]'
                if !g:buffergator_split_size
                    let l:new_size = &lines / 3
                else
                    let l:new_size = g:buffergator_split_size
                endif
                if l:new_size > 0
                    execute("resize " . string(l:new_size))
                endif
                let self.is_zoomed = 0
            endif
        else
            " if s:_is_full_height_window(l:bfwn) && !s:_is_full_width_window(l:bfwn)
            if g:buffergator_viewport_split_policy =~ '[RrLl]'
                if &columns > 20
                    execute("vertical resize " . string(&columns-10))
                    let self.is_zoomed = 1
                endif
            " elseif s:_is_full_width_window(l:bfwn) && !s:_is_full_height_window(l:bfwn)
            elseif g:buffergator_viewport_split_policy =~ '[TtBb]'
                if &lines > 20
                    execute("resize " . string(&lines-10))
                    let self.is_zoomed = 1
                endif
            endif
        endif
    endfunction

    " functions to be implemented by derived classes
    function! l:catalog_viewer.update_buffers_info() dict
    endfunction

    " Sets buffer syntax.
    function! l:catalog_viewer.setup_buffer_syntax() dict "{{{
        if has("syntax") && !(exists('b:did_syntax'))
            syn region BuffergatorFileLine start='\v^(TAB)@!' keepend oneline end='$' transparent
            syn region BuffergatorTabArea matchgroup=BuffergatorTabPageLine 
                  \ start="\v^TAB\sPAGE\s\d+\:" end="^T"me=s-1,re=s-1 keepend 
                  \ fold contains=BuffergatorFileLine transparent 
            syn match BuffergatorBufferNr '\v^\[[[:digit:][:space:]]{3}\]'
                  \ containedin=BuffergatorFileLine,BuffergatorTabArea nextgroup=@BuffergatorEntries
            syn match BuffergatorPath '\v\s[/~.].+$' containedin=BuffergatorFileLine
        
            for l:buffer_status in reverse(copy(self.symbol_order))
                let l:name = l:buffer_status
                let l:line_symbol = s:buffergator_buffer_line_symbols[l:buffer_status]

                " build the patern that matches it's symbol at a certain location
                let l:pattern = '\v]@<=('
                let l:pattern .= repeat('.', l:line_symbol[1])
                let l:pattern .= s:_buffer_line_symbol_list(l:buffer_status)
                let l:pattern .= repeat('.', self.symbol_columns - (l:line_symbol[1] + 1))
                let l:pattern .= ')'
                let l:pattern .= '.{-}(\t|$)@='
                
                let l:pattern_name = "Buffergator" . toupper(l:name[0]) . tolower(l:name[1:]) . "Entry"
                let l:element = [
                  \ "syn match", 
                  \ l:pattern_name, "'" . l:pattern . "'", 
                  \ "nextgroup=BuffergatorPath",
                  \ "containedin=BuffergatorFileLine"
                  \ ]

                let l:syntax_cmd = join(l:element," ")

                execute l:syntax_cmd
                execute 'syntax cluster BuffergatorEntries add=' . l:pattern_name
            endfor
                        
            for l:buffer_status in keys(s:buffergator_buffer_line_symbols)
              execute "syn match BuffergatorSymbol /" . s:_buffer_line_symbol_list(l:buffer_status)
                    \. "/ containedin=@BuffergatorEntries"
            endfor

            highlight link BuffergatorSymbol Constant
            highlight link BuffergatorPath Comment
            highlight link BuffergatorBufferNr LineNr 
            highlight link BuffergatorTabPageLine Title
            
            highlight link BuffergatorAlternateEntry Function
            highlight link BuffergatorModifiedEntry String
            highlight link BuffergatorCurrentEntry Keyword
            highlight link BuffergatorOntabEntry Normal 
            highlight link BuffergatorListedEntry NonText
            highlight link BuffergatorVisibleEntry Comment 
            highlight link BuffergatorReaderrorEntry Error
            highlight link BuffergatorReadonlyEntry Error

            let b:did_syntax = 1

        endif
    endfunction "}}}

    function! l:catalog_viewer.setup_buffer_keymaps() dict
    endfunction

    function! l:catalog_viewer.render_buffer() dict
    endfunction

    function! l:catalog_viewer.setup_buffer_statusline() dict
    endfunction

    function! l:catalog_viewer.append_line(text, jump_to_bufnum) dict
    endfunction

    return l:catalog_viewer

endfunction

" 1}}}

" BufferCatalogViewer {{{1
" ============================================================================
function! s:NewBufferCatalogViewer()

    " initialize
    let l:catalog_viewer = s:NewCatalogViewer("[[buffergator-buffers]]", "buffergator")
    let l:catalog_viewer["calling_bufnum"] = -1
    let l:catalog_viewer["buffers_catalog"] = {}
    let l:catalog_viewer["current_buffer_index"] = -1

    " Populates the buffer list
    function! l:catalog_viewer.update_buffers_info() dict
        let self.buffers_catalog = self.list_buffers()
        return self.buffers_catalog
    endfunction

    " Sets buffer key maps.
    function! l:catalog_viewer.setup_buffer_keymaps() dict 
        mapclear <buffer>
        call self.disable_editing_keymaps()
        for l:command_set in ['buffer_catalog_viewer', 'global']
            for l:command in keys(s:_default_keymaps[l:command_set])
                for l:sequence in s:_default_keymaps[l:command_set][l:command]
                    execute 'nmap <buffer> ' . l:sequence . ' ' . '<Plug>' . l:command
                endfor
            endfor
        endfor
    endfunction

    " Populates the buffer with the catalog index.
    function! l:catalog_viewer.render_buffer() dict "{{{
        setlocal modifiable
        call self.claim_buffer()
        call self.clear_buffer()
        call self.setup_buffer_keymaps()
        call self.setup_buffer_syntax()
        let self.jump_map = {}
        let l:initial_line = 1
        for l:bufinfo in self.buffers_catalog
          let l:line = self.render_entry(l:bufinfo)
          call self.append_line(l:line, l:bufinfo.bufnum)
        endfor
        let b:buffergator_last_render_time = localtime()
        try
            " remove extra last line
            execute('normal! GV"_X')
        catch //
        endtry
        setlocal nomodifiable
        call cursor(l:initial_line, 1)
    endfunction "}}}

    " Visits the specified buffer in the previous window, if it is already 
    " visible there. If not, then it looks for the first window with the
    " buffer showing and visits it there. If no windows are showing the
    " buffer, ... ?
    function! l:catalog_viewer.visit_buffer(bufnum, split_cmd) dict "{{{
        " acquire window
        let l:split_cmd = self.acquire_viewport(a:split_cmd)
        " switch to buffer in acquired window
        let l:old_switch_buf = &switchbuf
        if empty(l:split_cmd)
            " explicit split command not given: switch to buffer in current
            " window
            let &switchbuf="useopen"
            execute("silent buffer " . a:bufnum)
        else
            " explcit split command given: split current window
            let &switchbuf="split"
            execute("silent keepalt keepjumps " . l:split_cmd . " " . a:bufnum)
        endif
        let &switchbuf=l:old_switch_buf
    endfunction "}}}

    function! l:catalog_viewer.get_target_bufnum(cmd_count) dict "{{{
        if a:cmd_count == 0
            let l:cur_line = line(".")
            if !has_key(l:self.jump_map, l:cur_line)
                call s:_buffergator_messenger.send_info("Not a valid navigation line")
                return -1
            endif
            let [l:jump_to_bufnum] = self.jump_map[l:cur_line].target
            return l:jump_to_bufnum
        else
            let l:jump_to_bufnum = a:cmd_count
            if bufnr(l:jump_to_bufnum) == -1
                call s:_buffergator_messenger.send_info("Not a valid buffer number: " . string(l:jump_to_bufnum) )
                return -1
            endif
            for lnum in range(1, line("$"))
                if self.jump_map[lnum].target[0] == l:jump_to_bufnum
                    call cursor(lnum, 1)
                    return l:jump_to_bufnum
                endif
            endfor
            call s:_buffergator_messenger.send_info("Not a listed buffer number: " . string(l:jump_to_bufnum) )
            return -1
        endif
    endfunction "}}}

    " Go to the selected buffer.
    function! l:catalog_viewer.visit_target(keep_catalog, refocus_catalog, split_cmd) dict range "{{{
        let l:jump_to_bufnum = self.get_target_bufnum(v:count)
        if l:jump_to_bufnum == -1
            return 0
        endif
        let l:cur_tab_num = tabpagenr()
        if !a:keep_catalog
            call self.close(0)
        endif
        call self.visit_buffer(l:jump_to_bufnum, a:split_cmd)
        if a:keep_catalog && a:refocus_catalog
            execute("tabnext " . l:cur_tab_num)
            execute(bufwinnr(self.bufnum) . "wincmd w")
        endif
        call s:_buffergator_messenger.send_info(expand(bufname(l:jump_to_bufnum)))
    endfunction "}}}

    " Go to the selected buffer, preferentially using a window that already is
    " showing it; if not, create a window using split_cmd
    function! l:catalog_viewer.visit_open_target(unconditional, keep_catalog, split_cmd) dict range "{{{
        let l:jump_to_bufnum = self.get_target_bufnum(v:count)
        if l:jump_to_bufnum == -1
            return 0
        endif
        let wnr = bufwinnr(l:jump_to_bufnum)
        if wnr != -1
            execute(wnr . "wincmd w")
            if !a:keep_catalog
                call self.close(0)
            endif
            return
        endif
        let l:cur_tab_num = tabpagenr()
        for tabnum in range(1, tabpagenr('$'))
            execute("tabnext " . tabnum)
            let wnr = bufwinnr(l:jump_to_bufnum)
            if wnr != -1
                execute(wnr . "wincmd w")
                if !a:keep_catalog
                    call self.close(0)
                endif
                return
            endif
        endfor
        execute("tabnext " . l:cur_tab_num)
        if !a:unconditional
            call self.visit_target(a:keep_catalog, 0, a:split_cmd)
        endif
    endfunction "}}}

    function! l:catalog_viewer.delete_target(wipe, force) dict range "{{{
        let l:bufnum_to_delete = self.get_target_bufnum(v:count)
        if l:bufnum_to_delete == -1
            return 0
        endif
        if !bufexists(l:bufnum_to_delete)
            call s:_buffergator_messenger.send_info("Not a valid or existing buffer")
            return 0
        endif
        if a:wipe && a:force
            let l:operation_desc = "unconditionally wipe"
            let l:cmd = "bw!"
        elseif a:wipe && !a:force
            let l:operation_desc = "wipe"
            let l:cmd = "bw"
        elseif !a:wipe && a:force
            let l:operation_desc = "unconditionally delete"
            let l:cmd = "bd!"
        elseif !a:wipe && !a:force
            let l:operation_desc = "delete"
            let l:cmd = "bd"
        endif

        " store current window number
        let l:cur_win_num = winnr()

        call self.update_buffers_info()
        if len(self.buffers_catalog) == 1
            if self.buffers_catalog[0].bufnum == l:bufnum_to_delete
                call s:_buffergator_messenger.send_warning("Cowardly refusing to delete last listed buffer")
                return 0
            else
                call s:_buffergator_messenger.send_warning("Buffer not found")
                return 0
            endif
        endif
        let l:alternate_buffer = -1
        for xbi in range(0, len(self.buffers_catalog)-1)
            let curbf = self.buffers_catalog[xbi].bufnum
            if curbf == l:bufnum_to_delete
                if xbi == len(self.buffers_catalog)-1
                    if xbi > 0
                        let l:alternate_buffer = self.buffers_catalog[xbi-1].bufnum
                    else
                        call s:_buffergator_messenger.send_warning("Cowardly refusing to delete last listed buffer")
                        return 0
                    endif
                else
                    if xbi+1 < len(self.buffers_catalog)
                        let l:alternate_buffer = self.buffers_catalog[xbi+1].bufnum
                    else
                        call s:_buffergator_messenger.send_warning("Cowardly refusing to delete last listed buffer")
                        return 0
                    endif
                endif
                break
            endif
        endfor

        let l:changed_win_bufs = []
        for winnum in range(1, winnr('$'))
            let wbufnum = winbufnr(winnum)
            if wbufnum == l:bufnum_to_delete
                call add(l:changed_win_bufs, winnum)
                execute(winnum . "wincmd w")
                execute("silent keepalt keepjumps buffer " . l:alternate_buffer)
            endif
        endfor

        let l:bufname = expand(bufname(l:bufnum_to_delete))
        try
            execute(l:cmd . string(l:bufnum_to_delete))
            call self.open(1, l:alternate_buffer)
            let l:message = l:bufname . " " . l:operation_desc . "d"
            call s:_buffergator_messenger.send_info(l:message)
        catch /E89/
            for winnum in l:changed_win_bufs
                execute(winnum . "wincmd w")
                execute("silent keepalt keepjumps buffer " . l:bufnum_to_delete)
            endfor
            execute(l:cur_win_num . "wincmd w")
            let l:message = 'Failed to ' . l:operation_desc . ' "' . l:bufname . '" because it is modified; use unconditional version of this command to force operation'
            call s:_buffergator_messenger.send_error(l:message)
        catch //
            for winnum in l:changed_win_bufs
                execute(winnum . "wincmd w")
                execute("silent keepalt keepjumps buffer " . l:bufnum_to_delete)
            endfor
            execute(l:cur_win_num . "wincmd w")
            let l:message = 'Failed to ' . l:operation_desc . ' "' . l:bufname . '"'
            call s:_buffergator_messenger.send_error(l:message)
        endtry

    endfunction "}}}

    " Finds next line with occurrence of a rendered index
    function! l:catalog_viewer.goto_index_entry(direction, visit_target, refocus_catalog) dict range "{{{
        if v:count > 0
            let l:target_bufnum = v:count
            if bufnr(l:target_bufnum) == -1
                call s:_buffergator_messenger.send_info("Not a valid buffer number: " . string(l:target_bufnum) )
                return -1
            endif
            let l:ok = 0
            for lnum in range(1, line("$"))
                if self.jump_map[lnum].target[0] == l:target_bufnum
                    call cursor(lnum, 1)
                    let l:ok = 1
                    break
                endif
            endfor
            if !l:ok
                call s:_buffergator_messenger.send_info("Not a listed buffer number: " . string(l:target_bufnum) )
                return -1
            endif
        else
            let l:ok = self.goto_pattern("^\[", a:direction)
            execute("normal! zz")
        endif
        if l:ok && a:visit_target
            call self.visit_target(1, a:refocus_catalog, "")
        endif
    endfunction "}}}

    " Sets buffer status line.
    function! l:catalog_viewer.setup_buffer_statusline() dict "{{{
        setlocal statusline=%{BuffergatorBuffersStatusLine()}
    endfunction "}}}

    " Appends a line to the buffer and registers it in the line log.
    function! l:catalog_viewer.append_line(text, jump_to_bufnum) dict "{{{
        let l:line_map = {
                    \ "target" : [a:jump_to_bufnum],
                    \ }
        if a:0 > 0
            call extend(l:line_map, a:1)
        endif
        let self.jump_map[line("$")] = l:line_map
        call append(line("$")-1, a:text)
    endfunction "}}}

    " return object
    return l:catalog_viewer


endfunction
" 1}}}

" TabCatalogViewer {{{1
" ============================================================================
function! s:NewTabCatalogViewer()

    " initialize
    let l:catalog_viewer = s:NewCatalogViewer("[[buffergator-tabs]]", "buffergator")
    let l:catalog_viewer["tab_catalog"] = []
    let l:catalog_viewer["calling_view"] = -1
    let l:catalog_viewer["catalog_viewer"] = s:_catalog_viewer
    let l:catalog_viewer["prototype"] = "tab_catalog_viewer"

    " Populates the buffer list
    function! l:catalog_viewer.update_buffers_info() dict "{{{
        let self.tab_catalog = []
        for tabnum in range(1, tabpagenr('$'))
            call add(self.tab_catalog, tabpagebuflist(tabnum))
        endfor
        call s:_catalog_viewer.update_buffers_info()
        return self.tab_catalog
    endfunction "}}}

    " Populates the buffer with the catalog entries, sorted by tab.
    function! l:catalog_viewer.render_buffer() dict "{{{
        setlocal modifiable
        let l:cur_tab_num = tabpagenr()
        call self.claim_buffer()
        call self.clear_buffer()
        call self.setup_buffer_syntax()
        call self.setup_buffer_keymaps()
        let self.jump_map = {}
        let l:initial_line = 1
        " we always have to add one to tab_index and window_index
        " when we are dealing with actual tab and window objecst
        " and not their index in our own list of objects because
        " the window list is 1 based contra Lists
        for l:tab_index in range(len(self.tab_catalog))
            " start in the current tabe
            let l:tabinfo = self.tab_catalog[tab_index]
            if l:cur_tab_num == l:tab_index + 1
                let l:initial_line = line("$")
            endif

            let l:tabfield = "TAB PAGE " . string(l:tab_index+1) . ":"
            call self.append_line(l:tabfield, l:tab_index+1, 1)
            
            for l:window_index in range(len(l:tabinfo))
                let l:tabbufnum = l:tabinfo[l:window_index]
                " it's a tab display, replace the buffernumber with the the
                " number of the window displaying the buffer, which is much more
                " helpful than three copies of the same buffer info, and the
                " 'current' buffer with the current window
                let l:bufinfo = copy(get(self.catalog_viewer.find_buffer('bufnum',l:tabbufnum),0,{}))
                    if l:bufinfo != {}
                    
                    " only highlight on the current tab
                    if tabpagenr() == l:tab_index + 1
                      let l:bufinfo.is_current = (self.calling_view == l:window_index + 1) ? 1 : 0
                    else
                      let l:bufinfo.is_current = 0
                    endif
                    let l:bufinfo.bufnum = l:window_index + 1
                    let l:subline = self.render_entry(l:bufinfo)
                    call self.append_line(l:subline, l:tab_index+1, l:window_index + 1)
                endif
            endfor
        endfor
        let b:buffergator_last_render_time = localtime()
        try
            " remove extra last line
            execute('normal! GV"_X')
        catch //
        endtry
        setlocal nomodifiable
      call cursor(l:initial_line, 1)
    endfunction "}}}

    function! l:catalog_viewer.setup_buffer_keymaps() dict "{{{
        mapclear <buffer>
        call self.disable_editing_keymaps()
        for l:command_set in ['tab_catalog_viewer', 'global']
            for l:command in keys(s:_default_keymaps[l:command_set])
                for l:sequence in s:_default_keymaps[l:command_set][l:command]
                    execute 'nmap <buffer> ' . l:sequence . ' ' . '<Plug>' . l:command
                endfor
            endfor
        endfor
    endfunction 

    " Appends a line to the buffer and registers it in the line log.
    function! l:catalog_viewer.append_line(text, jump_to_tabnum, jump_to_winnum) dict "{{{
        let l:line_map = {
                    \ "target" : [a:jump_to_tabnum, a:jump_to_winnum],
                    \ }
        if a:0 > 0
            call extend(l:line_map, a:1)
        endif
        let self.jump_map[line("$")] = l:line_map
        call append(line("$")-1, a:text)
    endfunction"}}}

    function! l:catalog_viewer.goto_index_entry(direction) dict "{{{
        let l:ok = self.goto_pattern("^T", a:direction)
        execute("normal! zz")
        " if l:ok && a:visit_target
        "     call self.visit_target(1, a:refocus_catalog, "")
        " endif
    endfunction "}}}

    function! l:catalog_viewer.goto_win_entry(direction) dict "{{{
        let l:ok = self.goto_pattern('^\[', a:direction)
        execute("normal! zz")
    endfunction "}}}

    " Go to the selected buffer.
    function! l:catalog_viewer.visit_target() dict "{{{
        let l:cur_line = line(".")
        if !has_key(l:self.jump_map, l:cur_line)
            call s:_buffergator_messenger.send_info("Not a valid navigation line")
            return 0
        endif
        let [l:jump_to_tabnum, l:jump_to_winnum] = self.jump_map[l:cur_line].target
        call self.close(0)
        execute("tabnext " . l:jump_to_tabnum)
        execute(l:jump_to_winnum . "wincmd w")
        " call s:_buffergator_messenger.send_info(expand(bufname(l:jump_to_bufnum)))
    endfunction "}}}

    function! l:catalog_viewer.setup_buffer_statusline() dict "{{{
        setlocal statusline=%{BuffergatorTabsStatusLine()}
    endfunction "}}}

    " return object
    return l:catalog_viewer

endfunction
" 1}}}

" Global Functions {{{1
" ==============================================================================
function! BuffergatorBuffersStatusLine()
    let l:line = line(".")
    let l:status_line = "[[buffergator]]"
    if has_key(b:buffergator_catalog_viewer.jump_map, l:line)
        let l:status_line .= " Buffer " . string(l:line) . " of " . string(len(b:buffergator_catalog_viewer.buffers_catalog))
    endif
    return l:status_line
endfunction

function! BuffergatorTabsFoldtext()
    let l:line = getline(v:foldstart)
    let l:tab_page = matchlist(l:line, '\d\{1,3\}')[0]
    let l:buffer_numbers = tabpagebuflist(l:tab_page)
    let l:unique_buffers = []
    let l:buffers_name = []
    for l:buf in l:buffer_numbers
      if index(l:buf, l:unique_buffers) == -1
        if bufwinnr(l:buf) > 0 && buflisted(l:buf)
          call add(l:unique_buffers,l:buf)
          call add(l:buffers_name, fnamemodify(bufname(l:buf),":t"))
        endif
      endif
    endfor
    let l:fold_text = "+ TAB PAGE #" . l:tab_page . " [" . len(l:buffers_name) . " Buffer(s)] -- " . join(l:buffers_name,",") . "    "
    return l:fold_text
endfunction

function! BuffergatorTabsStatusLine()
    let l:status_line = "[[buffergator]]"
    let l:line = line(".")
    if has_key(b:buffergator_catalog_viewer.jump_map, l:line)
        let l:status_line .= " Tab Page: " . b:buffergator_catalog_viewer.jump_map[l:line].target[0]
        let l:status_line .= ", Window: " . b:buffergator_catalog_viewer.jump_map[l:line].target[1]
    endif
    return l:status_line
endfunction
" 1}}}

" Global Initialization {{{1
" ==============================================================================
if exists("s:_buffergator_messenger")
    unlet s:_buffergator_messenger
endif

let s:_buffergator_messenger = s:NewMessenger("")
let s:_catalog_viewer = s:NewBufferCatalogViewer()
let s:_tab_catalog_viewer = s:NewTabCatalogViewer()

" Autocommands that update the most recenly used buffers
augroup BufferGatorMRU
    au!
    autocmd BufEnter * call s:_update_mru(expand('<abuf>'))
    autocmd BufRead * call s:_update_mru(expand('<abuf>'))
    autocmd BufNewFile * call s:_update_mru(expand('<abuf>'))
    autocmd BufWritePost * call s:_update_mru(expand('<abuf>'))
augroup NONE

augroup BufferGatorAuto
    au!
    autocmd BufDelete * call <SID>UpdateBuffergator('delete',expand('<abuf>'))
    autocmd BufEnter * call <SID>UpdateBuffergator('enter',expand('<abuf>'))
    autocmd BufLeave * call <SID>UpdateBuffergator('leave', expand('<abuf>'))
    autocmd WinEnter * call <SID>UpdateBuffergator('enter',expand('<abuf>'))
    autocmd WinLeave * call <SID>UpdateBuffergator('leave', expand('<abuf>'))
    autocmd BufWritePost * call <SID>UpdateBuffergator('writepost',expand('<abuf>'))
augroup NONE
" 1}}}

" Functions Supporting User Commands {{{1
" ==============================================================================

function! s:OpenBuffergator(type)
    let l:gator_buffer = get(s:_find_buffers_with_var("is_buffergator_buffer",1),0,0)
    " if no buffergator current exists, open the specified type 
    if index(tabpagebuflist(),l:gator_buffer) == -1
        if a:type == "catalog_viewer"
            call s:_catalog_viewer.open(1,bufnr("%"))
        elseif a:type == "tab_catalog_viewer"
            call s:_tab_catalog_viewer.open(1,winnr())
        endif
    else
        " if a buffergator DOES exist, then toggle the window to that type
        call s:ToggleTypeBuffergator(l:gator_buffer, a:type)
    end
endfunction

function! s:CloseBuffergator(type)
    let l:gator_buffer = get(s:_find_buffers_with_var("is_buffergator_buffer",1),0,0)
    if index(tabpagebuflist(),l:gator_buffer) == -1
      return
    else
      let l:gator = getbufvar(l:gator_buffer,"buffergator_catalog_viewer")
      " calling close on an invisible buffergator has no effect
      if l:gator.prototype == a:type
        call l:gator.close(1)
    else
        s:_buffergator_messenger.warn("No Buffergator like that open.")
      endif
    endif
endfunction


function! s:UpdateBuffergator(event, affected)
    if !(g:buffergator_autoupdate)
        return
    endif

    let l:calling = bufnr("%")
    let l:self_call = 0
    
    let l:gator_buffer = get(s:_find_buffers_with_var("is_buffergator_buffer",1),0,0)
    if index(tabpagebuflist(),l:gator_buffer) == -1
        " no buffergator buffer is created, skip it.
        return
    endif

    let l:gator = getbufvar(l:gator_buffer,"buffergator_catalog_viewer")
   
    " BufDelete is the last Autocommand executed, but it's done BEFORE the
    " buffer is actually deleted. - preemptively remove the buffer from
    " the list if this is a delete event, after we update from te the current
    " buffer list
    if l:gator.prototype == "tab_catalog_viewer"
        let l:gator.calling_view = winnr() 
    else
        let l:gator.calling_view = bufnr('%')
    end
    call l:gator.update_buffers_info()
    if a:event == "delete"
      " this ALWAYS operates on the catalog_viewer
        call filter(s:_catalog_viewer.buffers_catalog,'v:val["bufnum"] != ' . a:affected)
    endif

    if bufwinnr(l:gator_buffer) > 0
        if l:calling != l:gator_buffer
            execute bufwinnr(l:gator_buffer) . "wincmd w"
        else
            " the event originated in the buffergator, so we don't
            " need to switch back
            let l:self_call = 1 
        endif
        call l:gator.render_buffer()
        if !l:self_call
            call l:gator.highlight_current_line()
        endif
    endif
    
    if exists("b:is_buffergator_buffer") && !l:self_call
        execute 'wincmd p'
    elseif a:event == "delete" && !l:self_call
        execute 'wincmd ^'
    endif
        
endfunction

function! s:ToggleTypeBuffergator(bufnum, ...)
    " if my window is open, switch to the other sort of navigator
    if bufwinnr(a:bufnum) >= 0
        if a:0 > 0
            if a:1 == "catalog_viewer"
                let l:buffergator_type = "tab_catalog_viewer"
            else
                let l:buffergator_type = "catalog_viewer"
            endif
        else
            let l:buffergator_type = getbufvar(a:bufnum,"buffergator_catalog_viewer")
        endif
        
        if l:buffergator_type == "tab_catalog_viewer"
            call setbufvar(a:bufnum,'buffergator_catalog_viewer',s:_catalog_viewer)
        else
            call setbufvar(a:bufnum,'buffergator_catalog_viewer',s:_tab_catalog_viewer)
        endif
        " force the buffergator to update so the change is immediate
        call s:UpdateBuffergator('',-1)
    endif
endfunction "}}}

" 1}}}

" Public Command and Key Maps {{{1
" ==============================================================================
command!  BuffergatorToggleType  :call <SID>ToggleTypeBuffergator()
command!  BuffergatorClose       :call <SID>CloseBuffergator("catalog_viewer")
command!  BuffergatorOpen        :call <SID>OpenBuffergator("catalog_viewer")
command!  BuffergatorTabsOpen    :call <SID>OpenBuffergator("tab_catalog_viewer")
command!  BuffergatorTabsClose   :call <SID>CloseBuffergator("tab_catalog_viewer")
command!  BuffergatorUpdate      :call <SID>UpdateBuffergator('',-1)

if !exists('g:buffergator_suppress_keymaps') || !g:buffergator_suppress_keymaps
    " nnoremap <silent> <Leader><Leader> :BuffergatorToggle<CR>
    nnoremap <silent> <Leader>b :BuffergatorOpen<CR>
    nnoremap <silent> <Leader>B :BuffergatorClose<CR>
    nnoremap <silent> <Leader>t :BuffergatorTabsOpen<CR>
    nnoremap <silent> <Leader>T :BuffergatorTabsClose<CR>
endif

" 1}}}

" Restore State {{{1
" ============================================================================
" restore options
let &cpo = s:save_cpo
" 1}}}

" vim:foldlevel=4:
