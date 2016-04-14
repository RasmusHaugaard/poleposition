"use strict";
const HEX = 16;

const DEBUG = false;

const RecordType = {
	Data: 0,
	EndOfFile: 1,
	ExtendedSegmentAddress: 2
};

/*
Example IHex file for .asm: .org 0; jmp 32; .org 32; jmp 64; .org 64; jmp 0

:02 0000 02 0000 FC
:04 0000 00 0C94 2000 3C
:04 0040 00 0C94 4000 DC
:04 0080 00 0C94 0000 DC
:00 0000 01 FF
*/

const parseIHex = (hex, PAGESIZE) => {
	var PAGESIZEB = PAGESIZE * 2;

	var lines = hex.replace(/\s/g, '').split(':');

	var segmentAddress = 0;
	var pages = [];

	const getByte = (line, byteIndex, byteCount) => parseInt(line.substr(8 + byteIndex * 2, (byteCount || 1) * 2), HEX);
	const putByte = (byte, address) => {
		var pageIndex = Math.floor(address / PAGESIZEB);
		var byteIndex = address - pageIndex * PAGESIZEB;
		var page = pages[pageIndex];
		if(typeof page === 'undefined'){
			page = new Array(PAGESIZEB);
			pages[pageIndex] = page;
		}
		page[byteIndex] = byte;
	}

	lines.forEach((line, i) => {
		if(line.trim().length === 0) return; //Skip empty lines!
		if(DEBUG){
			var dataPart = line.substr(8,line.length - 8 - 2);
			console.log("Linie", i + ":", line.substr(0,2), line.substr(2,4), line.substr(6,2), dataPart, line.substr(line.length - 2,2));
		}
		var byteCount = parseInt(line.substr(0,2), HEX); //se her: https://en.wikipedia.org/wiki/Intel_HEX
		if(DEBUG) console.log("Byte Count:", byteCount);
		var address = parseInt(line.substr(2,4), HEX);
		if(DEBUG) console.log("Address:", address);
		var recordType = parseInt(line.substr(6,2), HEX);
		if(DEBUG) console.log("Record Type:", recordType);

		if(recordType === RecordType.ExtendedSegmentAddress){
			segmentAddress = getByte(line, 0, 2) * 16;
			if(DEBUG) console.log("Segment Address:", segmentAddress);
		}else if(recordType === RecordType.Data){
			for(var i = 0; i < byteCount; i++){
				var byte = getByte(line, i);
				if(DEBUG) console.log("Byte " + i + ":", byte);
				putByte(byte, segmentAddress + address + i);
			}
		}else if(recordType === RecordType.EndOfFile){
			if(DEBUG) console.log(pages);
		}else{
			console.log("Couldn't understand recordtype!", recordType);
			process.exit(1);
		}
	});

	return pages;
}

module.exports = parseIHex;
