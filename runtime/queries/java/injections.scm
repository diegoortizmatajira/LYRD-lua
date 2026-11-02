;; extends

; JPQL/HQL has no treesitter grammar, so `sql` is used as an approximation
; (entity/field names are highlighted like tables/columns). Native queries are real SQL.

; @Query("...") and @NamedQuery("...")
(annotation
    name: (identifier) @_name
    (#any-of? @_name "Query" "NamedQuery")
    arguments: (annotation_argument_list
        (string_literal
            [(string_fragment) (multiline_string_fragment)] @injection.content))
    (#set! injection.language "sql"))

; @Query(value = "...") and @NamedQuery(query = "...")
(annotation
    name: (identifier) @_name
    (#any-of? @_name "Query" "NamedQuery" "NamedNativeQuery")
    arguments: (annotation_argument_list
        (element_value_pair
            key: (identifier) @_key
            (#any-of? @_key "value" "query")
            value: (string_literal
                [(string_fragment) (multiline_string_fragment)] @injection.content)))
    (#set! injection.language "sql"))

; @Query("..." + "...") concatenations (up to three parts, combined into one injection)
(annotation
    name: (identifier) @_name
    (#any-of? @_name "Query" "NamedQuery" "NamedNativeQuery")
    arguments: (annotation_argument_list
        [
            (binary_expression
                (string_literal
                    (string_fragment) @injection.content))
            (binary_expression
                (binary_expression
                    (string_literal
                        (string_fragment) @injection.content)))
            (element_value_pair
                key: (identifier) @_key
                (#any-of? @_key "value" "query")
                value: [
                    (binary_expression
                        (string_literal
                            (string_fragment) @injection.content))
                    (binary_expression
                        (binary_expression
                            (string_literal
                                (string_fragment) @injection.content)))
                ])
        ])
    (#set! injection.language "sql")
    (#set! injection.combined))

; em.createQuery("..."), createNamedQuery is a name lookup so it is excluded
(method_invocation
    name: (identifier) @_method
    (#any-of? @_method "createQuery" "createNativeQuery")
    arguments: (argument_list
        .
        (string_literal
            [(string_fragment) (multiline_string_fragment)] @injection.content))
    (#set! injection.language "sql"))
