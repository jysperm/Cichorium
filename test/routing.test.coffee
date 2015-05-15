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

    it 'skip current route', (done) ->
      app = new Cichorium()

      executed = []

      app.use (req, res) ->
        app.nextRoute()
        executed.push 1
      , (req, res) ->
        executed.push 2

      app.use (req, res) ->
        executed.push 3

      test(app).get '/'
      .end (err) ->
        executed.should.be.eql [3]
        done err

  describe 'errorHandling', ->
    it 'enter errorHandling when error', (done) ->
      app = new Cichorium()

      executed = []

      app.use (req, res) ->
        throw new Error 'Expected error'

      app.catch (req, res, err) ->
        executed.push 1
        err.message.should.be.equal 'Expected error'

      app.catch (req, res, err) ->
        executed.push 2
        err.message.should.be.equal 'Expected error'

      test(app).get '/'
      .end (err) ->
        executed.should.be.eql [1, 2]
        done err

    it 'resolve single err', (done) ->
      app = new Cichorium()

      executed = []

      app.use (req, res) ->
        throw new Error 'Expected error'
        executed.push 1

      app.catch (req, res, err) ->
        executed.push 2
        err.message.should.be.equal 'Expected error'
        app.errorResolved()

      app.catch (req, res, err) ->
        executed.push 3

      test(app).get '/'
      .end (err) ->
        executed.should.be.eql [2]
        done err

    it 'replace err if new error occurs', (done) ->
      app = new Cichorium()

      executed = []

      app.use (req, res) ->
        executed.push 1
        throw new Error 'Error1'

      app.catch (req, res, err) ->
        executed.push 2
        err.message.should.be.equal 'Error1'
        throw new Error 'Error2'

      app.catch (req, res, err) ->
        executed.push 3
        err.message.should.be.equal 'Error2'
        app.errorResolved()

      app.catch (req, res, err) ->
        executed.push 4
        err.message.should.be.equal 'Error1'
        app.errorResolved()

      app.catch (req, res, err) ->
        executed.push 5

      test(app).get '/'
      .end (err) ->
        executed.should.be.eql [1, 2, 3, 4]
        done err
