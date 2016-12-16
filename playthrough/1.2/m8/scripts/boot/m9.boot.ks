FUNCTION NOTIFY {
  PARAMETER message.
  PRINT "kOS: " + message.
  HUDTEXT ("kOS: " + message, 5, 2, 20, WHITE, false).
}

set mission to 9.

NOTIFY("SET MINMUS TARGET").
set target to minmus.

SET MYRADAR TO ALT:RADAR.
NOTIFY("Expecting radar under 50").
NOTIFY("Radar: " + MYRADAR).
IF MYRADAR < 50 {

	NOTIFY("m" + mission + " boot: load launch script").

	COPYPATH("0:/m" + mission + ".launch.ks", "1:/m9.launch.ks").
	COPYPATH("0:/autotransfer.ks", "1:/autotransfer.ks").
	COPYPATH("0:/doscience.ks","1:/doscience.ks").
	COPYPATH("0:/transferlib.ks", "1:/transferlib.ks").
	NOTIFY("m" + mission + " boot: wait 4"). WAIT 4.
	NOTIFY("m" + mission + " boot: run launch script").

	RUN transferlib.ks.
	RUN doscience.ks.
	RUN m9.launch.ks.
}
else
{
	NOTIFY("m" + mission + " boot: load launch script").
	NOTIFY("m" + mission + " boot orbit init").
	NOTIFY("m" + mission + " boot: wait 4").
	WAIT 4.
	NOTIFY("m" + mission + " boot: clean off launch script for space").
	NOTIFY("DELETE LAUNCH SCRIPT").
	deletepath("1:/m9.launch.ks").
	NOTIFY("copy transferlib").
	copypath("0:/transferlib.ks", "1:/transferlib.ks").
	run transferlib.ks.

	// maybe check for connectivity and wait loop until connected?
	NOTIFY("m" + mission + " boot: load transer script").
	COPYPATH("0:/m" + mission + ".transfer.ks","1:/m" + mission + ".transfer.ks").
	NOTIFY("m" + mission + " boot: run transfer script").
	RUN m9.transfer.ks.
	NOTIFY("finished transfer script").
}
