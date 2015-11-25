#
#
#         Nimlog logging library.
# 
# (c) Christoph Herzog <chris@theduke.at> 2015
# 
# This project is under the LGPL license.
# For details, see LICENSE.txt.
# 


from strutils import split, contains, startsWith, rfind, `%`
from sequtils import nil
from times import nil
import tables

from values import ValueMap, newValueMap, `[]=`, `.=`, toValue, getMap


###########
# LogErr. #
###########

type LogErr* = object of Exception
  discard

proc newLogErr*(msg: string): ref Exception =
  newException(LogErr, msg)

type 
  Severity* {.pure.} = enum
    UNKNOWN
    EMERGENCY
    ALERT
    CRITICAL
    ERROR
    WARNING
    NOTICE
    INFO
    DEBUG
    CUSTOM

  Entry* = object
    logger*: Logger

    facility*: string
    severity*: Severity
    customSeverity*: string
    time*: times.TimeInfo
    msg*: string
    fields*: ValueMap

  Formatter* = ref object of RootObj
    discard

  Writer* = ref object of RootObj
    minSeverity*: Severity
    filters*: seq[proc(e: Entry): bool]
    formatters*: seq[Formatter]

  Config = ref object of RootObj
    facility: string
    minSeverity: Severity

    rootConfig: RootConfig
    parent: Config

    hasWriters: bool
    writers: Table[string, Writer]

    formatters: seq[Formatter]

  RootConfig = ref object of Config
    customSeverities: seq[string]
    configs: Table[string, Config]

  Logger* = ref object of RootObj
    facility: string
    config: Config

##############
# Formatter. #
##############

method format(f: Formatter, e: ref Entry) {.base.} =
  assert false, "Formatter does not implement .format()"

###########
# Writer. #
###########

method close*(w: Writer, force: bool = false, wait: bool = true) {.base.} =
  assert false, "Writer does not implement .close()"

method shouldWrite*(w: Writer, e: Entry): bool {.base.} =
  if e.severity > w.minSeverity:
    return false
  for f in w.filters:
    if not f(e):
      return false 
  return true

method doWrite*(w: Writer, e: Entry) {.base.} =
  assert false, "Writer does not implement .doWrite()"

method write*(w: Writer, e: Entry) {.base.} =
  if not w.shouldWrite(e):
    return
  var eRef: ref Entry
  new(eRef)
  eRef[] = e
  for f in w.formatters:
    f.format(eRef)
  w.doWrite(eRef[])

proc addFilter*(w: Writer, filter: proc(e: Entry): bool) =
  if w.filters == nil:
    w.filters = @[]
  w.filters.add(filter)

proc clearFilters*(w: Writer) =
  w.filters = nil

proc addFormatter*(w: Writer, formatter: Formatter) =
  if w.formatters == nil:
    w.formatters = @[]
  w.formatters.add(formatter)

proc clearFormatters*(w: Writer) =
  w.formatters = nil

###############################
# Formatter / Writer imports. #
###############################

import formatters/defaultfields, formatters/message
import writers/file



###########
# Config. #
###########

proc newRootConfig(): RootConfig =
  result = RootConfig(
    facility: "",
    minSeverity: Severity.CUSTOM,
    hasWriters: true,
    writers: initTable[string, Writer](),
    formatters: @[],
    customSeverities: @[],
    configs: initTable[string, Config]()
  )
  result.rootConfig = result

proc buildChild(c: Config, facility: string): Config =
  var facility = facility
  if not facility.startsWith(c.facility):
    facility = c.facility & "." & facility

  Config(
    facility: facility,
    minSeverity: c.minSeverity,
    rootConfig: c.rootConfig,
    parent: c,
  )

proc getWriters(c: Config): seq[Writer] =
  if c.hasWriters:
    result = sequtils.toSeq(c.writers.values)
  else:
    result = c.parent.getWriters()

proc getFormatters(c: Config): seq[Formatter] =
  if c.formatters != nil: c.formatters else: c.parent.getFormatters()

proc getCustomSeverities(c: Config): seq[string] =
  c.rootConfig.customSeverities



###########
# Logger. #
###########

proc getLogger*(l: Logger, facility: string): Logger =
  var facility = facility
  if not facility.startsWith(l.facility):
    facility = l.facility & "." & facility

  var rootConfig = l.config.rootConfig
  # Find the closest parent config.
  var configFacility = facility
  while configFacility.contains(".") and not rootConfig.configs.hasKey(configFacility):
    configFacility = configFacility[0..rfind(configFacility, ".") - 1]

  var config: Config = rootConfig
  if rootConfig.configs.hasKey(configFacility):
    config = rootConfig.configs[configFacility]

  Logger(facility: facility, `config`: config)

