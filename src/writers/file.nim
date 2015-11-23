from ../nimlog import Entry, Writer, Severity, newLogErr, Formatter
from ../formatters/message import newMessageFormatter

from strutils import `%`

type FileWriter = ref object of Writer
  filePath*: string
  append*: bool
  mustWrite*: bool
  flushAfter*: int

  file: File
  writeCounter: int

method doWrite*(w: FileWriter, e: Entry) =
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

proc newFileWriter*(
  file: File = nil,
  path: string = nil, 
  minSeverity: Severity = Severity.CUSTOM, 
  append, mustWrite: bool = true, 
  flushAfter: int = 1, 
  formatter: Formatter = nil
): FileWriter =
  
  var formatter = formatter
  if formatter == nil:
    formatter = newMessageFormatter()

  if file == nil and (path == nil or path == ""):
    raise newLogErr("Must specify either file or filePath")

  FileWriter(
    `file`: file,
    filePath: path,
    `minSeverity`: minSeverity,
    `append`: append,
    `mustWrite`: mustWrite,
    `flushAfter`: flushAfter,
    formatters: @[formatter]
  )
