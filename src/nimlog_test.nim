import alpha, omega
import nimlog

Suite "NimLog":

  Describe "Global logger":

    # TODO: proper tests!!

    It "Should log":
      info("test")

    It "Should log with nested logger":
      getLogger("my.facility").withFields((a: 1, b: "x")).error("Err")
