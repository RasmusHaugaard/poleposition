.filedef temp = R16

ldi temp, 12 ;sæt i2c clk til 400 kHz
out TWBR, temp
