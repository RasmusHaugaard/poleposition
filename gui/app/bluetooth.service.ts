import {Injectable} from 'angular2/core';

@Injectable()
export class BluetoothService {
	private DEVICE_NAME = "RNBT-BCAC";
	private BITRATE = 115200;
	connId = null;
	private listeners:((byte)=>void)[];

	constructor(){
		chrome.serial.onReceive.addListener(this.serialReceive);
	}

	connect = (callback:(boolean)=>void) => {
		chrome.serial.getDevices((devs) => {
			var dev = devs.filter((dev) => {
				return dev.path.indexOf(this.DEVICE_NAME) !== -1
			})[0];
			if (!dev) {
				console.log("Cannot find: " + this.DEVICE_NAME);
				callback(false);
				return;
			}
			chrome.serial.connect(dev.path, {bitrate: this.BITRATE}, (ConnInfo) => {
				if (!ConnInfo) {
					console.log("Failed to connect to: " + this.DEVICE_NAME + ", with path: " + dev.path);
					callback(false);
					return;
				}
				this.connId = ConnInfo.connectionId;
				console.log("Connected with connection id: " + this.connId);
				callback(true);
				return;
			});
		});
	};

	addListener = (callback:(byte)=>void) => {
		if(this.listeners.indexOf(callback) === -1)
			this.listeners.push(callback);
	};

	removeListener = (callback:(byte)=>void) => {
		let i = this.listeners.indexOf(callback);
		if (i !== -1) this.listeners.splice(i, 1);
	};

	private receiveByte = (byte:number) => {
		this.listeners.forEach((callback)=>{
			callback(byte);
		});
	};

	private serialReceive = (info) => {
		if(info.connectionId !== this.connId) return;
		new Uint8Array(info.data)
			.forEach((byte) => {
				this.receiveByte(byte)
			});
	};

	serialSend = (bytes:number[], callback:()=>void) => {
		if (this.connId === null) throw("Not currently connected to bluetooth module.");
		let buf = new ArrayBuffer(bytes.length);
		let bufView = new Uint8Array(buf);
		bytes.forEach((byte, i) => {
			bufView[i] = bytes[i];
		});
		chrome.serial.send(this.connId, buf, this.sendCompleted);
	};

	sendCompleted = (sendInfo:Object) => {
		console.log("sendInfo: ", sendInfo);
	};
}