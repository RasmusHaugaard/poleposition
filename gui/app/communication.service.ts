class Command {
	constructor(private commandVal:number,
					public exec:(...a:any[]) => void,
					public dataSize:number){
	}
}

const obj = {
	TYPE: {
		SET: {
			val: 0x55,
			commands: {
				"Start" : new Command(
					0x10, 1, function(speed){
						if(!(0 <= speed <= 100)) throw("Hastigheden skal sættes mellem 0 og 100.");

					},
					1
				)
			}
		},
		GET: {
			val: 0xAA,
			commands: {

			}
		},
		REPLY: {
			val: 0xBB,
			commands: {

			}
		}
	}
}


//types
const SET = 0x55;
const GET = 0xAA;
const REPLY = 0xBB;
const TYPES = [SET, GET, REPLY];

//commands
const START = 0x10;
const SPEED = START;
const STOP = 0x11;
const COMMANDS = [START, STOP];

import {Injectable} from 'angular2/core';
import {BluetoothService} from "./bluetooth.service";

@Injectable()
export class CommunicationService {

	constructor(public bluetoothService:BluetoothService){

	}
}

var update = () => {
	window.requestAnimationFrame(update);
	var gp = navigator.getGamepads()[0];
	if (!gp) return;
	setSpeed(gp.buttons[7].value);
}

var receiveByte = (byte:number) => {

}

var receive = (type, command, data) => {
	if(type !== REPLY) throw("Did'nt expect to receive anything but a reply. type: ", type);

}

