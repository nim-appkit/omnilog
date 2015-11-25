#
#
#         Nimlog logging library.
# 
# (c) Christoph Herzog <chris@theduke.at> 2015
# 
# This project is under the LGPL license.
# For details, see LICENSE.txt.
# 

from ../nimlog import Entry, Writer, Severity, newLogErr, Formatter

type MemoryWriter = ref object of Writer
  entries: seq[Entry]
  maxEntries: int

method doWrite*(w: MemoryWriter, e: Entry) =
  w.entries.add(e)
  if w.entries.len() > w.maxEntries:
    var keepFrom = int(float(w.maxEntries)*0.2)
    w.entries = w.entries[keepFrom..high(w.entries)]

proc getEntries*(w: MemoryWriter): seq[Entry] = w.entries

method close*(w: MemoryWriter, force: bool = false, wait: bool = true) =
  # No-op.
  discard

proc newMemoryWriter*(minSeverity: Severity = Severity.CUSTOM, maxEntries: int = 10000): MemoryWriter =
  MemoryWriter(
    entries: @[],
    `maxEntries`: maxEntries,
    `minSeverity`: minSeverity
  )
