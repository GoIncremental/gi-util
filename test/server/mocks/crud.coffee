exports.create = (body, callback) ->
  if body
    callback null, body
  else
    callback 'no body', null

exports.update = (id, json, callback) ->
  if id is 'InvalidId'
    callback 'Fail'
  else if json._id
    callback 'Fail - id not removed'
  else
    json._id = id
    callback null, json

exports.destroy = (id, callback) ->
  if id
    id.should.equal 'validId'
    callback()
  else
    callback 'no id'

exports.findById = (id, callback) ->
  if id
    if id is '111111111111111111111111'
      callback null, null
    else if id is 'validId'
      callback null, { _id: id}
    else
      callback 'invalid id'
  else
    callback 'no id'

exports.find = (options, callback) ->
  if options.max?
    options.max.should.be.above -1
    result = []
    if options.max > 0
      result = ({some: 'toto'} for h in [1..options.max])
    if options.max is 666
      callback 'The Devil'
    else
      callback null, result
  else
    callback null, ({some: 'toto'} for h in [1..20])
