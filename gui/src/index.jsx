import React from 'react'
import {render} from 'react-dom'
import injectTapEventPlugin from 'react-tap-event-plugin'
injectTapEventPlugin()

import {Provider} from 'react-redux'
import configureStore from './store/configureStore'
import App from './components/App.jsx'

import {btConnect, btReceivedData} from './actions/bt'

let store = configureStore()

render(
	<Provider store={store}>
		<App />
	</Provider>,
	document.getElementById('app')
)

chrome.serial.onReceive.addListener((info) => {
	store.dispatch(btReceivedData(info, store.getState().btService))
});
store.dispatch(btConnect())
