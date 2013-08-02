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
    
    coffee:
      client:
        expand: true
        cwd: 'client'
        src: ['**/*.coffee']
        dest: 'temp/client/'
        ext: '.js'
        options:
          bare: true
      common:
        expand: true
        cwd: 'common'
        src: ['**/*.coffee']
        dest: 'temp/common/'
        ext: '.js'
        options:
          bare: true
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
        src: ['test/**/*Spec.coffee']
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

    requirejs:
      scripts:
        options:
          baseUrl: 'temp/client/'
          findNestedDependencies: true
          logLevel: 0
          mainConfigFile: 'temp/client/main.js'
          name: 'main'
          onBuildWrite: (moduleName, path, contents) ->
            modulesToExclude = ['main']
            shouldExcludeModule = modulesToExclude.indexOf(moduleName) >= 0

            if (shouldExcludeModule)
              return ''

            return contents
          optimize: 'none'
          out: 'bin/gint-util.js'
          preserveLicenseComments: false
          skipModuleInsertion: true
          uglify:
            no_mangle: false

  grunt.loadNpmTasks 'grunt-gint'
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-contrib-requirejs'

  grunt.registerTask 'build'
  , ['clean', 'coffeeLint', 'coffee', 'requirejs']

  grunt.registerTask 'default'
  , ['build']

  grunt.registerTask 'travis'
  , ['build', 'mocha:travis']

  grunt.registerTask 'run'
  , [ 'default', 'watch']