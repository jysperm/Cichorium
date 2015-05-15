http = require 'http'

describe 'cichorium', ->
  describe '#constructor', ->
    it 'default route', (done) ->
      app = new Cichorium()

      test(app).get '/'
      .end (err, res) ->
        res.statusCode.should.be.equal 404
        res.text.should.be.equal 'Cannot GET /'
        done err

    it 'default error handling', (done) ->
      app = new Cichorium()

      app.use ->
        throw new Error 'Expected error'

      test(app).get '/'
      .end (err, res) ->
        res.statusCode.should.be.equal 500
        res.text.should.be.equal 'Expected error'
        done err

  describe '#use', ->
    it 'single middleware', (done) ->
      app = new Cichorium()

      app.use (req, res) ->
        res.send 'response content'

      test(app).get '/'
      .end (err, res) ->
        res.text.should.be.equal 'response content'
        done err

    it 'multiple middlewares', (done) ->
      app = new Cichorium()
      executed = []

      app.use (req, res) ->
        Q.delay(5).then ->
          executed.push 1

      app.use (req, res) ->
        executed.push 2
        res.send 'response content'

      app.use (req, res) ->
        executed.push 3

      test(app).get '/'
      .end (err, res) ->
        res.text.should.be.equal 'response content'
        executed.should.be.eql [1, 2, 3]
        done err

  describe '#use with prefix', (done) ->
    app = new Cichorium()

    before ->
      app.use '/user', (req, res) ->
        res.send 'user'

      app.use /^\/order/, (req, res) ->
        res.send 'order'

      app.use (req, res) ->
        res.send 'index'

    it 'GET /', (done) ->
      test(app).get '/'
      .end (err, res) ->
        res.text.should.be.equal 'index'
        done err

    it 'GET /user', (done) ->
      test(app).get '/user'
      .end (err, res) ->
        res.text.should.be.equal 'user'
        done err

    it 'GET /order', (done) ->
      test(app).get '/order'
      .end (err, res) ->
        res.text.should.be.equal 'order'
        done err

  describe '#method', ->
    app = new Cichorium()

    before ->
      app.get '/', (req, res) ->
        res.send 'get'

      app.post '/', (req, res) ->
        res.send 'post'

      app.put '/', (req, res) ->
        res.send 'put'

    it 'GET /', (done) ->
      test(app).get '/'
      .end (err, res) ->
        res.text.should.be.equal 'get'
        done err

    it 'POST /', (done) ->
      test(app).post '/'
      .end (err, res) ->
        res.text.should.be.equal 'post'
        done err

    it 'PUT /', (done) ->
      test(app).put '/'
      .end (err, res) ->
        res.text.should.be.equal 'put'
        done err

  describe '#listen', ->
    it 'on tcp port', (done) ->
      app = new Cichorium()

      app.get '/', (req, res) ->
        res.send 'index'

      app.listen 19876

      http.get 'http://127.0.0.1:19876', (res) ->
        res.statusCode.should.be.equal 200
        done()
