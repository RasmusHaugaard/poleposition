import React from 'react';
import {connect} from 'react-redux'
import {TextField, FlatButton, RadioButton, RadioButtonGroup} from 'material-ui';

const style = {
	"width":"",
	"margin-right":"50px"
}

let Terminal = () => {
	return (
		<div style={{"display":"flex",
			"flex-direction":"column-reverse",
			"justify-content":"space-between",
			"bottom":"15px",
			"position":"absolute",
			"width":"calc(100% - 30px)"
		}}>
			<TextField hintText="Hungry for nunbers" style={{"width":""}}/>
			<RadioButtonGroup defaultSelected="numeric" style={{"flex-direction":"row", "display":"flex", "margin":"auto"}}>
				<RadioButton label="Numeric" value="numeric" style={style}/>
				<RadioButton label="Ascii" value="ascii" style={style}/>
			</RadioButtonGroup>
			<p className={"roboto"}>Hej</p>
		</div>
	)
}

export default Terminal
