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

from ../../omnilog import Entry, Handler, Severity, newLogErr, Formatter
from ../formatters/message import newMessageFormatter, Format

from strutils import `%`

type FileHandler = ref object of Handler
  filePath*: string
  append*: bool
  mustWrite*: bool
  flushAfter*: int

  file: File
  writeCounter: int

method doWrite*(w: FileHandler, e: Entry) =
  if w.file == nil:
    var mode = if w.append: fmAppend else: fmWrite
    if not w.file.open(w.filePath, mode):
      if w.mustWrite:
        raise newLogErr("Could not open log file $1 for writing." % [w.filePath])
      else:
        # mustWrite is not enabled, so ignore the open error.
        return

  try:
    w.file.write(e.msg)
  except:
    if w.mustWrite:
      raise newLogErr("Could not write to log file $1: $2" % [w.filePath, getCurrentExceptionMsg()])
    else:
      # mustWrite not enabled, so ignore the error.
      return

  w.writeCounter += 1
  if w.writeCounter >= w.flushAfter:
    w.file.flushFile()
    w.writeCounter = 0

method close*(w: FileHandler, force: bool = false, wait: bool = true) =
  if not (w.file == stdout or w.file == stderr):
    w.file.close()

proc newFileHandler*(
  file: File = nil,
  path: string = nil, 
  minSeverity: Severity = Severity.CUSTOM, 
  append, mustWrite: bool = true, 
  flushAfter: int = 1, 
  format: string = nil,
  formatter: Formatter = nil
): FileHandler =
  
  var formatter = formatter
  if formatter == nil:
    var format = format
    if format == nil:
      format = Format.DEFAULT.`$`
    formatter = newMessageFormatter(format)

  if file == nil and (path == nil or path == ""):
    raise newLogErr("Must specify either file or filePath")

  FileHandler(
    `file`: file,
    filePath: path,
    `minSeverity`: minSeverity,
    `append`: append,
    `mustWrite`: mustWrite,
    `flushAfter`: flushAfter,
    formatters: @[formatter]
  )
