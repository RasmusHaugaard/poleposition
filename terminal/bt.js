"use strict";

const DEVICE_NAME = "RNBT-BCAC";
const BAUDRATE = 115200;

var SerialPort = require("serialport").SerialPort;
var serialPort = require("serialport");

var connect = (callback) => {
	var privateListeners = [];
	var listeners = [];
  console.log("Trying to connect to " + DEVICE_NAME + "...");
  serialPort.list(function (err, ports) {
    var port = ports.filter(port => port.comName.indexOf(DEVICE_NAME) !== -1)[0];
    if(!port){
      console.log("Device not found. Please connect to the device once manually!");
      return;
    }
    var conn = new SerialPort(port.comName, {baudrate: BAUDRATE}, false);
    conn.open(function (error){
      if(error){
        console.log("Failed to open connection! - Make sure bt is enabled..\n" + error);
        callback(false);
      }else{
        console.log("Connection established!");
        conn.on("data", (data) => {
					listeners.forEach(listener => listener(data));
					if (privateListeners.length > 0) privateListeners[0](data);
				});
				conn.on("close", () => {
					console.log("Connection was closed.");
					process.exit();
				});
				conn.on("disconnect", (e) => {
					console.log("Connection lost.", e);
					process.exit(1);
				});
				conn.on("error", (e) => {
					console.log("Connection error.", e);
					process.exit(1);
				});
				conn.writeByteArray = (array) => {
					var buf = new ArrayBuffer(array.length);
					var bufView = new Uint8Array(buf);
					for (var i = 0; i < array.length; i++){
						bufView[i] = array[i];
					}
					conn.write(buf);
				};
				conn.listen = (onData) => {
					listeners.push(onData);
					return () => {
						listeners.splice(listeners.indexOf(onData),1);
					};
				};
				conn.listenPrivately = (onData) => {
					privateListeners.unshift(onData);
					return () => {
						privateListeners.splice(privateListeners.indexOf(onData), 1);
					};
				};
        callback(conn);
      }
    });
  });
}

module.exports = {connect};
