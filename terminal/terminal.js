"use strict";
/*

*/
const connect = require('./bt').connect;
const userinput = require('./util/userinput');

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
		connect(callback, onData);
	}
  conn = _conn;
  console.log("Ready for input:");
}

userinput((input)=>{
  conn.write(input);
});

connect(callback, onData);
