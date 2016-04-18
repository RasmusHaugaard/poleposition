const DEVICE_NAME = "RNBT-BCAC";
const BITRATE = 115200;

export const STATUS = {
	CONNECTED: "CONNECTED",
	NOTCONNECTED: "NOTCONNECTED",
	CONNECTING: "CONNECTING",
	DISCONNECTING: "DISCONNECTING"
};

export const BT_CLICK = "BT_CLICK"
export const btClick = (btService) => {
	return (dispatch) => {
		switch (btService.status) {
			case STATUS.NOTCONNECTED:
				dispatch(btConnect())
				return;
			case STATUS.CONNECTED:
				dispatch(btDisconnect(btService.connId))
				return;
		}
	}
}

export const BT_CONNECT = "BT_CONNECT"
export const btConnect = () => {
	return (dispatch) => {
		dispatch(btConnecting())
		chrome.serial.getDevices((devs) => {
			let dev = devs.filter((dev) => {
				return dev.path.indexOf(DEVICE_NAME) !== -1
			})[0];
			if (!dev) {
				dispatch(btFailedToConnect(
					"No such available device:", DEVICE_NAME,
					"Make sure you have connected manually at least once."
				))
				return
			}
			chrome.serial.connect(dev.path, {bitrate: BITRATE}, (ConnInfo) => {
				if (!ConnInfo) {
					dispatch(btFailedToConnect(
						"Failed to connec:", DEVICE_NAME, "with path:", dev.path,
						"Make sure bluetooth is on."
					))
					return
				}
				dispatch(btConnected(
					ConnInfo
				))
			})
		})
	}
}

export const BT_DISCONNECT = "BT_DISCONNECT"
export const btDisconnect = (connId) => {
	return (dispatch) => {
		dispatch(btDisconnecting())
		chrome.serial.disconnect(connId, () => {
			dispatch(btDisconnected())
		})
	}
}

export const BT_RECEIVED_DATA = "BT_RECEIVED_DATA"
export const btReceivedData = (info, btService) => {
	return (dispatch) => {
		if (info.connectionId !== btService.connId) return;
		new Uint8Array(info.data)
			.forEach(byte => dispatch(btReceiveByte(byte)))
	}
}

export const BT_TRANSMIT_DATA = "BT_TRANSMIT_DATA"
export const btTransmit = (data, callback) => {
	let state = window.store.getState()
	if (typeof state.btService.connId !== "number"){
		callback(false)
	}else{
		let buf
		if (typeof data === "string"){
			buf = new ArrayBuffer(data.length)
			let bufView = new Uint8Array(buf)
			for (let i in data){
				bufView[i] = data.charCodeAt(i)
			}
		}else if (Array.isArray(data)){
			buf = new ArrayBuffer(data.length);
			let bufView = new Uint8Array(buf);
			for (let i = 0; i < data.length; i++){
				let value = data[i];
				if (typeof value !== "number"){
					console.log("Cannot send array with other than numbers.", value)
					callback(false)
					return;
				}
				bufView[i] = value
			}
		}else{
			console.log("Type error. What is THIS?", data)
			callback(false)
			return;
		}
		chrome.serial.send(state.btService.connId, buf, (e) => {
			if (e.error){
				callback(false)
			}else{
				callback(true)
			}
		})
	}
}

export const BT_TRANSMIT_ERROR = "BT_TRANSMIT_ERROR"
export const btTransmitError = (errorText) => {
	return {
		type: BT_TRANSMIT_ERROR,
		errorText
	}
}

export const BT_RECEIVED_BYTE = "BT_RECEIVED_BYTE"
export const btReceivedByte = (byte) => {
	return {
		type: BT_RECEIVED_BYTE,
		byte
	}
}

export const BT_CONNECTING = "BT_CONNECTING"
export const btConnecting = () => {
	return {
		type: BT_CONNECTING
	}
}

export const BT_DISCONNECTING = "BT_DISCONNECTING"
export const btDisconnecting = () => {
	return {
		type: BT_DISCONNECTING
	}
}

export const BT_CONNECTED = "BT_CONNECTED"
export const btConnected = (ConnInfo) => {
	return {
		type: BT_CONNECTED,
		ConnInfo
	}
}

export const BT_FAILED_TO_CONNECT = "BT_FAILED_TO_CONNECT"
export const btFailedToConnect = (error) => {
	return {
		type: BT_FAILED_TO_CONNECT,
		error
	}
}

export const BT_DISCONNECTED = "BT_DISCONNECTED"
export const btDisconnected = () => {
	return {
		type: BT_DISCONNECTED
	}
}
