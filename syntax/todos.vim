syn match todosStartTime "\vSTART_TIME: \d+-\d+-\d+ \d+:\d+:\d+"
syn match todosDoneTime "\vDONE_TIME: \d+-\d+-\d+ \d+:\d+:\d+"
syn match todosElapsedTime "\vELAPSED: (\d+h)?(\d+m)?\d+s"
syn match todosGroupName /^.*:$/
syn region todosTaskTitle start=/^  \*/ end=/$/ contains=todosStartTime,todosDoneTime,todosElapsedTime
syn region todosSubTaskTitle start=/^    \*\*/ end=/$/ contains=todosStartTime,todosDoneTime,todosElapsedTime

hi todosStartTime guifg=yellow
hi todosDoneTime guifg=LightGreen
hi todosElapsedTime guifg=LightBlue
hi todosGroupName guifg=Cyan
hi todosTaskTitle guifg=LightMagenta
hi todosSubTaskTitle guifg=White
