"use strict";
/*
Sender byten 0x00 dataSize antal gange til atmega32 og forventer at få det samme retur.
Den måler tiden mellem den starter med at sende pakken til den har modtaget hele pakken igen.
*/
var connect = require('../../bt').connect;

var conn = null;

var dataSize = 10000;
var data = (new Array(dataSize)).fill("0").join('');
var receivedSize = 0;
var receivedPackages = 0;

var onData = (data) => {
  receivedPackages++;
  receivedSize += data.length;
  if(receivedSize === dataSize) transferComplete();
}

var callback = (_conn) => {
  if(!_conn) process.exit(1);
  conn = _conn;
  startTransfer();
}

connect(callback, onData);

var startTime;

var startTransfer = () => {
  console.log("starting transfer..");
  startTime = new Date();
  conn.write(data);
}

var transferComplete = () => {
  var deltaTime = (new Date()) - startTime;
  console.log("\n");
  console.log(dataSize + ' bytes sent and received in ' + deltaTime + ' ms.');
  console.log("Received " + receivedPackages + ' packages.');
  console.log("Transfer complete!");
  process.exit();
}
