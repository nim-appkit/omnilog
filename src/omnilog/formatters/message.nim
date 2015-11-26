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

from ../../omnilog import Formatter, Entry

from values import pairs, `$`, len
from strutils import contains, `%`, replace, endsWith
from times import timeInfoToTime, getLocalTime, format

type 
  Format* {.pure.} = enum
    DEFAULT     = "$time $severity $bracketFacility: $msg $fields"
    LONG_PRETTY = "$time3339 - $severity $bracketFacility: $msg $prettyFields" 
    LONG        = "$time3339 - $severity $bracketFacility: $msg $fields" 
    SHORT       = "$severity: $msg"


  MessageFormatter* = ref object of Formatter
    format: string

proc setFormat*(f: MessageFormatter, format: Format) =
  f.format = $format  

proc setFormat*(f: MessageFormatter, format: string) =
  f.format = format  

method format(f: MessageFormatter, e: ref Entry) =
  var msg = f.format

  msg = msg.replace("$severity", e[].severity.`$`)
  msg = msg.replace("$severityId", int(e[].severity).`$`)
  msg = msg.replace("$bracketFacility", if e[].facility == "": "" else: "[" & e[].facility & "]")
  msg = msg.replace("$msg", e[].msg)

  # Times.
  if msg.contains("$datetime"):
    msg = msg.replace("$datetime", e[].time.format("yyyy-dd-MM HH:mm"))
  if msg.contains("$time3339"):
    msg = msg.replace("$time3339", e[].time.format("yyyy-dd-MM'T'HH:mmzzz"))
  if msg.contains("$time"):
    msg = msg.replace("$time", e[].time.format("HH:mm"))

  if e[].fields == nil:
    msg = msg.replace("$fields", "").replace("$prettyFields", "")
  else:
    if msg.contains("$fields"):
      var fields = " "
      for key, val in e[].fields:
        fields &= key & "=" & $val & " "
      msg = msg.replace("$fields", fields)
    if msg.contains("$prettyFields"):
      var fields = ""
      if e[].fields.len() > 0:
        fields &= "\n"
        for key, val in e[].fields:
          fields &= "  " & key & " => " & repr(val)
      msg = msg.replace("$prettyFields", fields)

  if not msg.endsWith("\n"):
    msg &= "\n"

  e[].msg = msg

proc newMessageFormatter*(format: Format = Format.DEFAULT): MessageFormatter =
  MessageFormatter(format: $format)

proc newMessageFormatter*(format: string): MessageFormatter =
  MessageFormatter(format: format)
