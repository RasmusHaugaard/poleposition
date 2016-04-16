import React from 'react';
import connect from 'react-redux'
import {TextField, FlatButton} from 'material-ui';

let Terminal = () => {
	return (
		<div style={{"display":"flex",
			"flex-direction":"column",
			"justify-content":"space-between",
			"overflow": "scroll",
			"padding" : "20px"
		}}>
			<p className={"roboto"}>{"Hej"}</p>
		</div>
	)
}

export default Terminal
