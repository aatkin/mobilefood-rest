module.exports = function(grunt) {

    grunt.initConfig({
        pkg: grunt.file.readJSON('package.json')
    });

    grunt.registerTask('compliment', function() {
        grunt.log.ok("You are so awesome!");
    });

    grunt.registerTask('default', ['compliment']);
};
