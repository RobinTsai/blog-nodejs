module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'
    coffee:
      root:
        expand: true
        flatten: true
        cwd: 'static'
        src: ['*.coffee']
        dest: './'
        ext: '.js'
      routes:
        expand: true
        flatten: true
        cwd: 'static'
        src: ['routes/*.coffee']
        dest: './routes/'
        ext: '.js'
      models:
        expand: true
        flatten: true
        cwd: 'static'
        src: ['models/*.coffee']
        dest: './models/'
        ext: '.js'

    scsslint:
      options:
        config: './scsslint.yml'
        force: true
        maxBuffer: 1024 * 1024 * 1024
        colorizeOutput: true
      buildModule:
        src: './static/{**/,*/}*.scss'

    coffeelint:
      options:
        configFile: 'coffeelint.json'
      app: ['static/{**/,*/}*.coffee']

    sass:
      dist:
        files:
          './public/stylesheets/style.css': './static/sass/*.scss'
        options:
          sourcemap: true

    watch:
      options:
        livereload: true
      coffee:
        files: ['./static/**/{,*/}*.coffee']
        tasks: [
          'coffeelint:app', 'coffee'
        ]
      sass:
        files: ['./static/**/{,*/}*.scss']
        tasks: ['scsslint:buildModule', 'sass:dist']

  grunt.loadNpmTasks 'grunt-coffeelint'
  grunt.loadNpmTasks 'grunt-contrib-sass'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-livereload'
  grunt.loadNpmTasks 'grunt-scss-lint'

  grunt.registerTask 'default', ['coffee', 'scsslint', 'sass', 'watch']
  # registerTask('default') have its order, when you run command 'grunt', run this, 'watch' will stop the right task, so you'd better to lay 'watch' at the end.
