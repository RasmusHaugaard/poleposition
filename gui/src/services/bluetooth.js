"use strict";

const DEVICE_NAME = "RNBT-BCAC";
const BITRATE = 115200;

export default class BluetoothService {
	connId = null;
	listeners = [];
	statusListeners = [];
	STATUS = {
		CONNECTED:0,
		NOTCONNECTED:1,
		CONNECTING:2
	};
	status = this.STATUS.NOTCONNECTED;

	constructor(){
		chrome.serial.onReceive.addListener(this.serialReceive);
	}

	connect = () => {

		if (this.status == this.STATUS.CONNECTING) return;

		if (typeof this.connId === 'number'){
			chrome.serial.disconnect(connId, () => {
				this.connId = null;
				this.updateStatus(this.STATUS.NOTCONNECTED);
			});
		}

		this.updateStatus(this.STATUS.CONNECTING);
		chrome.serial.getDevices((devs) => {
			var dev = devs.filter((dev) => {
				return dev.path.indexOf(DEVICE_NAME) !== -1
			})[0];
			if (!dev) {
				console.log("Cannot find: " + DEVICE_NAME);
				this.updateStatus(this.STATUS.NOTCONNECTED);
				return;
			}
			chrome.serial.connect(dev.path, {bitrate: BITRATE}, (ConnInfo) => {
				if (!ConnInfo) {
					console.log("Failed to connect to: " + DEVICE_NAME + ", with path: " + dev.path);
					this.updateStatus(this.STATUS.NOTCONNECTED);
					return;
				}
				this.connId = ConnInfo.connectionId;
				console.log("Connected with connection id: " + this.connId);
				this.updateStatus(this.STATUS.CONNECTED);
				return;
			});
		});
	};

	updateStatus = (status) => {
		this.status = status;
		this.statusListeners.forEach((cb) => cb(status));
	}

	addStatusListener = (callback) => {
		this.statusListeners.push(callback);
	}

	addListener = (callback) => {
			this.listeners.push(callback);
	};

	removeListener = (callback) => {
		let i = this.listeners.indexOf(callback);
		if (i !== -1) this.listeners.splice(i, 1);
	};

	receiveByte = (byte) => {
		this.listeners.forEach((callback)=>{
			callback(byte);
		});
	};

	serialReceive = (info) => {
		if(info.connectionId !== this.connId) return;
		new Uint8Array(info.data)
			.forEach((byte) => {
				this.receiveByte(byte)
			});
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

	sendCompleted = (sendInfo) => {

	};
}
