var rimraf = require('rimraf');

var dir = process.argv[2];
if (!dir) throw("Clean what directory? No argument passed!");
if (dir[0] === "/" || dir === "./" || dir.substr(0,2) === "..") throw("Please don't do that..");

rimraf.sync(dir);
