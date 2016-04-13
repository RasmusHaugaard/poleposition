import React from 'react';
import ReactDOM from 'react-dom';

import {IconButton} from 'material-ui';
import Bluetooth from 'material-ui/lib/svg-icons/device/bluetooth.js';
import BluetoothConnected from 'material-ui/lib/svg-icons/device/bluetooth-connected.js';
import BluetoothSearching from 'material-ui/lib/svg-icons/device/bluetooth-searching.js';

export default class BluetoothButton extends React.Component {
  constructor(props){
    super(props);
    this.btService = window.app.services.bluetoothService;
    this.state = {status: this.btService.status};
    this.btService.addStatusListener(this.updateStatus);
  }

  componentDidMount = () => {
    this.connect();
  }

  updateStatus = (status) => {
    this.setState({status : status});
  }

  connect = () => {
    this.btService.connect();
  }

  render(){
    var STATUS = this.btService.STATUS;
    var status = this.state.status;
    var icon = null;
    if(status === STATUS.CONNECTED){
      icon = <BluetoothConnected color={"white"}/>
    }else if(status === STATUS.NOTCONNECTED){
      icon = <Bluetooth color={"white"} className={"greyed-out"}/>
    }else if(status === STATUS.CONNECTING){
      icon = <BluetoothSearching color={"white"} className={"wiggle"}/>
    }

    return(
      <IconButton
        onClick={this.connect}>
        {icon}
      </IconButton>
    );
  }
}
