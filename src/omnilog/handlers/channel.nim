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


from strutils import `%`

import ../../omnilog

type ChannelHandler* = ref object of Handler
  maxChannelSize: int
  onChannelFullDiscard: bool

  handler*: Handler

  thread: Thread[ptr ChannelHandler]
  channel: Channel[Entry]

  shouldClose: bool
  forceClose: bool
  isClosed: bool


proc process(wRef: ptr ChannelHandler) =
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
          raise newLogErr("ChannelHandler channel is full: $1 items queued" % [$waiting])
        else:
          # Throw away entries.
          for i in 0..(waiting - w.maxChannelSize):
            discard w.channel.recv()

    var entry = w.channel.recv()
    w.handler.write(entry)

proc run*(w: var ChannelHandler) =
  w.channel.open()
  var wRef: ptr ChannelHandler = addr(w)
  createThread(w.thread, process, wRef)

method doWrite*(w: ChannelHandler, e: Entry) =
  w.channel.send(e)

method close*(w: ChannelHandler, force: bool = false, wait: bool = true) =
  w.shouldClose = true
  w.forceClose = force

  if wait:
    # Wait until handler is properly closed down.
    while true:
      if w.isClosed:
        break
  w.handler.close(force, wait)
  w.channel.close()

proc newChannelHandler*(
  handler: Handler, 
  minSeverity: Severity = Severity.CUSTOM, 
  maxChannelSize: int = 5000, 
  onChannelFullDiscard: bool = true
): ChannelHandler =
  ChannelHandler(
    `handler`: handler,
    `minSeverity`: minSeverity,
    `maxChannelSize`: maxChannelSize,
    `onChannelFullDiscard`: onChannelFullDiscard,
    channel: Channel[Entry]()
  )
