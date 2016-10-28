" IsWin returns 1 if current OS is Windows or 0 otherwise
function! bosh#IsWin()
    let win = ['win16', 'win32', 'win64', 'win95']
    for w in win
        if (has(w))
            return 1
        endif
    endfor

    return 0
endfunction

" PathSep returns the appropriate OS specific path separator.
function! bosh#PathSep()
    if bosh#IsWin()
        return '\'
    endif
    return '/'
endfunction

" Default returns the default GOPATH. If there is a single GOPATH it returns
" it. For multiple GOPATHS separated with a the OS specific separator, only
" the first one is returned
function! bosh#DefaultPath()
    let go_paths = split($GOPATH, bosh#PathListSep())

    if len(go_paths) == 1
        return $GOPATH
    endif

    return go_paths[0]
endfunction

" PathListSep returns the appropriate OS specific path list separator.
function! bosh#PathListSep()
    if bosh#IsWin()
        return ";"
    endif
    return ":"
endfunction

" BinPath returns the binary path of installed tools.
function! bosh#BinPath()
    let bin_path = ""

    " check if our global custom path is set, if not check if $GOBIN is set so
    " we can use it, otherwise use $GOPATH + '/bin'
    if exists("g:go_bin_path")
        let bin_path = g:go_bin_path
    elseif $GOBIN != ""
        let bin_path = $GOBIN
    elseif $GOPATH != ""
        let bin_path = expand(bosh#DefaultPath() . "/bin/")
    else
        " could not find anything
    endif

    return bin_path
endfunction

" CheckBinPath checks whether the given binary exists or not and returns the
" path of the binary. It returns an empty string doesn't exists.
function! bosh#CheckBinPath(binpath)
    " remove whitespaces if user applied something like 'goimports   '
    let binpath = substitute(a:binpath, '^\s*\(.\{-}\)\s*$', '\1', '')

    " if it's in PATH just return it
    if executable(binpath)
        return binpath
    endif

    " just get the basename
    let basename = fnamemodify(binpath, ":t")

    " check if we have an appropriate bin_path
    let bosh_bin_path = bosh#BinPath()
    if empty(bosh_bin_path)
        echo "vim-bosh: could not find '" . basename . "'. Run :BoshInstallBinaries to fix it."
        return ""
    endif

    " append our GOBIN and GOPATH paths and be sure they can be found there...
    " let us search in our GOBIN and GOPATH paths
    let old_path = $PATH
    let $PATH = $PATH . bosh#PathListSep() . bosh_bin_path

    if !executable(basename)
        echo "vim-bosh: could not find '" . basename . "'. Run :BoshInstallBinaries to fix it."
        " restore back!
        let $PATH = old_path
        return ""
    endif

    let $PATH = old_path

    return bosh_bin_path . bosh#PathSep() . basename
endfunction
