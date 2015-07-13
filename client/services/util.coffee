angular.module('gi.util').factory 'giUtil'
, [ () ->
  emailRegex: /^[0-9a-zA-Z][-0-9a-zA-Z.+_]*@[-0-9a-zA-Z.+_]+\.[a-zA-Z]{2,4}$/
  vatRegex: /^(AT|BE|BG|CY|CZ|DE|DK|EE|EL|ES|FI|FR|GB|HU|IE|IT|LT|LU|LV|MT|NL|PL|PT|SE|SI|SK|RO)(\w{8,12})$/
  countrySort: (topCodes) ->
    (country) ->
      if country?.code?
        index = country.code in topCodes
        if index
          return topCodes.indexOf(country.code)
        else
          return country.name
      return ""
]
