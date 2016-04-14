"use strict";

const DEBUG = false;

const bt = require('./bt');
const fs = require('fs');
const parseIHex = require('./util/parseIHex');

const PAGESIZE = 64;
const PAGESIZEB = PAGESIZE * 2;
const PAGECOUNT = 256;
const APP_PAGECOUNT = 224;
const REPROGRAM_CODE = 87;
const RESET_CODE = 253;

const pf_write_page_code = 250;
const pf_erase_page_code = 251;
const pf_file_end_code = 252;

var hex = fs.readFileSync('../avr/build/program.hex').toString();
var pages = parseIHex(hex, PAGESIZE);

const erasePageByteSize = 3;
var erasePage = (pageIndex) => {
	bytesInBuffer += erasePageByteSize;
	var address = PAGESIZEB * pageIndex;
	var ZL = address & 0xFF;
	var ZH = address >> 8;
	if (DEBUG) console.log("Erasing page", pageIndex + "..", ZH, ZL);
	status.push(STATUS.erasingPage);
	conn.writeByteArray([pf_erase_page_code, ZL, ZH]);
}

const writePageByteSize = 3 + PAGESIZEB;
var writePage = (pageIndex, page) => {
	bytesInBuffer += writePageByteSize;
	var address = PAGESIZEB * pageIndex;
	var ZL = address & 0xFF;
	var ZH = address >> 8;
	status.push(STATUS.writingPage);
	if (DEBUG) console.log("Writing page", pageIndex + "..", ZH, ZL);
	conn.writeByteArray([pf_write_page_code, ZL, ZH]);
	conn.writeByteArray(page.map((val)=>{
		return (typeof val === "undefined") ? 255 : val;
	}));
	if (DEBUG) console.log("Sent", page.length, "bytes..");
}

var pageIndex = 0;
var noMorePages = false;
var pause = false;
const BufferSize = 1000;
if (BufferSize < 3 + PAGESIZEB) throw("BufferSize skal være minimum 3 + PAGESIZEB!!!");
var bytesInBuffer = 0;

var decreaseBytesInBuffer = (byteCount) => {
	bytesInBuffer -= byteCount;
	if (DEBUG) console.log("bytesInBuffer:", bytesInBuffer);
	if (DEBUG) console.log("noMorePages:", noMorePages);
	if (noMorePages){
		if (bytesInBuffer === 0) complete();
	}else{
		sendNextPage();
	}
};

var sendNextPage = () => {
	if (pageIndex === APP_PAGECOUNT) throw("No more pages to send!");
	var page = pages[pageIndex];
	var bytesLeftInBuffer = BufferSize - bytesInBuffer;
	if (typeof page === 'undefined'){
		if(bytesLeftInBuffer < erasePageByteSize) return;
		erasePage(pageIndex);
	}else{
		if(bytesLeftInBuffer < writePageByteSize) return;
		writePage(pageIndex, page);
	}
	pageIndex++;
	if(pageIndex === APP_PAGECOUNT){
		noMorePages = true;
	}else{
		sendNextPage();
	}
}

var conn = null;

var STATUS = {
	waitingForPermission: 0,
	writingPage: 1,
	erasingPage: 2,
	waitingForReset: 3
};

const PERMISSION_GRANTED = 200;
const PAGE_WRITTEN = 201;
const PAGE_ERASED = 202;
const RESETTING = 203;

var status = [STATUS.waitingForPermission];

var onData = (data) => {
	for (var i = 0; i < data.length; i++){
		receiveByte(data[i]);
	}
}

var receiveByte = (byte) => {
	var curStatus = status.shift();
	switch (curStatus) {
		case STATUS.waitingForPermission:
			if (byte === PERMISSION_GRANTED){
				if (DEBUG) console.log("Permission granted..");
				decreaseBytesInBuffer(1);
				break;
			}
			throw("Received unexpected byte!", byte);
			break;
		case STATUS.writingPage:
			if (byte === PAGE_WRITTEN){
				if (DEBUG) console.log("Page Successfully flashed..");
				decreaseBytesInBuffer(writePageByteSize);
				break;
			}
			throw("Received unexpected byte!", byte);
			break;
		case STATUS.erasingPage:
			if (byte === PAGE_ERASED){
				if (DEBUG) console.log("Page Successfully erased..");
				decreaseBytesInBuffer(erasePageByteSize);
				break;
			}
			throw("Received unexpected byte!", byte);
			break;
		case STATUS.waitingForReset:
			if (byte === RESETTING){
				console.log("Resetting avr..");
				process.exit();
			}
			throw("Received unexpected byte!", byte);
			break;
		default:
			throw("Status: '" + status + "' not expected..");
	}
}

var t0 = null;
var complete = () => {
	conn.writeByteArray([RESET_CODE]);
	console.log("Programming complete with no errors.");
	if(DEBUG) console.log("Asking for reset..");
	status.push(STATUS.waitingForReset);
	var t1 = new Date();
	console.log("Programming took: ", t1 - t0, "ms.");
}

bt.connect((_conn) => {
  if(!_conn) process.exit(1);
  conn = _conn;
	t0 = new Date();
	conn.writeByteArray([REPROGRAM_CODE]);
	console.log("Starting programming..");
	if (DEBUG) console.log("Asking for permission to program..");
	bytesInBuffer += 1;
}, onData);
