import {STATUS as BL_STATUS} from '../actions/bl'
import {tmReceived} from '../actions/terminal'
import {btConnect} from '../actions/bt'

export const DEVICE_NAME = "RNBT-BCAC"
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

	window.btDevices = () => {
		chrome.serial.getDevices(devs => console.log(devs.map(dev => dev.path)))
	}

	window.btConnect = path => {
		window.store.dispatch(
			btConnect(path)
		)
	}
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

export const connect = (_deviceName, success, error) => {
	let deviceName = _deviceName || DEVICE_NAME
	window.connId = null
	chrome.serial.getDevices((devs) => {
		let dev = devs.filter((dev) => {
			return dev.path.indexOf(deviceName) !== -1
		})[0];
		if (!dev) {
			error(
				"No such available device: " + deviceName +
				". Make sure you have connected manually at least once."
			)
		}else{
			chrome.serial.connect(dev.path, {bitrate: BITRATE}, (ConnInfo) => {
				if (!ConnInfo) {
					error(
						"Failed to connec: " + deviceName +
						", with path: " + dev.path + ". Make sure bluetooth is on."
					)
				}else{
					window.connId = ConnInfo.connectionId
					window.btSendBuffer = new btSendBuffer()
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

const send = (data, callback) => {
	if (typeof window.connId !== "number"){
		if (callback) callback(false, "Not currently connected. Cannot send byte.")
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
				if (callback) callback(false, {string:"Cannot send array with other than numbers.", value})
				return;
			}
			bufView[i] = value
		}
	}else{
		console.log("Type error. What is THIS?", data)
		if (callback) callback(false, {string:"Unknown data type. Data must be either a string or an array of numbers.", data})
		return;
	}
	window.btSendBuffer.add(buf, callback)
}

class btSendBuffer{
	constructor(){
		this.sendBuf = []
		this.ready = true
		this.pending = false
	}
	sendNext(){
		if(this.sendBuf.length === 0 || this.ready === false || this.pending) return
		this.ready = false
		var {aBuf, callback} = this.sendBuf[0]
		chrome.serial.send(window.connId, aBuf, (e) => {
			if (e.error){
				if (e.error === "pending"){
					console.log("Controlled pending")
					this.pending = true
					setTimeout(() => {
						this.pending = false
						this.sendNext()
					}, 10)
				}else{
					console.log("Unhandled bt error.", e.error, "Flushing btSendBuffer")
					this.sendBuf = []
					this.ready = true
					if (callback) callback(false, e.error)
				}
			}else{
				this.sendBuf.shift()
				this.ready = true
				if (callback) callback(true)
				this.sendNext()
			}
		})
	}
	add(aBuf, callback){
		this.sendBuf.push({aBuf, callback})
		this.sendNext()
	}
}

window.send = send

exports.send = send
