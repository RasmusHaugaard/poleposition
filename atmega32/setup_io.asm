
		; PORTC setup
		ldi		R16, 0x00			; 
		;out		DDRC, R16			; Set PORTC as input
		ldi		R16, 255			;
		out 	PORTC, R16 			; Enable pull-up on PORTC
				
		; PORTB setup
		out 	DDRB, R16			; PORTB = output
		ldi		R16, 0x55
		out		PORTB, R16			; Turn LEDS off
