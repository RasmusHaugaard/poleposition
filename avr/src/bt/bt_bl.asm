.include "src/bt/bt_setup.asm"
.include "src/bt/bt_tr.asm"
.include "src/bt/bt_rc.asm"

sbi UCSRB, RXCIE
;evt send "$$$" (wait) "F,1\n" for at gå i fast mode
