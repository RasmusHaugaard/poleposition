import {send} from './bluetooth'
import {tmReceived} from '../actions/terminal'
import {PROGRAMMING, NOT_PROGRAMMING} from '../actions/bl'

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

const types = {
	128: new Type("Start", 1, () => {
		console.log("Atmega Restarted!")
	}),
	30: new Type("accX", 2, (data) => {
		console.log(this.name, toSigned(data[0]))
	}),
	31: new Type("accY", 2, (data) => {
		console.log(this.name, toSigned(data[0]))
	}),
	32: new Type("accZ", 2, (data) => {
		console.log(this.name, toSigned(data[0]))
	})
}
