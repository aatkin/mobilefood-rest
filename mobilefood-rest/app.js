var fs = require('fs');
var path = require('path');

var express = require('express');

var configFile = 'config.json';

var setupApp = function(app) {
    try {
        var port = JSON.parse(fs.readFileSync(configFile)).port;
        var mongo_address = JSON.parse(fs.readFileSync(configFile)).mongo_address;

        app.set('port', port);
        app.set('mongo_address', mongo_address);

        // Enable CORS
        app.use(function(req, res, next) {
            res.header("Access-Control-Allow-Origin", "*");
            res.header(
                "Access-Control-Allow-Headers",
                "Origin, X-Requested-With, Content-Type, Accept");
            next();
        });

        var routes = require('./routes');
        app.use('/mobilerest', routes.restaurants);
        app.use('/', routes.defaultroute);
    } catch (e) {
        console.error(e);
        process.exit(1);
    }
};

var start = function(app, port) {
    app.listen(port, function() {
        console.log('Listening on ' + port);
    });
};

var stop = function(app) {
    app.close(function() {
        console.log('Closing server now');
    });
};


if (!module.parent) {
    exports.app = app = express();
    setupApp(app);
    start(app, app.get('port'));
}