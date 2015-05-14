describe 'response', ->
  describe '#header', ->
    it 'set single header', (done) ->
      app = new Cichorium()

      app.use (req, res) ->
        res.header 'X-Header', 'value'
        res.send()

      test(app).get '/'
      .end (err, res) ->
        res.headers['x-header'].should.be.equal 'value'
        done err

    it 'set multi headers as object', (done) ->
      app = new Cichorium()

      app.use (req, res) ->
        res.header
          'X-1': 'header1'
          'X-2': 'header2'
        res.send()

      test(app).get '/'
      .end (err, res) ->
        res.headers['x-1'].should.be.equal 'header1'
        res.headers['x-2'].should.be.equal 'header2'
        done err

  describe '#send', ->
    it 'status and data', (done) ->
      app = new Cichorium()

      app.use (req, res) ->
        res.send 201, 'new item'

      test(app).get '/'
      .expect 201
      .end (err, res) ->
        res.text.should.be.equal 'new item'
        done err

    it 'status only', (done) ->
      app = new Cichorium()

      app.use (req, res) ->
        res.send 404

      test(app).get '/'
      .expect 404
      .end done

    it 'data only', (done) ->
      app = new Cichorium()

      app.use (req, res) ->
        res.send 'data'

      test(app).get '/'
      .end (err, res) ->
        res.text.should.be.equal 'data'
        done err

    it 'no data', (done) ->
      app = new Cichorium()

      app.use (req, res) ->
        res.send()

      test(app).get('/').end done

  describe '#json', ->
    it 'status and object', (done) ->
      app = new Cichorium()

      app.use (req, res) ->
        res.json 500, error: 'unknown'

      test(app).get '/'
      .expect 500
      .end (err, res) ->
        res.headers['content-type'].should.match /json/
        res.body.error.should.be.equal 'unknown'
        done err

    it 'object only', (done) ->
      app = new Cichorium()

      app.use (req, res) ->
        res.json result: 'success'

      test(app).get '/'
      .expect 200
      .end (err, res) ->
        res.body.result.should.be.equal 'success'
        done err

  describe '#redirect', ->
    it 'url only', (done) ->
      app = new Cichorium()

      app.use (req, res) ->
        res.redirect '/account'

      test(app).get '/'
      .expect 302
      .end (err, res) ->
        res.headers.location.should.be.equal '/account'
        done err
