"use strict";
/*

*/
var connect = require('../../bt').connect;
//var userinput = require('../userinput');

var conn = null;

var kbCount = 255; // 1 <= kbCount <= 255
var dataSize = kbCount * 1000;
var receivedSize = 0;
var receivedPackages = 0;
var errCount = 0;
var char = 0;

var onData = (data) => {
  for (var i = 0; i < data.length; i++){
    if(! (data[i] === char)){
      console.log("Error! Expected " + char + "but got: " + data[i]);
      errCount++;
      char = data[i];
    }
    char++;
    if(char > 255) char = 0;
  }
  receivedPackages++;
  receivedSize += data.length;
  if(receivedSize === dataSize) transferComplete();
  if(receivedSize > dataSize) console.log("Received more data than expected!! " + receivedSize + ' bytes!');
  console.log(receivedSize + ' Bytes received..');
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
  var buf = new ArrayBuffer(1);
  var bufView = new Uint8Array(buf);
  bufView[0] = kbCount;
  conn.write(buf);
}

var transferComplete = () => {
  var deltaTime = (new Date()) - startTime;
  console.log("\n");
  console.log("1 byte sent and " + dataSize + ' bytes received in ' + deltaTime + ' ms.');
  console.log(parseFloat((dataSize / deltaTime).toFixed(2)) + " kB/s");
  console.log("Received " + receivedPackages + ' packages.');
  if(errCount === 0) {
    console.log("Transfer complete without errors!");
  }else{
    console.log(errCount + " Errors!!");
  }
  process.exit();
}
