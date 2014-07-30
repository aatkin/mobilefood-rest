module.exports = function(grunt) {

    grunt.initConfig({
        pkg: grunt.file.readJSON('package.json'),

        concurrent: {
            target: {
                tasks: ['nodemon', 'watch'],
                options: {
                    logConcurrentOutput: true
                }
            }
        },
        watch: {
            files: ['src/*.coffee'],
            tasks: ['coffee'],
            options: {
                livereload: 'true'
            }
        },
        nodemon: {
            dev: {
                script: 'app.js'
            }
        },
        coffee: {
            compile: {
                files: {
                    "./app.js": "src/app.coffee"
                }
            }
        },
        mochaTest: {
            // TODO: add testing
        }
    });

    grunt.event.on('watch', function(action, filepath) {
        grunt.config('coffee.compile.files', filepath);
    });

    grunt.loadNpmTasks('grunt-contrib-watch');
    grunt.loadNpmTasks('grunt-contrib-coffee');
    grunt.loadNpmTasks('grunt-nodemon');
    grunt.loadNpmTasks('grunt-concurrent');
    grunt.loadNpmTasks('grunt-mocha-test');

    grunt.registerTask('compliment', function() {
        grunt.log.ok("You are so awesome!");
    });

    grunt.registerTask('default', ['compliment']);
    grunt.registerTask('compile', ['coffee']);
    grunt.registerTask('workflow', ['concurrent:target']);
};
