"use strict";
const HEX = 16;
const RecordType = {
	Data: 0,
	EndOfFile: 1,
	ExtendedSegmentAddress: 2
};

/*
Example Hex file for .asm: .org 0; jmp 32; .org 32; jmp 64; .org 64; jmp 0

:02 0000 02 0000 FC
:04 0000 00 0C94 2000 3C
:04 0040 00 0C94 4000 DC
:04 0080 00 0C94 0000 DC
:00 0000 01 FF
*/

const parseIHex = (hex) => {
	var lines = hex.replace(/\s/g, '').split(':');

	var segmentAddress = 0;
	var pages = [];

	const getByte = (line, byteIndex, byteCount) => parseInt(line.substr(8 + byteIndex * 2, (byteCount || 1) * 2, HEX));
	const putByte = (byte, address) => {
		var pageIndex = Math.floor(address / PAGESIZEB);
		var byteIndex = address - pageIndex * PAGESIZEB;
		var page = pages[pageIndex];
		if(typeof page === 'undefined'){
			page = [];
			pages[pageIndex] = page;
		}
		page[byteIndex] = byte;
	}

	lines.forEach((line, i) => {
		console.log("Line:", i, line);
		if(line.trim().length === 0) return; //Skip empty lines!
		var byteCount = parseInt(line.substr(0,2), HEX); //se her: https://en.wikipedia.org/wiki/Intel_HEX
		var address = parseInt(line.substr(2,4), HEX);
		var recordType = parseInt(line.substr(6,2), HEX);

		if(recordType === RecordType.ExtendedSegmentAddress){
			segmentAddress = getByte(line, 0, 2) * 16;
		}else if(recordType === RecordType.Data){
			for(var i = 0; i < byteCount; i++){
				putByte(getByte(line, i), segmentAddress + address + i);
			}
		}else if(recordType === RecordType.EndOfFile){
			console.log(pages);
		}else{
			console.log("Couldn't understand recordtype!", recordType);
		}
	});
}

module.exports = parseIHex;
