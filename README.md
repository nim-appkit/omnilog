# nimlog

Nimlog is a logging library for the [Nim language](http://nim-lang.org).

It supports plain text and structured logging with
multiple, pluggable writers which can be seperately filtered,


## Additional Information

### Log levels

By default, nimlog supports the log severities specified in the syslog RFC [syslog](http://tools.ietf.org/html/rfc5424).
You can also configure *custom levels*.

| Severity  | Numerical value |
| --------- | --------------- |
| emergency | 0 |
| alert     | 1 |
| critical  | 2 |
| error     | 3 |
| warning   | 4 |
| notice    | 5 |
| info      | 6 |
| debug     | 7 |


### Time format

While you may change the time format used, it is highly recommended to stick to the default specified by [RFC3339](http://tools.ietf.org/htmlrfc3339).

### Versioning

This project follows [SemVer](semver.org).

### License.

This project is under the [MIT license](https://opensource.org/licenses/MIT).
