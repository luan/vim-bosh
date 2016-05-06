" install necessary Bosh tools
if exists("g:bosh_loaded_install")
    finish
endif
let g:go_loaded_install = 1


" these packages are used by vim-bosh and can be automatically installed if
" needed by the user with GoInstallBinaries
let s:packages = [
            \ "github.com/luan/boshtags",
            \ ]

" These commands are available on any filetypes
command! BoshInstallBinaries call s:BoshInstallBinaries(-1)
command! BoshUpdateBinaries call s:BoshInstallBinaries(1)

" BoshInstallBinaries downloads and install all necessary binaries stated
" in the packages variable. It uses by default $GOBIN or $GOPATH/bin as the
" binary target install directory. BoshInstallBinaries doesn't install
" binaries if they exist, to update current binaries pass 1 to the argument.
function! s:BoshInstallBinaries(updateBinaries)
    if $GOPATH == ""
        echohl Error
        echomsg "vim-bosh: $GOPATH is not set"
        echohl None
        return
    endif

    let err = s:CheckBinaries()
    if err != 0
        return
    endif

    let bosh_bin_path = bosh#BinPath()

    " change $GOBIN so go get can automatically install to it
    let $GOBIN = bosh_bin_path

    " old_path is used to restore users own path
    let old_path = $PATH

    " vim's executable path is looking in PATH so add our go_bin path to it
    let $PATH = $PATH . bosh#PathListSep() . bosh_bin_path

    " when shellslash is set on MS-* systems, shellescape puts single quotes
    " around the output string. cmd on Windows does not handle single quotes
    " correctly. Unsetting shellslash forces shellescape to use double quotes
    " instead.
    let resetshellslash = 0
    if has('win32') && &shellslash
        let resetshellslash = 1
        set noshellslash
    endif

    let cmd = "go get -u -v "

    let s:go_version = matchstr(system("go version"), '\d.\d.\d')

    " https://github.com/golang/go/issues/10791
    if s:go_version > "1.4.0" && s:go_version < "1.5.0"
        let cmd .= "-f "
    endif

    for pkg in s:packages
        let basename = fnamemodify(pkg, ":t")
        let binname = "go_" . basename . "_bin"

        let bin = basename
        if exists("g:{binname}")
            let bin = g:{binname}
        endif

        if !executable(bin) || a:updateBinaries == 1
            if a:updateBinaries == 1
                echo "vim-bosh: Updating ". basename .". Reinstalling ". pkg . " to folder " . bosh_bin_path
            else
                echo "vim-bosh: ". basename ." not found. Installing ". pkg . " to folder " . bosh_bin_path
            endif


            let out = system(cmd . shellescape(pkg))
            if v:shell_error
                echo "Error installing ". pkg . ": " . out
            endif
        endif
    endfor

    " restore back!
    let $PATH = old_path
    if resetshellslash
        set shellslash
    endif
endfunction

" CheckBinaries checks if the necessary binaries to install the Go tool
" commands are available.
function! s:CheckBinaries()
    if !executable('go')
        echohl Error | echomsg "vim-bosh: go executable not found." | echohl None
        return -1
    endif

    if !executable('git')
        echohl Error | echomsg "vim-bosh: git executable not found." | echohl None
        return -1
    endif
endfunction

" boshtags generates ctags for the current buffer
" function! s:boshtags()
"     if &filetype != "bosh"
"         return
"     endif

"     let bin_path = bosh#CheckBinPath(g:bosh_boshtags_bin)
"     if empty(bin_path)
"         return
"     endif
"     call system(expand(bin_path) . " -f " . &tags . " " . expand("%:p"))
" endfunction

" Autocommands
" ============================================================================
"
augroup vim-bosh
    autocmd!

    " run gometalinter on save
    " if get(g:, "bosh_tags_autosave", 1)
    "     autocmd FileType bosh
    "                 \ let b:tagspath = tempname() |
    "                 \ exec 'setlocal tags='.b:tagspath |
    "                 \ call s:boshtags()
    "     autocmd BufWritePost *.yml call s:boshtags()
    " endif
augroup END


" vim:ts=4:sw=4:et
