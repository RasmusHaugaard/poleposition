import {createStore, applyMiddleware} from 'redux'
import thunkMiddleware from 'redux-thunk'
import createLogger from 'redux-logger'
import rootReducer from '../reducers/root'

let loggerMiddleware = createLogger()

const configureStore = () => {
	return createStore(
		rootReducer,
		applyMiddleware(
			thunkMiddleware,
			//loggerMiddleware
		)
	)
}

export default configureStore
