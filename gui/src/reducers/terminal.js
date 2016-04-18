import {TERMINAL_VALID_INPUT, TERMINAL_INVALID_INPUT, TERMINAL_SENT,
	TERMINAL_SET_ENCODING, TERMINAL_SET_SIGNED, TERMINAL_SET_INPUT_TEXT,
	TERMINAL_SENDING, TERMINAL_NOT_SENT, TERMINAL_RECEIVED} from '../actions/terminal'

let messageId = 0

export default function terminal(state = {
	encoding: "NUMERIC",
	signed: false,
	chat: [],
	inputText: "",
	inputValid: true,
	inputErrorText: ""
}, action){
	switch (action.type){
		case TERMINAL_VALID_INPUT:
			return {
				...state,
				inputValid: true,
				inputErrorText: ""
			}
		case TERMINAL_SET_INPUT_TEXT:
			return {
				...state,
				inputText: action.text
			}
		case TERMINAL_INVALID_INPUT:
			return {
				...state,
				inputValid: false,
				inputErrorText: action.errorText
			}
		case TERMINAL_SET_ENCODING:
			return {
				...state,
				encoding: action.encoding
			}
		case TERMINAL_SET_SIGNED:
			return {
				...state,
				signed: action.signed
			}
		case TERMINAL_SENDING:
			return {
				...state,
				chat: [...state.chat, {value: action.value, sender: "MASTER", key: messageId++}]
			}
		case TERMINAL_SENT:
			return {
				...state,
				chat: state.chat.map((message) => (message.value === action.value ? {...message, sent:true} : message))
			}
		case TERMINAL_NOT_SENT:
			return {
				...state,
				chat: state.chat.map((message) => (message.value === action.value ? {...message, sent:false} : message))
			}
		case TERMINAL_RECEIVED:
			return {
				...state,
				chat: [...state.chat, {value: action.value, sender: "SLAVE", key: messageId++}]
			}
		default:
			return state;
	}
}