proc setSeverity*(l: Logger, s: Severity) =
  if l.config.facility != l.facility:
    l.config = l.config.buildChild(l.facility)
  l.config.minSeverity = s

proc addWriter*(l: Logger, name: string, w: Writer) =
  if l.config.facility != l.facility:
    l.config = l.config.buildChild(l.facility)
  if not l.config.hasWriters:
    l.config.writers = l.config.parent.writers
    l.config.hasWriters = true
  l.config.writers[name] = w

proc clearWriters*(l: Logger) =
  if l.config.facility != l.facility:
    l.config = l.config.buildChild(l.facility)
  l.config.writers = initTable[string, Writer]()

proc getWriter*(l: Logger, name: string): Writer =
  var conf = l.config
  while not conf.hasWriters:
    conf = conf.parent
  if not conf.writers.hasKey(name):
    raise newLogErr("Unknown writer: '" & name & "'")
  conf.writers[name]

proc addFormatter*(l: Logger, f: Formatter) =
  if l.config.facility != l.facility:
    l.config = l.config.buildChild(l.facility)
    l.config.formatters = l.config.parent.formatters
  l.config.formatters.add(f)

proc clearFormatters*(l: Logger) =
  if l.config.facility != l.facility:
    l.config = l.config.buildChild(l.facility)
  l.config.formatters = @[]

proc setFormatter*(l: Logger, f: Formatter) =
  l.clearFormatters()
  l.config.formatters.add(f)

proc setFormatters*(l: Logger, f: seq[Formatter]) =
  l.clearFormatters()
  l.config.formatters = f

proc getFormatters*(l: Logger): seq[Formatter] =
  l.config.getFormatters()

proc registerSeverity*(l: Logger, severity: string) =
  l.config.rootConfig.customSeverities.add(severity)

proc newRootLogger*(withDefaultWriter: bool = true): Logger =
  result = Logger(
    facility: "",
    config: newRootConfig()
  )

  if withDefaultWriter:
    result.addWriter("stdout", newFileWriter(file=stdout)) 

###############
# newEntry(). #
###############

proc newEntry*(facility: string, severity: Severity, msg: string, customSeverity: string = nil, fields: ValueMap = nil): Entry =
  Entry(
    facility: facility,
    severity: severity,
    msg: msg,
    time: times.getLocalTime(times.getTime()),
    `fields`: fields
  )

#########################
# Logger logging procs. #
#########################

proc log*(l: Logger, e: Entry) =
  # Log arbitrary entries.

  if e.severity == Severity.UNKNOWN:
    raise newLogErr("Can't log entries with severity: UNKNOWN")

  if e.severity > l.config.minSeverity:
    # Ignore severities which should not be logged.
    return

  var eRef: ref Entry
  new(eRef)
  eRef[] = e

  eRef[].facility = l.facility

  if e.msg == nil:
    eRef[].msg = ""

  for f in l.config.getFormatters:
    f.format(eRef)
  for w in l.config.getWriters:
    w.write(eRef[])

# General severity log.

proc log*(l: Logger, severity: Severity, msg: string, args: varargs[string, `$`]) =
  var msg = if msg == nil: "" else: msg
  # Log a message with specified severity.
  l.log(newEntry(l.facility, severity, msg % args))

# General custom Severity log.

proc log*(l: Logger, customSeverity: string, msg: string, args: varargs[string, `$`]) =
  # Log a message with a custom severity.
  var msg = if msg == nil: "" else: msg
  if not (l.config.getCustomSeverities().contains(customSeverity)):
    raise newLogErr("Unregistered custom severity: " & customSeverity)
  l.log(newEntry(l.facility, Severity.CUSTOM, msg % args, customSeverity = customSeverity))

# Emergency.

proc emergency*(l: Logger, msg: string, args: varargs[string, `$`]) =
  l.log(Severity.EMERGENCY, msg, args)

# Alert.

proc alert*(l: Logger, msg: string, args: varargs[string, `$`]) =
  l.log(Severity.ALERT, msg, args)

# Critical.

proc critical*(l: Logger, msg: string, args: varargs[string, `$`]) =
  l.log(Severity.CRITICAL, msg, args)

# Error.

proc error*(l: Logger, msg: string, args: varargs[string, `$`]) =
  l.log(Severity.ERROR, msg, args)

# Warning.

proc warning*(l: Logger, msg: string, args: varargs[string, `$`]) =
  l.log(Severity.WARNING, msg, args)

# Notice.

proc notice*(l: Logger, msg: string, args: varargs[string, `$`]) =
  l.log(Severity.NOTICE, msg, args)

# Info.

proc info*(l: Logger, msg: string, args: varargs[string, `$`]) =
  l.log(Severity.INFO, msg, args)

# Debug.

