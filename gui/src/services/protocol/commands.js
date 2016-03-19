"use strict";

//command types
const SET = 0x55,
			GET = 0xAA;

commands = {
	ping: () => {
		return [0x00];
	},
	start: (speed) => {
		speed = parseInt(speed);
		if (speed < 0 || 100 < speed)) throw("Hastigheden skal sættes mellem 0 og 100(%)");
		return [SET, 0x10, speed];
	},
	stop: () => {
		return [SET, 0x11, 0];
	}
};

module.exports = commands;
