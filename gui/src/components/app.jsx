"use strict";

import React from 'react';
import ReactDom from 'react-dom';
import {Router, Route} from 'react-router';

import LeftNavPP from './left-nav-pp.jsx';
import AppBarPP from './app-bar-pp.jsx';

import Terminal from './terminal.jsx';
import Stats from './stats.jsx';

export default class App extends React.Component {

  constructor(props) {
    super(props);
    this.state = {
      leftNavOpen: false
    };
  }

  onClickMenu = () => {
    this.setState({leftNavOpen: !this.state.leftNavOpen})
  }

  render(){
    return (
      <div>
        <AppBarPP onClickMenu={this.onClickMenu} />
        <LeftNavPP open={this.state.leftNavOpen} />
        <Terminal />
      </div>
    )
  }
}
