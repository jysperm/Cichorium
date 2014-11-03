describe 'cichorium', ->
  cichorium = null
  app = null
  agent = null

  it 'should can create app and listen', (done) ->
    cichorium = require '../index'

    app = cichorium()
    agent = supertest app

    app.use (req, res) ->
      res.end 'response content'

    app.listen 23431, done

  it 'should can handle request', (done) ->
    agent.get '/'
    .end (err, res) ->
      res.text.should.be.equal 'response content'
      done err
