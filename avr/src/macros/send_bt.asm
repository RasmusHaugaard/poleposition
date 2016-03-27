.def store_byte = R16

.macro send_bt_byte
.endm

.macro send_bt_byte [8]
  push store_byte
  mov store_byte, @0
  call store_bt_to_buf
  pop store_byte
.endm
