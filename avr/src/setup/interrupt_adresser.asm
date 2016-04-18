;=====ISR adresser=====
.org 0
jmp main
.org 0x14		;adresse for timer1 compare match (interrupt vektor table)
jmp T1_CM_ISR	;adresse med mere plads
.org 0x60		;adresse for extern interrupt (Port B, pin 2)
jmp EX2_ISR		;adresse med mere plads