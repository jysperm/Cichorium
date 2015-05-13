describe 'request', ->
  describe '#ip', ->
    it 'should be loopback address', (done) ->
      app = new Cichorium()

      app.use (req, res) ->
        expect(req.ip() in ['127.0.0.1', '::ffff:127.0.0.1']).to.be.ok
        res.send()

      test(app).get('/').end done
