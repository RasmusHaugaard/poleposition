import annyang from 'annyang'
import {blProgram} from '../actions/bl'

export default function init(){
	window.speak = (text) => {
		let msg = new SpeechSynthesisUtterance()
		let voice = speechSynthesis.getVoices().filter(voice => {return voice.voiceURI === "Samantha"})[0]
		msg.voice = voice
		msg.text = text
		msg.lang = voice.lang
		speechSynthesis.speak(msg)
	}
	speechSynthesis.onvoiceschanged = () => {
		window.speak("Welcome master. I am Samantha. Can i help you?")
	}
	let commands = {
		'(Samantha) (yes) (please) upload (my) (the) program': () => {
			window.store.dispatch(blProgram())
		},
		'hello (Samantha)': () => {
			window.speak('Hello master.')
		},
		'(no) thank you (Samantha)': youAreWelcome,
		'(no) thanks (Samantha)': youAreWelcome,
		'(Samantha) give me (some) *tag': (tag) => {
			window.speak('I can give you some ' + tag)
		}
	}
	annyang.addCommands(commands)
	annyang.start(console.log)
}

const youAreWelcome = ()=>{
	window.speak(
		youAreWelcomeStrings[Math.floor(Math.random() * youAreWelcomeStrings.length)]
	)
}

const youAreWelcomeStrings = [
	"You are welcome master.",
	"No problem master.",
	"Anytime master.",
	"I am at your service master"
]
