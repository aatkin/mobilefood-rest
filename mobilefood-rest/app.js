var fs = require('fs');
var path = require('path');

var express = require('express');
var mongoClient = require('mongodb').MongoClient;

var configFile = 'config.json';

var setupApp = function(app) {
    try {
        var port = JSON.parse(fs.readFileSync(configFile)).port;
        var mongo_address = JSON.parse(fs.readFileSync(configFile)).mongo_address;

        app.set('port', port);

        // Enable CORS
        app.use(function(req, res, next) {
            res.header("Access-Control-Allow-Origin", "*");
            res.header(
                "Access-Control-Allow-Headers",
                "Origin, X-Requested-With, Content-Type, Accept");
            next();
        });

        // inject mongodb instance
        mongoClient.connect(mongo_address, function(err, db) {
            app.set('db', db);
            var routes = require('./routes');
            app.use('/api/foods', routes.foods);
            app.use('/api/info', routes.info);
            // app.use('/api/restaurant', routes.restaurant);
            app.use('/', routes.defaultroute);
        });

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
    app.get('db').close();
    app.close(function() {
        console.log('Closing server now');
    });
};


if (!module.parent) {
    exports.app = app = express();
    setupApp(app);
    start(app, app.get('port'));
}