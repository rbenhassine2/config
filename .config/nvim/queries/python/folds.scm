; ~/.config/nvim/queries/python/folds.scm
; extends

(string
  (string_start) @fold.start
  (string_content)
  (string_end) @fold.end
  (#make-range! "fold" @fold.start @fold.end))

; Also fold docstrings that are expression_statement (optional but nice)
(
  (expression_statement
    (string) @fold
    (#make-range! "fold" @fold))
)
