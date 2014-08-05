express = require 'express'
fs = require 'fs'
path = require 'path'
routes = require './routes'
argv = app = __CONFIG = __LOGPATH = __DIR = null

exports.init = init = ->
    try
        exports.__CONFIG = __CONFIG = argv.config || 'config.json'
        exports.__LOGPATH = __LOGPATH = argv.log ||
            JSON.parse(fs.readFileSync(__CONFIG)).logdir
        exports.__DIR = __DIR = argv.dir ||
            JSON.parse(fs.readFileSync(__CONFIG)).dir
        console.log "exports.__CONFIG: #{exports.__CONFIG}, exports.__LOGPATH:
            #{exports.__LOGPATH}, exports.__DIR: #{exports.__DIR}"
        # app.enable 'trust proxy'
        app.use('/mobilerest', routes.log)
        app.use('/mobilerest', routes.restaurants)
        app.use('/', routes.defaultroute)
    catch e
        console.log e
        process.exit(1)

exports.start = start = ->
    port = argv.port || process.env.PORT || 4730
    app.listen port
    console.log "listening on #{port}"

exports.stop = stop = ->
    if app
        app.close
        app = argv = __CONFIG = __LOGPATH = __DIR = null
        console.log "closing server now"

exports.app = app = express()
exports.argv = argv = require('minimist')(process.argv.slice(2))

# main
if not module.parent
    init()
    start()
