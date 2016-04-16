import React from 'react'
import connect from 'react-redux'

//import Terminal from './Terminal.jsx'

let BodyPP = ({mainRoute}) => (
	<div>
			<div>{"Hej"}</div>
	</div>
);

const mapStateToProps = (state) => {
	return {
		mainRoute: state.mainRoute
	}
}

BodyPP = connect(
	mapStateToProps
)(BodyPP)

export default BodyPP
