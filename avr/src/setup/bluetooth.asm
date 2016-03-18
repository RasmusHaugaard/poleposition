;enable transmitter
ldi R16, (1<<TXEN) | (1<<RXEN)
out UCSRB, R16
;8-bit data, no parity, 1 stop bit
ldi R16, (1<<UCSZ1) | (1<<UCSZ0) | (1<<URSEL)
out UCSRC, R16
;Set baudrate (16MHz / (16 * (9600)) - 1) -> HEX
ldi R16, 0x03
out UBRRL, R16


;Send "$$$" + "F,1" for at gå i fast mode