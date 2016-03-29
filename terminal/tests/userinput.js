var util = require('util');

const input = (onInput) => {
  process.stdin.resume();
  process.stdin.setEncoding('utf8');

  process.stdin.on('data', function (input) {
    if (input === 'quit\n') {
      process.exit();
    }
    input = input.substr(0, input.length - 1);
    if(input.length >= 2 && input.substr(input.length - 2, 2) === "\\n") input = input.substr(0, input.length - 2) + "\n";
    if(input.substr(0,2) == "0d" && input.length > 2){
      var val = parseInt(input.substr(2, input.length - 2));
      if(val > 255){
        console.log("Please only send values between 0 and 255.");
        return;
      }
      var buf = new ArrayBuffer(1);
      var bufView = new Uint8Array(buf);
      bufView[0] = val;
      input = buf;
    }
    onInput(input);
  });
}

module.exports = input;
