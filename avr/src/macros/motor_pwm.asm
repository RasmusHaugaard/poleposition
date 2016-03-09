.macro setspeed
.endm

.macro	setspeed_8	;tager adresse til gpr
	out OCR2, @0	;og skriver gpr til OCR2
.endm

.macro	setspeed_i	;tager konstant
	ldi R16, @0
	out OCR2, R16
.endm