if not exports?
  if not @gi
    @gi = {}
  if not @gi.util
    @gi['util'] = {}
  if not @gi.util.common
    @gi.util['common'] = {}

do (exports = (if exports? then exports else @gi.util.common['timePatterns'] = {} )) ->
  moment =  if window? then window.moment else require('moment')

  enrichPeriod = (pattern, recurrence) ->
    length = 0
    secondsInADay = 60*60*24
        
    if recurrence is 'weekly'
      length = secondsInADay * 7

    #the create & update methods protect us from patterns
    #longer than the recurrence
    onTime = 0
    calculatedPeriodLength = 0
    
    for s, i in pattern
      if i % 2 == 1
        #an on period
        onTime += s
      calculatedPeriodLength += s

    if calculatedPeriodLength < length
      #push the difference on the end of the array
      missingSecondsInPattern = length - calculatedPeriodLength
      pattern.push missingSecondsInPattern
      #if it's an on period, add it to the periodOnTime
      if pattern.length % 2 is 0
        #the last entry is an on time
        onTime += missingSecondsInPattern

    length: length
    onTime: onTime

  calculatePeriodStart = (period, start, pattern, recurrence) ->
    period.start = moment(start)
    #now the difference is at most one recurrence length
    if recurrence is 'weekly'
      period.start = moment(start).startOf('week')
      
    period.secondsToStart = start.diff period.start, 'seconds'
    
    # console.log 'period start: ' + period.start.toString()
    # console.log 'start: ' + start.toString()
    # console.log 'seconds to start: ' +  period.secondsToStart
    # console.log pattern

    period

  #
  # This is a complicated function, but it's well unit tested.  I've left
  # the console lines in, but commented out to aid any future debugging
  # as they proved quite helpful to see what's going on
  #
  exports.timeOnBetween = (_start, _stop, pattern, recurrence) ->
    #clone the moments so we don't alter them for the calling function
    start = moment(_start)
    stop = moment(_stop)
    # console.log 'period start: ' + periodStart.toString()
    # console.log 'start: ' + start.toString()
    
    result = 0

    period = enrichPeriod pattern, recurrence

    #calculate the seconds we are into the period
    secondsFromStartToStop = stop.diff start, 'seconds'

    while secondsFromStartToStop > period.length
      #fast forward through whole periods if we can
      # console.log 'fast forwarding (added ' + period.onTime + ' seconds)'
      result += period.onTime
      start.add 'seconds', period.length
      secondsFromStartToStop = stop.diff start, 'seconds'

    # console.log 'seconds from start to stop ' + secondsFromStartToStop

    #now the difference is at most one recurrence length
    period = calculatePeriodStart period, start, pattern, recurrence

    index = 0
    while true
      #we want to fast forward to the right point in the index
      if period.secondsToStart >= pattern[index]
        # console.log 'subtracting ' + pattern[index]
        # + ' seconds from start'
        period.secondsToStart -= pattern[index]
        index += 1
      else
        # console.log 'found start index ' + index + ' plus ' +
        # period.secondsToStart + ' seconds '
        break

    #so now index points to the correct start point in the pattern
    #and secondsFromStart needs to be added to that index
    if index % 2 is 0
      #it's an off period
      # console.log 'considering off period ' + index
      if secondsFromStartToStop >= pattern[index] - period.secondsToStart
        # console.log 'increasing index'
        secondsFromStartToStop -= pattern[index] - period.secondsToStart
        index += 1
      else
        # console.log 'we are done'
        secondsFromStartToStop = 0
    else
      # console.log 'considering on period ' + index
      if secondsFromStartToStop >= pattern[index] - period.secondsToStart
        result += pattern[index] - period.secondsToStart
        secondsFromStartToStop -= pattern[index] - period.secondsToStart
        index += 1
      else
        result += secondsFromStartToStop
        secondsFromStartToStop = 0

    while secondsFromStartToStop > 0
      if index % 2 is 0
        #it's an off period
        # console.log 'considering off period ' + index
        if secondsFromStartToStop >= pattern[index]
          secondsFromStartToStop -= pattern[index]
          index += 1
        else
          secondsFromStartToStop = 0
      else
        #it's an on period
        # console.log 'considering on period ' + index
        if secondsFromStartToStop >= pattern[index]
          result += pattern[index]
          secondsFromStartToStop -= pattern[index]
          #console.log 'current result: ' + result
          index += 1
        else
          result += secondsFromStartToStop
          # console.log 'current result: ' + result
          secondsFromStartToStop = 0

    # console.log 'returning: ' + result
    # console.log ''
    result


  exports.timeAfterXSecondsOnFrom = (_start, x, pattern, recurrence) ->
    #clone the moments so we don't alter them for the calling function
    start = moment(_start)
    # console.log 'start: ' + start.toString()

    result = moment(start)
    #calculate the seconds into the period we are
    period = enrichPeriod pattern, recurrence

    while x > period.onTime
      #fast forward through whole periods if we can
      # console.log 'fast forwarding (' + period.onTime + ' seconds)'
      result.add('seconds', period.length)
      start.add('seconds', period.length)
      x -= period.onTime

    # console.log 'x remaining: ' + x

    period = calculatePeriodStart period, start, pattern, recurrence

    index = 0
    while true
      #we want to fast forward to the right point in the index
      if period.secondsToStart >= pattern[index]
        # console.log 'subtracting ' + pattern[index] +
        # ' seconds from start'
        period.secondsToStart -= pattern[index]
        index += 1
        if index is pattern.length
          index = 0
        #console.log 'index is incremented to: ' + index
      else
        # console.log 'found start index ' + index + ' plus ' +
        # period.secondsToStart + ' seconds'
        if index % 2 is 1
          x += period.secondsToStart
        result.subtract 'seconds', period.secondsToStart
        # console.log 'current result: ' + result.toString()
        break

    #so now index points to the correct start point in the pattern
    #and secondsFromStart needs to be added to that index
    # console.log x
    while x > 0
      if index % 2 is 0
        #it's an off period
        # console.log 'considering off period ' + index
        result.add 'seconds', pattern[index]
        index += 1
        if index is pattern.length
          index = 0
      else
        # console.log 'considering on period ' + index
        onSeconds = pattern[index]
        if x >= onSeconds
          result.add 'seconds', onSeconds
          x -= onSeconds
          index += 1
          if index is pattern.length
            index = 0
        else
          result.add 'seconds', x
          x = 0

    # console.log 'returning: ' + result
    # console.log ''
    result