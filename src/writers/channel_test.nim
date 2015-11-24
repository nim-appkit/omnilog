discard """
import os, threadpool
from strutils import countLines

import alpha, omega

import ../nimlog
import ../formatters/message
import channel, file, delay
proc threadWrite(w: ptr ChannelWriter) =
  var w = w[]
  w.write(newEntry("facility", Severity.INFO, "msg"))

Suite "ChannelWriter":

  Describe("ChannelWriter"):

    It "Should work":
      var path = os.joinPath(os.getTempDir(), "nimlog_channel_test.log")
      var fileW = newFileWriter(path=path, append=false)
      fileW.clearFormatters()
      fileW.addFormatter(newMessageFormatter(format=Format.SHORT))
      var w = newChannelWriter(fileW)
      w.run()


      w.write(newEntry("facility", Severity.INFO, "msg"))
      w.close()

      path.should(beAFile())
      readFile(path).should(equal("INFO: msg\n"))

    It "Should wait until all writes have finished":
      var path = os.joinPath(os.getTempDir(), "nimlog_channel_test.log")
      var fileW = newFileWriter(path=path, append=false)
      fileW.clearFormatters()
      fileW.addFormatter(newMessageFormatter(format=Format.SHORT))

      var delayW = newDelayWriter(filew)
      
      var w = newChannelWriter(delayW)
      w.run()

      for i in 1..10:
        w.write(newEntry("facility", Severity.INFO, "msg"))
      w.close()

      path.should(beAFile())
      readFile(path).countLines().should(equal(10))

    It "Should be thread-safe":
      var path = os.joinPath(os.getTempDir(), "nimlog_channel_test.log")
      var fileW = newFileWriter(path=path, append=false)
      fileW.clearFormatters()
      fileW.addFormatter(newMessageFormatter(format=Format.SHORT))

      var delayW = newDelayWriter(filew, 200)
       
      var w = newChannelWriter(delayW)
      w.run()

      var wRef: ptr ChannelWriter = addr w

      var threads = newSeq[Thread[ptr ChannelWriter]](15)
      for i in 1..10:
        createThread(threads[i], threadWrite, wRef)

      os.sleep(20)
      w.close()

      path.should(beAFile())
      readFile(path).countLines().should(equal(10)) 

omega.run()
"""