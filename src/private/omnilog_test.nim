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
import ../omnilog, ../omnilog/handlers/memory


Suite "NimLog":
  
  Describe "Basic logging":

    Describe "Logger":
      var l = newRootLogger(withDefaultHandler = false)
      l.setFacility("test")
      var mem = newMemoryHandler()
      l.addHandler("memory", mem)

      l.emergency("emergency") 
      l.emergency("emergency $1 $2", 3.33, false)

      l.alert("alert") 
      l.alert("alert $1 $2", 3.33, false)

      l.critical("critical") 
      l.critical("critical $1 $2", 3.33, false)

      l.error("error") 
      l.error("error $1 $2", 3.33, false)

      l.warning("warning") 
      l.warning("warning $1 $2", 3.33, false)

      l.notice("notice") 
      l.notice("notice $1 $2", 3.33, false)

      l.info("info") 
      l.info("info $1 $2", 3.33, false)

      l.debug("debug") 
      l.debug("debug $1 $2", 3.33, false)

      l.trace("trace") 
      l.trace("trace $1 $2", 3.33, false)

      var entries = @[
        newEntry("test", Severity.EMERGENCY, "emergency"),
        newEntry("test", Severity.EMERGENCY, "emergency 3.33 false"),

        newEntry("test", Severity.ALERT, "alert"),
        newEntry("test", Severity.ALERT, "alert 3.33 false"),

        newEntry("test", Severity.CRITICAL, "critical"),
        newEntry("test", Severity.CRITICAL, "critical 3.33 false"),

        newEntry("test", Severity.ERROR, "error"),
        newEntry("test", Severity.ERROR, "error 3.33 false"),

        newEntry("test", Severity.WARNING, "warning"),
        newEntry("test", Severity.WARNING, "warning 3.33 false"),

        newEntry("test", Severity.NOTICE, "notice"),
        newEntry("test", Severity.NOTICE, "notice 3.33 false"),

        newEntry("test", Severity.INFO, "info"),
        newEntry("test", Severity.INFO, "info 3.33 false"),

        newEntry("test", Severity.DEBUG, "debug"),
        newEntry("test", Severity.DEBUG, "debug 3.33 false"),

        newEntry("test", Severity.TRACE, "trace"),
        newEntry("test", Severity.TRACE, "trace 3.33 false")
      ]

      mem.getEntries().should equal entries


  Describe "Global logger":
    discard

