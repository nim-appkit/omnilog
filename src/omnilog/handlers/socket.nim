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

import net, nativesockets
from strutils import `%`, replace
from times import nil

import ../../omnilog
from ../formatters/jsonformatter import newJsonFormatter

type 
  Protocol {.pure.} = enum
    TCP, UDP

  SocketHandler = ref object of Handler
    host: string
    port: uint16
    protocol: Protocol
    mustWrite*: bool
    flushAfter*: int
    separator: string
    connectionRetryInterval: float
    waitFor: int
    maxBufferSize: int

    socket: net.Socket
    lastConnectTry: float
    buffer: seq[Entry]

method sendAll(w: SocketHandler) =
  if w.socket == nil:
    if w.lastConnectTry > 0 and times.epochTime() - w.lastConnectTry < w.connectionRetryInterval:
      # We have not reached the retry interval yet, so ignore this log message.
      return

    w.lastConnectTry = times.epochTime()

    var proto = if w.protocol == Protocol.TCP: IPPROTO_TCP else: IPPROTO_UDP
    # Try to connect.
    try:
      w.socket = newSocket(protocol = proto)
      w.socket.connect(w.host, Port(w.port), w.waitFor)
    except:
      w.socket.close()
      if w.mustWrite:
        var msg = "SocketHandler: Could not connect to $1.$2 for logging: " & getCurrentExceptionMsg() % [w.host, w.port.`$`]
        raise newLogErr(msg)
      else:
        # Enable reconnect tries.
        w.socket = nil
        # mustWrite is false, so ignore errors.
        return

  # Connection should exist, so write the message.
  var payload = ""

  for entry in w.buffer:
    var msg = entry.msg
    # Replace separator.
    if w.separator[0] == '\\':
      msg = msg.replace(w.separator, "\\" & w.separator)
    else:
      msg = msg.replace(w.separator, "")
    msg &= w.separator
    payload &= msg

  try:
    w.socket.send(payload)
  except:
    # Close the socket.
    w.socket.close()
    # Enable retries by setting socket to nil.
    w.socket = nil
    if w.mustWrite:
      var msg = "SocketHandler: Could not send socket data to $1.$2: $3" % [w.host, w.port.`$`, getCurrentExceptionMsg()]
      raise newLogErr(msg)

  w.buffer = @[]

method doWrite*(w: SocketHandler, e: Entry) =
  if w.buffer.len() >= w.maxBufferSize:
    return

  w.buffer.add(e)
  if w.flushAfter > 1 and w.buffer.len() < w.flushAfter:
    # Buffer the log msg and send it later.
    return
  else:
    w.sendAll()

proc close*(w: SocketHandler, force: bool = false, wait: bool = true) =
  if not force:
    # Try to write all buffered messages.
    w.flushAfter = 1 
    w.sendAll()
  w.socket.close()

proc newSocketHandler*(
  host: string, 
  port: uint16, 
  minSeverity: Severity = Severity.CUSTOM,  
  separator: string = "\n", 
  protocol: Protocol = Protocol.TCP,
  mustWrite: bool = true,
  flushAfter: int = 1,
  connectionRetryInterval: float = 60,
  waitFor: int = 100,
  maxBufferSize: int = 1000
): SocketHandler =
  result = SocketHandler(
    `minSeverity`: minSeverity,
    `host`: host,
    `port`: port,
    `separator`: separator,
    `protocol`: protocol,
    `mustWrite`: mustWrite,
    `flushAfter`: flushAfter,
    `connectionRetryInterval`: connectionRetryInterval,
    `waitFor`: waitFor,
    `maxBufferSize`: maxBufferSize,
    buffer: @[]
  )

  result.addFormatter(newJsonFormatter())