"use strict"

const gulp = require('gulp')
const glob = require('glob').sync
const clean = require('./scripts/clean')
const run = require("./scripts/run").run
const runSequence = require("./scripts/run").runSequence
const mv = require('mv')
const rename = require('fs').renameSync
const doPreprocess = require('./scripts/preprocess')
const Watch = require('watch')

const project = "program"
const deviceArgs = ["-p", "m32"]
const programmerArgs = ["-c","usbasp","-P","usb"]
const inDir = "src"
const tempDir = "temp"
const outDir = "build"

gulp.task('default', assembleFlash)
gulp.task('fuse', fuse)
gulp.task('flash', flash)
gulp.task('assemble', assemble)
gulp.task('preprocess', preprocess)
gulp.task('erase', erase)
gulp.task('watch', watch)
gulp.task('watchassemble', watchAssemble)

function flash(){
	return run(
		"avrdude",
		deviceArgs.concat(programmerArgs)
			.concat(["-U","flash:w:" + outDir + "/" + project + ".hex"])
	)
}

function fuse(){
	const highFuse = "0xd8"
	const lowFuse = "0xff"
	return run(
		"avrdude",
		deviceArgs.concat(programmerArgs)
		 	.concat([
				"-U","hfuse:w:" + highFuse + ":m",
				"-U","lfuse:w:" + lowFuse + ":m"
			])
	)
}

function erase(){
	return run(
		"avrdude",
		deviceArgs.concat(programmerArgs)
			.concat(["-e"])
	)
}

function assembleFlash(){
	runSequence([
		assemble(),
		flash()
	])
}

function assemble(){
	preprocess()
	clean(outDir)
	let obj = run(
		"avra",
		["-l", inDir + "/listfile.lst", inDir + "/" + project + ".asm"],
		{cwd: tempDir}
	)
	if(!obj.status){
		let outputFiles = glob(tempDir + "/" + inDir + "/**/*.{lst,obj,hex,cof}")
		outputFiles.forEach(file => {
			rename(file, file.replace(tempDir + "/" + inDir, outDir))
		})
	}
	return obj
}

function preprocess(){
	clean(tempDir)
	doPreprocess(inDir, tempDir)
}

function watch(){
	Watch.watchTree(inDir, {interval:100}, () => {
		clearConsole()
		assembleFlash()
	})
}

function watchAssemble(){
	Watch.watchTree(inDir, {interval:100}, () => {
		clearConsole()
		assemble()
	})
}

function clearConsole(){
	console.log("\x1B[2J")
}
