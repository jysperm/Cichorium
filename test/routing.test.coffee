describe 'routing', ->
  describe 'handleRoute', ->
    it 'response is not end', (done) ->
      app = new Cichorium()

      app.use (req, res) ->
        res.header 'X-Header', 'header'

      test(app).get '/'
      .end (err, res) ->
        res.headers['x-header'].should.be.equal 'header'
        done err

    it 'route is not Array or Function'

    it 'skip current route'

  describe 'errorHandling', ->
    it 'enter errorHandling when error'

    it 'replace err if new error occurs'

    it 'custom error handler'

    it 'custom error handler and resolve err'