proc debug*(l: Logger, msg: string, args: varargs[string, `$`]) =
  l.log(Severity.DEBUG, msg, args)



######################
# Entry field logic. #
######################

proc withField*[T](l: Logger, name: string, value: T): Entry =
  var m = newValueMap()
  m[name] = value
  result = newEntry(nil, Severity.UNKNOWN, nil, nil, m)
  result.logger = l

proc withFields*(l: Logger, fields: tuple): Entry =
  result = newEntry(nil, Severity.UNKNOWN, nil, nil, toValue(fields).getMap())
  result.logger = l

proc addField*[T](e: Entry, name: string, value: T): Entry =
  if e.fields == nil:
    e.fields = newValueMap()
  e.fields[name] = value
  return e

proc addFields*(e: Entry, t: tuple): Entry =
  if e.fields == nil:
    e.fields = newValueMap()
  for key, val in t.fieldPairs:
    e.fields[key] = val
  return e

proc log*(e: Entry, severity: Severity, msg: string, args: varargs[string, `$`]) =
  # Log a message with specified severity.

  var msg = if msg == nil: "" else: msg
  var e = e
  e.severity = severity
  e.msg = msg % args
  e.logger.log(e)

# General custom Severity log.

proc log*(e: Entry, customSeverity: string, msg: string, args: varargs[string, `$`]) =
  # Log a message with a custom severity.

  if not (e.logger.config.getCustomSeverities().contains(customSeverity)):
    raise newLogErr("Unregistered custom severity: " & customSeverity)
  var msg = if msg == nil: "" else: msg
  var e = e
  e.severity = Severity.CUSTOM
  e.customSeverity = customSeverity
  e.msg = msg % args
  e.logger.log(e)

# Emergency.

proc emergency*(e: Entry, msg: string, args: varargs[string, `$`]) =
  e.log(Severity.EMERGENCY, msg, args)

# Alert.

proc alert*(e: Entry, msg: string, args: varargs[string, `$`]) =
  e.log(Severity.ALERT, msg, args)

# Critical.

proc critical*(e: Entry, msg: string, args: varargs[string, `$`]) =
  e.log(Severity.CRITICAL, msg, args)

# Error.

proc error*(e: Entry, msg: string, args: varargs[string, `$`]) =
  e.log(Severity.ERROR, msg, args)

# Warning.

proc warning*(e: Entry, msg: string, args: varargs[string, `$`]) =
  e.log(Severity.WARNING, msg, args)

# Notice.

proc notice*(e: Entry, msg: string, args: varargs[string, `$`]) =
  e.log(Severity.NOTICE, msg, args)

# Info.

proc info*(e: Entry, msg: string, args: varargs[string, `$`]) =
  e.log(Severity.INFO, msg, args)

# Debug.

proc debug*(e: Entry, msg: string, args: varargs[string, `$`]) =
  e.log(Severity.DEBUG, msg, args)



##################
# Global logger. #
##################

var globalLogger = newRootLogger()

proc setFormat*(format: string) =
  for w in globalLogger.config.getWriters():
    for f in w.formatters:
      if f is MessageFormatter:
        cast[MessageFormatter](f).setFormat(format)

proc getLogger*(facility: string): Logger =
  globalLogger.getLogger(facility)

proc setFormat*(format: Format) =
  setFormat($format)

proc withField*[T](name: string, val: T): Entry =
  globalLogger.withField(name, val)

proc logFields*(fields: tuple): Entry =
  globalLogger.withFields(fields)

proc log*(severity: Severity, msg: string, args: varargs[string, `$`]) =
  globalLogger.log(severity, msg, args)

# General custom Severity log.

proc log*(customSeverity: string, msg: string, args: varargs[string, `$`]) =
  globalLogger.log(customSeverity, msg, args)

# Emergency.

proc emergency*(msg: string, args: varargs[string, `$`]) =
  globalLogger.emergency(msg, args)

# Alert.

proc alert*(msg: string, args: varargs[string, `$`]) =
  globalLogger.alert(msg, args)

# Critical.

proc critical*(msg: string, args: varargs[string, `$`]) =
  globalLogger.critical(msg, args)

# Error.

proc error*(msg: string, args: varargs[string, `$`]) =
  globalLogger.error(msg, args)

# Warning.

proc warning*(msg: string, args: varargs[string, `$`]) =
  globalLogger.warning(msg, args)

# Notice.

proc notice*(msg: string, args: varargs[string, `$`]) =
  globalLogger.notice(msg, args)

# Info.

proc info*(msg: string, args: varargs[string, `$`]) =
  globalLogger.info(msg, args)

# Debug.

proc debug*(msg: string, args: varargs[string, `$`]) =
  globalLogger.debug(msg, args)
