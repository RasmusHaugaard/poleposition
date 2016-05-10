import React, {Component} from 'react';
import {connect} from 'react-redux'
import {TextField, RadioButton, RadioButtonGroup, Checkbox} from 'material-ui';
import ChatList from './ChatList.jsx'
import {tmEnter, tmTyping, tmSetEncoding, tmSetSigned, tmSetInputText} from '../actions/terminal'
import Rx from 'rx'

window.Rx = Rx

const radioStyle = {
	"width":"",
	"marginRight":"50px"
}
const radioGroupStyle = {
	"flexDirection":"row",
	"display":"flex",
	"marginRight":"80px"
}

class Terminal extends Component {
	constructor(props){
		super(props)
	}
	componentDidMount(){
		let inputObservable = Rx.Observable.create((observer) => {
			this.inputObserver = observer
		})
		this.subscription = inputObservable
			.debounce(350)
			.subscribe(() => {
				this.props.onInputChange(this.refs.input.getValue(), this.props.encoding)
			},
			(e)=>{console.log("Error", e)},
			()=>{console.log("Complete")}
		)
	}
	render(){
		let {encoding, signed, chat, onEnterKeyDown, inputValid, inputErrorText, onSignedChange, onEncodingChange, inputText, setInputText} = this.props;
		return (
			<div style={{"display":"flex",
				"flexDirection":"column-reverse",
				"justifyContent":"space-between",
				"bottom":"15px",
				"position":"absolute",
				"width":"calc(100% - 30px)"
			}}>
				<div className="roboto" style={{"color":"#BBB"}}>{">"}
					<TextField
						ref="input"
						hintText="Hit me!"
						style={{"width":"calc(100% - 25px)", "marginLeft":"5px"}}
						onKeyDown={(e)=>{
							if(e.keyCode === 13){
								onEnterKeyDown(this.refs.input.getValue(), encoding)
							}
						}}
						value={inputText}
						onChange={()=>{
							setInputText(this.refs.input.getValue())
							this.inputObserver.onNext()
						}}
						errorText={inputErrorText}
						/>
				</div>

				<div style={{"display":"flex", "justifyContent":"center"}}>
					<RadioButtonGroup ref="encoding" name="encoding" defaultSelected={encoding} style={radioGroupStyle}
						onChange={(e)=>{
							let encoding = e.target.value
							onEncodingChange(encoding)
							this.props.onInputChange(this.refs.input.getValue(), encoding)
						}}>
						<RadioButton label="Numeric" value="NUMERIC" style={radioStyle}/>
						<RadioButton label="Ascii" value="ASCII" style={radioStyle}/>
					</RadioButtonGroup>
					<Checkbox
						onCheck={(e)=>{onSignedChange(e.target.checked)}}
						checked={signed}
						disabled={encoding === "ASCII"} label="Signed" style={{"width":""}}/>
				</div>

				<ChatList encoding={encoding} signed={signed} list={chat}/>
			</div>
		)
	}
}

const mapStateToProps = (state) => {
	return {
		encoding: state.terminal.encoding,
		signed: state.terminal.signed,
		chat: state.terminal.chat,
		inputErrorText: state.terminal.inputErrorText,
		inputValid: state.terminal.inputValid,
		inputText: state.terminal.inputText
	}
}

const mapDispatchToProps = (dispatch, ownProps) => {
	return {
		onEnterKeyDown: (value, encoding) => {
			dispatch(tmEnter(value, encoding))
		},
		onInputChange: (value, encoding) => {
			dispatch(tmTyping(value, encoding))
		},
		onSignedChange: (signed) => {
			dispatch(tmSetSigned(signed))
		},
		onEncodingChange: (value) => {
			dispatch(tmSetEncoding(value))
		},
		setInputText: (text) => {
			dispatch(tmSetInputText(text))
		}
	}
}

Terminal = connect(
	mapStateToProps,
	mapDispatchToProps
)(Terminal)

export default Terminal
