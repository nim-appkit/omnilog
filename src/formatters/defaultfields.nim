#
#
#         Nimlog logging library.
# 
# (c) Christoph Herzog <chris@theduke.at> 2015
# 
# This project is under the LGPL license.
# For details, see LICENSE.txt.
# 

from ../nimlog import Formatter, Entry
from values import newValueMap, `.=`

type DefaultFieldsFormatter = ref object of Formatter
  # FieldsFormatter adds the log entries facility and and message as 
  # separate fields.
  discard

method format(f: DefaultFieldsFormatter, e: ref Entry) =
  if e[].fields == nil:
    e[].fields = newValueMap()
  e[].fields.facility = e.facility
  e[].fields.msg = e.msg

proc newFieldsFormatter*(): DefaultFieldsFormatter =
  DefaultFieldsFormatter()
