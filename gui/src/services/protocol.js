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

class Type {
	constructor(name, byteCount, func){
		this.name = name
		this.byteCount = byteCount
		this.func = func
	}
}

const types = {
	200: new Type("Start", 1, () => {
		window.speak("Controller restarted.")
	})
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
