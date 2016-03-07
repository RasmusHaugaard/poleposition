;PWM opsætning.  (s. 561)
;Vores PWM er sat på PD7, så vi bruger Timer2 til PWM og TCCR2 registeret
;Den sammenligner timer2(TCNT2) og OCR2. 
;Vi kan så styre dutycycle med OCR2. 
;Eks. out OCR2, 255/4 for 25% dutycycle
		;Fast PWM------------     PWM active high  PWM clk = clk / 1024 = 16k
ldi R16, (1<<WGM21) | (1<<WGM20) | (1<<COM21) | (1<<CS22) | (1<<CS20)
out TCCR2, R16