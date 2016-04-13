"use strict";

import React from 'react';
import ReactDOM from 'react-dom';

import {TextField, FlatButton} from 'material-ui';

export default class Terminal extends React.Component {
  constructor(props){
    super(props);
    this.btService = window.app.services.bluetoothService;
    this.state = {text:""};
    this.btService.addListener(this.receiveByte);
  }

  receiveByte = (byte) => {
    this.setState({text: this.state.text + String.fromCharCode(byte)});
  }

  sendString = (e) => {
    e = e.nativeEvent;
    if(e && e.keyIdentifier === "Enter"){
      if (e.shiftKey) return;
      e.preventDefault();
    }
    var string = this.refs.textField.getValue();
    this.btService.sendString(string);
    this.refs.textField.input.setValue("");
  }

  clear = () => {
    this.setState({text:""});
  }

  render(){
    return(
      <div style={{"display":"flex",
        "flex-direction":"column",
        "justify-content":"space-between",
        "overflow": "scroll",
        "padding" : "20px"
      }}>
        <p className={"roboto"}>{this.state.text}</p>
        <TextField
          ref="textField"
          onEnterKeyDown={this.sendString}
          multiLine={true}
          rows={1}
          style={{
            "width":""
          }}/>
        <FlatButton label="Clear Terminal" onClick={this.clear}/>
      </div>
    );
  }
}
