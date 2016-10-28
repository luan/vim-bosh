" Vim indent file
" Language: Bosh Flavored YAML
" Author:   Luan Santos <vim@luan.sh>
" URL:      https://github.com/luan/vim-bosh

setlocal autoindent sw=2 ts=2 expandtab foldmethod=syntax
setlocal indentexpr=
setlocal norelativenumber nocursorline

if globpath(&rtp, 'plugin/rainbow.vim') != ""
  silent! RainbowToggleOff
endif

function! s:SetTagbar()
    let bin_path = bosh#CheckBinPath(g:bosh_boshtags_bin)
    if empty(bin_path)
        return
    endif

    if !exists("g:tagbar_type_bosh")
        let g:tagbar_type_bosh = {
            \ 'ctagstype' : 'bosh',
            \ 'kinds'     : [
                \ 'b:basic',
                \ 'p:primitives',
                \ 'v:vm_types',
                \ 'd:disk_types',
                \ 'n:networks',
                \ 'a:azs',
                \ 'c:compilation',
                \ 'i:instance_groups',
                \ 'j:jobs',
                \ 'r:releases',
                \ 's:stemcells',
                \ 'u:update',
           \ ],
            \ 'sro' : '.',
            \ 'kind2scope' : {
                \ 'p' : 'ptype',
                \ 'v' : 'vtype',
                \ 'd' : 'dtype',
                \ 'n' : 'ntype',
                \ 'i' : 'itype',
                \ 'j' : 'jtype',
                \ 'a' : 'atype',
                \ 'r' : 'rtype',
                \ 's' : 'stype',
            \ },
            \ 'scope2kind' : {
                \ 'ptype' : 'p',
                \ 'vtype' : 'v',
                \ 'dtype' : 'd',
                \ 'ntype' : 'n',
                \ 'itype' : 'i',
                \ 'jtype' : 'j',
                \ 'atype' : 'a',
                \ 'rtype' : 'r',
                \ 'stype' : 's',
            \ },
            \ 'ctagsbin'  : expand(bin_path),
            \ 'ctagsargs' : '-sort -silent'
        \ }
    endif
    let g:tagbar_type_bosh_cloud_config = g:tagbar_type_bosh
    let g:tagbar_type_bosh_deployment = g:tagbar_type_bosh
endfunction

call s:SetTagbar()

" vim:set sw=2:
