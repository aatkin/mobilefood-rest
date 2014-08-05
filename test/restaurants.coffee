express = require 'express'
request = require 'supertest'
mobilerest = require('../src/app.coffee')
app = require('../src/app.coffee').app
routes = require('../src/routes.coffee')

before (done) ->
    app.use(express.static('./'))
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
    it 'should return 400 given url /mobilerest/unica', (done) ->
        request(app)
            .get('/mobilerest/unica')
            .expect('Content-Type', /json/)
            .expect(400, done)

describe 'restaurant urls', ->
    it 'should return 404 given url /mobilerest/unica/current
        and no files to serve', (done) ->
            request(app)
                .get('/mobilerest/unica/current')
                .expect('Content-Type', /json/)
                .expect(404, done)