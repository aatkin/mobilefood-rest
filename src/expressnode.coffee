express = require 'express'
app = express()
counter = 0

fs = require 'fs'
DIR = JSON.parse(fs.readFileSync 'config.json').dir
console.log 'Current output dir: ' + DIR

app.get '/', (req, res) ->
	# set content-type
	res.type 'text/json'
	# retrieve query parameters
	restaurant = req.query.restaurant
	year = req.query.year
	week = req.query.week
	fs.readFile DIR+year+'_w'+week+'_'+restaurant+'.json', 'utf8', (err, data) ->
		if err
			console.log err
			res.type 'text/plain'
			res.send 'ERROR 404: file not found'
		res.send data
	console.log 'Client queried for: ' + JSON.stringify req.query
	console.log 'Answered to request #' + (++counter)

app.listen process.env.PORT || 4730