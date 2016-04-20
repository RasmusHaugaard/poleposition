import {combineReducers} from 'redux'
import mainRoute from './mainRoute'
import leftNavOpen from './leftNavOpen'
import bt from './bt'
import terminal from './terminal'
import bl from './bl'

const rootReducer = combineReducers({
	mainRoute,
	leftNavOpen,
	bt,
	terminal,
	bl
});

export default rootReducer
