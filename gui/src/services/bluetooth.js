"use strict";

	receiveByte = (byte) => {
		this.listeners.forEach((callback)=>{
			callback(byte);
		});
	};

	serialReceive = (info) => {
		if(info.connectionId !== this.connId) return;

	};

	serialSend = (bytes, callback) => {
		if (this.connId === null) throw("Not currently connected to bluetooth module!");
		let buf = new ArrayBuffer(bytes.length);
		let bufView = new Uint8Array(buf);
		bytes.forEach((byte, i) => {
			bufView[i] = bytes[i];
		});
		chrome.serial.send(this.connId, buf, this.sendCompleted);
	};

	sendString = (string) => {
		var a = new Array(string.length);
		for (var i = 0; i < string.length; i++){
			a[i] = string.charCodeAt(i);
		}
		this.serialSend(a);
	}
}
