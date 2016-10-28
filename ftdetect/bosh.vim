" Determine if normal YAML or Bosh YAML
" Language: Bosh Flavored YAML
" Author:   Luan Santos <vim@luan.sh>
" URL:      https://github.com/luan/vim-bosh

autocmd BufNewFile,BufRead *.yml,*.yaml  call s:SelectBosh()

fun! s:SelectBosh()
  " Bail out if 'filetype' is already set to "bosh".
  if index(split(&ft, '\.'), 'bosh') != -1
    return
  endif

  let lines = join(getline('1', '$'), "\n")

  let grep = 'grep -E'
  if executable('ag')
    let grep = 'ag'
  endif

  let fp = expand("<afile>:p")
  let boshRegex = '^(name|releases|stemcells|update|instance_groups):'
  let boshKeyCount = system('cat ' . fp . ' | ' . grep . ' "' . boshRegex . '" | wc -l')

  if boshKeyCount =~# '5'
    execute 'set filetype=bosh_deployment'
  endif

  let boshRegex = '^(azs|networks|resource_pools|vm_types|disk_pools|disk_types):'
  let boshKeyCount = system('cat ' . fp . ' | ' . grep . ' "' . boshRegex . '" | wc -l')

  if boshKeyCount =~# '4'
    execute 'set filetype=bosh_cloud_config'
  endif
endfun
