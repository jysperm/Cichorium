## Cichorium
Just a copy of express in coffee script.

### Usage

    cichorium = require 'cichorium'
    app = cichorium()

    app.get '/', (req, res) ->
      res.json 200,
        hello: 'world'

    app.use (req, res) ->
      res.send 404, 'Not found'

    app.listen 3000

### Todo

* param in url, prepare of param
* custom error handler
