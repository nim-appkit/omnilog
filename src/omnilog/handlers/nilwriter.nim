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

from ../../omnilog import Entry, Handler, Severity, newLogErr, Formatter

from strutils import `%`

type NilHandler* = ref object of Handler
  discard

method doWrite*(w: NilHandler, e: Entry) =
  discard

method close*(w: NilHandler, force, wait: bool = false) =
  discard

proc newNilHandler*(minSeverity: Severity = Severity.CUSTOM): NilHandler =
  NilHandler(`minSeverity`: minSeverity)
