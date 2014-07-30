(function() {
  var DIR, LOG_FILEPATH, app, configFile, counter, error, express, fs, log4js, logger, path, port, serveErrorMessage;

  express = require('express');

  fs = require('fs');

  path = require('path');

  log4js = require('log4js');

  log4js.configure('log4js_config.json');

  logger = log4js.getLogger("mobilerest");

  logger.setLevel('INFO');

  try {
    configFile = path.resolve('./config.json');
    DIR = JSON.parse(path.resolve(fs.readFileSync(configFile))).dir;
    LOG_FILEPATH = JSON.parse(path.resolve(fs.readFileSync(configFile))).logpath;
  } catch (_error) {
    error = _error;
    logger.fatal('Error happened while retrieving configuration information: \n' + error);
    express = fs = path = log4js = logger = configFile = DIR = LOG_FILEPATH = null;
    process.exit(1);
  }

  logger.info('Current output dir: ' + DIR + ', logfile path: ' + LOG_FILEPATH);

  app = express();

  app.enable('trust proxy');

  counter = 0;

  serveErrorMessage = function(error, msg, res) {
    var message;
    message = {
      "status": "error",
      "message": msg
    };
    res.type('text/json');
    return res.send(message);
  };

  app.get('/mobilerest/log', function(req, res) {
    logger.info('Received GET-request from ' + req.ip);
    return fs.readFile(LOG_FILEPATH, 'utf8', function(err, data) {
      var msg;
      if (err) {
        msg = "File not found - missing log file";
        serveErrorMessage(err, msg, res);
      } else {
        res.type('text/plain');
        return res.send(data);
      }
    });
  });

  app.get('/mobilerest/:restaurant/:year/:week', function(req, res) {
    var filePath, restaurant, week, year;
    logger.info('Received GET-request from ' + req.ip);
    restaurant = req.params('restaurant').toLowerCase() + path.sep;
    year = req.params('year') + path.sep;
    week = req.params('week') + path.sep;
    filePath = DIR + restaurant + year + week;
    return fs.readFile(filePath, 'utf8', function(err, data) {
      var msg;
      if (err) {
        logger.error(err + "\n");
        msg = "File not found - bad restaurant name or week number";
        serveErrorMessage(err, msg, res);
      } else {
        res.type('text/json');
        res.send(data);
      }
    });
  });

  app.get('mobilerest/:restaurant/current', function(req, res) {
    var filePath, restaurant;
    logger.info('Received GET-request from ' + req.ip);
    restaurant = req.params('restaurant').toLowerCase() + path.sep;
    filePath = DIR + restaurant + 'current' + path.sep;
    return fs.readFile(filePath, 'utf8', function(err, data) {
      var msg;
      if (err) {
        logger.error(err + "\n");
        msg = "File not found - bad restaurant name or missing food list";
        serveErrorMessage(err, msg, res);
      } else {
        res.type('text/json');
        res.send(data);
      }
    });
  });


  /* DEPRECATED API */

  app.get('/mobilerest/', function(req, res) {
    var filepath, restaurant, restaurantDir, week, year;
    restaurant = req.params.restaurant;
    restaurantDir = restaurant + path.sep;
    year = req.query.year;
    week = req.query.week;
    filepath = DIR + restaurantDir + year + '_w' + week + '_' + restaurant + '.json';
    fs.readFile(filepath, 'utf8', function(err, data) {
      var msg;
      if (err) {
        msg = "File not available - Bad restaurant name or week number: " + restaurant + " " + week;
        serveErrorMessage(err, msg, res);
      } else {
        res.type('text/json');
        return res.send(data);
      }
    });
    console.log('Client queried for: ' + JSON.stringify(req.query));
    return console.log('Answered to request #' + (++counter));
  });

  app.get('/mobilerest/queryAllUnicaNewest', function(req, res) {
    var currentDate, filepath, week, year;
    currentDate = new Date();
    year = currentDate.getFullYear();
    week = currentDate.getWeek();
    filepath = DIR + 'unica/' + year + '_w' + week + '_' + 'unica.json';
    return fs.readFile(filepath, 'utf8', function(err, data) {
      var msg;
      if (err) {
        msg = "File not available - Bad week number: " + week;
        serveErrorMessage(err, msg, res);
        return;
      }
      res.type('text/json');
      res.send(data);
      console.log('Client queried for: ' + JSON.stringify(req.query));
      return console.log('Answered to request #' + (++counter));
    });
  });

  Date.prototype.getWeek = function() {
    var dayNr, firstThursday, target;
    target = new Date(this.valueOf());
    dayNr = (this.getDay() + 6) % 7;
    target.setDate(target.getDate() - dayNr + 3);
    firstThursday = target.valueOf();
    target.setMonth(0, 1);
    if (target.getDay() !== 4) {
      target.setMonth(0, 1 + ((4 - target.getDay()) + 7) % 7);
    }
    return Math.ceil(1 + (firstThursday - target) / 604800000);
  };

  port = process.env.PORT || 4730;

  console.log("Listening on port " + port);

  app.listen(port);

}).call(this);
