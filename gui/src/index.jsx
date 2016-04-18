import React from 'react'
import {render} from 'react-dom'
import injectTapEventPlugin from 'react-tap-event-plugin'
injectTapEventPlugin()

import {Provider} from 'react-redux'
import configureStore from './store/configureStore'
import App from './containers/App.jsx'

import {btConnect, btReceivedData, btDisconnected} from './actions/bt'
import {tmReceived} from './actions/terminal'

let store = configureStore()

render(
	<Provider store={store}>
		<App />
	</Provider>,
	document.getElementById('app')
)

chrome.serial.onReceive.addListener((info) => {
	var state = store.getState()
	if (info.connectionId !== state.btService.connId) return;
	if (state.mainRoute === "TERMINAL"){
		var a = new Uint8Array(info.data)
		var ar = new Array(info.data)
		for (let i in a){
			ar[i] = a[i]
		}
		console.log("Received data")
		store.dispatch(tmReceived(ar))
		return;
	}
	console.log("Not in terminal, but received byte!")
	//store.dispatch(btReceivedData(info, store.getState().btService))
});

chrome.serial.onReceiveError.addListener((info) => {
	if (!store.getState().btService.connId === info.connId) return;
	store.dispatch(btDisconnected())
})

window.store = store

store.dispatch(btConnect())
