"use strict"

const spawn = require('child_process').spawnSync

function run(command, args, options){
	let obj = spawn(command, args, options)
	obj.output.filter(buf => buf)
	.forEach(buf => {
		console.log(buf.toString())
	})
	return obj
}

const runException = {}
function runSequence(arr){
	try{
		arr.forEach(func => {
			let obj = func()
			//allows to also execute non-child-process functions
			if (obj && obj.status) throw runException
		})
	}catch(e){
		return false
	}
	return true
}

module.exports = {run, runSequence}
