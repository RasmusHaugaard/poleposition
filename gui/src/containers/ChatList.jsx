import React from 'react'
import connect from 'react-redux'

let Number = ({value, color, base}) => {
	return (
		<span className={"roboto"} style={{color, "marginRight":"4px"}}
			title={"Decimal: " + value + "  Hex: " + value.toString(16) + "\nBinary: " + value.toString(2) + "  Ascii: " + String.fromCharCode(value)}>
			{base === 2 ? "0b" : (base === 16 ? "0x":"")}
			{value.toString(base)}
		</span>
	)
}

let Text = ({value, color}) => {
	return (
		<span className={"roboto"} style={{color, "fontStyle":"italic"}}>{value}</span>
	)
}

const colorFromSent = (sent) => {
	return typeof sent === "undefined" ? "grey" : (sent === false ? "red" : "black")
}

let SlaveMessage = ({value, encoding, key}) => {
	return (
		<div style={{"marginLeft":"10px"}}><span className={"roboto"}>
			{(()=>{
				if (encoding === "ASCII"){
					return value.map(val => String.fromCharCode(val)).join('')
				}else{
					return value.map((val, i) => (<Number value={val} base={10} color={"blue"} key={key+"-"+i}/>))
				}
			})()}
		</span></div>
	)
}

let MasterMessage = ({value, sent, key}) => {
	if (typeof value === "string") return (
		<div>
			{">"}
			<Text value={value} color={colorFromSent(sent)}/>
		</div>
	)
	return (
		<div>
			{">"}
			{value.map((number, i) => {
				return (<Number value={number.value} base={number.base} color={colorFromSent(sent)} key={key+"-"+i} />)
			})}
		</div>
	)
}

let ChatList = ({list, encoding}) => {
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
						<SlaveMessage value={message.value} encoding={encoding} key={message.key}/>
					)
				}
				console.log(message)
				throw("Message sender unknown")
			})}
		</div>
	)
}

export default ChatList
