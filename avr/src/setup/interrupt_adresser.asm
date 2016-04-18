;=====ISR adresser=====
.org 0			;start adresse
jmp main		;adresse med mere plads

.org 0x12		;adresse for timer1 overflow (interrupt vektor table)
jmp T1_OV_ISR	;adresse med mere plads

.org 0x06		;adresse for extern interrupt 2 (Port B, pin 2)
jmp EX2_ISR		;adresse med mere plads

.org 0x04		;adresse for extern interrupt 1 (Port D, pin 3)
jmp EX1_ISR		;adresse med mere plads
