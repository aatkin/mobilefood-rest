request = require 'supertest'
mobilerest = require('../src/app.coffee')
app = require('../src/app.coffee').app
routes = require('../src/routes.coffee')

describe 'undefined urls', ->
    before (done) ->
        app.use('/mobilerest', routes.log)
        app.use('/mobilerest', routes.restaurants)
        app.use('/', routes.defaultroute)
        mobilerest.start()
        done()
    after (done) ->
        mobilerest.stop()
        done()
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