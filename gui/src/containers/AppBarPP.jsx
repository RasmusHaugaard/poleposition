import React, {PropTypes} from 'react'
import {connect} from 'react-redux'
import {AppBar} from 'material-ui'
import BluetoothButton from './BluetoothButton.jsx';
import {toggleLeftNav} from '../actions/leftNavOpen'

let AppBarPP = ({onLeftIconClick}) => (
	<AppBar
		style={{"zIndex" : 1400}}
		title="poleposition"
		onLeftIconButtonTouchTap={onLeftIconClick}
		iconElementRight={<BluetoothButton/>}
		/>
)

AppBarPP.propTypes = {
	onLeftIconClick: PropTypes.func.isRequired
}

const mapDispatchToProps = (dispatch) => {
	return {
		onLeftIconClick: () => {
			dispatch(toggleLeftNav())
		}
	}
}

AppBarPP = connect(
	null,
	mapDispatchToProps
)(AppBarPP)

export default AppBarPP
