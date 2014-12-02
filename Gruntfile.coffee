module.exports = (grunt) ->

  PORT = 8111
  DATA_FILES = []
  BOWER_FILES = [
    "requirejs/require.js"
    "modernizr/modernizr.js"
    "d3/d3.min.js"
    "topojson/topojson.js"
    "underscore/underscore.js"
  ]


  require("load-grunt-tasks")(grunt)

  grunt.initConfig
    watch:
      options:
        livereload: PORT + 3e4
        spawn: false
      bower:
        files: BOWER_FILES.map (d) -> "bower_components/#{d}"
        tasks: ["copy:bower", "copy:vendor"]
      vendor:
        files: "app/vendor"
        tasks: ["copy:vendor"]
      index:
        files: "app/index.html"
        tasks: ["copy:index"]
      scripts:
        files: "app/scripts/**/*.coffee"
        tasks: ["copy:source", "coffee"]
      styles:
        files: "app/styles/**/*"
        tasks: ["sass", "autoprefixer"]
      assets:
        files: "app/assets/**/*"
        tasks: ["copy:assets"]
      data:
        files: "data/**/*"
        tasks: ["copy:data"]

    clean:
      build: ".tmp"

    connect:
      livereload:
        options:
          base: ".tmp"
          port: PORT
          livereload: PORT + 3e4

    coffee:
      build:
        options:
          sourceMap: true
        files: [
          expand: true
          cwd: "app/scripts"
          src: "**/*.coffee"
          dest: ".tmp"
          ext: ".js"
        ]
      production:
        files: [
          expand: true
          cwd: "app/scripts"
          src: "**/*.coffee"
          dest: ".tmp"
          ext: ".js"
        ]

    sass:
      options:
        sourcemap: true
      build:
        src: "app/styles/main.scss"
        dest: ".tmp/main.css"

    autoprefixer:
      options:
        browsers: ["> 1%"]
      build:
        src: ".tmp/main.css",
        dest: ".tmp/main.css"

    copy:
      index:
        expand: true
        cwd: "app"
        src: "index.html"
        dest: ".tmp/"
      assets:
        expand: true
        cwd: "app"
        src: "assets/**/*"
        dest: ".tmp/"
      source:
        src: ["app/scripts/**", "app/styles/**"]
        dest: ".tmp/"
      bower:
        expand: true
        cwd: "bower_components"
        dest: "app/vendor"
        src: BOWER_FILES
      vendor:
        expand: true
        cwd: "app"
        src: "vendor/**/*"
        dest: ".tmp"
      data:
        expand: true
        cwd: "data"
        dest: ".tmp/data"
        src: DATA_FILES

    aws: try grunt.file.readJSON "aws-credentials.json"
    s3:
      options:
        key: "<%= aws.aws_access_key_id %>"
        secret: "<%= aws.aws_secret_access_key %>"
        # bucket: "throwaway.dechov.com"
        gzip: true
      production:
        sync: [
          src: ".tmp/**"
          dest: "/"
          rel: ".tmp"
          options:
            verify: true
        ]

  grunt.registerTask "development", [
    "clean"
    "copy:bower"
    "copy:vendor"
    "copy:data"
    "copy:assets"
    "copy:index"
    "copy:source"
    "sass:build"
    "autoprefixer:build"
    "coffee:build"
    "connect:livereload"
    "watch"
  ]
  grunt.registerTask "default", ["development"]

  grunt.registerTask "production", [
    "clean"
    "copy:bower"
    "copy:vendor"
    "copy:data"
    "copy:assets"
    "copy:index"
    "sass:build"
    "autoprefixer:build"
    "coffee:production"
  ]
  grunt.registerTask "deploy", ["production", "s3"]
