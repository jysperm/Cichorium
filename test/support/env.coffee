process.env.NODE_ENV = 'test'

if process.env.COV_TEST == 'true'
  require('coffee-coverage').register
    path: 'relative'
    basePath: "#{__dirname}/../.."
    exclude: ['test', 'node_modules', '.git']

global._ = require 'underscore'
global.fs = require 'fs'
global.chai = require 'chai'
global.supertest = require 'supertest'

global.expect = chai.expect

chai.should()
chai.config.includeStack = true
