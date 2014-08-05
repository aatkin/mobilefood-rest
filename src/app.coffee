express = require 'express'
fs = require 'fs'
path = require 'path'
routes = require './routes'
argv = app = configfile = logfile = dir = null

exports.init = init = (config) ->
    try
        configfile = argv?.config || config?.configfile || 'config.json'
        logfile = argv?.log || config?.logfile ||
            JSON.parse(fs.readFileSync(configfile)).logfile
        dir = argv?.dir || config?.dir ||
            JSON.parse(fs.readFileSync(configfile)).dir
        app.set('configfile', configfile)
        app.set('logfile', logfile)
        app.set('dir', dir)
        # app.enable 'trust proxy'
        app.use('/mobilerest', routes.log)
        app.use('/mobilerest', routes.restaurants)
        app.use('/', routes.defaultroute)
    catch e
        console.log e
        process.exit(1)

exports.start = start = (p) ->
    if app
        port = p || argv.port || process.env.PORT || 4730
        app.listen port
        console.log "listening on #{port}"

exports.stop = stop = ->
    if app
        app.close
        app = argv = config = log = dir = null
        console.log "closing server now"

exports.app = app = express()

# main
if not module.parent
    argv = require('minimist')(process.argv.slice(2))
    init()
    start()
