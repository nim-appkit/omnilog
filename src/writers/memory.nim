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

proc newMemoryWriter*(minSeverity: Severity = Severity.CUSTOM, maxEntries: int = 10000): MemoryWriter =
  MemoryWriter(
    entries: @[],
    `maxEntries`: maxEntries,
    `minSeverity`: minSeverity
  )
