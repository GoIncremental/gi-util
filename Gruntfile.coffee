module.exports = (grunt) ->
  # Project configuration.
  grunt.initConfig
    pkg: grunt.file.readJSON('package.json')

    clean:
      reset:
        src: ['dist','testbin']
      temp:
        src: ['temp']

    coffeeLint: 
      scripts:
        files: [
          {
            expand: true
            src: ['client/**/*.coffee', '!client/js/components/**']
          }
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
      scripts:
        expand: true
        cwd: 'client'
        src: ['**/*.coffee']
        dest: 'temp/client/'
        ext: '.js'
        options:
          bare: true
      tests:
        expand: true
        cwd: 'test'
        src: ['**/*.coffee']
        dest: 'temp/test/'
        ext: '.js'
        options:
          bare: true

    copy:
      server:
        expand: true
        cwd: 'server'
        src: '**'
        dest: 'temp/server/'
      conf:
        src: ['.npmignore', 'component.json', 'package.json', 'README.md']
        dest: 'temp/'
      dist:
        expand: true
        cwd: 'temp/'
        src: ['**', '!*.coffee', '!test/**']
        dest: 'dist'      
      test:
        expand: true
        cwd: 'temp/'
        src: ['**']
        dest: 'testbin'     

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
          out: './client/index.js'
          preserveLicenseComments: false
          skipModuleInsertion: true
          uglify:
            no_mangle: false
    watch:
      mochatests:
        files: ['testbin/server/**/*.coffee', 'testbin/test/server/**/*.js']
        tasks: ['mocha']

    mocha:
      all:
        expand: true
        src: ['test/server/_helper.js', 'testbin/test/server/**/*_test.js']
        options:
          globals: ['should']
          timeout: 3000
          ignoreLeaks: false
          ui: 'bdd'
          reporter: 'spec'

  grunt.loadNpmTasks 'grunt-gint'
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-requirejs'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-gint'

  grunt.registerTask 'default'
  , ['clean', 'coffeeLint', 'coffee', 'requirejs', 'copy', 'clean:temp', 'mocha']