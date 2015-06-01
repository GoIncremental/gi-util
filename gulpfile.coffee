del = require 'del'
gulp = require 'gulp'
gutil = require 'gulp-util'
concat = require 'gulp-concat'
coffeelint = require 'gulp-coffeelint'
coffeeCompiler = require 'gulp-coffee'
streamqueue = require 'streamqueue'
runSequence = require 'run-sequence'

buildDir = 'dist'
modulePath = 'gi-util'

coffee = () ->
  gulp.src(['client/**/*.coffee'])
  .pipe(coffeelint())
  .pipe(coffeelint.reporter())
  .pipe(coffeeCompiler {bare: true}).on('error', gutil.log)

libs = () ->
  gulp.src(['momentjs/moment.js'
            'underscore/underscore.js'
            'json2/json2.js'
            'html5shiv/dist/html5shiv-printshiv.js'
            'angular/angular.js'
            'angular-resource/angular-resource.js'
            'angular-route/angular-route.js'
            'angular-cookies/angular-cookies.js'
            'angular-touch/angular-touch.js'
            'aws-sdk/dist/aws-sdk.js'
            'angular-loggly-logger/angular-loggly-logger.js'
            ], {cwd:'bower_components/'})

gulp.task 'clean', (cb) ->
  del 'dist', cb

gulp.task 'build', () ->
  streamqueue({objectMode: true}, libs(), coffee())
  .pipe(concat(modulePath + '.js'))
  .pipe(gulp.dest(buildDir))

gulp.task 'default', ['build']

gulp.task 'default', (cb) ->
  runSequence 'clean', 'build'

gulp.task 'watch', ['build'], () ->
  gulp.watch(['client/views/*.html'
              'client/**/*.coffee']
             ['build'])
