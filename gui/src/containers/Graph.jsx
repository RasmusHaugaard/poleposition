import React, {Component} from 'react'
import Rx from 'rx'
import AnimFrameObs from '../helpers/animationFrameObserver'
import fastPlot from 'fast-plot'

class Graph extends Component {
	constructor(props){
		super(props)
	}
	componentDidMount(){
		this.resizeObserver = Rx.Observable.fromEvent(window, 'resize')
			.debounce(200)
			.subscribe(() => {
				this.updateSize()
			})
		this.updateSize()
		this.animFrameObs = new AnimFrameObs()
			.subscribe(() => {
				console.log("Rerender anim frame")
				this.forceUpdate()
			})
		this.ctx = this.refs.canvas.getContext("2d")
	}
	componentWillUnmount(){
		this.resizeObserver.dispose()
		this.animFrameObs.dispose()
	}
	updateSize(){
		let rect = this.refs.container.getClientRects()[0]
		this.refs.canvas.width = rect.width
		this.refs.canvas.height = rect.height - 15
		this.renderGraph()
	}
	renderGraph(){
		fastPlot(this.ctx, {
			lines: [
				{
					x: [1,2,3,4],
					y: [1,2,3,4]
				}
			]
		})
	}
	render(){
		return (
			<div ref="container" style={{"overflow":"hidden", "width":"100%", "height":"100%"}}>
				<canvas ref="canvas"></canvas>
			</div>
		)
	}
	shouldComponentUpdate(){
		return false
	}
}

const mapStateToProps = (state) => {
	return {
		data: state.graph
	}
}

Graph = connect(mapStateToProps)(Graph)

export default Graph
