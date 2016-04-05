"use strict";
//var util = require('util');

const input = (onInput) => {
	process.stdin.resume();
	process.stdin.setEncoding('utf8');
	process.stdin.on('data', (input) => {
		//remove automatic newline.
		input = input.substr(0, input.length - 1);
		//enables the user to exit the program
		if (input === 'quit') process.exit();
		//enables the user to send manual newline by writing "\n"
		input = input.replace(/\\n/g, "\n");
		//enables the user to send decimal, hex, and binary by writing (dec 10): 0d10, 0xA, 0b1010
		if(input.length > 2 && input.substr(0,1) === "0"){
			var letter = input.substr(1,1);
			var valStr = input.substr(2, input.length - 2);
			var val = null;
			if(letter === "d"){
				val = parseNumber(valStr, 10);
			}else if(letter === "x"){
				val = parseNumber(valStr, 16);
			}else if(letter === "b"){
				val = parseNumber(valStr, 2);
			}
			//If it was not one of 0x, 0d, 0b, it will not have changed. Send the string.
			if(val !== null){
				//Return if the val could not be parsed
				if(val === false) return;
				var buf = new ArrayBuffer(1);
				var bufView = new Uint8Array(buf);
				bufView[0] = val;
				input = buf;
			}
		}
		onInput(input);
	});
}

var parseNumber = (valStr, base) => {
	var val = parseInt(valStr, base);
	if(val !== val){
		console.log("Couldn't parse:", input, "in base ", base);
		return false;
	}else if(val > 255){
		console.log("Please only send values between 0 and 255.");
		return false;
	}
	return val;
}

module.exports = input;
