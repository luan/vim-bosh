" Vim syntax/macro file
" Language: BOSH Deployment YAML
" Author: Luan Santos <vim@luan.sh>
" URL: https://github.com/luan/vim-bosh

if version < 600
 syntaxtax clear
endif

syntax sync fromstart

syntax match yamlBlock "[\[\]\{\}\|\>]"
syntax match yamlOperator "[?^+-]\|=>"
syntax match yamlDelimiter /\v(^[^:]*)@<=:/
syntax match yamlDelimiter /\v^\s*- /

syntax match yamlNumber /\v[{, ][_0-9]+((\.[_0-9]*)(e[+-][_0-9]+)?)?\ze($|[, \t])/
syntax match yamlNumber /\v([+\-]?\.inf|\.NaN)/

syntax region yamlComment start="\v(^| )\#" end="$"
syntax match yamlIndicator "#YAML:\S\+"

syntax region yamlString start="'" end="'" skip="\\'"
syntax region yamlString start='"' end='"' skip='\\"' contains=yamlEscape
syntax match yamlEscape +\\[abfnrtv'"\\]+ contained
syntax match yamlEscape "\\\o\o\=\o\=" contained
syntax match yamlEscape "\\x\x\+" contained

syntax match yamlType "!\S\+"

syntax keyword yamlConstant NULL Null null NONE None none NIL Nil nil
syntax keyword yamlConstant TRUE True true YES Yes yes ON On on
syntax keyword yamlConstant FALSE False false NO No no OFF Off off
syntax match   yamlConstant /\v( |\{ ?)@<=\~\ze( ?\}|, |$)/

syntax match yamlKey    /\v[0-9A-Za-z_-]+\ze:( |$)/
syntax match yamlAnchor /\v(: )@<=\&\S+/
syntax match yamlAlias  /\v(: )@<=\*\S+/

hi link yamlConstant Keyword
hi link yamlNumber Keyword
hi link yamlIndicator PreCondit
hi link yamlAnchor Function
hi link yamlAlias Function
hi link yamlKey Identifier
hi link yamlType Type

hi link yamlComment Comment
hi link yamlBlock Operator
hi link yamlOperator Operator
hi link yamlDelimiter Delimiter
hi link yamlString String
hi link yamlEscape Special

let roots               = ['name', 'director_uuid', 'releases', 'stemcells',
                          \ 'update', 'instance_groups']
let deprecatedRoots     = ['properties']

let releaseOptions       = ['name', 'version']
let stemcellOptions      = ['name', 'alias', 'os', 'version']
let updateOptions        = ['canaries', 'max_in_flight', 'canary_watch_time', 'update_watch_time', 'serial']
let instanceGroupOptions = ['name', 'azs', 'instances', 'jobs', 'name',
                           \ 'release', 'consumes', 'provides', 'properties',
                           \ 'vm_type', 'vm_extensions', 'stemcell',
                           \ 'persistent_disk_type', 'networks', 'name',
                           \ 'static_ips', 'default', 'update',
                           \ 'migrated_from', 'lifecycle']

let deprecatedInstanceGroupOptions = ['properties']

let jobOptions = ['name', 'release', 'consumes', 'provides', 'properties']

" single string properties
syntax region boshPrimitiveGroup matchgroup=boshRootKey start=/\v^(name|director_uuid)\ze:/ excludenl end=/$/ contains=boshName,yamlDelimiter,yamlString keepend

" array properties
syntax region boshPrimitiveGroup matchgroup=boshRootKey start=/\v^releases\ze:/ skip=/\v^([- ].*)?$/ excludenl end=/^/ contains=yamlDelimiter,boshreleases fold keepend
syntax region boshPrimitiveGroup matchgroup=boshRootKey start=/\v^stemcells\ze:/ skip=/\v^([- ].*)?$/ excludenl end=/^/ contains=yamlDelimiter,boshstemcells fold keepend
syntax region boshPrimitiveGroup matchgroup=boshRootKey start=/\v^instance_groups\ze:/ skip=/\v^([- ].*)?$/ excludenl end=/^/ contains=yamlDelimiter,boshinstancegroups fold keepend

" hash properties
syntax region boshPrimitiveGroup matchgroup=boshRootKey start=/\v^update\ze:/ skip=/\v^( .*)?$/ excludenl end=/^/ contains=yamlDelimiter,boshupdate fold keepend
" deprecated 
syntax region boshPrimitiveGroup matchgroup=deprecatedKey start=/\v^properties\ze:/ skip=/\v^( .*)?$/ excludenl end=/^/ contains=yamlDelimiter,boshproperties fold keepend

if has('nvim')
  syntax match boshName /\v(name: )@<=.*>/ contained
endif

let rootsRegex = join(roots + deprecatedRoots, "|")

function! s:defArrayElement(name, contains, deprecatedContains)
  let groups = ['yamlDelimiter', 'boshName']
  let name = 'bosh'.a:name
  for group in a:contains
    call add(groups, name.group)
    execute 'syntax match '.name.group.' /\v\s*-?\s*'.group.'\ze:/ contained'
    execute 'hi link '.name.group.' boshOptions'
  endfor
  for group in a:deprecatedContains
    call add(groups, name.group)
    execute 'syntax match '.name.group.' /\v\s*-?\s*'.group.'\ze:/ contained'
    execute 'hi link '.name.group.' deprecatedKey'
  endfor
  execute 'syntax region '.name.' start=/\v^\z(\s*)-/ skip=/\v\\./ excludenl end=/\v\ze\n?^\z1-/ contained contains='.join(groups, ',').' fold transparent'
endfunction

function! s:defHashElement(name, contains, deprecatedContains)
  let groups = ['yamlDelimiter', 'boshName']
  let name = 'bosh'.a:name
  for group in a:contains
    call add(groups, name.group)
    execute 'syntax match '.name.group.' /\v\s*-?\s*'.group.'\ze:/ contained'
    execute 'hi link '.name.group.' boshOptions'
  endfor
  for group in a:deprecatedContains
    call add(groups, name.group)
    execute 'syntax match '.name.group.' /\v\s*-?\s*'.group.'\ze:/ contained'
    execute 'hi link '.name.group.' deprecatedKey'
  endfor
  execute 'syntax region '.name.' start=/\v\z(\s*)/ skip=/\z1/ excludenl end=// contained contains='.join(groups, ',').' transparent'
endfunction

call s:defArrayElement('releases', releaseOptions, [])
call s:defArrayElement('stemcells', stemcellOptions, [])
call s:defArrayElement('instancegroups', instanceGroupOptions, deprecatedInstanceGroupOptions)
" jobs nested in instancegroups
hi link boshinstancegroupsjobs None
syntax region boshinstancegroupsjobs matchgroup=boshOptions start=/\v^\z(\s+)jobs\ze:/ skip=/\v^(\z1([- ].*)?)?$/ excludenl end=/^/ contains=boshinstancegroupsjob fold keepend
call s:defArrayElement('instancegroupsjob', jobOptions, [])
" properties nested in instancegroupsjob
hi link boshinstancegroupsjobproperties None
syntax region boshinstancegroupsjobproperties matchgroup=boshOptions start=/\v^\z(\s+)properties\ze:/ skip=/\v^(\z1( .*)?)?$/ excludenl end=/^/ contains=boshinstancegroupsjobpropertieshash fold keepend
syntax region boshinstancegroupsjobpropertieshash start=/\v\z(\s*)/ skip=/\z1/ excludenl end=// contained contains=TOP, transparent
" consumes nested in instancegroupsjob
hi link boshinstancegroupsjobconsumes None
syntax region boshinstancegroupsjobconsumes matchgroup=boshOptions start=/\v^\z(\s+)consumes\ze:/ skip=/\v^(\z1( .*)?)?$/ excludenl end=/^/ contains=boshinstancegroupsjobconsumeshash fold keepend
syntax region boshinstancegroupsjobconsumeshash start=/\v\z(\s*)/ skip=/\z1/ excludenl end=// contained contains=TOP, transparent
" provides nested in instancegroupsjob
hi link boshinstancegroupsjobprovides None
syntax region boshinstancegroupsjobprovides matchgroup=boshOptions start=/\v^\z(\s+)provides\ze:/ skip=/\v^(\z1( .*)?)?$/ excludenl end=/^/ contains=boshinstancegroupsjobprovideshash fold keepend
syntax region boshinstancegroupsjobprovideshash start=/\v\z(\s*)/ skip=/\z1/ excludenl end=// contained contains=TOP, transparent

" update nested in instancegroups
hi link boshinstancegroupsupdate None
syntax region boshinstancegroupsupdate matchgroup=boshOptions start=/\v^\z(\s+)update\ze:/ skip=/\v^(\z1( .*)?)?$/ excludenl end=/^/ contains=boshinstancegroupsupdatehash fold keepend
call s:defHashElement('instancegroupsupdatehash', updateOptions, [])

" properties nested in instancegroups
hi link boshinstancegroupsproperties None
syntax region boshinstancegroupsproperties matchgroup=deprecatedKey start=/\v^\z(\s+)properties\ze:/ skip=/\v^(\z1( .*)?)?$/ excludenl end=/^/ contains=boshinstancegroupspropertieshash fold keepend
syntax region boshinstancegroupspropertieshash start=/\v\z(\s*)/ skip=/\z1/ excludenl end=// contained contains=TOP, transparent

call s:defHashElement('update', updateOptions, [])
syntax region boshproperties start=// excludenl end=// contained contains=TOP transparent

" Setupt the hilighting links

hi link boshKeywords Function
hi link boshOptions Function
hi link boshName Type
hi link boshSteps Type
hi link boshRootKey Keyword
hi link boshPlan Function
hi link deprecatedKey Todo
