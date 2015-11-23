import alpha, omega
import nimlog

Suite "NimLog":

  Describe "Global logger":

    It "Should log":
      info("test")