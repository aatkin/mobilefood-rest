express = require 'express'
fs = require 'fs'
path = require 'path'
winston = require 'winston'

logger = new (winston.Logger)({
    transports: [
        new (winston.transports.Console)(
            {
                level: 'warn',
                colorize: 'true',
                timestamp: true
            }),
        new (winston.transports.File)(
            {
                filename: 'mobilelog.log',
                level: 'silly',
                maxsize: 2048000,
                json: false
            })
    ]
})

if not fs.existsSync("mobilelog.log")
    fs.writeFileSync("mobilelog.log")

try
    configFile = path.resolve('config.json')
    DIR = JSON.parse(fs.readFileSync(configFile)).dir
    LOG_FILEPATH = JSON.parse(fs.readFileSync(configFile)).logpath
catch error
    logger.error('Error happened while retrieving configuration information:
        \n' + error)
    express = fs = path = winston = logger = configFile =
        DIR = LOG_FILEPATH = null
    process.exit(1)

logger.info('Current output dir: ' + DIR + ', logfile path: ' + LOG_FILEPATH)
app = express()
app.enable('trust proxy')
port = process.env.PORT || 4730
logger.info("Listening on port " + port)
app.listen port

serveErrorMessage = (error, msg, res) ->
    message = {
        "status": "error",
        "message": msg
    }
    res.type 'text/json'
    res.send(error, message)

#
# MIDDLEWARE
# Log all requests
#
app.use (req, res, next) ->
    logger.info('Received GET-request from ' + req.ip)
    next()

#
# GET
#
app.get '/mobilerest/log', (req, res) ->
    fs.readFile LOG_FILEPATH, 'utf8', (err, data) ->
        if err
            logger.debug(err + "\n")
            msg = "Error happened while reading file"
            serveErrorMessage(404, msg, res)
        else
            res.type 'text/plain'
            res.send(200, data)

#
# GET
# Returns food list marked as 'current' from file system as JSON.
#
app.get '/mobilerest/:restaurant/current', (req, res) ->
    restaurant = req.params.restaurant.toLowerCase() + path.sep
    filePath = DIR + restaurant + 'current' + path.sep
    fs.readFile filePath, 'utf8', (err, data) ->
        if err
            logger.debug(err + "\n")
            msg = "Error happened while reading file - missing food list?"
            serveErrorMessage(404, msg, res)
        else
            res.type('text/json')
            res.send(200, data)

#
# GET
# Returns specified food list from file system as JSON.
#
app.get '/mobilerest/:restaurant/:year/:week', (req, res) ->
    restaurant = req.params.restaurant.toLowerCase() + path.sep
    year = req.params.year + path.sep
    week = req.params.week + path.sep
    filePath = DIR + restaurant + year + week
    fs.readFile filePath, 'utf8', (err, data) ->
        if err
            logger.verbose(err + "\n")
            msg = "Error happened while reading file - missing food list?"
            serveErrorMessage(404, msg, res)
        else
            res.type('text/json')
            res.send(200, data)

#
# GET
# Default route, if none of above apply.
#
app.get '*', (req, res) ->
    msg = "Bad request"
    serveErrorMessage(400, msg, res)
