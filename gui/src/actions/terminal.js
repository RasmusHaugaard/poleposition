import {btTransmit} from './bt'

export const TERMINAL_TYPING = "TERMINAL_TYPING"
export const tmTyping = (value, encoding) => {
	return (dispatch) => {
		let parsedInput = parseInput(value, encoding)
		if (parsedInput.valid){
			dispatch(tmValidInput())
		}else{
			dispatch(tmInvalidInput(parsedInput.errorText))
		}
	}
}

export const TERMINAL_ENTER = "TERMINAL_ENTER"
export const tmEnter = (value, encoding) => {
	return (dispatch) => {
		let parsedInput = parseInput(value, encoding)
		value = parsedInput.value
		let {errorText, valid} = parsedInput
		if (valid){
			let output
			if (typeof value === "string"){
				output = value
			}else{
				output = value.map((number) => number.value)
			}
			dispatch(tmSending(value))
			dispatch(tmSetInputText(""))
			btTransmit(output, (success) => {
				if (success){
					dispatch(tmSent(value))
				}else{
					dispatch(tmNotSent(value))
				}
			})
		}else{
			dispatch(tmInvalidInput(errorText))
		}
	}
}

export const TERMINAL_SENDING = "TERMINAL_SENDING"
export const tmSending = (value) => {
	return {
		type: TERMINAL_SENDING,
		value
	}
}

export const TERMINAL_SENT = "TERMINAL_SENT"
export const tmSent = (value) => {
	return {
		type: TERMINAL_SENT,
		value
	}
}

export const TERMINAL_NOT_SENT = "TERMINAL_NOT_SENT"
export const tmNotSent = (value) => {
	return {
		type: TERMINAL_NOT_SENT,
		value
	}
}

export const TERMINAL_RECEIVED = "TERMINAL_RECEIVED"
export const tmReceived = (value) => {
	return {
		type: TERMINAL_RECEIVED,
		value
	}
}

export const TERMINAL_SET_ENCODING = "TERMINAL_SET_ENCODING"
export const tmSetEncoding = (encoding) => {
	return {
		type: TERMINAL_SET_ENCODING,
		encoding
	}
}

export const TERMINAL_SET_SIGNED = "TERMINAL_SET_SIGNED"
export const tmSetSigned = (signed) => {
	return {
		type: TERMINAL_SET_SIGNED,
		signed
	}
}

export const TERMINAL_SET_INPUT_TEXT = "TERMINAL_SET_INPUT_TEXT"
export const tmSetInputText = (text) => {
	return {
		type: TERMINAL_SET_INPUT_TEXT,
		text
	}
}

export const TERMINAL_INVALID_INPUT = "TERMINAL_INVALID_INPUT"
export const tmInvalidInput = (errorText) => {
	return {
		type: TERMINAL_INVALID_INPUT,
		errorText
	}
}

export const TERMINAL_VALID_INPUT = "TERMINAL_VALID_INPUT"
export const tmValidInput = () => {
	return {
		type: TERMINAL_VALID_INPUT
	}
}

const parseInput = (value, encoding) => {
	if (value.trim().length === 0){
		return {
			valid: true,
			value
		}
	}else if (encoding === "ASCII"){
		return {
			valid: true,
			value: value.replace(/\\n/, "\n")
		}
	}else if (encoding === "NUMERIC"){
		let numbersStr = value.trim().split(/[, ]/)
		let numbers = []
		for (let str of numbersStr){
			let number
			str = str.trim();
			if (str.length === 0) return {
				valid: false,
				errorText: "Empty numeric field."
			}
			let base = 10
			if (str.substr(0,2).toUpperCase() === "0X"){
				base = 16
				str = str.substr(2)
				let match = str.match(/[^0-9a-fA-F]/)
				if (match !== null) return {
					valid: false,
					errorText: "You know.. Last time i checked, " + match + ", wasn't a hex character.."
				}
			}else if(str.substr(0,2).toUpperCase() === "0B"){
				base = 2
				str = str.substr(2)
				let match = str.match(/[^01]/)
				if (match !== null) return {
					valid: false,
					errorText: match +"? Haha, you are so silly! Binary numbers can only contain ones and zeroes."
				}
			}else{
				let match = str.match(/[^0-9]/)
				if (match !== null) return {
					valid: false,
					errorText: '"' +  match + '" That is personally my favorite number.'
				}
			}
			number = parseInt(str, base);
			if (number !== number) return {
				valid: false,
				errorText: str.length === 0 ? "Well.. technically nothing is not a number, so.." : "Am i supposed to try to parse that?"
			}
			if (number < -128 || number > 255){
				return {
					valid: false,
					errorText: "You're logic is undeniable:  -128 <= " + number + "  <= 255"
				}
			}
			numbers.push({
				value: number,
				base
			})
		}
		return {
			valid: true,
			value: numbers
		}
	}else{
		throw("Encoding of type:", encoding, "not expected.")
	}
}
