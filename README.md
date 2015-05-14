# Cichorium
Routing framework based on Promise using CoffeeScript.

## Usage

    Cichorium = require 'cichorium'
    app = new Cichorium()

    app.use '/account', (req, res) ->
      Account.authenticate(req.cookies['token']).then (account) ->
        req.account = account

    app.get '/account/dashboard', (req, res) ->
      res.json 200,
        hello: req.account?.name

    app.catch (err) ->
      res.send 500, err.message

    app.listen 3000

## TODO

* param in url, prepare of param
* render
* send and render with promise
