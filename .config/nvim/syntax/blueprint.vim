" Vim syntax file for Blueprint (.blp), GNOME's declarative GTK UI language.
"
" Hand-written, because nvim-treesitter ships no blueprint parser and
" blueprint-compiler 0.16 installs no editor syntax definition (checked
" 2026-09-12). The token inventory below is taken from the compiler's own
" tokenizer at /usr/lib/python3/dist-packages/blueprintcompiler/tokenizer.py:
"
"   operators:    $ << >> => :: < > := . || | + - * = : /
"   punctuation:  ( ) { } ; [ ] ,
"
" Keywords come from the parser's string literals in the same package.

if exists("b:current_syntax")
  finish
endif

syn case match

" Comments ---------------------------------------------------------------
" Regions restrict what may match inside them, so strings and comments do not
" leak into each other.
syn region blueprintComment start="//" end="$" keepend contains=@Spell
syn region blueprintComment start="/\*" end="\*/" contains=@Spell

" Strings ----------------------------------------------------------------
syn region blueprintString start=+"+ skip=+\\"+ end=+"+ contains=blueprintEscape
syn region blueprintString start=+'+ skip=+\\'+ end=+'+ contains=blueprintEscape
syn match  blueprintEscape +\\[\\"'nrt]+ contained

" Translation function: _("literal")
syn match blueprintTranslator "_\ze("

" Keywords ---------------------------------------------------------------
syn keyword blueprintKeyword using import as bind bind-property
syn keyword blueprintKeyword template typeof default signal
syn keyword blueprintKeyword property required deprecated
syn keyword blueprintBoolean true false null
syn match   blueprintAnnotation /@[A-Za-z-]\+/

" Template child and signal handler references: $title_label, $on_clicked()
syn match blueprintTemplateRef /\$[A-Za-z_][A-Za-z0-9_-]*/

" Structure --------------------------------------------------------------
" Widget instantiation, qualified (Gtk.Button, Adw.Bin) or bare (Button).
syn match blueprintType /\<[A-Z][A-Za-z0-9]*\.[A-Z][A-Za-z0-9]*\>/
syn match blueprintType /\<[A-Z][A-Za-z0-9]*\>/

" Property assignment: a lower-case identifier followed by a colon.
syn match blueprintProperty /\<[a-z_][A-Za-z0-9_-]*\ze\s*:/

" Signal connection: an identifier followed by =>.
syn match blueprintSignal /\<[a-z_][A-Za-z0-9_-]*\ze\s*=>/

" Literals and operators ------------------------------------------------
syn match blueprintNumber   /\<0x[0-9A-Fa-f_]\+\>/
syn match blueprintNumber   /\<\d[\d_]*\(\.[\d_]\+\)\?\>/
syn match blueprintOperator /=>\|<<\|>>\|::\|:=\|\$\|||\||/
syn match blueprintDelimiter /[{}()\[\];,]/

" Highlight links --------------------------------------------------------
hi def link blueprintComment     Comment
hi def link blueprintString      String
hi def link blueprintEscape      SpecialChar
hi def link blueprintTranslator  Function
hi def link blueprintKeyword     Keyword
hi def link blueprintBoolean     Constant
hi def link blueprintAnnotation  PreProc
hi def link blueprintTemplateRef Identifier
hi def link blueprintType        Type
hi def link blueprintProperty    Identifier
hi def link blueprintSignal      Function
hi def link blueprintNumber      Number
hi def link blueprintOperator    Operator
hi def link blueprintDelimiter   Delimiter

let b:current_syntax = "blueprint"
