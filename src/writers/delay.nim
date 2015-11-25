#
#
#         Nimlog logging library.
# 
# (c) Christoph Herzog <chris@theduke.at> 2015
# 
# This project is under the LGPL license.
# For details, see LICENSE.txt.
# 

import os

import ../nimlog

type DelayWriter = ref object of Writer
  # DelayWriter is only used for testing thread safety.
  # It delays each write by delay ms.

  delay: int
  writer: Writer

method doWrite*(w: DelayWriter, e: Entry) =
  os.sleep(w.delay)
  w.writer.write(e)

method close*(w: DelayWriter, force: bool = false, wait: bool = true) =
  w.writer.close(force, wait)

proc newDelayWriter*(writer: Writer, delay: int = 100): DelayWriter =
  DelayWriter(
    `writer`: writer,
    `delay`: delay,
    minSeverity: Severity.CUSTOM
  )
