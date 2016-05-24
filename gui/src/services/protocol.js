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
				console.log("Type not know?", byte)
				return
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

const is = test => typeof test !== "undefined"

const toSigned = val => val > 127 ? val - 256 : val

const quickAddToGraph = (name, x, y) => {
	let lines = window.graph.lines || (window.graph.lines = [])
	let	line = lines.find(line => line.name === name)
	if (!line){
			line = {name}
			window.graph.lines.push(line)
	}
	;(line.x || (line.x = [])).push(x)
	;(line.y || (line.y = [])).push(y)
	if (!is(line.xmin) || x < line.xmin) line.xmin = x
	if (!is(line.xmax) || x > line.xmax) line.xmax = x
	if (!is(line.ymin) || y < line.ymin) line.ymin = y
	if (!is(line.ymax) || y > line.ymax) line.ymax = y
}


window.quickAddToGraph = quickAddToGraph
window.clearGraph = () => {window.graph = {}}

const tps = (16 * Math.pow(10,6))/256
const spt = 1/tps
const cmptick = 0.307
const speedscaler = 2

const toRealTime = time => time * spt

const tc = {
	start:{name:"start", code:200},
	gyrzhDis:{name:"gyrzh-dis", code:10},
	speedDis:{name:"speed", code:11},
	nextLapTimeDis:{code:14},
	readyToProgram:{code:203}
}

var types = {}
types[tc.readyToProgram.code] = {
	byteCount: 1,
	func: () => {
		window.speak("Ready to program.")
		console.log("Ready to program")
	}
}
types[tc.start.code] = {
	byteCount: 1,
	func: () => {
		window.speak("Controller restarted.")
		console.log("Controller restarted")
	}
}
types[tc.nextLapTimeDis.code] = {
	byteCount: 5,
	func: buf => {
		let lapTime = toRealTime(
			buf[0] * Math.pow(2,16) + buf[1] * Math.pow(2,8)
		)
		let lapDistance = (buf[2] * Math.pow(2,8) + buf[3]) * cmptick
		let avgSpeed = lapDistance / lapTime
		console.log("New lap in:", lapTime.toFixed(3) + "s")
		console.log("Lap distance:", lapDistance.toFixed(1) + "cm")
		console.log("Avg speed:", avgSpeed.toFixed(1), "cm/s")
	}
}
types[tc.gyrzhDis.code] = {
	byteCount: 4,
	func: buf => {
		quickAddToGraph(
			tc.gyrzhDis.name,
			buf[0] * 256 + buf[1],
			toSigned(buf[2])
		)
	}
}
types[tc.speedDis.code] = {
	byteCount: 4,
	func: buf => {
		let distance = buf[0] * 256 + buf[1]
		let dt = buf[2]
		//quickAddToGraph("Speed (dtime)", speedtimei++, dt)
		quickAddToGraph(
			tc.speedDis.name,
			distance,
			(tps/speedscaler)/(dt/cmptick)
		)
	}
}

function save(graph){
	//if (!graph.lines && !graph.xGridLines) return

	window.folderEntry.getDirectory('data', {create:true}, directoryEntry => {
		directoryEntry.getFile(
			(new Date()).toString() + ".csv",
			{create:true, exclusive: true},
			fileEntry => {
				fileEntry.createWriter(fileWriter => {
					window.fileWriter = fileWriter
					let file = []
					if (graph.lines){
						let lines = graph.lines
						lines.forEach(line => {
							file.push(line.name + "_x,")
							file.push(line.name + "_y,")
						})
						file.push("\n")
						let rowCounts = lines.map(line => Math.min(line.x.length, line.y.length))
						let maxRowCount = rowCounts.reduce((prev, val) => Math.max(prev, val))
						for (var row = 0; row < maxRowCount; row++){
							lines.forEach((line, i) => {
								if (rowCounts[i] >= row){
									file.push(line.x[row] + ",")
									file.push(line.y[row] + ",")
								}else{
									file.push(",,")
								}
							})
							file.push("\n")
						}
					}
					fileWriter.onwriteend = () => console.log("write complete")
					fileWriter.onerror = e => console.log("write failed:" + e.toString())
					fileWriter.write(new Blob(file))
				})
			}
		)
	})
}

window.saveGraph = () => {
	save(window.graph)
}
