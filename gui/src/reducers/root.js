import {combineReducers} from 'redux'
import mainRoute from './mainRoute'
import leftNavOpen from './leftNavOpen'
import btService from './btService'

const rootReducer = combineReducers({
	mainRoute,
	leftNavOpen,
	btService
});

export default rootReducer
