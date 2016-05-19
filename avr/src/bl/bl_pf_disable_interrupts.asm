;TODO: Disable all interrupts manually
.filedef temp = R16

;1A, 1C, 1E
in temp, UCSRB
andi temp, low(~((1<<RXCIE)|(1<<UDRIE)|(1<<TXCIE)))
out UCSRB, temp

;eksterne interrupts
cbi GICR, INT0
cbi GICR, INT1
cbi GICR, INT2

;timer 1 overflow
cbi TIMSK, TOV1
