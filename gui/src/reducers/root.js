import {combineReducers} from 'redux'
import mainRoute from './mainRoute'
import leftNavOpen from './leftNavOpen'
import btService from './btService'
import terminal from './terminal'

const rootReducer = combineReducers({
	mainRoute,
	leftNavOpen,
	btService,
	terminal
});

export default rootReducer
