import {send} from './bluetooth'
import {tmReceived} from '../actions/terminal'
import {PROGRAMMING, NOT_PROGRAMMING} from '../actions/bl'
import {addDataToGraph} from '../actions/graph'

export const init = () => {
	window.protocol = new ProtocolService()
}

class ProtocolService {
	constructor(){
		this.reset()
	}
	reset(){
		this.buffer = []
		this.type = null
		this.receivedBytes = 0
	}
	receiveByte(byte){
		if (this.type === null){
			this.type = types[byte]
			if (typeof this.type === "undefined"){
				this.type = null
				throw("Type not known?", byte)
			}
		}else{
			this.buffer.push(byte)
		}
		this.receivedBytes++
		if (this.receivedBytes === this.type.byteCount){
			this.type.func(this.buffer)
			this.reset()
		}
	}
}

class Type {
	constructor(name, byteCount, func){
		this.name = name
		this.byteCount = byteCount
		this.func = func
	}
}

const toSigned = (val) => {
	return val > 127 ? val - 256 : val
}

/*const quickAddToGraph = (name, point) => {
	let data = window.data.name || (window.data.name = [])
	data.push(point)
}*/


const quickAddToGraph = (name, point) => {
	window.store.dispatch(
		addDataToGraph({name, point})
	)
}


let idx = 0, idy = 0, idz = 0

const types = {
	128: new Type("Start", 1, () => {
		window.speak("Controller restarted.")
	}),
	30: new Type("accX", 2, (data) => {
		quickAddToGraph("accX", {x:idx++, y: toSigned(data[0])})
	}),
	31: new Type("accY", 2, (data) => {
		quickAddToGraph("accY", {x:idy++, y: toSigned(data[0])})
	}),
	32: new Type("accZ", 2, (data) => {
		quickAddToGraph("accZ", {x:idz++, y: toSigned(data[0])})
	}),
	40: new Type("gyrX", 2, (data) => {
		quickAddToGraph("gyrX", {x:idz++, y: toSigned(data[0])})
	}),
	41: new Type("gyrY", 2, (data) => {
		quickAddToGraph("gyrY", {x:idz++, y: toSigned(data[0])})
	}),
	42: new Type("gyrZ", 2, (data) => {
		quickAddToGraph("gyrZ", {x:idz++, y: toSigned(data[0])})
	})
}
