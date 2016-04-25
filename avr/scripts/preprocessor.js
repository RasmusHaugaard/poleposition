"use strict"
/*
Assembly preprocessor med direktivet ".filedef", en filescopet ".def" analog.
*/
const fs = require('fs')
const mkdirp = require('mkdirp')
const escapeRgx = require('escape-string-regexp')

var inputDir = process.argv[2] //første argument
var outputDir = process.argv[3] //andet argument

//funktion, der finder alle ".inc" og ".asm" filer i en mappe og mappens undermapper.
const getFilePaths = (root) => {
	var filePaths = []
	const handlePath = (path) => {
		var stat = fs.statSync(path)
		if (stat.isFile()){
			var fileext = path.substr(-4).toUpperCase()
			if (fileext === '.ASM' || fileext === '.INC') filePaths.push(path)
		}else if (stat.isDirectory()){
			mkdirp.sync(path.replace(inputDir, outputDir))

			fs.readdirSync(path).forEach(subPath => {
				handlePath(path + '/' + subPath)
			})
		}else{
			throw(path + ", is not a file nor a path?")
		}
	}
	handlePath(root)
	return filePaths
}

//hjælpefunktion, der returnerer en regular expression, som finder to argumenter til et diretktiv.
const RGX_D = (directive, seperator) => {
	return new RegExp(
		'^[\\t ]*\\.' + escapeRgx(directive) +
		'[\\t ]+([^\\t\\n\\r= ]*)\\s*' + escapeRgx(seperator) + '\\s*([^\\t\\n\\r; ]*)'
		,	'gmi'
	)
}

var rgxFileDef = RGX_D("filedef", "=")

//hjælpefunktion, der logger en fejl ved en linje i en fil.
const lineErr = (filePath, index) => {
	console.log(filePath + '(' + (index + 1) + ')')
}

//funktion, der preprocesser én fil
const processFile = (inputPath, outputPath) => {
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
	fs.writeFileSync(outputPath, newText)
}


var startTime = new Date()

const filePaths = getFilePaths(inputDir)

filePaths.forEach(path => {
	processFile(path, path.replace(inputDir, outputDir))
})

var endTime = new Date()

console.log("Processed in " + (endTime - startTime) + ' ms')

process.exit(0)
