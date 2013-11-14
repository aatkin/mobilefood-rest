var express = require('express');
var app = express();
var counter = 0;

var fs = require('fs')

app.get('/', function(req, res) {
	res.type('text/json'); // set content-type
	fs.readFile(req.query.restaurant + '.json', 'utf8', function(err, data) {
		if (err) {
			console.log(err);
			res.type('text/plain');
			res.send("ERROR 404: file not found")
		}
		res.json(data);
	});
	console.log('answered to request #' + ++counter);
});

app.listen(process.env.PORT || 4730);