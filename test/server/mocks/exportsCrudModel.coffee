expect = require('chai').expect

module.exports = (name, model, overrides) ->
  describe 'Standard Crud', ->

    it "name: #{name}", (done) ->
      expect(model.name).to.equal name
      done()

    if not overrides?.find
      it 'find: function(options, callback) -> (err, [obj])', (done) ->
        expect(model).to.have.property 'find', 'crudModel find'
        done()

    if not overrides?.findById
      it 'findById: function(id, systemId, callback) -> (err, obj)', (done) ->
        expect(model).to.have.property 'findById', 'crudModel findById'
        done()

    if not overrides?.findOne
      it 'findOne: function(query, callback) -> (err, obj)', (done) ->
        expect(model).to.have.property 'findOne', 'crudModel findOne'
        done()
    if not overrides?.findOneBy
      it 'findOneBy: function(key, value, systemId, callback) -> (err, obj)'
      , (done) ->
        expect(model).to.have.property 'findOneBy', 'crudModel findOneBy'
        done()

    if not overrides?.create
      it 'create: function(json, callback) -> (err, obj)', (done) ->
        expect(model).to.have.property 'create', 'crudModel create'
        done()

    if not overrides?.update
      it 'update: function(id, json, callback) -> (err, obj)', (done) ->
        expect(model).to.have.property 'update', 'crudModel update'
        done()

    if not overrides?.destroy
      it 'destroy: function(id, systemId, callback) -> (err)', (done) ->
        expect(model).to.have.property 'destroy', 'crudModel destroy'
        done()