describe 'application', ->
  cichorium = require '../index'

  describe 'use', ->
    it 'should work with single fn', (done) ->
      app = cichorium()

      app.use (req, res) ->
        res.end 'response content'

      supertest app
      .get '/'
      .end (err, res) ->
        res.text.should.be.equal 'response content'
        done err

    it 'should work with multi fn', (done) ->
      app = cichorium()
      fn_log = []

      app.use (req, res, next) ->
        fn_log.push 'fn1'
        next()

      app.use (req, res, next) ->
        fn_log.push 'fn2'
        res.end 'response content'
        next()

      app.use (req, res, next) ->
        fn_log.push 'fn3'
        next()

      supertest app
      .get '/'
      .end (err, res) ->
        res.text.should.be.equal 'response content'
        fn_log.should.be.eql ['fn1', 'fn2', 'fn3']
        done err

    describe 'should work with prefix', ->
      app = cichorium()
      agent = supertest.agent app

      before ->
        app.use '/p', (req, res) ->
          res.end 'sub path'

        app.use (req, res) ->
          res.end 'index'

      it 'GET /p', (done) ->
        agent.get '/p'
        .end (err, res) ->
          res.text.should.be.equal 'sub path'
          done err

      it 'GET /', (done) ->
        agent.get '/'
        .end (err, res) ->
          res.text.should.be.equal 'index'
          done err

  describe 'useMethod', ->
    describe 'should work with single fn', ->
      app = cichorium()
      agent = supertest.agent app

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
      app = cichorium()
      agent = supertest.agent app

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
