Feature: gint.common.rest
  Scenario: Public Exports routeResource()
    When the rest module is required
    Then it exports a routeResource function

  Scenario: Private Exports respondIfOk()
    When the rest module is required
    Then it exports a private respondIfOk function
  
Feature: route a Resource with specified Middleware
  if I call routeResource(name, app, middleware, controller) 
  with specified middleware, then it is used before the 
  controller routes
  Background:
    Given an express app
    And some middleware
    And a crudController
    When the rest module is required
    And a terminal request handler spied upon

  Scenario: Calling routeResource defines api routes
    When the routeResourceFunction is called with [aResource], app, middleware and controller
    Then GET /api/aResource is a valid route
    And POST /api/aResource is a valid route
    And GET /api/aResource/count is a valid route
    And PUT /api/aResource/:id is a valid route
    And GET /api/aResource/:id is a valid route
    And DEL /api/aResource/:id is a valid route

  Scenario: middleware is passed to each route
    When the routeResourceFunction is called with [aResource], app, middleware and controller
    Then requests to GET /api/aResource are passed through middleware
    And requests to POST /api/aResource are passed through middleware
    And requests to GET /api/aResource/count are passed through middleware
    And requests to PUT /api/aResource/:id are passed through middleware
    And requests to GET /api/aResource/:id are passed through middleware
    And requests to DEL /api/aResource/:id are passed through middleware

  Scenario: The routes forward on to RESTful crudController methods
    When the routeResourceFunction is called with [aResource], app, middleware and controller
    Then requests to GET /api/aResource are handled by controller method index
    And requests to POST /api/aResource are handled by controller method create
    And requests to GET /api/aResource/count are handled by controller method count
    And requests to PUT /api/aResource/:id are handled by controller method update
    And requests to GET /api/aResource/:id are handled by controller method show
    And requests to DEL /api/aResource/:id are handled by controller method destroy

  Scenario: All defined routes are passed respondIfOk as their catch all handler
    When the routeResourceFunction is called with [aResource], app, middleware and controller
    Then requests to GET /api/aResource are terminated by _respondIfOk
    And requests to POST /api/aResource are terminated by _respondIfOk
    And requests to GET /api/aResource/count are terminated by _respondIfOk
    And requests to PUT /api/aResource/:id are terminated by _respondIfOk
    And requests to GET /api/aResource/:id are terminated by _respondIfOk
    And requests to DEL /api/aResource/:id are terminated by _respondIfOk

Feature: gi.common.rest._respondIfOk(req,res)
  Background:
    Given the rest module is required
    And a result object
  
  Scenario: _respondIfOk when req.giResult is present
    Given the response has a gi result
    When _respondIfOk is called
    Then the response is ended with 200 OK
    And the response returns the res.giResult as json
  
  Scenario: _respondIfOk when req.giResult is missing
    Given the response has no gi result
    When _respondIfOk is called
    Then the response is ended with 500 server error
    And the response returns message: something went wrong as json
