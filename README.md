# nimlog

Nimlog is an advanced logging library for the [Nim language](http://nim-lang.org).

It supports *plain text* and **structured** logging with
*multiple*, pluggable **writers** which can be **seperately filtered and formatted**.

**Documentation is still lacking a lot of info. Will improve soon.**

## Install

Nimlog is best installed with [Nimble](https://github.com/nim-lang/nimble), Nims package manager.

```bash
nimble install nimlog
```

## Getting started

This is a simple example showing how to use nimlog with the global logger.

By default, a global logger is setup up that will write to stdout with a simple format for debugging.

You can also retrieve a named sub-logger for a *facility*.

```nim
import nimlog

# Plain log message.
info("Msg")

# Message with interpolation.
error("Msg $1 - $2", 33, 55.55)

# Log fields.
logFields((f1: "x", f2: 11)).warning("Msg")

# Facility.
var appLogger = getLogger("myfacility")

# Limit custom logger to messages of INFO and higher.
appLogger.setSeverity(Severity.INFO)

appLogger.critical("Msg $1", [1, 2, 3])
appLogger.withField("x", 55).debug("Msg") # Will be ignored, since severity is set to INFO.
appLogger.withFields((a: 1, b: "x")).info("msg")

# Nested logger.
appLogger.getLogger("subfacility").warning("Warn")
```

## Concepts

This section explains how nimlog is structured, and how you can customize it.

You can create an arbitrary amount of **nested, named loggers**.

Each logger has a *facility*, which is just a string name. 
This usually corresponds to specific parts of your program.

Each log message has a **severity**.
By default, the syslog severities are supported (see additional information).
But you can register your own, **custom severities**.

Each logger can have multiple **formatters**, which transform the log message.
They can add fields, change the log message, or even change the severity.

Each logger can have multiple **filters**, which decide whether the log message should be ignored.

Each logger can have multiple **writers**, which handle the log entry. 
Included writers are: 
* NilWriter: discards all messages, useful for stubbing.
* FileWriter: writes to files, also used for stdout.
* SocketWriter:  sends structured log data to log aggregators like graylog.
* ChannelWriter: allows to use any other writer in a **thread-safe** manner.


Each **writer** can again have **it's own** **filters** and **formatters**.

### Log Entry

Log entries are represented as an object.
Formatters and writers receive that object and can handle it as they whish.

```nim
Entry* = object
  facility*: string
  severity*: Severity
  customSeverity*: string
  time*: times.TimeInfo
  msg*: string
  fields*: ValueMap
```


## Additional Information

### Log levels

By default, nimlog supports the log severities specified in the syslog RFC [syslog](http://tools.ietf.org/html/rfc5424).
You can also configure *custom levels*.

| Severity  | Numerical value |
| --------- | --------------- |
| emergency | 1 |
| alert     | 2 |
| critical  | 3 |
| error     | 4 |
| warning   | 5 |
| notice    | 6 |
| info      | 7 |
| debug     | 8 |
| custom    | 9 |


### Time format

While you may change the time format used, it is highly recommended to stick to the default specified by [RFC3339](http://tools.ietf.org/htmlrfc3339).

### Todo

- [ ] More tests.
- [ ] Finish writing documentation.
- [ ] Thread-safe memory writer.
- [ ] Rolling file writer.

### Versioning

This project follows [SemVer](semver.org).

### License.

This project is under the [LGPL 3](http://www.gnu.org/licenses/lgpl-3.0.en.html) license.
