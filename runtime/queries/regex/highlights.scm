;; extends

[
  "{"
  "}"
  "*"
  "+"
  "?"
  "|"
  "="
  "!"
  "-"
  "\\k"
  (lazy)
  (lazy)
  (optional)
  (zero_or_more)
  (one_or_more)
  (count_quantifier)
] @keyword.operator

[
  (control_letter_escape)
  (character_class_escape)
  (control_escape)
  (boundary_assertion)
  (non_boundary_assertion)
] @keyword.directive

