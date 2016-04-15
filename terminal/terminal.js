"use strict";


const connect = require('./bt').connect;
//const userinput = require('./util/userinput');
const btFlash = require('./bt_flash');
const repl = require('repl');

var ctx = repl.start('> ').context;

var retries = 3;
var conn = null;

var onData = (data) => {
	for (var i = 0; i < data.length; i++ ){
		var val = data[i];
		console.log(val);
		//console.log((val > 127 ? val - 255 : val) * .018);
	}
}

var callback = (_conn) => {
  if(!_conn){
		if(!retries) process.exit(1);
		console.log("Retrying..", retries, "retries left.");
		retries--;
		connect(callback);
	}
  conn = _conn;
	conn.listenPrivately(onData);
  console.log("Ready for input:");
}

connect(callback);

const checknumber = (number) => {
	if (!typeof number === "number"){
		console.log(number, "is not a number..");
		return false;
	}else if(number > 255 || number < -128){
		console.log(number, "is not in range -128 <= number <= 255.");
		return false;
	}
	return true;
}

ctx.num = (numbers, nothing) => {
	if (typeof nothing !== "undefined"){
		console.log("Please provide an explicit array.");
		return;
	}
	if (Array.isArray(numbers)){
		for (var number in numbers){
			if (!checknumber(number)) return;
		}
		conn.writeByteArray(numbers);
	}else if(typeof numbers === "number"){
		if (!checknumber(number)) return;
		conn.writeByteArray([numbers]);
	}else{
		console.log("Input must be a number or an array of numbers.");
	}
	return "Number(s) sent.";
}

ctx.text = (text) => {
	if (typeof text === "string"){
		conn.write(text);
	}else{
		console.log("Input must be a string.");
	}
	return "Text sent.";
}

ctx.program = () => btFlash(conn);
ctx.m = "Hey";
