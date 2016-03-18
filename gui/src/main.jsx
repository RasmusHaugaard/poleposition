var app = document.getElementById('app');

import React from 'react';
import ReactDom from 'react-dom';
import {RaisedButton, AppBar, AutoComplete} from 'material-ui';

ReactDom.render(
  <div>
    <AppBar title="poleposition"/>
    <RaisedButton label="Hey Mikkel"/>
      <AutoComplete
          hintText="Skriv type!"
          dataSource={["SET", "GET", "REPLY", "REPLYTWICE"]}
        />
  </div>,
  app
);
