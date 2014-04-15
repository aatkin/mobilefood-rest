express = require 'express'
fs = require 'fs'

counter = 0
configFile = '/var/www/projects/mobilerest/config.json'

DIR = JSON.parse(fs.readFileSync(configFile)).dir
console.log 'Current output dir: ' + DIR

app = express()

serveErrorMessage = (error, msg, res) ->
    console.log error
    message = {
        "status": "error",
        "message": msg
    }
    res.type 'text/json'
    res.send message

app.get '/mobilerest/', (req, res) ->
    # retrieve query parameters
    restaurant = req.query.restaurant
    restaurantDir = restaurant + '/'
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

app.get '/mobilerest/log', (req, res) ->
    filepath = '/home/brigesh/koodit/git/mobilefood-parser/log'
    fs.readFile filepath, 'utf8', (err, data) ->
        if err
            msg = "Logfile not available"
            serveErrorMessage(err, msg, res)
            return
        res.type 'text/plain'
        res.send data

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
