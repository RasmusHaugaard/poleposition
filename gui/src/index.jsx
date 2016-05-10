import React from 'react'
import {render} from 'react-dom'
import injectTapEventPlugin from 'react-tap-event-plugin'
injectTapEventPlugin()

import {Provider} from 'react-redux'
import configureStore from './store/configureStore'
import App from './containers/App.jsx'

import voiceControlInit from './services/voiceControl'
import {getHex} from './services/flasher'

voiceControlInit()

let store = configureStore()
window.store = store

render(
	<Provider store={store}>
		<App />
	</Provider>,
	document.getElementById('app')
)

chrome.storage.local.get("folderEntry", (obj) => {
	if (!obj.folderEntry){
		chrome.fileSystem.chooseEntry(
			{type: "openDirectory"},
			(entry) => {
				window.folderEntry = entry
				let id = chrome.fileSystem.retainEntry(entry)
				chrome.storage.local.set({folderEntry: id})
				getHex()
			}
		)
	}else{
		chrome.fileSystem.restoreEntry(
			obj.folderEntry,
			(entry) => {
				window.folderEntry = entry
				getHex()
			}
		)
	}
})
