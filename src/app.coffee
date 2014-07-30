express = require 'express'
fs = require 'fs'
path = require 'path'

try
    configFile = path.resolve('./config.json')
    DIR = JSON.parse(path.resolve(fs.readFileSync(configFile))).dir
    LOG_FILEPATH = JSON.parse(path.resolve(fs.readFileSync(configFile))).logpath
catch error
    logger.fatal('Error happened while retrieving configuration information: \n' + error)
    express = fs = path = log4js = logger = configFile = DIR = LOG_FILEPATH = null
    process.exit(1)

logger.info('Current output dir: ' + DIR + ', logfile path: ' + LOG_FILEPATH)

app = express()
app.enable('trust proxy')
counter = 0

serveErrorMessage = (error, msg, res) ->
    message = {
        "status": "error",
        "message": msg
    }
    res.type 'text/json'
    res.send message

#
# GET
#
app.get '/mobilerest/log', (req, res) ->
    logger.info('Received GET-request from ' + req.ip)
    fs.readFile LOG_FILEPATH, 'utf8', (err, data) ->
        if err
            msg = "File not found - missing log file"
            serveErrorMessage(err, msg, res)
            return
        else
            res.type 'text/plain'
            res.send data

#
# GET
# Returns specified food list from file system as JSON.
#
app.get '/mobilerest/:restaurant/:year/:week', (req, res) ->
    logger.info('Received GET-request from ' + req.ip)
    restaurant = req.params('restaurant').toLowerCase() + path.sep
    year = req.params('year') + path.sep
    week = req.params('week') + path.sep
    filePath = DIR + restaurant + year + week
    fs.readFile filePath, 'utf8', (err, data) ->
        if err
            logger.error(err + "\n")
            msg = "File not found - bad restaurant name or week number"
            serveErrorMessage(err, msg, res)
            return
        else
            res.type('text/json')
            res.send(data)
            return

#
# GET
# Returns food list marked as 'current' from file system as JSON.
#
app.get 'mobilerest/:restaurant/current', (req, res) ->
    logger.info('Received GET-request from ' + req.ip)
    restaurant = req.params('restaurant').toLowerCase() + path.sep
    filePath = DIR + restaurant + 'current' + path.sep
    fs.readFile filePath, 'utf8', (err, data) ->
        if err
            logger.error(err + "\n")
            msg = "File not found - bad restaurant name or missing food list"
            serveErrorMessage(err, msg, res)
            return
        else
            res.type('text/json')
            res.send(data)
            return

#
### DEPRECATED API ###
#

app.get '/mobilerest/', (req, res) ->
    restaurant = req.params.restaurant
    restaurantDir = restaurant + path.sep
    year = req.query.year
    week = req.query.week
    filepath = DIR + restaurantDir + year + '_w' + week + '_' + restaurant + '.json'
    
    fs.readFile filepath, 'utf8', (err, data) ->
        if err
            msg = "File not available - Bad restaurant name or week number: " + restaurant + " " + week
            serveErrorMessage(err, msg, res)
            return
        else
            res.type 'text/json'
            res.send data

    console.log 'Client queried for: ' + JSON.stringify(req.query)
    console.log 'Answered to request #' + (++counter)

# queries all newest unica restaurants
app.get '/mobilerest/queryAllUnicaNewest', (req, res) ->
    currentDate = new Date()
    year = currentDate.getFullYear()
    week = currentDate.getWeek()
    filepath = DIR + 'unica/' + year + '_w' + week + '_' + 'unica.json'

    fs.readFile filepath, 'utf8', (err, data) ->
        if err
            msg = "File not available - Bad week number: " + week
            serveErrorMessage(err, msg, res)
            return
        res.type 'text/json'
        res.send data
        console.log 'Client queried for: ' + JSON.stringify(req.query)
        console.log 'Answered to request #' + (++counter)


Date.prototype.getWeek = ->
    target = new Date(this.valueOf())
    dayNr = (this.getDay() + 6) % 7
    target.setDate(target.getDate() - dayNr + 3)
    firstThursday = target.valueOf()
    target.setMonth 0, 1
    if target.getDay() != 4
        target.setMonth(0, 1 + ((4 - target.getDay()) + 7) % 7)
    Math.ceil(1 + (firstThursday - target) / 604800000)

port = process.env.PORT || 4730
console.log "Listening on port " + port
app.listen port
