angular.module('gi.util').directive 'giMatch'
, [ '$parse', 'giLog'
, ($parse, Log) ->
  require: '?ngModel',
  restrict: 'A',
  link: (scope, elem, attrs, ctrl) ->
    if not ctrl
      Log.warn 'giMatch validation requires ngModel to be on the element'
      return
    else
      Log.debug 'giMatch linked'

    matchGetter = $parse attrs.giMatch
    requiredGetter = $parse attrs.ngRequired

    #So it feels like this function is surplus to requirements,
    #but without it wrapping the get Match VAlue function the $watch
    #doesn't fire when you need it to.
    evaluateMatch = () ->
      getMatchValue()

    #I can't see this function documented anywhere, so we should be careful
    scope.$watch evaluateMatch, (newVal) ->
      ctrl.$$parseAndValidate()

    ctrl.$validators.giMatch = () ->
      if requiredGetter(scope)
        match = getMatchValue()
        if match?
          ctrl.$viewValue is match
        else
          #in this case, as there is no password, we have nothing to match
          true
      else
        #We need not botther validating if the field is not required
        true

    isRequired = () ->
      requiredGetter(scope)

    getMatchValue = () ->
      match = matchGetter(scope)
      if angular.isObject(match) and match.hasOwnProperty('$viewValue')
        match = match.$viewValue

      match
]
