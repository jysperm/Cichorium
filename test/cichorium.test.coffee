describe 'cichorium', ->
  describe '#constructor', ->
    it 'default routes', (done) ->
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
      executed_middlewares = []

      app.use (req, res) ->
        Q.delay(5).then ->
          executed_middlewares.push 1

      app.use (req, res) ->
        executed_middlewares.push 2
        res.send 'response content'

      app.use (req, res) ->
        executed_middlewares.push 3

      test(app).get '/'
      .end (err, res) ->
        res.text.should.be.equal 'response content'
        executed_middlewares.should.be.eql [1, 2, 3]
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

  describe.skip 'useMethod', ->
    describe 'should work with single fn', ->
      before ->
        app.get (req, res) ->
          res.end 'get method'

        app.post (req, res) ->
          res.end 'post method'

      it 'GET /', (done) ->
        agent.get '/'
        .end (err, res) ->
          res.text.should.be.equal 'get method'
          done err

      it 'POST /', (done) ->
        agent.post '/'
        .end (err, res) ->
          res.text.should.be.equal 'post method'
          done err

    describe 'should work with prefix', ->
      before ->
        app.get '/path', (req, res) ->
          res.end 'get of /path'

        app.get '/', (req, res) ->
          res.end 'get of /'

        app.post '/path', (req, res) ->
          res.end 'post of /path'

      it 'GET /path', (done) ->
        agent.get '/path'
        .end (err, res) ->
          res.text.should.be.equal 'get of /path'
          done err

      it 'GET /', (done) ->
        agent.get '/'
        .end (err, res) ->
          res.text.should.be.equal 'get of /'
          done err

      it 'POST /path', (done) ->
        agent.post '/path'
        .end (err, res) ->
          res.text.should.be.equal 'post of /path'
          done err

  describe.skip 'handle', ->
    it 'should break when error', (done) ->
      app = cichorium()
      agent = supertest.agent app

      app.use (req, res, next) ->
        next new Error 'err!'

      app.use (req, res, next) ->
        req.should.not.exist

      agent.get '/'
      .expect 500
      .end (err, res) ->
        res.text.should.be.equal '[Error: err!]'
        done err

    it 'should catch exception thrown in middleware', (done) ->
      app = cichorium()
      agent = supertest.agent app

      app.use (req, res, next) ->
        throw new Error 'err!'

      app.use (req, res, next) ->
        req.should.not.exist

      agent.get '/'
      .expect 500
      .end (err, res) ->
        res.text.should.be.equal '[Error: err!]'
        done err

    it 'should 404 when no middleware matched', (done) ->
      app = cichorium()
      agent = supertest.agent app

      app.use '/p', (req, res) ->
        res.send 'sub path'

      agent.get '/'
      .expect 404
      .end (err, res) ->
        res.text.should.be.equal 'Cannot GET /\n'
        done err

    it 'should end request if middleware did not', (done) ->
      app = cichorium()
      agent = supertest.agent app

      app.use (req, res, next) ->
        res.header 'X-Header', 'value'
        next()

      agent.get '/'
      .expect 200
      .end (err, res) ->
        res.headers['x-header'].should.be.equal 'value'
        done err
