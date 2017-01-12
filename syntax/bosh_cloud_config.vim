" Vim syntax/macro file
" Language: BOSH Cloud Config YAML
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

let roots               = ['azs', 'vm_types', 'resource_pools', 'disk_types',
                          \ 'disk_pools', 'compilation', 'networks']

let azOptions          = ['name', 'cloud_properties']
let vmtypeOptions      = ['name', 'cloud_properties']
let disktypeOptions    = ['name', 'disk_size', 'cloud_properties']
let networkOptions     = ['name', 'type', 'dns', 'static_ips', 'subnets', 'default', 'cloud_properties']
let subnetOptions      = ['dns', 'az', 'azs', 'cloud_properties', 'gateway', 'range', 'reserved', 'static']
let compilationOptions = ['workers', 'network', 'az', 'reuse_compilation_vms', 'vm_type']

" array properties
syntax region boshPrimitiveGroup matchgroup=boshRootKey start=/\v^azs\ze:/ skip=/\v^([- ].*)?$/ excludenl end=/^/ contains=yamlDelimiter,boshazs fold keepend
syntax region boshPrimitiveGroup matchgroup=boshRootKey start=/\v^(vm_types|resource_pools)\ze:/ skip=/\v^([- ].*)?$/ excludenl end=/^/ contains=yamlDelimiter,boshvmtypes fold keepend
syntax region boshPrimitiveGroup matchgroup=boshRootKey start=/\v^(disk_types|disk_pools)\ze:/ skip=/\v^([- ].*)?$/ excludenl end=/^/ contains=yamlDelimiter,boshdisktypes fold keepend
syntax region boshPrimitiveGroup matchgroup=boshRootKey start=/\v^networks\ze:/ skip=/\v^([- ].*)?$/ excludenl end=/^/ contains=yamlDelimiter,boshnetworks fold keepend

" hash properties
syntax region boshPrimitiveGroup matchgroup=boshRootKey start=/\v^compilation\ze:/ skip=/\v^( .*)?$/ excludenl end=/^/ contains=yamlDelimiter,boshcompilation fold keepend

if has('nvim')
  syntax match boshName /\v(name: )@<=.*>/ contained
endif

let rootsRegex = join(roots, "|")

function! s:defArrayElement(name, contains)
  let groups = ['yamlDelimiter', 'boshName']
  let name = 'bosh'.a:name
  for group in a:contains
    call add(groups, name.group)
    execute 'syntax match '.name.group.' /\v\s*-?\s*'.group.'\ze:/ contained'
    execute 'hi link '.name.group.' boshOptions'
  endfor
  execute 'syntax region '.name.' start=/\v^\z(\s*)-/ skip=/\v\\./ excludenl end=/\v\ze\n?^\z1-/ contained contains='.join(groups, ',').' fold transparent'
endfunction

function! s:defHashElement(name, contains)
  let groups = ['yamlDelimiter', 'boshName']
  let name = 'bosh'.a:name
  for group in a:contains
    call add(groups, name.group)
    execute 'syntax match '.name.group.' /\v\s*-?\s*'.group.'\ze:/ contained'
    execute 'hi link '.name.group.' boshOptions'
  endfor
  execute 'syntax region '.name.' start=/\v\z(\s*)/ skip=/\z1/ excludenl end=// contained contains='.join(groups, ',').' transparent'
endfunction

call s:defArrayElement('azs', azOptions)
" cloud_properties nested in azs
hi link boshazscloud_properties None
syntax region boshazscloud_properties matchgroup=boshOptions start=/\v^\z(\s+)cloud_properties\ze:/ skip=/\v^(\z1( .*)?)?$/ excludenl end=/^/ contains=boshazscloud_propertieshash fold keepend
syntax region boshazscloud_propertieshash start=/\v\z(\s*)/ skip=/\z1/ excludenl end=// contained contains=TOP, transparent

call s:defArrayElement('vmtypes', vmtypeOptions)
" cloud_properties nested in vmtypes
hi link boshvmtypescloud_properties None
syntax region boshvmtypescloud_properties matchgroup=boshOptions start=/\v^\z(\s+)cloud_properties\ze:/ skip=/\v^(\z1( .*)?)?$/ excludenl end=/^/ contains=boshvmtypescloud_propertieshash fold keepend
syntax region boshvmtypescloud_propertieshash start=/\v\z(\s*)/ skip=/\z1/ excludenl end=// contained contains=TOP, transparent

call s:defArrayElement('networks', networkOptions)
" cloud_properties nested in networks
hi link boshnetworkscloud_properties None
syntax region boshnetworkscloud_properties matchgroup=boshOptions start=/\v^\z(\s+)cloud_properties\ze:/ skip=/\v^(\z1( .*)?)?$/ excludenl end=/^/ contains=boshnetworkscloud_propertieshash fold keepend
syntax region boshnetworkscloud_propertieshash start=/\v\z(\s*)/ skip=/\z1/ excludenl end=// contained contains=TOP, transparent
" subnets nested in networks
hi link boshnetworkssubnets None
syntax region boshnetworkssubnets matchgroup=boshOptions start=/\v^\z(\s+)subnets\ze:/ skip=/\v^(\z1([- ].*)?)?$/ excludenl end=/^/ contains=boshnetworkssubnet fold keepend
call s:defArrayElement('networkssubnet', subnetOptions)
  " cloud_properties nested in subnets
  hi link boshnetworkssubnetcloud_properties None
  syntax region boshnetworkssubnetcloud_properties matchgroup=boshOptions start=/\v^\z(\s+)cloud_properties\ze:/ skip=/\v^(\z1( .*)?)?$/ excludenl end=/^/ contains=boshnetworkssubnetcloud_propertieshash fold keepend
  syntax region boshnetworkssubnetcloud_propertieshash start=/\v\z(\s*)/ skip=/\z1/ excludenl end=// contained contains=TOP, transparent
" default nested in networks
hi link boshnetworksdefault None
syntax region boshnetworksdefault matchgroup=boshOptions start=/\v^\z(\s+)default\ze:/ skip=/\v^(\z1( .*)?)?$/ excludenl end=/^/ contains=boshnetworksdefaulthash fold keepend
syntax region boshnetworksdefaulthash start=/\v\z(\s*)/ skip=/\z1/ excludenl end=// contained contains=TOP, transparent

call s:defArrayElement('disktypes', disktypeOptions)
" cloud_properties nested in disktypes
hi link boshdisktypescloud_properties None
syntax region boshdisktypescloud_properties matchgroup=boshOptions start=/\v^\z(\s+)cloud_properties\ze:/ skip=/\v^(\z1( .*)?)?$/ excludenl end=/^/ contains=boshdisktypescloud_propertieshash fold keepend
syntax region boshdisktypescloud_propertieshash start=/\v\z(\s*)/ skip=/\z1/ excludenl end=// contained contains=TOP, transparent


call s:defHashElement('compilation', compilationOptions)

" Setupt the hilighting links

hi link boshKeywords Function
hi link boshOptions Function
hi link boshName Type
hi link boshSteps Type
hi link boshRootKey Keyword
hi link boshPlan Function
