expect = require('chai').expect
sinon = require 'sinon'
path = require 'path'
dir =  path.normalize __dirname + '../../../../../../../server'

module.exports = () ->
  @When /^the rest module is required$/, (next) ->
    delete require.cache[require.resolve(dir + '/common/rest')]
    @rest = require dir + '/common/rest'
    next()

  @Given /^an express app$/, (next) ->
    @app =
      get: sinon.spy()
      post: sinon.spy()
      put: sinon.spy()
      del: sinon.spy()
    next()

  @Given /^some middleware$/, (next) ->
    @middleware = 'middleware'
    next()

  @Given /^a crudController$/, (next) ->
    @controller =
      index: 'crudControllerIndex'
    next()

  @Given /^a result object$/, (next) ->
    @res =
      json: sinon.spy()
    next()

  @Given /^a terminal request handler spied upon$/, (next) ->
    @rest._respondIfOk = 'stubbedmethod'
    next()

  @Then /^it exports a (.*) function$/, (functionName, next) ->
    expect(@rest, 'does not export ' + functionName)
    .to.have.ownProperty functionName
    next()

  @Then /^it exports a private (.*) function$/, (functionName, next) ->
    expect(@rest, 'does not export _' + functionName)
    .to.have.ownProperty '_' + functionName
    next()

  @Given ///^the\srouteResourceFunction\sis\scalled\swith\s\[(.*)\],\sapp
  ,\smiddleware\sand\scontroller$///
  , (name, next) ->
    @rest.routeResource name, @app, @middleware, @controller
    next()

  @Then /^(.*) (.*) is a valid route$/, (verb, url, next) ->
    expect(@app[verb.toLowerCase()].calledWith(url)
    , verb + ' ' + url + ' requests are not called with ' + url)
    .to.be.true
    next()

  @Then /^requests to (.*) (.*) are passed through middleware$/
  , (verb, url, next) ->
    expect(@app[verb.toLowerCase()].calledWith(url, @middleware)
    , verb + ' ' + url + ' requests not passed to the given middleware')
    .to.be.true
    next()

  @Then /^requests to (.*) (.*) are handled by controller method (.*)$/
  , (verb, url, method, next) ->
    expect(@app[verb.toLowerCase()].calledWith(
      url, @middleware, @controller[method])
    , verb + ' ' + url + ' requests not passed to controller method ' + method)
    .to.be.true
    next()

  @Then /^requests to (.*) (.*) are terminated by (.*)$/
  , (verb, url, terminalHandler, next) ->
    expect(@app[verb.toLowerCase()].calledWith(
      url, @middleware, sinon.match.any,  @rest[terminalHandler])
    , verb + ' ' + url + ' requests not terminated by ' + terminalHandler)
    .to.be.true
    next()

  @Given /^the response has a gi result$/, (next) ->
    @res.giResult = 'a gi result'
    next()

  @Given /^the response has no gi result$/, (next) ->
    @res.giResult = null
    next()

  @When /^_respondIfOk is called$/, (next) ->
    @rest._respondIfOk @req, @res
    next()

  @Then /^the response is ended with (\d+) (?:OK|server error)$/
  , (code, next) ->
    expect(@res.json.calledWith(parseInt code)
    , "res.json was not called with " + code
    ).to.be.true
    next()

  @Then /^the response returns the res\.giResult as json$/, (next) ->
    expect(@res.json.calledWith(sinon.match.any, @res.giResult)
    , "res.json was not called with message " + @res.giResult
    ).to.be.true
    next()

  @Then /^the response returns message: (.*) as json$/, (msg, next) ->
    expect(@res.json.calledWith(sinon.match.any, {message: msg})
    , "res.json was not called with message " + msg
    ).to.be.true
    next()