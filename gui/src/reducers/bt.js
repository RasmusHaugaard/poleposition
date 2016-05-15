import {BT_CONNECTED, BT_CONNECTING, BT_DISCONNECTED,
	BT_DISCONNECTING,	BT_FAILED_TO_CONNECT} from '../actions/bt'
import {STATUS} from '../services/bluetooth'

export default function bt(
	state = STATUS.NOTCONNECTED,
	action){

	switch (action.type){
		case BT_CONNECTED:
			return STATUS.CONNECTED
		case BT_FAILED_TO_CONNECT:
		case BT_DISCONNECTED:
			return STATUS.NOTCONNECTED
		case BT_CONNECTING:
			return STATUS.CONNECTING
		case BT_DISCONNECTING:
			return STATUS.DISCONNECTING
		default:
			return state
	}
}
