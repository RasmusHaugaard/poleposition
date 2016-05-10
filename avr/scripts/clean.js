"use strict"
/*
Cross platform remove folder recursively
*/
const rimraf = require('rimraf')
const mkdirp = require('mkdirp')

function clean(dir){
	if (!dir) throw "Clean what directory? No argument passed!"
	if (dir[0] === "/" || dir === "./" || dir.substr(0,2) === "..") throw "Please don't do that.."
	rimraf.sync(dir)
	mkdirp.sync(dir)
}

module.exports = clean
