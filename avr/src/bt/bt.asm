.include "src/bt/setup.asm"
.include "src/bt/tr.asm"
.include "src/bt/rc.asm"

sbi UCSRB, RXCIE
;evt send "$$$" (wait) "F,1\n" for at gå i fast mode
