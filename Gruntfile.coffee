module.exports = (grunt) ->
  # Project configuration.
  grunt.initConfig
    pkg: grunt.file.readJSON('package.json')

    clean:
      reset:
        src: ['bin']
      temp:
        src: ['temp']

    coffeeLint: 
      scripts:
        files: [
          {
            expand: true
            src: ['server/**/*.coffee']
          }
        ]
        options:
          indentation:
            value: 2
            level: 'error'
          no_plusplus: 
            level: 'error'
      tests:
        files: [
          {
            expand: true
            src: ['test/**/*.coffee']
          }
        ]
        options:
          indentation:
            value: 2
            level: 'error'
          no_plusplus: 
            level: 'error'

    watch:
      dev:
        files: ['server/**']
        tasks: ['default']
      mochaTests:
        files: ['test/server/**/*.coffee']
        tasks: ['coffeeLint:tests', 'mocha:unit']

    mocha:
      unit:
        expand: true
        src: ['test/server/**/*_test.coffee']
        options:
          globals: ['should']
          timeout: 3000
          ignoreLeaks: false
          ui: 'bdd'
          reporter: 'spec'
          growl: true
      travis:
        expand: true
        src: ['test/server/**/*_test.coffee']
        options:
          globals: ['should']
          timeout: 3000
          ignoreLeaks: false
          reporter: 'dot'   

  grunt.loadNpmTasks 'grunt-gint'
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-requirejs'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-gint'

  grunt.registerTask 'build'
  , ['clean', 'coffeeLint']

  grunt.registerTask 'default'
  , ['build', 'mocha:unit']

  grunt.registerTask 'travis'
  , ['build', 'mocha:travis']

  grunt.registerTask 'run'
  , [ 'default', 'watch']