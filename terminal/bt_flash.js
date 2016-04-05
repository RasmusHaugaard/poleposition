"use strict";

const bt = require('./bt');
const fs = require('fs');
const parseHex = require('./util/parseHex');

const PAGESIZE = 64;
const PAGESIZEB = PAGESIZE * 2;
const PAGECOUNT = 256;
const APP_PAGECOUNT = 224;

const pf_write_page_code = 250;
const pf_erase_page_code = 251;
const pf_file_end_code = 252;

var hex = fs.readFileSync('../avr/build/program.hex');




var erasePage = (pageIndex) => {
	var address = PAGESIZEB * pageIndex;
	var ZL = address & 0x0F;
	var ZH = address >> 4;
	conn.writeByteArray([pf_erase_page_code, ZL, ZH]);
}

var writePage = (pageIndex, page) => {
	var address = PAGESIZEB * pageIndex;
	var ZL = address & 0x0F;
	var ZH = address >> 4;
	conn.writeByteArray([pf_write_page_code, ZL, ZH]);
	var buf = new ArrayBuffer(PAGESIZEB);
	var bufView = new Uint8Array(buf);
	page.forEach((byte, i) => {
		bufView[i] = byte;
	});
	conn.write(buf);
}

for (var pageIndex = 0; pageIndex < APP_PAGECOUNT; pageIndex++){
	var page = pages[pageIndex];
	if (typeof page === 'undefined'){
		erasePage(pageIndex);
		continue;
	}
	writePage(pageIndex, page);
}


const connect = require('../bt').connect;
var conn = null;

var onData = (data) => {
	/*received data from atmega*/
}

bt.connect((_conn) => {
  if(!_conn) process.exit(1);
  conn = _conn;
}, onData);
