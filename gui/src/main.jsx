"use strict";

import React from 'react';
import ReactDom from 'react-dom';
import injectTapEventPlugin from 'react-tap-event-plugin';
injectTapEventPlugin();

import BluetoothService from './services/bluetooth.js';
import ProtocolService from './services/protocol.js';

var services = {};
services.bluetoothService = new BluetoothService();
services.protocolService = new ProtocolService();
window.app.services = services;

import App from './components/app.jsx';

ReactDom.render(
  <App/>,
  document.getElementById('app')
);
