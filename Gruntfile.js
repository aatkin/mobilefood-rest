module.exports = function(grunt) {

    grunt.initConfig({
        pkg: grunt.file.readJSON('package.json'),

        concurrent: {
            target: {
                tasks: ['watch', 'nodemon'],
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
            },
            test: {
                files: ['test/**/*.coffee'],
                tasks: ['mochaTest']
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
            test: {
                options: {
                    reporter: 'spec',
                    require: 'coffee-script/register'
                },
                src: ['test/**/*.coffee']
            }
        }
    });

    grunt.event.on('watch', function(action, filepath) {
        if(filepath.match(/test\//)) {
            grunt.config('mochaTest.test.src', filepath);
        }
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
    grunt.registerTask('tests', ['mochaTest']);
    grunt.registerTask('workflow', ['concurrent:target']);
};
