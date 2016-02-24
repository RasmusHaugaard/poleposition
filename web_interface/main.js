var deviceName = "RNBT-C915";
var bitrate = 115200;

var connPath;
var connId;

chrome.serial.getDevices((devs) => {
	var dev = devs.filter((dev) => dev.path.indexOf(deviceName) >= 0)[0];
	if(!dev){
		console.log("Cannot find: " + deviceName);
		return;
	}
	connPath = dev.path;
	chrome.serial.connect(connPath, {bitrate: bitrate}, (ConnInfo) => {
		if(!ConnInfo){
			console.log("Failed to connect to: " + deviceName + ", with path: " + connPath);
			console.log(devs);
			return;
		}
		connId = ConnInfo.connectionId;
		chrome.serial.flush(connId, ()=>{});
		console.log("Connected with connection id: " + connId);
	});
});

chrome.serial.onReceive.addListener((info) => {
	if(info.connectionId !== connId) return;
	var bufView = new Uint8Array(info.data);
	dec = bufView[bufView.length - 1];
	document.getElementById("receiver").style.height = (dec / 255 * 100) + "%";
});

var writeSerial = (val) => {
	var buf = new ArrayBuffer(1);
	var bufView = new Uint8Array(buf);
	bufView[0] = val;
	chrome.serial.send(connId, buf, ()=>{});
}

var setSpeed = (val) => {
	var dec = Math.min(Math.floor(val*256), 255);
	writeSerial(dec);
	document.getElementById("sender").style.height = (dec / 255 * 100) + "%";
}

var update = () => {
	window.requestAnimationFrame(update);
	var gp = navigator.getGamepads()[0];
	if (!gp) return;
	setSpeed(gp.buttons[7].value);
}

update();
