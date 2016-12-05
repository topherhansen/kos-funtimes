FUNCTION NOTIFY {
  PARAMETER message.
  PRINT "kOS: " + message.
  HUDTEXT ("kOS: " + message, 5, 2, 20, WHITE, false).
}

SET MYRADAR TO ALT:RADAR.
NOTIFY("Expecting radar under 50").
NOTIFY("Radar: " + MYRADAR).
IF MYRADAR < 50 {
  NOTIFY("m4 boot pad init").
  NOTIFY("m4 boot: wait 4").
  WAIT 4.
  NOTIFY("m4 boot: load launch script").
  COPYPATH("0:/m4.launch.ks","1:/m4.launch.ks").
  NOTIFY("m4 boot: run launch script").
  RUN m4.launch.ks.
  SHUTDOWN.
}
else
{
NOTIFY("m4 boot orbit init").
NOTIFY("m4 boot: wait 4").
WAIT 4.
NOTIFY("m4 boot: clean off launch script for space").
NOTIFY("DELETE LAUNCH SCRIPT").
deletepath("1:/m4.launch.ks").
NOTIFY("copy transferlib").
copypath("0:/transferlib.ks", "1:/transferlib.ks").
run transferlib.ks.

// maybe check for connectivity and wait loop until connected?
NOTIFY("m4 boot: load transer script").
COPYPATH("0:/m4.transfer.ks","1:/m4.transfer.ks").
NOTIFY("m4 boot: run transfer script").
RUN m4.transfer.ks.
NOTIFY("finished transfer script").
}