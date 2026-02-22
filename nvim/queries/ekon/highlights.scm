; Highlights for Ekon

; Comments
(comment) @comment

; Keys
(pair
  key: (_) @property)

; Strings
(string) @string
(multiline_string) @string
(unquoted_string) @string.special

; Escape sequences
(escape_sequence) @string.escape

; Numbers
(number) @number

; Constants
(true) @boolean
(false) @boolean
(null) @constant.builtin

; Brackets
["{" "}"] @punctuation.bracket
["[" "]"] @punctuation.bracket

; Delimiters
":" @punctuation.delimiter
"," @punctuation.delimiter
