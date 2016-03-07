; Initialiser stack pointer, så vi kan bruge "call / callr", lave interrupts mm.
ldi R16, HIGH(RAMEND)
out SPH, R16
ldi R16, LOW(RAMEND)
out SPL, R16