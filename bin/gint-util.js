

if (!(typeof exports !== "undefined" && exports !== null)) {
  if (!this.gint) {
    this.gint = {};
  }
  if (!this.gint.util) {
    this.gint['util'] = {};
  }
  if (!this.gint.util.common) {
    this.gint.util['common'] = {};
  }
}

(function(exports) {
  var calculatePeriodStart, enrichPeriod, moment;
  moment = typeof window !== "undefined" && window !== null ? window.moment : require('moment');
  enrichPeriod = function(pattern, recurrence) {
    var calculatedPeriodLength, i, length, missingSecondsInPattern, onTime, s, secondsInADay, _i, _len;
    length = 0;
    secondsInADay = 60 * 60 * 24;
    if (recurrence === 'weekly') {
      length = secondsInADay * 7;
    }
    onTime = 0;
    calculatedPeriodLength = 0;
    for (i = _i = 0, _len = pattern.length; _i < _len; i = ++_i) {
      s = pattern[i];
      if (i % 2 === 1) {
        onTime += s;
      }
      calculatedPeriodLength += s;
    }
    if (calculatedPeriodLength < length) {
      missingSecondsInPattern = length - calculatedPeriodLength;
      pattern.push(missingSecondsInPattern);
      if (pattern.length % 2 === 0) {
        onTime += missingSecondsInPattern;
      }
    }
    return {
      length: length,
      onTime: onTime
    };
  };
  calculatePeriodStart = function(period, start, pattern, recurrence) {
    period.start = moment(start);
    if (recurrence === 'weekly') {
      period.start = moment(start).startOf('week');
    }
    period.secondsToStart = start.diff(period.start, 'seconds');
    return period;
  };
  exports.timeOnBetween = function(_start, _stop, pattern, recurrence) {
    var index, period, result, secondsFromStartToStop, start, stop;
    start = moment(_start);
    stop = moment(_stop);
    result = 0;
    period = enrichPeriod(pattern, recurrence);
    secondsFromStartToStop = stop.diff(start, 'seconds');
    while (secondsFromStartToStop > period.length) {
      result += period.onTime;
      start.add('seconds', period.length);
      secondsFromStartToStop = stop.diff(start, 'seconds');
    }
    period = calculatePeriodStart(period, start, pattern, recurrence);
    index = 0;
    while (true) {
      if (period.secondsToStart >= pattern[index]) {
        period.secondsToStart -= pattern[index];
        index += 1;
      } else {
        break;
      }
    }
    if (index % 2 === 0) {
      if (secondsFromStartToStop >= pattern[index] - period.secondsToStart) {
        secondsFromStartToStop -= pattern[index] - period.secondsToStart;
        index += 1;
      } else {
        secondsFromStartToStop = 0;
      }
    } else {
      if (secondsFromStartToStop >= pattern[index] - period.secondsToStart) {
        result += pattern[index] - period.secondsToStart;
        secondsFromStartToStop -= pattern[index] - period.secondsToStart;
        index += 1;
      } else {
        result += secondsFromStartToStop;
        secondsFromStartToStop = 0;
      }
    }
    while (secondsFromStartToStop > 0) {
      if (index % 2 === 0) {
        if (secondsFromStartToStop >= pattern[index]) {
          secondsFromStartToStop -= pattern[index];
          index += 1;
        } else {
          secondsFromStartToStop = 0;
        }
      } else {
        if (secondsFromStartToStop >= pattern[index]) {
          result += pattern[index];
          secondsFromStartToStop -= pattern[index];
          index += 1;
        } else {
          result += secondsFromStartToStop;
          secondsFromStartToStop = 0;
        }
      }
    }
    return result;
  };
  return exports.timeAfterXSecondsOnFrom = function(_start, x, pattern, recurrence) {
    var index, onSeconds, period, result, start;
    start = moment(_start);
    result = moment(start);
    period = enrichPeriod(pattern, recurrence);
    while (x > period.onTime) {
      result.add('seconds', period.length);
      start.add('seconds', period.length);
      x -= period.onTime;
    }
    period = calculatePeriodStart(period, start, pattern, recurrence);
    index = 0;
    while (true) {
      if (period.secondsToStart >= pattern[index]) {
        period.secondsToStart -= pattern[index];
        index += 1;
        if (index === pattern.length) {
          index = 0;
        }
      } else {
        if (index % 2 === 1) {
          x += period.secondsToStart;
        }
        result.subtract('seconds', period.secondsToStart);
        break;
      }
    }
    while (x > 0) {
      if (index % 2 === 0) {
        result.add('seconds', pattern[index]);
        index += 1;
        if (index === pattern.length) {
          index = 0;
        }
      } else {
        onSeconds = pattern[index];
        if (x >= onSeconds) {
          result.add('seconds', onSeconds);
          x -= onSeconds;
          index += 1;
          if (index === pattern.length) {
            index = 0;
          }
        } else {
          result.add('seconds', x);
          x = 0;
        }
      }
    }
    return result;
  };
})((typeof exports !== "undefined" && exports !== null ? exports : this.gint.util.common['timePatterns'] = {}));

;