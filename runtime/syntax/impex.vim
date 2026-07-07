" SAP Commerce / Hybris ImpEx syntax highlighting.
" Filetype is registered via vim.filetype.add({extension={impex='impex'}}) in
" lua/hybris/init.lua. ImpEx is line-oriented: header lines start with an operation
" keyword (INSERT/UPDATE/INSERT_UPDATE/REMOVE) followed by an ItemType and
" ';'-separated columns with optional [modifier=...] and (sub.qualifier) syntax;
" data lines are ';'-separated values; '#' starts a comment; '$' defines/uses macros.

if exists("b:current_syntax")
  finish
endif

syntax case match

" Comments (full line and trailing)
syntax match impexComment "#.*$" contains=@Spell

" Macro definitions and references: $macroName , $config-... etc.
syntax match impexMacro "\$[A-Za-z_][A-Za-z0-9_.-]*"

" Operation keywords at (optional-whitespace) line start
syntax match impexHeaderMode "^\s*\%(INSERT_UPDATE\|INSERT\|UPDATE\|REMOVE\)\>"

" The ItemType right after the operation keyword
syntax match impexType "\%(^\s*\%(INSERT_UPDATE\|INSERT\|UPDATE\|REMOVE\)\s\+\)\@<=[A-Za-z][A-Za-z0-9_]*"

" Bracketed modifiers: [unique=true], [allownull=true], [dateformat=...], [mode=append]
syntax region impexModifier matchgroup=impexBracket start="\[" end="\]" contains=impexModKey,impexBool,impexNumber,impexMacro oneline
syntax match impexModKey "\<\%(unique\|allownull\|default\|mode\|dateformat\|numberformat\|lang\|translator\|cellDecorator\|virtual\|forceWrite\|ignoreKeyCase\|path\|collection-delimiter\|key2value-delimiter\|map-delimiter\)\>" contained

" Sub-qualifier / foreign-key syntax: (code), (isocode), (PassengerInformation.passengerId)
syntax region impexQualifier matchgroup=impexParen start="(" end=")" contains=impexMacro oneline

" Beanshell / scripting directives
syntax match impexDirective "^\s*\%(#%\|\"#%\|INSERT_UPDATE Script\).*$"
syntax match impexBeanshell "^\s*\"\?#%.*$"

" Literals
syntax keyword impexBool true false TRUE FALSE
syntax match impexNumber "\<\d\+\%(\.\d\+\)\?\>"

" Header/value separators
syntax match impexSep ";"

highlight default link impexComment    Comment
highlight default link impexMacro      PreProc
highlight default link impexHeaderMode Statement
highlight default link impexType       Type
highlight default link impexModifier   Normal
highlight default link impexBracket    Delimiter
highlight default link impexModKey     Identifier
highlight default link impexQualifier  Normal
highlight default link impexParen      Delimiter
highlight default link impexBool       Boolean
highlight default link impexNumber     Number
highlight default link impexSep        Delimiter
highlight default link impexBeanshell  Special
highlight default link impexDirective  Special

let b:current_syntax = "impex"
