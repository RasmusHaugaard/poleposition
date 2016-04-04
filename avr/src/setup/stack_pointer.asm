; Initialiser stack pointer, så vi kan bruge "call / callr", lave interrupts mm.
.filedef temp = R16

ldi temp, HIGH(RAMEND)
out SPH, temp
ldi temp, LOW(RAMEND)
out SPL, temp
