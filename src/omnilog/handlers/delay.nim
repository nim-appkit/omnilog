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

import os

import ../../omnilog

type DelayHandler = ref object of Handler
  # DelayHandler is only used for testing thread safety.
  # It delays each write by delay ms.

  delay: int
  handler: Handler

method doWrite*(w: DelayHandler, e: Entry) =
  os.sleep(w.delay)
  w.handler.write(e)

method close*(w: DelayHandler, force: bool = false, wait: bool = true) =
  w.handler.close(force, wait)

proc newDelayHandler*(handler: Handler, delay: int = 100): DelayHandler =
  DelayHandler(
    `handler`: handler,
    `delay`: delay,
    minSeverity: Severity.CUSTOM
  )
