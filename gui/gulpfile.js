var gulp = require('gulp');

gulp.task('default', function(){
  gulp.start('reload');
});

gulp.task('reload', function() {
  var open = require('open');
  open("http://reload.extensions");
  // Kræver chrome extension:
  //https://chrome.google.com/webstore/detail/extensions-reloader/fimgfedafeadlieiabdeeaodndnlbhid
});
