"use strict"
/*
Assembly preprocessor med direktivet ".filedef", en filescopet ".def" analog.
*/
const fs = require('fs')
const glob = require('glob').sync
const mkdirp = require('mkdirp')
const escapeRgx = require('escape-string-regexp')
const writeFile = require('./writeFileMkdirp')

function preprocess(inputDir, outputDir){
	var startTime = Date.now()
	const filePaths = glob(inputDir + "/**/*.{asm,inc}")
	filePaths.forEach(path => {
		processFile(path, path.replace(inputDir, outputDir + "/" + inputDir))
	})
	console.log("Processed in " + (Date.now() - startTime) + ' ms')
}

const RGX_D = (directive, seperator) => {
	return new RegExp(
		'^[\\t ]*\\.' + escapeRgx(directive) +
		'[\\t ]+([^\\t\\n\\r= ]*)\\s*' + escapeRgx(seperator) + '\\s*([^\\t\\n\\r; ]*)'
		,	'gmi'
	)
}

const lineErr = (filePath, index) => {
	console.log(filePath + '(' + (index + 1) + ')')
}

const processFile = (inputPath, outputPath) => {
	let rgxFileDef = RGX_D("filedef", "=")
	var text = fs.readFileSync(inputPath, "utf8")
	var lines = text.split('\n')
	var fileDefs = {names:[], values:[]}

	lines.forEach((line, i) => {
		rgxFileDef.lastIndex = 0
		var m = rgxFileDef.exec(line)
		if (!m) return
		if (m.length !== 3 || m[1].length === 0 || m[2].length === 0){
				lineErr(filePath, i)
				console.log('Empty .filedef name or value!')
				process.exit(1)
		}
		var name = m[1].toUpperCase()
		var nameIndex = fileDefs.names.indexOf(name)
		if(nameIndex !== -1){
			lineErr(inputPath, i)
			console.log('Name "' + name + '" already defined to value "' + fileDefs.values[nameIndex] + '"')
			process.exit(1)
		}
		var value = m[2].toUpperCase()
		var valueIndex = fileDefs.values.indexOf(value)
		if(valueIndex !== -1){
			lineErr(inputPath, i)
			console.log('Value "' + value + '" already defined to name "' + fileDefs.names[valueIndex] + '"')
			process.exit(1)
		}
		fileDefs.names.push(name)
		fileDefs.values.push(value)

		lines[i] = ';' + line
	})

	for (var i = 0; i < fileDefs.names.length; i++){
		var name = fileDefs.names[i]
		var value = fileDefs.values[i]

		var nameRgx = new RegExp('\\b' + escapeRgx(name) + '\\b','gi')

		lines.forEach((line, i) => {
			var lineparts = line.split(';')
			lineparts[0] = lineparts[0].replace(nameRgx, value)
			lines[i] = lineparts.join(';')
		})
	}

	var newText = lines.join('\n')
	writeFile(outputPath, newText)
}

module.exports = preprocess
