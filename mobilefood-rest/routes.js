var express = require('express');
var mongoClient = require('mongodb').MongoClient;

var mongo_address = require('./app').app.get('mongo_address');

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
exports.restaurants = restaurants = express.Router();

// Return the latest foodlist for a given chain-restaurant-combo

restaurants.get('/:chain/:restaurant/current', function(req, res, next) {
    var chain = req.params.chain.toLowerCase();
    var restaurant = req.params.restaurant.toLowerCase();
    try {
        mongoClient.connect(mongo_address, function(err, db) {
            var collection = db.collection('restaurant');
            collection
                .find(
                    {'restaurant_info.id': restaurant, 'parser_info.parser_name': chain},
                    {'_id': 0, 'restaurant_info.id': 0})
                .sort({'_id': -1})
                .toArray(function(err, restaurants) {
                    if (restaurants.length) {
                        res.set('Connection', 'close');
                        res.status(200).json(restaurants[0]);
                    } else {
                        console.log(
                            'Didn\'t find any records for ' + chain + '/' + restaurant);
                        res.set('Connection', 'close');
                        res.status(200).json({});
                    }
                    db.close();
                });
        });
    } catch (e) {
        console.error(e);
    }
});

// Return the foodlist for a given chain-restaurant and year-week -combo

restaurants.get('/:chain/:restaurant/:year/:week', function(req, res, next) {
    var chain = req.params.chain.toLowerCase();
    var restaurant = req.params.restaurant.toLowerCase();
    var year = parseInt(req.params.year, 10);
    var week = parseInt(req.params.week, 10);
    try {
        mongoClient.connect(mongo_address, function(err, db) {
            var collection = db.collection('restaurant');
            collection
                .find(
                    {
                        'restaurant_info.id': restaurant,
                        'parser_info.parser_name': chain,
                        'foodlist_date.year': year,
                        'foodlist_date.week_number': week
                    },
                    {'_id': 0, 'restaurant_info.id': 0})
                .sort({'_id': -1})
                .toArray(function(err, restaurants) {
                    if (restaurants.length) {
                        res.set('Connection', 'close');
                        res.status(200).json(restaurants[0]);
                    } else {
                        console.log(
                            'Didn\'t find any records for ' + chain + '/' + restaurant);
                        res.set('Connection', 'close');
                        res.status(200).json({});
                    }
                    db.close();
                });
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