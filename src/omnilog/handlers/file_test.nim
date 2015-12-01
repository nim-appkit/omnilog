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
from os import nil

import ../../omnilog
from ../formatters/message import Format
import file

Suite "FileHandler":
  Describe "FileHandler":

    It "Should write single file":
      var path = os.joinPath(os.getTempDir(), "omnilog_file_test.log")
      var w = newFileHandler(path=path, format=Format.SHORT.`$`, append=false)

      w.write(newEntry("", Severity.INFO, "msg"))
      path.should(beAFile())
      readFile(path).should(equal("INFO: msg\n"))

    It "Should write multiple files":
      var path = os.joinPath(os.getTempDir(), "omnilog_file_test.log")
      var w = newFileHandler(path=path, format=Format.SHORT.`$`, append=false)

      w.write(newEntry("", Severity.INFO, "info"))
      w.write(newEntry("", Severity.ERROR, "err"))
      w.write(newEntry("", Severity.ALERT, "alert"))
      path.should(beAFile())
      readFile(path).should(equal("""INFO: info
ERROR: err
ALERT: alert
"""))

