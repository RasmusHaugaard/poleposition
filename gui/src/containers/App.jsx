import React from 'react'
import {connect} from 'react-redux'

import LeftNavPP from './LeftNavPP.jsx'
import AppBarPP from './AppBarPP.jsx'

import Terminal from './Terminal.jsx'

let App = ({mainRoute}) => {
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
					"box-sizing": "border-box",
					"padding": "15px",
					"overflow": "scroll"
				}}>
				{body}
			</div>
		</div>
	)
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
