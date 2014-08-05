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
            gruntfile: {
                files: 'Gruntfile.js'
            },
            coffee: {
                files: ['src/**/*.coffee'],
                tasks: ['coffee']
            }
        },
        nodemon: {
            dev: {
                script: 'build/app.js',
                // options: {
                //     args: ['--log=oo.log']
                // }
            }
        },
        coffee: {
            compile: {
                expand: true,
                flatten: true,
                cwd: 'src',
                src: ['*.coffee'],
                dest: 'build/',
                ext: '.js'

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
