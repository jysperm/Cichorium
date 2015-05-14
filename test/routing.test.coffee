describe 'routing', ->
  describe 'handleRoute', ->
    it 'response is not finished', (done) ->
      app = new Cichorium()

      app.use (req, res) ->
        res.header 'X-Header', 'header'

      test(app).get '/'
      .end (err, res) ->
        res.headers['x-header'].should.be.equal 'header'
        done err

    it 'route is not Array or Function', (done) ->
      app = new Cichorium()

      app.pushRoute 'not a middleware'

      test(app).get '/'
      .end (err, res) ->
        res.text.should.be.equal 'Route is not Array or Function'
        done err

    it 'skip current route'

  describe 'errorHandling', ->
    it 'enter errorHandling when error'

    it 'resolve single err'

    it 'replace err if new error occurs'
