"use strict";

import React from 'react';
import {LeftNav, MenuItem} from 'material-ui';

export default class LeftNavPP extends React.Component {

  constructor(props) {
    super(props);
  }

  render(){
    return (
      <LeftNav open={this.props.open} width={150}>
        <div style={{height:"75px"}}></div>
        <MenuItem>Stats</MenuItem>
        <MenuItem>Terminal</MenuItem>
      </LeftNav>
    )
  }
}
