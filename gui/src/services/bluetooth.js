import {STATUS as BL_STATUS} from '../actions/bl'
import {tmReceived} from '../actions/terminal'

const DEVICE_NAME = "RNBT-BCAC"
const BITRATE = 115200

export const STATUS = {
	CONNECTED: "CONNECTED",
	NOTCONNECTED: "NOTCONNECTED",
	CONNECTING: "CONNECTING",
	DISCONNECTING: "DISCONNECTING"
}

export const init = () => {
	chrome.serial.onReceive.addListener((info) => {
		if (info.connectionId !== window.connId) return;
		receiveData(info.data)
	})

	chrome.serial.onReceiveError.addListener((info) => {
		if (window.connId !== info.connId) return;
		store.dispatch(btDisconnected())
	})
}

const receiveData = (buf) => {
	let bufView = new Uint8Array(buf)
	let data = new Array(bufView.length)
	for (let i in bufView){
		data[i] = bufView[i]
	}
	receiveArray(data)
}

const receiveArray = (data) => {
	let store = window.store
	let state = store.getState()
	if (state.mainRoute === "TERMINAL" && state.bl.status !== BL_STATUS.PROGRAMMING){
		store.dispatch(tmReceived(data))
	}else{
		data.forEach(byte => receiveByte(byte))
	}
}
window.receiveArray = receiveArray

const receiveByte = (byte) => {
	let state = window.store.getState()
	if(state.bl.status === BL_STATUS.PROGRAMMING){
		window.flasher.receiveByte(byte)
	}else{
		window.protocol.receiveByte(byte)
	}
}

export const connect = (success, error) => {
	chrome.serial.getDevices((devs) => {
		let dev = devs.filter((dev) => {
			return dev.path.indexOf(DEVICE_NAME) !== -1
		})[0];
		if (!dev) {
			window.connId = null
			error(
				"No such available device: " + DEVICE_NAME +
				". Make sure you have connected manually at least once."
			)
		}else{
			chrome.serial.connect(dev.path, {bitrate: BITRATE}, (ConnInfo) => {
				if (!ConnInfo) {
					window.connId = null
					error(
						"Failed to connec: " + DEVICE_NAME +
						", with path: " + dev.path + ". Make sure bluetooth is on."
					)
				}else{
					window.connId = ConnInfo.connectionId
					success()
				}
			})
		}
	})
}

export const disconnect = (callback) => {
	if (typeof window.connId === "number"){
		chrome.serial.disconnect(connId, () => {
			window.connId = null
			callback()
		})
	}else{
		callback()
	}
}

export const send = (data, callback) => {
	if (typeof window.connId !== "number"){
		callback(false)
		return
	}
	let buf
	if (typeof data === "string"){
		buf = new ArrayBuffer(data.length)
		let bufView = new Uint8Array(buf)
		for (let i in data){
			bufView[i] = data.charCodeAt(i)
		}
	}else if (Array.isArray(data)){
		buf = new ArrayBuffer(data.length)
		let bufView = new Uint8Array(buf)
		for (let i in data){
			let value = data[i];
			if (typeof value !== "number"){
				console.log("Cannot send array with other than numbers.", value)
				callback(false)
				throw("Bt error")
				return;
			}
			bufView[i] = value
		}
	}else{
		console.log("Type error. What is THIS?", data)
		callback(false)
		throw("Type error")
		return;
	}
	chrome.serial.send(window.connId, buf, (e) => {
		if (e.error){
			callback(false)
		}else{
			callback(true)
		}
	})
}
