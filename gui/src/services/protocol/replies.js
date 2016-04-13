"use strict";

class Reply {
	constructor(name, value, dataSize){
		this.name = name;
		this.value = value;
		this.dataSize = dataSize;
	}
}

var replies = [
	new Reply("ping", 0x00, 0),
  new Reply("speed", 0x01, 2),
  new Reply("accX", 0x02, 2)
];

module.exports = replies;
