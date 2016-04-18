import {BT_CONNECTED, BT_CONNECTING, BT_DISCONNECTED,
	BT_DISCONNECTING, BT_RECEIVED_BYTE, BT_TRANSMIT_DATA,
	BT_FAILED_TO_CONNECT, STATUS, BT_TRANSMIT_ERROR, btTransmitError} from '../actions/bt'

export default function btService(state = {
	connId: null,
	status: STATUS.NOTCONNECTED
}, action){
	switch (action.type){
		case BT_RECEIVED_BYTE:
			console.log(action.byte);
			return state
		case BT_CONNECTED:
			return {
				...state,
				connId: action.ConnInfo.connectionId,
				status: STATUS.CONNECTED
			}
		case BT_FAILED_TO_CONNECT:
		case BT_DISCONNECTED:
			return {
				...state,
				connId: null,
				status: STATUS.NOTCONNECTED
			}
		case BT_CONNECTING:
			return {
				...state,
				status: STATUS.CONNECTING
			}
		case BT_DISCONNECTING:
			return {
				...state,
				status: STATUS.DISCONNECTING
			}
		case BT_TRANSMIT_DATA:
			console.log("This does nothing..")
			return state
		case BT_TRANSMIT_ERROR:
			console.log(BT_TRANSMIT_ERROR, action.errorText)
			return state
		default:
			return state
	}
}
