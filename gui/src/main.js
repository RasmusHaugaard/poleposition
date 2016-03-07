const DEVICE_NAME = "RNBT-C915";
const BITRATE = 115200;

const TYPE = 0;
const COMMAND = 1;
const DATA = 2;

//types
const SET = 85; 	//0x55
const GET = 170;	//0xAA
const REPLY = 187;	//0xBB
const TYPES = [SET, GET, REPLY];

//commands
const START = SPEED = 16;	//0x10
const STOP = 17;	//0x11
const COMMANDS = [START, STOP];

var connId = null;

var connectBluetooth = () => {
	chrome.serial.getDevices((devs) => {
		var dev = devs.filter((dev) => {
			return dev.path.indexOf(DEVICE_NAME) !== -1
		})[0];
		if(!dev){
			console.log("Cannot find: " + DEVICE_NAME);
			return;
		}
		chrome.serial.connect(dev.path, {bitrate: BITRATE}, (ConnInfo) => {
			if(!ConnInfo){
				console.log("Failed to connect to: " + DEVICE_NAME + ", with path: " + dev.path);
				console.log(devs);
				return;
			}
			connId = ConnInfo.connectionId;
			console.log("Connected with connection id: " + connId);
		});
	});
};

var serialReceive = (info) => {
	if(info.connectionId !== connId) return;
	Uint8Array(info.data)
		.forEach((byte) => {
			receiveByte(byte)
		});
}

var type = null;
var command = null;
var receiveNext = TYPE;
var receiveByte = (byte) => {
	switch (receiveNext) {
		case TYPE:
			if (TYPES.indexOf(byte) < 0) throw("Expected to receive type. Received: ", byte);
			type = byte;
			receiveNext = COMMAND;
			break;
		case COMMAND:
			if (COMMANDS.indexOf(byte) < 0) throw("Expected to receive command. Received: ", byte);
			command = byte;
			receiveNext = DATA;
			break;
		case DATA:
			receive(type, command, byte);
			receiveNext = TYPE;
			break;
		default:
			throw("receiveNext is not properly set: ", receiveNext);
			break;
	}
}

var receive = (type, command, data) => {
	if(type !== REPLY) throw("Did'nt expect to receive anything but a reply. type: ", type);
	
}

var send = (type, command, data) => {
	if (connId === null) return;
	var buf = new ArrayBuffer(3);
	var bufView = new Uint8Array(buf);
	bufView[0] = type;
	bufView[1] = command;
	bufView[2] = data;
	chrome.serial.send(connId, buf, ()=>{});
}

var preSpeed;
var setSpeed = (val) => {	
	var speed = Math.min(Math.floor(val*101), 100);
	if (speed === preSpeed) return;
	preSpeed = speed;
	serialSend(SET, SPEED, speed);
	document.getElementById("sender").style.height = speed + "%";
	//document.getElementById("receiver").style.height = (dec / 255 * 100) + "%";
}

var update = () => {
	window.requestAnimationFrame(update);
	var gp = navigator.getGamepads()[0];
	if (!gp) return;
	setSpeed(gp.buttons[7].value);
}

chrome.serial.onReceive.addListener(serialReceive);
connectBluetooth();
update();
