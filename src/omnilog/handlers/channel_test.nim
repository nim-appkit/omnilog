discard """
import os, threadpool
from strutils import countLines

import alpha, omega

import ../omnilog
import ../formatters/message
import channel, file, delay
proc threadWrite(w: ptr ChannelHandler) =
  var w = w[]
  w.write(newEntry("facility", Severity.INFO, "msg"))

Suite "ChannelHandler":

  Describe("ChannelHandler"):

    It "Should work":
      var path = os.joinPath(os.getTempDir(), "omnilog_channel_test.log")
      var fileW = newFileHandler(path=path, append=false)
      fileW.clearFormatters()
      fileW.addFormatter(newMessageFormatter(format=Format.SHORT))
      var w = newChannelHandler(fileW)
      w.run()


      w.write(newEntry("facility", Severity.INFO, "msg"))
      w.close()

      path.should(beAFile())
      readFile(path).should(equal("INFO: msg\n"))

    It "Should wait until all writes have finished":
      var path = os.joinPath(os.getTempDir(), "omnilog_channel_test.log")
      var fileW = newFileHandler(path=path, append=false)
      fileW.clearFormatters()
      fileW.addFormatter(newMessageFormatter(format=Format.SHORT))

      var delayW = newDelayHandler(filew)
      
      var w = newChannelHandler(delayW)
      w.run()

      for i in 1..10:
        w.write(newEntry("facility", Severity.INFO, "msg"))
      w.close()

      path.should(beAFile())
      readFile(path).countLines().should(equal(10))

    It "Should be thread-safe":
      var path = os.joinPath(os.getTempDir(), "omnilog_channel_test.log")
      var fileW = newFileHandler(path=path, append=false)
      fileW.clearFormatters()
      fileW.addFormatter(newMessageFormatter(format=Format.SHORT))

      var delayW = newDelayHandler(filew, 200)
       
      var w = newChannelHandler(delayW)
      w.run()

      var wRef: ptr ChannelHandler = addr w

      var threads = newSeq[Thread[ptr ChannelHandler]](15)
      for i in 1..10:
        createThread(threads[i], threadWrite, wRef)

      os.sleep(20)
      w.close()

      path.should(beAFile())
      readFile(path).countLines().should(equal(10)) 

omega.run()
"""