expect = require('chai').expect

module.exports = (name, model, overrides) ->
  describe 'Standard Crud', ->

    it "name: #{name}", (done) ->
      expect(model.name).to.equal name
      done()

    it 'find: function(options, callback) -> (err, [obj])', (done) ->
      expect(model).to.have.property 'find', 'crudModel find'
      done()

    it 'findById: function(id, systemId, callback) -> (err, obj)', (done) ->
      expect(model).to.have.property 'findById', 'crudModel findById'
      done()

    it 'findOne: function(query, callback) -> (err, obj)', (done) ->
      expect(model).to.have.property 'findOne', 'crudModel findOne'
      done()

    it 'findOneBy: function(key, value, systemId, callback) -> (err, obj)'
    , (done) ->
      expect(model).to.have.property 'findOneBy', 'crudModel findOneBy'
      done()

    it 'create: function(json, callback) -> (err, obj)', (done) ->
      expect(model).to.have.property 'create', 'crudModel create'
      done()

    if not overrides?.update
      it 'update: function(id, json, callback) -> (err, obj)', (done) ->
        expect(model).to.have.property 'update', 'crudModel update'
        done()

    it 'destroy: function(id, systemId, callback) -> (err)', (done) ->
      expect(model).to.have.property 'destroy', 'crudModel destroy'
      done()