"use strict";

import replies from './replies.js';

const TYPE = {
	REPLYVAL: 0,
	DATA: 1
};

export class Receiver {
	next = TYPE.REPLYVAL;
	curReply = null;
	buffer = [];
	listeners = {};

	constructor(){
		this.btService = window.services.bluetoothService;
	}

	addListener = (replyName, callback) => {
		listeners[replyName] = (listeners[replyName] || []).push(callback);
	}

	receiveByte = (byte) => {
		if(this.next === TYPE.REPLYVAL){
			this.curReply = replies.filter((reply)=>{
				return reply.value === byte;
			})[0];
			if (!this.curReply) throw("Reply value not defined! ", byte);
			if (this.curReply.dataSize > 0) this.next = TYPE.DATA;
		}else if(this.next === TYPE.DATA){
			this.buffer.push(byte);
			if (this.buffer.length >= this.currentCommand.dataSize){
				notify(this.currentCommand.name, this.replyBuffer);
				this.next = TYPE.REPLYVAL;
			}
		}
	}

	notify = (replyName, data) => {
		var replyListeners = listeners[replyName];
		if(replyListeners.length === 0) throw("No listeners for this value!");
		replyListeners.forEach(callback => callback(data));
	}
}
