import React, {Component, PropTypes} from 'react'
import {connect} from 'react-redux'

//TODO: Only use numbers. No text. Number shall be able to be shown as ascii
class Number extends Component{
	constructor(props){
		super(props)
	}
	render(){
		let {value, color, base} = this.props
		return (
			<span className={"roboto"} style={{color, "marginRight":"4px"}}
				title={"Decimal: " + value + "  Hex: " + value.toString(16) + "\nBinary: " + value.toString(2) + "  Ascii: " + String.fromCharCode(value)}>
				{base === 2 ? "0b" : (base === 16 ? "0x":"")}
				{value.toString(base)}
			</span>
		)
	}
}
Number = connect()(Number)

class Text extends Component{
	constructor(props){
		super(props)
	}
	render(){
		let {value, color} = this.props
		return (
			<span className={"roboto"} style={{color, "fontStyle":"italic"}}>{value}</span>
		)
	}
}
Text = connect()(Text)

class SlaveMessage extends Component{
	constructor(props){
		super(props)
	}
	render(){
		let palette = this.context.muiTheme.baseTheme.palette
		let {value, encoding, signed, key} = this.props
		let body
		if (encoding === "ASCII"){
			body = (
				<Text value={value.map(val => String.fromCharCode(val)).join('')}
					color={palette.primary1Color} />
			)
		}else{
			body = (
				value.map((val, i) => {
					return (
						<Number value={signed ? (val > 127 ? val - 256 : val) : val}
							base={10} color={palette.primary1Color} key={key+"-"+i} />
					)
				})
			)
		}
		return (
			<div style={{"marginLeft":"10px"}}>
				<span className={"roboto"}>
					{"> "}{body}
				</span>
			</div>
		)
	}
}
SlaveMessage.contextTypes = {
	muiTheme: PropTypes.object
}
SlaveMessage = connect()(SlaveMessage)

const colorFromSent = (sent, palette) => {
	return typeof sent === "undefined" ? palette.disabledColor : (sent === false ? palette.errorColor : palette.textColor)
}

class MasterMessage extends Component{
	constructor(props){
		super(props)
	}
	render(){
		console.log(this.context)
		let palette = this.context.muiTheme.baseTheme.palette
		let {value, sent, key} = this.props
		let body
		if (typeof value === "string"){
			body = <Text value={value} color={colorFromSent(sent, palette)}/>
		}else{
			body = value.map((number, i) => {
				return (
					<Number value={number.value} base={number.base}
						color={colorFromSent(sent, palette)} key={key+"-"+i} />
				)
			})
		}
		return (
			<div style={{"marginLeft":"10px"}}>
				<span className={"roboto"}>
					{"> "}{body}
				</span>
			</div>
		)
	}
}
MasterMessage.contextTypes = {
	muiTheme: PropTypes.object
}
MasterMessage = connect()(MasterMessage)

class ChatList extends Component{
	constructor(props){
		super(props)
	}
	render(){
		let {list, encoding, signed} = this.props
		return (
			<div>
				{list.map((message) => {
					if (message.sender === "MASTER"){
						return (
							<MasterMessage sent={message.sent} value={message.value} key={message.key} />
						)
					}
					if (message.sender === "SLAVE"){
						return (
							<SlaveMessage value={message.value} encoding={encoding} signed={signed} key={message.key}/>
						)
					}
					console.log(message)
					throw("Message sender unknown")
				})}
			</div>
		)
	}
}
ChatList = connect()(ChatList)

export default ChatList
