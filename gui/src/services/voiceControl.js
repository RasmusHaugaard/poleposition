import annyang from 'annyang'
import {blProgram} from '../actions/bl'

export default function init(){
	window.speak = (text) => {
		let msg = new SpeechSynthesisUtterance()
		let voice = speechSynthesis.getVoices().find(voice => voice.voiceURI === "Samantha")
		if (!voice) voice = speechSynthesis.getVoices().find(voice => voice.voiceURI === "Google US English")
		if (!voice) throw "Kan ikke finde nogen af de ønskede stemmer"
		msg.voice = voice
		msg.text = text
		msg.lang = voice.lang
		speechSynthesis.speak(msg)
	}
	speechSynthesis.onvoiceschanged = (e) => {
		speechSynthesis.onvoiceschanged = () => {}
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
		},
		"(*tag1) Fuck you (*tag2)": () => {
			window.speak("Well fuck you Alexander!")
		},
		"first i was afraid": () => {
			window.speak("i was petrified")
		},
		"Kept thinking I could never live without you by my side": () => {
			window.speak("But then I spent so many nights thinking how you did me wrong")
		},
		"and i grew strong": () => {
			window.speak("and i learned how to get along")
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
