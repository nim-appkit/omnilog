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

type MemoryHandler = ref object of Handler
  entries: seq[Entry]
  maxEntries: int

method doWrite*(w: MemoryHandler, e: Entry) =
  w.entries.add(e)
  if w.entries.len() > w.maxEntries:
    var keepFrom = int(float(w.maxEntries)*0.2)
    w.entries = w.entries[keepFrom..high(w.entries)]

proc getEntries*(w: MemoryHandler): seq[Entry] = w.entries

method close*(w: MemoryHandler, force: bool = false, wait: bool = true) =
  # No-op.
  discard

proc newMemoryHandler*(minSeverity: Severity = Severity.CUSTOM, maxEntries: int = 10000): MemoryHandler =
  MemoryHandler(
    entries: @[],
    `maxEntries`: maxEntries,
    `minSeverity`: minSeverity
  )
