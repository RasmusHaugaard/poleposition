import {STATUS, connect, disconnect, send} from '../services/bluetooth'

export const BT_CLICK = "BT_CLICK"
export const btClick = (bt) => {
	return (dispatch) => {
		switch (bt) {
			case STATUS.NOTCONNECTED:
				dispatch(btConnect())
				return;
			case STATUS.CONNECTED:
				dispatch(btDisconnect())
				return;
		}
	}
}

export const BT_CONNECT = "BT_CONNECT"
export const btConnect = () => {
	return (dispatch) => {
		dispatch(btConnecting())
		connect(
			() => dispatch(btConnected()),
			errorText => dispatch(btFailedToConnect(errorText))
		)
	}
}

export const BT_DISCONNECT = "BT_DISCONNECT"
export const btDisconnect = (connId) => {
	return (dispatch) => {
		dispatch(btDisconnecting())
		disconnect(() => dispatch(btDisconnected()))
	}
}

export const btTransmit = (data, callback) => {
	send(data, callback)
}

export const BT_TRANSMIT_ERROR = "BT_TRANSMIT_ERROR"
export const btTransmitError = (errorText) => {
	return {
		type: BT_TRANSMIT_ERROR,
		errorText
	}
}

export const BT_CONNECTING = "BT_CONNECTING"
export const btConnecting = () => {
	return {
		type: BT_CONNECTING
	}
}

export const BT_DISCONNECTING = "BT_DISCONNECTING"
export const btDisconnecting = () => {
	return {
		type: BT_DISCONNECTING
	}
}

export const BT_CONNECTED = "BT_CONNECTED"
export const btConnected = (ConnInfo) => {
	return {
		type: BT_CONNECTED,
		ConnInfo
	}
}

export const BT_FAILED_TO_CONNECT = "BT_FAILED_TO_CONNECT"
export const btFailedToConnect = (error) => {
	return {
		type: BT_FAILED_TO_CONNECT,
		error
	}
}

export const BT_DISCONNECTED = "BT_DISCONNECTED"
export const btDisconnected = () => {
	return {
		type: BT_DISCONNECTED
	}
}
