"use strict";
/*

*/
const connect = require('../bt').connect;
const userinput = require('./userinput');

var conn = null;

var onData = (data) => {
	var val = data[0];
  console.log((val > 127 ? val - 255 : val).toString());
}

var callback = (_conn) => {
  if(!_conn) process.exit(1);
  conn = _conn;
  console.log("Ready for input:");
}

userinput((input)=>{
  conn.write(input);
});

connect(callback, onData);
