import {MAIN_ROUTE} from '../actions/mainRoute'
import {TOGGLE_LEFT_NAV} from '../actions/leftNavOpen'

export default function leftNavOpen(state = false, action){
	switch (action.type){
		case TOGGLE_LEFT_NAV:
			return !state
		case MAIN_ROUTE:
			return false
		default:
			return state;
	}
}
