import React, {Component} from 'react'
import Rx from 'rx'
import AnimFrameObs from '../helpers/animationFrameObserver'
import fastPlot from 'fast-plot'


class Graph extends Component {
	constructor(props){
		super(props)
	}
	componentDidMount(){
		this.ctx = this.refs.canvas.getContext("2d")
		this.resizeObserver = Rx.Observable.fromEvent(window, 'resize')
			.debounce(200)
			.subscribe(() => {
				this.updateSize()
			})
		this.updateSize()
		this.animFrameObs = AnimFrameObs()
			.subscribe(() => {
				this.renderGraph()
			})
	}
	componentWillUnmount(){
		this.resizeObserver.dispose()
		this.animFrameObs.dispose()
	}
	updateSize(){
		let rect = this.refs.container.getClientRects()[0]
		let width = rect.width
		let height = rect.height - 15
		this.refs.canvas.width = width * window.devicePixelRatio
		this.refs.canvas.height = height * window.devicePixelRatio
		this.refs.canvas.style.width = width + 'px'
		this.renderGraph()
	}
	renderGraph(){
		fastPlot(this.ctx, window.graph)
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

/*
const mapStateToProps = (state) => {
	return {
		data: state.graph
	}
}
*/
//Graph = connect(mapStateToProps)(Graph)

export default Graph
