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

import alpha, omega
import net, nativesockets
from strutils import endsWith
import macros

import ../../omnilog
import socket

type StubServer* = ref object of RootObj
  separator*: string
  receivedMessages*: seq[string]
  socket*: Socket

proc newStubServer*(port: uint16 = 9991, separator: string = "\n"): StubServer =
  result = StubServer(
    `separator`: separator,
    receivedMessages: @[],
    socket: newSocket()
  )

  result.socket.bindAddr(Port(port))
  result.socket.listen()

proc receive*(s: StubServer) =
  var clientSock: Socket
  new(clientSock) 
  s.socket.accept(clientSock)

  var data = ""
  var buffer = ""
  while clientSock.recv(buffer, 1) != 0:
    data &= buffer
    if data.endsWith(s.separator):
      s.receivedMessages.add(data[0..high(data) - s.separator.len()])
      echo("received msg: ", s.receivedMessages[high(s.receivedMessages)])

proc clearMessages*(s: StubServer) =
  s.receivedMessages = @[]

proc close*(s: StubServer) =
  s.socket.close()

Suite "SocketHandler":

  Describe "SocketHandler":

    It "Should send messages":
      var server = newStubServer()
      var w = newSocketHandler("localhost", 9991)
      w.write(newEntry("facility", Severity.INFO, "msg"))
      w.write(newEntry("facility", Severity.ALERT, "msg 2"))
      w.close()

      server.receive()
      server.close()

      server.receivedMessages.should haveLen 2
