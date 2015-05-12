process.env.NODE_ENV = 'test'

global._ = require 'lodash'
global.fs = require 'fs'
global.chai = require 'chai'
global.supertest = require 'supertest'
global.cichorium = require '../lib/cichorium'
global.expect = chai.expect

chai.should()
chai.config.includeStack = true
