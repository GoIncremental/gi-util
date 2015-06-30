angular.module('gi.util').provider 'giI18n',
[ () ->

  countries = {}
  defaultCountryCode = "ROW"

  @setMessagesForCountry = (messages, countryCode) ->
    if not countries[countryCode]?
      countries[countryCode] = {}

    angular.forEach messages, (msg) ->
      countries[countryCode][msg.key] = msg.value

  @setDefaultCountry = (countryCode) ->
    defaultCountryCode = countryCode

  @$get = [ () ->
    messages = countries[defaultCountryCode]

    setCountry: (countryCode) ->
      if countries[countryCode]?
        messages = countries[countryCode]
      else if countries[defaultCountryCode]?
        messages = countries[defaultCountryCode]

    getMessage: (messageKey) ->
      messages[messageKey] or ""

    getCapitalisedMessage: (messageKey) ->
      msg = messages[messageKey]
      if msg?
        return msg.charAt(0).toUpperCase() + msg.slice(1)
      else
        ""
  ]

  @

]
