.filedef temp = R16

ldi temp, 12 ;sæt i2c clk til 400 kHz
out TWBR, temp

.include "src/i2c/i2c_id_macros.asm"
.include "src/i2c/i2c_ie_macros.asm"
