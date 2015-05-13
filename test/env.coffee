process.env.NODE_ENV = 'test'

global._ = require 'lodash'
global.fs = require 'fs'
global.Q = require 'q'
global.chai = require 'chai'
global.supertest = require 'supertest'
global.Cichorium = require '../lib/cichorium'
global.expect = chai.expect

global.test = (cichorium) ->
  return supertest cichorium.handle.bind(cichorium)

chai.should()
chai.config.includeStack = true
