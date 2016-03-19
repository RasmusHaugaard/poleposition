chrome.app.runtime.onLaunched.addListener(function() {
  chrome.app.window.create("index.html", {
    //state: "fullscreen"
    outerBounds: {
      left: 0, top: 0, width: 700, height: 500
    }
  });
});
