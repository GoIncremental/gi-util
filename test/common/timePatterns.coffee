path = require 'path'
expect = require('chai').expect
moment = require 'moment'
async = require 'async'

dir =  path.normalize __dirname + '../../../common'

module.exports = () ->
  describe 'timePatterns', ->
    
    tp = require dir + '/timePatterns'

    describe 'Function: timeOnBetween(start, stop, pattern, callback)', ->

      it 'Can calculate the number of seconds `on` between two moments'
      , (done) ->
        startOfWeek = moment().startOf 'week'
        testTime = moment().startOf('week').add 'seconds', 788
        tests = []
        
        tests.push (cb) ->
          output = tp.timeOnBetween startOfWeek, testTime, [0,3600], 'weekly'
          expect(output).to.equal 788
          cb()
        
        tests.push (cb) ->
          output = tp.timeOnBetween startOfWeek, testTime, [3600, 0], 'weekly'
          expect(output).to.equal 0
          cb()

        tests.push (cb) ->
          output = tp.timeOnBetween startOfWeek, testTime, [10,300], 'weekly'
          expect(output).to.equal 300
          cb()

        tests.push (cb) ->
          output = tp.timeOnBetween startOfWeek, testTime
          , [10, 300, 10], 'weekly'
          expect(output).to.equal 768
          cb()

        async.parallel tests, done

      it 'Handles start dates before current week / month /year', (done) ->
        startOfWeek = moment().subtract('weeks',2).startOf 'week'
        testTime = moment().subtract('weeks',2)
        .startOf('week').add 'seconds', 788

        output = tp.timeOnBetween startOfWeek, testTime, [0,3600], 'weekly'
        expect(output).to.equal 788
        done()

      it 'Handles intervals greater then the recurrence length', (done) ->

        startOfWeek = moment().startOf 'week'
        testTime = moment().startOf('week').add('weeks',2).add 'seconds', 788
        tests = []
        
        tests.push (cb) ->
          output = tp.timeOnBetween startOfWeek, testTime, [0,3600], 'weekly'
          expect(output).to.equal 788 + 2 * 3600
          cb()

        tests.push (cb) ->
          output = tp.timeOnBetween startOfWeek, testTime, [3600,0], 'weekly'
          expect(output).to.equal 0
          cb()

        tests.push (cb) ->
          output = tp.timeOnBetween startOfWeek, testTime, [10, 300], 'weekly'
          expect(output).to.equal 900
          cb()

        tests.push (cb) ->
          output = tp.timeOnBetween startOfWeek, testTime
          , [10, 300, 10], 'weekly'
          expect(output).to.equal 768 + 2 * 604780
          cb()
        
        async.parallel tests, done

      it 'Handles start times that are midway through a recurrence'
      , (done) ->
        start = moment().startOf('week').add('seconds', 1800)
        stop = moment(start).add 'seconds', 788
        tests = []
        
        tests.push (cb) ->
          output = tp.timeOnBetween start, stop, [0,3600,300], 'weekly'
          expect(output).to.equal 788
          stop.add 'seconds', 1800
          cb()

        tests.push (cb) ->
          output = tp.timeOnBetween start, stop, [0,3600,300], 'weekly'
          expect(output).to.equal 1800 + 488
          start.add 'seconds', 1800
          cb()

        tests.push (cb) ->
          output = tp.timeOnBetween start, stop, [0,3600,300], 'weekly'
          expect(output).to.equal 488
          cb()

        async.series tests, done

    describe 'Function: timeAfterXSecondsOnFrom(start, x, pattern, callback)'
    , ->
      it 'takes into account off times in the pattern', (done) ->

        start = moment().startOf('week')
        x = 150
        tests = []
        correctAnswer = moment(start).add 'seconds', 3600 + 150
        
        tests.push (cb) ->
          output = tp.timeAfterXSecondsOnFrom start, x,[3600, 300], 'weekly'
          expect(output.toString()).to.equal correctAnswer.toString()
          start.add 'seconds', 1800
          cb()

        tests.push (cb) ->
          output = tp.timeAfterXSecondsOnFrom start, x, [3600, 300], 'weekly'
          # should not change answer, as we've just pushed start further along
          # an off period
          expect(output.toString()).to.equal correctAnswer.toString()
          x += 152
          cb()

        tests.push (cb) ->
          output = tp.timeAfterXSecondsOnFrom start, x, [3600, 300], 'weekly'
          expect(output.toString()).to.equal moment(start)
          .add('weeks',1).add('seconds', 1802 ).toString()
          cb()

        async.series tests, done

      it 'works with long duration slas', (done) ->
        pattern = [118800,28800,57600,28800,57600,28800
        ,57600,28800,57600,28800,111600]

        start = moment().startOf('week').add('days', 1)
        .add('hours', 14) #2pm Monday
        x = 540000
        output = tp.timeAfterXSecondsOnFrom start, x, pattern, 'weekly'
        correctAnswer = moment(start).add('weeks', 3).add('days', 3)
        .add('hours', 22) #Midday 3 weeks on Friday
        expect(output.toString()).to.equal correctAnswer.toString()
        done()
