import alpha, omega
import nimlog

Suite "NimLog":

  Describe "Global logger":

    It "Should log":
      info("test")

    It "Should log with nested logger":
      getLogger("my.facility").withFields((a: 1, b: "x")).error("Err")
