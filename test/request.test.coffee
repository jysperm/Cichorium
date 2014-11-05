describe 'request', ->
  cichorium = require '../index'

  describe 'param', ->
    it 'pending'

  describe 'ip', ->
    it 'should be loopback address', (done) ->
      app = cichorium()

      app.use (req, res) ->
        expect(
          req.ip == '127.0.0.1' or
          req.ip == '::ffff:127.0.0.1'
        ).to.be.ok
        res.end()

      supertest app
      .get '/'
      .end done
