import React, {Component, PropTypes} from 'react'
import {connect} from 'react-redux'

import getMuiTheme from 'material-ui/lib/styles/getMuiTheme'
import theme from '../theme.js'

import LeftNavPP from './LeftNavPP.jsx'
import AppBarPP from './AppBarPP.jsx'

import Terminal from './Terminal.jsx'

class App extends Component{
	constructor(props){
		super(props)
	}
	getChildContext(){
		return {
			muiTheme: getMuiTheme(theme)
		}
	}
	render(){
		let {mainRoute} = this.props
		let body = null
		switch (mainRoute) {
			case "TERMINAL":
				body = <Terminal />
				break;
			case "STATS":
				body = <div>Stats</div>
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
						"overflow": "scroll"
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

App = connect(
	mapStateToProps
)(App)

export default App
