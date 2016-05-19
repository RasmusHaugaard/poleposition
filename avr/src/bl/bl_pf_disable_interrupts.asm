;TODO: Disable all interrupts manually
.filedef temp = R16

;1A, 1C, 1E
in temp, UCSRB
andi temp, low(~((1<<RXCIE)|(1<<UDRIE)|(1<<TXCIE)))
out UCSRB, temp

;eksterne interrupts
in temp, GICR
andi temp, low(~((1<<INT0)|(1<<INT1)|(1<<INT2)))
out GICR, temp

;timer 1 overflow
in temp, TIMSK
andi temp, low(~(1<<TOV1))
out TIMSK, temp
