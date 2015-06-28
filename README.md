# Cichorium
Routing framework based on Promise using CoffeeScript.

Cichorium has a Route Table and an Error Route Table. The route table is an array containing some of:

* a child route table (Array)
* a middleware `(req, res) -> Promise`

The middleware will be executed sequentially. If the middleware return a Promise, Cichorium will execute next middleware after the promise is fulfilled.

Inside middleware, you can use `nextRoute` skip other middlewares on this route, enter next route on parent level directly. Conditional-route are implemented by this feature, like match HTTP method or URL prefix.

If middleware throws a Exception or Promise is rejected, Cichorium will enter error handling, middleware in error route table will be executed sequentially. if new exception has be thrown, the new exception will replace the original.

Error middleware can use `errorResolved` to resolve exception, the other error middleware will not be executed. Unless there are more than one exception, the last exception will be passed to next error middleware.

## Usage

    Cichorium = require 'cichorium'
    app = new Cichorium()

    app.use '/account', (req, res) ->
      Account.authenticate(req.headers['x-token']).then (account) ->
        req.account = account

    app.get '/account/dashboard', (req, res) ->
      res.json 200,
        hello: req.account?.name

    app.catch (err) ->
      res.send 500, err.message

    app.listen 3000
