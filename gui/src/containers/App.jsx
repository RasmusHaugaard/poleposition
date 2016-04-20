import React, {Component, PropTypes} from 'react'
import {connect} from 'react-redux'

import getMuiTheme from 'material-ui/lib/styles/getMuiTheme'
import theme from '../theme.js'

import LeftNavPP from './LeftNavPP.jsx'
import AppBarPP from './AppBarPP.jsx'

import Terminal from './Terminal.jsx'
import Graph from './Graph.jsx'

import {btConnect} from '../actions/bt'
import {init as btInit} from '../services/bluetooth'
import {init as protocolInit} from '../services/protocol'

class App extends Component{
	constructor(props){
		super(props)
	}
	getChildContext(){
		return {
			muiTheme: getMuiTheme(theme)
		}
	}
	componentDidMount(){
		btInit()
		protocolInit()
		this.props.btConnect()
	}
	render(){
		let {mainRoute} = this.props
		let body
		switch (mainRoute) {
			case "TERMINAL":
				body = <Terminal />
				break;
			case "GRAPH":
				body = <Graph />
				break;
			default:
				body = <div>Unknown route, {mainRoute}</div>
		}
		return (
			<div style={{height: "100%"}}>
				<AppBarPP />
				<LeftNavPP />
				<div style={{
						"height": "calc(100% - 64px)",
						"boxSizing": "border-box",
						"padding": "15px",
						"overflow": "auto"
					}}>
					{body}
				</div>
			</div>
		)
	}
}

App.childContextTypes = {
	muiTheme: PropTypes.object
}

const mapStateToProps = (state) => {
	return {
		mainRoute: state.mainRoute
	}
}

const mapDispatchToProps = (dispatch) => {
	return {
		btConnect: () => {
			dispatch(btConnect())
		}
	}
}

App = connect(
	mapStateToProps,
	mapDispatchToProps
)(App)

export default App
