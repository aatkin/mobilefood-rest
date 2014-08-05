express = require 'express'
fs = require 'fs'
path = require 'path'
app = require './app'

serveErrorMessage = (error, msg, res) ->
    message = {
        status: error,
        message: msg
    }
    res.status(error).json(message)

#
# GET
# Logging route
#
exports.log = log = express.Router()

log.get '/log', (req, res) ->
    fs.readFile app.__LOGPATH, 'utf8', (err, data) ->
        if err
            msg = "Error happened while reading file"
            serveErrorMessage(404, msg, res)
        else
            res.type 'text/plain'
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
    restaurant = req.params.restaurant.toLowerCase() + path.sep
    filePath = app.__DIR + restaurant + 'current' + path.sep
    fs.readFile filePath, 'utf8', (err, data) ->
        if err
            msg = "Error happened while reading file - missing food list?"
            serveErrorMessage(404, msg, res)
        else
            res.status(200).json(data)

#
# GET
# Returns specified food list from file system as JSON.
#
restaurants.get '/:restaurant/:year/:week', (req, res) ->
    restaurant = req.params.restaurant.toLowerCase() + path.sep
    year = req.params.year + path.sep
    week = req.params.week + path.sep
    filePath = app.__DIR + restaurant + year + week
    fs.readFile filePath, 'utf8', (err, data) ->
        if err
            msg = "Error happened while reading file - missing food list?"
            serveErrorMessage(404, msg, res)
        else
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
    msg = "Bad request"
    serveErrorMessage(400, msg, res)