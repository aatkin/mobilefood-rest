var express = require('express');

var db = require('./app').app.get('db');

var serveErrorMsg = function(error, msg, res) {
    var message = {
        status: error,
        message: msg
    };
    res.set('Connection', 'close');
    res.status(error).json(message);
};

//
// Restaurant routing
//
exports.foods = foods = express.Router();

// Return the latest foodlist for a given chain-restaurant-combo

foods.get('/chain/:chain/restaurant/:restaurant/current', function(req, res, next) {
    var start = new Date();
    var chain = req.params.chain.toLowerCase();
    var restaurant = req.params.restaurant.toLowerCase();
    var filter = {
        '_id': 0,
        'foodlist_info.id': 0,
        'debug': 0
    };
    if (req.query.debug && req.query.debug.toLowerCase() == 'true') delete filter.debug;
    try {
        var collection = db.collection('foods');
        collection
            .find(
                {'foodlist_info.id': restaurant, 'foodlist_info.chain': chain},
                filter)
            .sort({'_id': -1})
            .toArray(function(err, restaurants) {
                if (restaurants.length) {
                    res.set('Connection', 'close');
                    if (!filter.debug) {
                        var end = new Date() - start;
                        restaurants[0].debug.process_time = String(end) + 'ms';
                    }
                    res.status(200).json(restaurants[0]);
                } else {
                    console.log(
                        'Didn\'t find any records for ' + chain + '/' + restaurant);
                    res.set('Connection', 'close');
                    res.status(200).json({});
                }
            });
    } catch (e) {
        console.error(e);
    }
});

// Return the foodlist for a given chain-restaurant and year-week -combo

foods.get('/chain/:chain/restaurant/:restaurant/:year/:week', function(req, res, next) {
    var start = new Date();
    var chain = req.params.chain.toLowerCase();
    var restaurant = req.params.restaurant.toLowerCase();
    var year = parseInt(req.params.year, 10);
    var week = parseInt(req.params.week, 10);
    var filter = {
        '_id': 0,
        'foodlist_info.id': 0,
        'debug': 0
    };
    if (req.query.debug && req.query.debug.toLowerCase() == 'true') delete filter.debug;
    try {
        var collection = db.collection('foods');
        collection
            .find(
                {
                    'foodlist_info.id': restaurant,
                    'foodlist_info.chain': chain,
                    'foodlist_info.year': year,
                    'foodlist_info.week_number': week
                },
                filter)
            .sort({'_id': -1})
            .toArray(function(err, restaurants) {
                if (restaurants.length) {
                    res.set('Connection', 'close');
                    if (!filter.debug) {
                        var end = new Date() - start;
                        restaurants[0].debug.process_time = String(end) + 'ms';
                    }
                    res.status(200).json(restaurants[0]);
                } else {
                    console.log(
                        'Didn\'t find any records for ' + chain + '/' + restaurant);
                    res.set('Connection', 'close');
                    res.status(200).json({});
                }
            });
    } catch (e) {
        console.error(e);
    }
});

//
// Info routing
//
exports.info = info = express.Router();

// Return restaurant information

info.get('/chain/:chain/restaurant/:restaurant', function(req, res, next) {
    var start = new Date();
    var chain = req.params.chain.toLowerCase();
    var restaurant = req.params.restaurant.toLowerCase();
    var filter = {
        '_id': 0,
        'restaurant_info.id': 0,
        'debug': 0
    };
    if (req.query.debug && req.query.debug.toLowerCase() == 'true') delete filter.debug;
    try {
        var collection = db.collection('info');
        collection
            .find(
                {
                    'restaurant_info.id': restaurant,
                    'restaurant_info.chain': chain
                },
                filter)
            .toArray(function(err, info) {
                if (info.length) {
                    res.set('Connection', 'close');
                    if (!filter.debug) {
                        var end = new Date() - start;
                        info[0].debug.process_time = String(end) + 'ms';
                    }
                    res.status(200).json(info[0]);
                } else {
                    console.log(
                        'Didn\'t find any records for ' + chain + '/' + restaurant);
                    res.set('Connection', 'close');
                    res.status(200).json({});
                }
            });
    } catch (e) {
        console.error(e);
    }
});

//
// Default routing
//
exports.defaultroute = defaultroute = express.Router();

defaultroute.get('*', function(req, res, next) {
    var msg = 'Bad request';
    serveErrorMsg(400, msg, res);
    next();
});