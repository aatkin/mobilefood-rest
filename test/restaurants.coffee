fs = require 'fs'
path = require 'path'
express = require 'express'
request = require 'supertest'
mobilerest = require('../src/app.coffee')
app = require('../src/app.coffee').app
routes = require('../src/routes.coffee')

describe 'restaurants RESTful GET-requests', ->
    before (done) ->
        app.set('dir', 'test/testdata')
        app.use('/mobilerest', routes.log)
        app.use('/mobilerest', routes.restaurants)
        app.use('/', routes.defaultroute)
        mobilerest.start(4731)
        done()
    after (done) ->
        mobilerest.stop()
        done()
        
    describe 'undefined urls', ->
        it 'should return 400 given url /', (done) ->
            request(app)
                .get('/')
                .expect('Content-Type', /json/)
                .expect(400, done)
        it 'should return 400 given url \'\'', (done) ->
            request(app)
                .get('')
                .expect('Content-Type', /json/)
                .expect(400, done)
        it 'should return 400 given url /mobilerest/unica', (done) ->
            request(app)
                .get('/mobilerest/unica')
                .expect('Content-Type', /json/)
                .expect(400, done)
        it 'should return 400 given url /mobilerest/unica/food', (done) ->
            request(app)
                .get('/mobilerest/unica/food')
                .expect('Content-Type', /json/)
                .expect(400, done)
        it 'should return 400 given url /mobilerest/unica/3/food/ls', (done) ->
            request(app)
                .get('/mobilerest/unica/3/food/ls')
                .expect('Content-Type', /json/)
                .expect(400, done)

    describe 'restaurant urls, no files', ->
        it 'should return 404 given url /mobilerest/unica/current
            and no files to serve', (done) ->
                request(app)
                    .get('/mobilerest/unica/current')
                    .expect('Content-Type', /json/)
                    .expect(404, done)
        it 'should return 404 given url /mobilerest/unica/2014/34
            and no files to serve', (done) ->
                request(app)
                    .get('/mobilerest/unica/2014/34')
                    .expect('Content-Type', /json/)
                    .expect(404, done)

    describe 'restaurant urls, fake data', ->
        it 'should return 200 given url /mobilerest/unica/2014/33', (done) ->
            request(app)
                .get('/mobilerest/unica/2014/33')
                .expect('Content-Type', /json/)
                .expect(200, done)