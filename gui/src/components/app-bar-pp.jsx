import React from 'react';
import {AppBar} from 'material-ui';

import BluetoothButton from './bluetooth-button.jsx';

var style = {
  "zIndex" : 1400
};

export default class AppBarPP extends React.Component {

  constructor(props) {
    super(props);
    this.state = {open: false};
  }

  render(){
    return (
      <AppBar
        style={style}
        title="poleposition"
        onLeftIconButtonTouchTap={this.props.onClickMenu}
        iconElementRight={<BluetoothButton/>}
        />
    )
  }
}
