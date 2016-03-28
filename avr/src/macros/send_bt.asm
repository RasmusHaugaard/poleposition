.def storebyte = R16

.macro send_bt_byte
  call store_bt_to_buf
.endm

.macro send_bt_byte_8
  push storebyte
  mov storebyte, @0
  call store_bt_to_buf
  pop storebyte
.endm

.undef storebyte
