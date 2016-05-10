"use strict"

const mkdirp = require('mkdirp').sync
const writeFileSync = require('fs').writeFileSync
const getDirName = require('path').dirname

function writeFileMkdirp(path, content) {
  mkdirp(getDirName(path))
  writeFileSync(path, content)
}

module.exports = writeFileMkdirp
