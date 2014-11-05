describe 'response', ->
  cichorium = require '../index'

  describe 'header', ->
    it 'should success with single header', (done) ->
      app = cichorium()

      app.use (req, res) ->
        res.header 'X-Header', 'value'
        res.end()

      supertest app
      .get '/'
      .end (err, res) ->
        res.headers['x-header'].should.be.equal 'value'
        done err

    it 'should success with multi headers', (done) ->
      app = cichorium()

      app.use (req, res) ->
        res.header
          'X-1': 'header1'
          'X-2': 'header2'
        res.end()

      supertest app
      .get '/'
      .end (err, res) ->
        res.headers['x-1'].should.be.equal 'header1'
        res.headers['x-2'].should.be.equal 'header2'
        done err

  describe 'send', ->
    it 'should success', (done) ->
      app = cichorium()

      app.use (req, res) ->
        res.send 200, 'data'

      supertest app
      .get '/'
      .expect 200
      .end (err, res) ->
        res.text.should.be.equal 'data'
        done err

    it 'should success with status only', (done) ->
      app = cichorium()

      app.use (req, res) ->
        res.send 404

      supertest app
      .get '/'
      .expect 404
      .end done

    it 'should success with data only', (done) ->
      app = cichorium()

      app.use (req, res) ->
        res.send 'data'

      supertest app
      .get '/'
      .end (err, res) ->
        res.text.should.be.equal 'data'
        done err

    it 'should success with no data', (done) ->
      app = cichorium()

      app.use (req, res) ->
        res.send()

      supertest app
      .get '/'
      .end done

  describe 'json', ->
    it 'should success', (done) ->
      app = cichorium()

      app.use (req, res) ->
        res.json 500, error: 'unknown'

      supertest app
      .get '/'
      .expect 500
      .end (err, res) ->
        res.headers['content-type'].should.match /json/
        res.body.error.should.be.equal 'unknown'
        done err

    it 'should success with object only', (done) ->
      app = cichorium()

      app.use (req, res) ->
        res.json result: 'success'

      supertest app
      .get '/'
      .expect 200
      .end (err, res) ->
        res.body.result.should.be.equal 'success'
        done err

  describe 'redirect', ->
    it 'should success', (done) ->
      app = cichorium()

      app.use (req, res) ->
        res.redirect '/account'

      supertest app
      .get '/'
      .expect 302
      .end (err, res) ->
        res.headers.location.should.be.equal '/account'
        done err
