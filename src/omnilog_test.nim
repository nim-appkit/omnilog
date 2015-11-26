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
import omnilog

Suite "NimLog":

  Describe "Global logger":

    # TODO: proper tests!!

    It "Should log":
      info("test")

    It "Should log with nested logger":
      getLogger("my.facility").withFields((a: 1, b: "x")).error("Err")
