rjmp encoder_handler_file_end

.filedef dh = R16
.filedef dl = R17
.filedef temp = R18


encoder_handler:
	rcall increment_dis
	reti

encoder_handler_file_end:
