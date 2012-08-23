require './helper'
rest = require '../rest-lite'

describe "Resource", ->
  beforeEach ->
    @service = rest.service 'service.com'
    @units   = @service.resource 'units'

  it "should get one", (done) ->
    @service.stub 'get', '/units/probe', (err, data, options, callback) ->
      expect(data).to.eql {profile: 'short'}
      callback null, {id: 'probe', name: 'Probe'}

    @units.get 'probe', {profile: 'short'}, (err, data) ->
      expect(data).to.eql {id: 'probe', name: 'Probe'}
      done()

  it 'should get collection', (done) ->
    @service.stub 'get', '/units', (err, data, options, callback) ->
      expect(data).to.eql {page: 1}
      callback null, [{id: 'probe', name: 'Probe'}]

    @units.get {page: 1}, (err, data) ->
      expect(data).to.eql [{id: 'probe', name: 'Probe'}]
      done()

  it "should create", (done) ->
    @service.stub 'post', '/units', (err, data, options, callback) ->
      expect(data).to.eql name: 'Probe'
      callback null, {id: 'probe'}

    @units.create name: 'Probe', (err, data) ->
      expect(data).to.eql {id: 'probe'}
      done()

  it "should update", (done) ->
    @service.stub 'put', '/units/probe', (err, data, options, callback) ->
      expect(data).to.eql name: 'Probe'
      callback null, {result: 'ok'}

    @units.update 'probe', name: 'Probe', (err, data) ->
      expect(data).to.eql {result: 'ok'}
      done()

  it "should delete", (done) ->
    @service.stub 'delete', '/units/probe', (err, data, options, callback) ->
      expect(data).to.eql safe: true
      callback null, {result: 'ok'}

    @units.delete 'probe', {safe: true}, (err, data) ->
      expect(data).to.eql {result: 'ok'}
      done()

  it 'should call method on resource', (done) ->
    @service.stub 'get', '/units/count', (err, data, options, callback) ->
      expect(data).to.eql {race: 'Protoss'}
      callback null, 10

    @units.call 'get', 'count', {race: 'Protoss'}, (err, data) ->
      expect(data).to.be 10
      done()

  it 'should call method on element', (done) ->
    @service.stub 'get', '/units/probe/history', (err, data, options, callback) ->
      expect(data).to.eql {size: 1}
      callback null, {state: 'alive'}

    @units.call 'get', 'probe', 'history', {size: 1}, (err, data) ->
      expect(data).to.eql {state: 'alive'}
      done()