import {combineReducers} from 'redux'
import mainRoute from './mainRoute'
import leftNavOpen from './leftNavOpen'
import bt from './bt'
import terminal from './terminal'
import bl from './bl'
import graph from './graph'

const rootReducer = combineReducers({
	mainRoute,
	leftNavOpen,
	bt,
	terminal,
	bl,
	graph
});

export default rootReducer
