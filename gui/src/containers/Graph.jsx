import React, {Component} from 'react'
import {connect} from 'react-redux'
import {LineChart} from 'rd3'
import Rx from 'rx'

class Graph extends Component {
	constructor(props){
		super(props)
	}
	componentDidMount(){
		this.resizeObserver = Rx.Observable.fromEvent(window, 'resize')
			.debounce(200)
			.subscribe(() => {
				this.updateSize()
				this.forceUpdate()
			})
		this.updateSize()
		this.forceUpdate()
		this.timerObserver = Rx.Observable
			.interval(400)
			.subscribe(() => {
				this.forceUpdate()
			})
	}
	componentWillUnmount(){
		this.resizeObserver.dispose()
		this.timerObserver.dispose()
	}
	updateSize(){
		let rect = this.refs.container.getClientRects()[0]
		this.width = rect.width
		this.height = rect.height - 15
	}
	render(){
		let {data} = this.props
		return (
			<div ref="container" style={{"overflow":"hidden", "width":"100%", "height":"100%"}}>
				<LineChart
				  legend={false}
				  data={data}
				  width={this.width}
				  height={this.height}
					colors={(a) => {return ["red","green","blue", "orange", "pink", "purple"][a]}}
				/>
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
