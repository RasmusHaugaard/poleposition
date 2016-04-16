import React, {PropTypes} from 'react'
import {connect} from 'react-redux'

import {IconButton} from 'material-ui'
import Bluetooth from 'material-ui/lib/svg-icons/device/bluetooth.js'
import BluetoothConnected from 'material-ui/lib/svg-icons/device/bluetooth-connected.js'
import BluetoothSearching from 'material-ui/lib/svg-icons/device/bluetooth-searching.js'

import {btClick, STATUS} from '../actions/bt'

let BluetoothButton = ({btService, onClick}) => {
	let icon = (() => {
		switch (btService.status) {
			case STATUS.CONNECTED:
				return <BluetoothConnected color={"white"}/>
			case STATUS.NOTCONNECTED:
				return <Bluetooth color={"white"} className={"greyed-out"}/>
			case STATUS.CONNECTING:
			case STATUS.DISCONNECTING:
				return <BluetoothSearching color={"white"} className={"wiggle"}/>
		}
	})()
  return(
    <IconButton
      onClick={() => {
				onClick(btService)
			}}>
      {icon}
    </IconButton>
  )
}

const mapStateToProps = (state) => {
	return {
		btService: state.btService
	}
}

const mapDispatchToProps = (dispatch) => {
	return {
		onClick: (btService) => {
			dispatch(btClick(btService))
		}
	}
}

BluetoothButton = connect(
	mapStateToProps,
	mapDispatchToProps
)(BluetoothButton)

export default BluetoothButton
