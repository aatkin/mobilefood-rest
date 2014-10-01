express = require 'express'
fs = require 'fs'
path = require 'path'

serveErrorMessage = (error, msg, res) ->
    message = {
        status: error,
        message: msg
    }
    res.set('Connection', 'close')
    res.status(error).json(message)

#
# GET
# Info route
#
exports.info = info = express.Router()

info.get '/info', (req, res) ->
    try
        infopath = path.resolve(require('./app').app.get('infofile'))
    catch e
        console.log e
        msg = 'Error happened while resolving file location'
        serveErrorMessage(400, msg, res)
    fs.readFile infopath, 'utf8', (err, data) ->
        if err
            msg = 'Error happened while reading file - missing file?'
            console.log err
            serveErrorMessage(404, msg, res)
        else
            res.type 'text/html'
            res.set('Connection', 'close')
            res.status(200).send(data)

#
# GET
# Logging route
#
exports.log = log = express.Router()

log.get '/log', (req, res) ->
    try
        logpath = path.resolve(require('./app').app.get('logfile'))
    catch e
        console.log e
        msg = 'Error happened while resolving file location'
        serveErrorMessage(400, msg, res)
    fs.readFile logpath, 'utf8', (err, data) ->
        if err
            msg = 'Error happened while reading file - missing file?'
            console.log err
            serveErrorMessage(404, msg, res)
        else
            res.type 'text/plain'
            res.set('Connection', 'close')
            res.status(200).send(data)

#
# Restaurant routing
#

exports.restaurants = restaurants = express.Router()

#
# GET
# Returns food list marked as 'current' from file system as JSON.
#
restaurants.get '/:restaurant/current', (req, res) ->
    dir = require('./app').app.get('dir')
    restaurant = req.params.restaurant.toLowerCase()
    try
        filepath = path.resolve(path.join(
            dir, restaurant, 'current', "foodlist.json"))
    catch e
        console.log e
        msg = 'Error happened while resolving file location'
        serveErrorMessage(400, msg, res)
    fs.readFile filepath, 'utf8', (err, data) ->
        if err
            msg = 'Error happened while reading file - missing file?'
            serveErrorMessage(404, msg, res)
        else
            res.set('Connection', 'close')
            res.status(200).json(data)

#
# GET
# Returns specified food list from file system as JSON.
#
restaurants.get '/:restaurant/:year/:week', (req, res) ->
    dir = require('./app').app.get('dir')
    restaurant = req.params.restaurant.toLowerCase()
    year = req.params.year
    week = req.params.week
    try
        filepath = path.resolve(path.join(
            dir, restaurant, year, week, "foodlist.json"))
    catch e
        console.log e
        msg = 'Error happened while resolving file location'
        serveErrorMessage(400, msg, res)
    fs.readFile filepath, 'utf8', (err, data) ->
        if err
            msg = 'Error happened while reading file - missing file?'
            serveErrorMessage(404, msg, res)
        else
            res.set('Connection', 'close')
            res.status(200).json(data)

#
# Default routing
#

exports.defaultroute = defaultroute = express.Router()

#
# GET
# Default route, if none of above apply.
#
defaultroute.get '*', (req, res) ->
    msg = 'Bad request'
    serveErrorMessage(400, msg, res)