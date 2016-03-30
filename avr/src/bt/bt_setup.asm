.filedef temp = R16

;enable transmitter
ldi temp, (1<<TXEN) | (1<<RXEN)
out UCSRB, temp
;8-bit data, no parity, 1 stop bit
ldi temp, (1<<UCSZ1) | (1<<UCSZ0) | (1<<URSEL)
out UCSRC, temp
;Set baudrate (16MHz / (16 * (38000)) - 1)
ldi temp, 25
out UBRRL, temp
