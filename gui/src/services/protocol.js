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

const quickAddToGraph = (name, x, y, extremes, color) => {
	let lines = window.graph.lines || (window.graph.lines = [])
	let	line = lines.find(line => line.name === name)
	if (!line){
			line = {name}
			if (color) line.color = color
			window.graph.lines.push(line)
	}
	;(line.x || (line.x = [])).push(x)
	;(line.y || (line.y = [])).push(y)
	if(extremes){
			if (is(extremes.xmin)) line.xmin = extremes.xmin
			if (is(extremes.xmax)) line.xmax = extremes.xmax
			if (is(extremes.ymin)) line.ymin = extremes.ymin
			if (is(extremes.ymax)) line.ymax = extremes.ymax
	}
	if (!is(line.xmin) || x < line.xmin) line.xmin = x
	if (!is(line.xmax) || x > line.xmax) line.xmax = x
	if (!is(line.ymin) || y < line.ymin) line.ymin = y
	if (!is(line.ymax) || y > line.ymax) line.ymax = y
	if (color) line.color = color
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
	speedDis:{name:"speed-dis", code:11},
	nextLapTimeDis:{code:14},
	readyToProgram:{code:203},
	detectedStraightPath:{name:"Straight Path", code:15},
	detectedLeftTurn:{name:"Left Turn", code:16},
	detectedRightTurn:{name:"Right Turn", code:17},
	gyrInt:{name:"Gyr Integration", code:18},
	brakeDis:{name:"Breaking Distance", code:19}
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
			toSigned(buf[2]),
			{xmin: 0, ymin: -128, ymax: 127},
			"red"
		)
	}
}
types[tc.gyrInt.code] = {
	byteCount: 4,
	func: buf => {
		quickAddToGraph(
			tc.gyrInt.name,
			buf[0] * 256 + buf[1],
			buf[2],
			{xmin: 0, ymin: 0, ymax: 170},
			"purple"
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
			dt,//(tps/speedscaler)/(dt/cmptick)
			{ymin: 0, ymax: 255},
			"green"
		)
	}
}
types[tc.brakeDis.code] = {
	byteCount: 5,
	func: buf => {
		let distance = buf[0] * 256 + buf[1]
		let brakeDistance = buf[2] * 256 + buf[3]
		quickAddToGraph(
			tc.brakeDis.name,
			distance,
			brakeDistance,
			null,
			"blue"
		)
	}
}

const xGridLine = (buf, text) => {
	let g = window.graph
	if (!g.xGridLines) g.xGridLines = []
	g.xGridLines.push({
		x: buf[0] * 256 + buf[1],
		topText: text
	})
}

types[tc.detectedStraightPath.code] = {
	byteCount: 3,
	func: buf => {
		xGridLine(buf, tc.detectedStraightPath.name)
	}
}

types[tc.detectedLeftTurn.code] = {
	byteCount: 3,
	func: buf => {
		xGridLine(buf, tc.detectedLeftTurn.name)
	}
}

types[tc.detectedRightTurn.code] = {
	byteCount: 3,
	func: buf => {
		xGridLine(buf, tc.detectedRightTurn.name)
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
