import alpha, omega
import times

import ../nimlog
import memory

Suite "MemoryWriter":
  Describe "MemoryWriter":

    It "Should log":
      var w = newMemoryWriter()
      var e = Entry(
        facility: "test",
        severity: Severity.INFO,
        msg: "hallo",
        time: getTime().getLocalTime()
      )
      w.write(e)

      var entries = w.getEntries()
      entries.len().should(equal(1))
      (entries[0]).should(equal(e))

    It "Should roll over when maxEntries are reached":
      var w = newMemoryWriter(maxEntries = 20)
      for i in 0..19:
        var e = Entry(
          facility: "test",
          severity: Severity.INFO,
          msg: $i,
          time: getTime().getLocalTime()
        )
        w.write(e)
      w.getEntries().len().should(equal(20))

      w.write(Entry(
        facility: "test",
        severity: Severity.INFO,
        msg: "20",
        time: getTime().getLocalTime()
      ))
      var entries = w.getEntries()
      entries.len().should(equal(17))
      entries[0].msg.should(equal("4"))
      entries[high(entries)].msg.should(equal("20"))
