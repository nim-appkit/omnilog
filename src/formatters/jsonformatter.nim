#
#
#         Nimlog logging library.
# 
# (c) Christoph Herzog <chris@theduke.at> 2015
# 
# This project is under the LGPL license.
# For details, see LICENSE.txt.
# 

from json import escapeJson
from strutils import `%`
from times import nil
from values import toJson

from ../nimlog import Formatter, Entry, Severity

type JsonFormatter = ref object of Formatter
  includeFields: bool

proc toJson*(e: Entry, includeFields: bool = true): string =
  var json = """{"facility": $1, "severity": $2, "severityId": $3, "time": $4, "msg": $5 """
  # Remove last space.
  json = json[0..high(json)-1]
  # Insert tokens.
  json = json % [
    escapeJson(e.facility),
    escapeJson(e.severity.`$`),
    int(e.severity).`$`,
    escapeJson(times.format(e.time, "yyyy-dd-MM'T'HH:mmzzz")),
    escapeJson(e.msg)
  ]

  if e.severity == Severity.CUSTOM and e.customSeverity != nil and e.customSeverity != "":
    json &= ", \"customSeverity\": \"" & escapeJson(e.customSeverity) & "\""

  if e.fields != nil and includeFields:
    json &= ", \"data\": " & e.fields.toJson()

  json &= "}"
  return json 

method format*(f: JsonFormatter, e: ref Entry) =
  e[].msg = e[].toJson(f.includeFields)

proc newJsonFormatter*(includeFields: bool = true): JsonFormatter =
  JsonFormatter(
    `includeFields`: includeFields
  )
