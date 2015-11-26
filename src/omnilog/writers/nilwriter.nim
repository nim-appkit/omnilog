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

from ../../omnilog import Entry, Writer, Severity, newLogErr, Formatter

from strutils import `%`

type NilWriter* = ref object of Writer
  discard

method doWrite*(w: NilWriter, e: Entry) =
  discard

method close*(w: NilWriter, force, wait: bool = false) =
  discard

proc newNilWriter*(minSeverity: Severity = Severity.CUSTOM): NilWriter =
  NilWriter(`minSeverity`: minSeverity)
