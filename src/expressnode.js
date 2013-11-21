var express = require('express');
var app = express();
var counter = 0;

var fs = require('fs')
var DIR = JSON.parse(fs.readFileSync('config.json')).dir;
console.log("Current output dir: " + DIR);

app.get('/', function(req, res) {
	res.type('text/json'); // set content-type
	var restaurant = req.query.restaurant;
	var year = req.query.year;
	var week = req.query.week;
	fs.readFile(DIR + year + "_w" + week + "_" + restaurant + '.json', 'utf8', function(err, data) {
		if (err) {
			console.log(err);
			res.type('text/plain');
			res.send("ERROR 404: file not found");
		}
		res.send(data);
	});
	console.log("Client queried for: " + JSON.stringify(req.query));
	console.log('answered to request #' + ++counter);
});

app.listen(process.env.PORT || 4730);