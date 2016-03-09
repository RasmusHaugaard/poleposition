	;sørg for interrupts ligger i bootloaderen
	;(s. 48 i datablad)
	in R16, GICR	;load GICR register
	sbr R16, IVSEL	;sæt Interrupt Vector Select i R16
	sbi GICR, IVCE	;sæt Interrupt Vector Change Enable for at kunne ændre værdien
	out GICR, R16	;skriv så R16 til GICR (nu lav IVCE)