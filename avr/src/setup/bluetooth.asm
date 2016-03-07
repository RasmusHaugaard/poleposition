;enable transmitter
ldi R16, (1<<TXEN) | (1<<RXEN)
out UCSRB, R16
;8-bit data, no parity, 1 stop bit
ldi R16, (1<<UCSZ1) | (1<<UCSZ0) | (1<<URSEL)
out UCSRC, R16
;Set baudrate to 9600 - (16MHz / (16 * (9600)) - 1) -> HEX
ldi R16, 0x67
out UBRRL, R16