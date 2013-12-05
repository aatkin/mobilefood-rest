express = require 'express'
fs = require 'fs'

counter = 0

DIR = JSON.parse(fs.readFileSync 'config.json').dir
console.log 'Current output dir: ' + DIR

app = express()

app.get '/', (req, res) ->
	# retrieve query parameters
	restaurant = req.query.restaurant
	year = req.query.year
	week = req.query.week
	filepath = DIR + year + '_w' + week + '_' + restaurant + '.json'
	
	fs.readFile filepath, 'utf8', (err, data) ->
		if err
			console.log err
			res.type 'text/plain'
			res.send 'ERROR 404: file not found'
			return
		res.type 'text/json'
		res.send data
	console.log 'Client queried for: ' + JSON.stringify(req.query)
	console.log 'Answered to request #' + (++counter)

app.listen process.env.PORT || 4730