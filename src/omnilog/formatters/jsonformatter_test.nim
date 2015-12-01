###############################################################################
##                                                                           ##
##                     Omnilog logging library                               ##
##                                                                           ##
##   (c) Christoph Herzog <chris@theduke.at> 2015                            ##
##                                                                           ##
##   This project is under the LGPL license.                                 ##
##   Check LICENSE.txt for details.                                          ##
##                                                                           ##
###############################################################################

import alpha, omega
from strutils import `%`
from times import format
import values

import ../../omnilog
import jsonformatter

Suite "JsonFormatter":

  Describe "toJson()":

    It "Should convert an entry without fields":
      var e = newEntry("facility", Severity.INFO, "msg")
      var time = times.format(e.time, "yyyy-dd-MM'T'HH:mmzzz")
      var json = """{"facility": "facility", "severity": "INFO", "severityId": 7, "time": "$1", "msg": "msg"}""" % [time]
      e.toJson().should(equal(json))

    It "Should convert an entry with fields":
      var data = @%(
        str: "string", 
        num: 55, 
        decimal: 1.131,
        nestedSeq: ["a", "b", "c"],
        nestedObj: (a: "a", i: 33)
      )
      var dataJson = data.toJson()

      var e = newEntry("facility", Severity.INFO, "msg", nil, data)
      var time = times.format(e.time, "yyyy-dd-MM'T'HH:mmzzz")
      var json = """{"facility": "facility", "severity": "INFO", "severityId": 7, "time": "$1", "msg": "msg", "data": $2}""" % [time, dataJson]
      e.toJson().should(equal(json))

  Describe "JsonFormatter":
    var f = newJsonFormatter()

    var data = @%(
      str: "string", 
      num: 55, 
      decimal: 1.131,
      nestedSeq: ["a", "b", "c"],
      nestedObj: (a: "a", i: 33)
    )
    var dataJson = data.toJson()

    var e = newEntry("facility", Severity.INFO, "msg", nil, data)
    var eRef: ref Entry
    new(eRef)
    eRef[] = e

    f.format(eRef)
    eRef[].msg.should(equal(e.toJson()))
