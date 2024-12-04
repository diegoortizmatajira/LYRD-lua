((comment) @injection.content
  (#set! injection.language "comment"))


(attribute
    name: (identifier) @constant
    (#any-of? @constant "GeneratedRegex")
    (attribute_argument_list
        (attribute_argument
            (verbatim_string_literal) @injection.content (#set! injection.language "regex")
)))


; (
;     (
;         (verbatim_string_literal) @constant
;         (#match? @constant "(SELECT|select|insert|INSERT).*")
;     )@injection.content 
;     (#set! injection.language "sql")
; )
