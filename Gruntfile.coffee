module.exports = (grunt) ->

  PORT = 8111
  DATA_FILES = []
  BOWER_FILES = [
    "requirejs/require.js"
    "modernizr/modernizr.js"
    "d3/d3.min.js"
    "topojson/topojson.js"
    "underscore/underscore.js"
    "hammerjs/hammer.min.js"
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
      post: [
        ".tmp/*.js", "!.tmp/main.js"
        ".tmp/vendor/*", "!.tmp/vendor/modernizr", "!.tmp/vendor/requirejs"
      ]

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
        sourcemap: false
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
      htaccess:
        expand: true
        cwd: "app"
        src: ".htaccess"
        dest: ".tmp/"

    rsync:
      options:
        args: ["-avz"]
        recursive: true
      deploy:
        options:
          src: ".tmp/"
          host: "twoninc@two-n.com"
          dest: "/home/twoninc/prototypes.two-n.com/williams/#{ grunt.option("target") ? "" }"

    requirejs:
      build:
        options:
          baseUrl: '.tmp'
          out: ".tmp/main.js"
          name: 'main'
          # optimize: 'none'
          # include: "vendor/requirejs/require"
          paths:
            "d3": "vendor/d3/d3.min"
            "topojson": "vendor/topojson/topojson"
            "underscore": "vendor/underscore/underscore"
            "hammer": "vendor/hammerjs/hammer.min"


  grunt.registerTask "development", [
    "clean:build"
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
    "clean:build"
    "copy:bower"
    "copy:vendor"
    "copy:data"
    "copy:assets"
    "copy:index"
    "copy:htaccess"
    "sass:build"
    "autoprefixer:build"
    "coffee:production"
    "requirejs:build"
    "clean:post"
  ]
  grunt.registerTask "deploy", ["production", "rsync"]
