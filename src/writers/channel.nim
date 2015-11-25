#
#
#         Nimlog logging library.
# 
# (c) Christoph Herzog <chris@theduke.at> 2015
# 
# This project is under the LGPL license.
# For details, see LICENSE.txt.
# 


from strutils import `%`

import ../nimlog

type ChannelWriter* = ref object of Writer
  maxChannelSize: int
  onChannelFullDiscard: bool

  writer*: Writer

  thread: Thread[ptr ChannelWriter]
  channel: Channel[Entry]

  shouldClose: bool
  forceClose: bool
  isClosed: bool


proc process(wRef: ptr ChannelWriter) =
  var w = wRef[]
  while true:
    var waiting = w.channel.peek()

    if w.shouldClose:
      if w.forceClose or waiting < 1:
        w.isClosed = true
        break
    
    if waiting < 1:
      continue

    if w.maxChannelSize > 0:
      if waiting > w.maxChannelSize:
        if not w.onChannelFullDiscard:
          raise newLogErr("ChannelWriter channel is full: $1 items queued" % [$waiting])
        else:
          # Throw away entries.
          for i in 0..(waiting - w.maxChannelSize):
            discard w.channel.recv()

    var entry = w.channel.recv()
    w.writer.write(entry)

proc run*(w: var ChannelWriter) =
  w.channel.open()
  var wRef: ptr ChannelWriter = addr(w)
  createThread(w.thread, process, wRef)

method doWrite*(w: ChannelWriter, e: Entry) =
  w.channel.send(e)

method close*(w: ChannelWriter, force: bool = false, wait: bool = true) =
  w.shouldClose = true
  w.forceClose = force

  if wait:
    # Wait until writer is properly closed down.
    while true:
      if w.isClosed:
        break
  w.writer.close(force, wait)
  w.channel.close()

proc newChannelWriter*(
  writer: Writer, 
  minSeverity: Severity = Severity.CUSTOM, 
  maxChannelSize: int = 5000, 
  onChannelFullDiscard: bool = true
): ChannelWriter =
  ChannelWriter(
    `writer`: writer,
    `minSeverity`: minSeverity,
    `maxChannelSize`: maxChannelSize,
    `onChannelFullDiscard`: onChannelFullDiscard,
    channel: Channel[Entry]()
  )
