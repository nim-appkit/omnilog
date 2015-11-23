import alpha, omega
from os import nil

import ../nimlog
from ../formatters/message import Format
import file

Suite "FileWriter":
  Describe "FileWriter":

    It "Should write single file":
      var path = os.joinPath(os.getTempDir(), "nimlog_file_test.log")
      var w = newFileWriter(path=path, format=Format.SHORT.`$`, append=false)

      w.write(newEntry("", Severity.INFO, "msg"))
      path.should(beAFile())
      readFile(path).should(equal("INFO: msg\n"))

    It "Should write multiple files":
      var path = os.joinPath(os.getTempDir(), "nimlog_file_test.log")
      var w = newFileWriter(path=path, format=Format.SHORT.`$`, append=false)

      w.write(newEntry("", Severity.INFO, "info"))
      w.write(newEntry("", Severity.ERROR, "err"))
      w.write(newEntry("", Severity.ALERT, "alert"))
      path.should(beAFile())
      readFile(path).should(equal("""INFO: info
ERROR: err
ALERT: alert
"""))

