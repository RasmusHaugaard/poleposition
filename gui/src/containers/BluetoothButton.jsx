import React, {PropTypes} from 'react'
import {connect} from 'react-redux'

import {IconButton} from 'material-ui'
import Bluetooth from 'material-ui/lib/svg-icons/device/bluetooth.js'
import BluetoothConnected from 'material-ui/lib/svg-icons/device/bluetooth-connected.js'
import BluetoothSearching from 'material-ui/lib/svg-icons/device/bluetooth-searching.js'

import {btClick} from '../actions/bt'
import {STATUS} from '../services/bluetooth'

let BluetoothButton = ({bt, onClick}) => {
	let icon
	switch (bt) {
		case STATUS.CONNECTED:
			icon = (<BluetoothConnected color={"white"} />)
			break
		case STATUS.NOTCONNECTED:
			icon = (<Bluetooth color={"white"} className={"greyed-out"} />)
			break
		case STATUS.CONNECTING:
		case STATUS.DISCONNECTING:
			icon = (<BluetoothSearching color={"white"} className={"wiggle bluetooth"} style={{"transform":"translateX(8px)"}} />)
			break
	}
	return(
		<IconButton
			onClick={
				() => {
					onClick(bt)
				}
			}>
			{icon}
		</IconButton>
	)
}

const mapStateToProps = (state) => {
	return {
		bt: state.bt
	}
}

const mapDispatchToProps = (dispatch) => {
	return {
		onClick: (bt) => {
			dispatch(btClick(bt))
		}
	}
}

BluetoothButton = connect(
	mapStateToProps,
	mapDispatchToProps
)(BluetoothButton)

export default BluetoothButton
