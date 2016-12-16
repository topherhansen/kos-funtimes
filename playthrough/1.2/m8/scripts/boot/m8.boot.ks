FUNCTION NOTIFY {
  PARAMETER message.
  PRINT "kOS: " + message.
  HUDTEXT ("kOS: " + message, 5, 2, 20, WHITE, false).
}

set mission to 8.

SET MYRADAR TO ALT:RADAR.
NOTIFY("Expecting radar under 50").
NOTIFY("Radar: " + MYRADAR).
IF MYRADAR < 50 {

	NOTIFY("m" + mission + " boot: load launch script").

	COPYPATH("0:/m" + mission + ".launch.ks", "1:/m8.launch.ks").
	COPYPATH("0:/autotransfer.ks", "1:/autotransfer.ks").
	COPYPATH("0:/doscience.ks","1:/doscience.ks").

	NOTIFY("m" + mission + " boot: wait 4"). WAIT 4.
	NOTIFY("m" + mission + " boot: run launch script").

	RUN "doscience.ks".
	RUN m8.launch.ks.
}
else
{
	NOTIFY("m" + mission + " boot: load launch script").
	NOTIFY("m" + mission + " boot orbit init").
	NOTIFY("m" + mission + " boot: wait 4").
	WAIT 4.
	NOTIFY("m" + mission + " boot: clean off launch script for space").
	NOTIFY("DELETE LAUNCH SCRIPT").
	deletepath("1:/m8.launch.ks").
	NOTIFY("copy transferlib").
	copypath("0:/transferlib.ks", "1:/transferlib.ks").
	run transferlib.ks.

	// maybe check for connectivity and wait loop until connected?
	NOTIFY("m" + mission + " boot: load transer script").
	COPYPATH("0:/m" + mission + ".transfer.ks","1:/m" + mission + ".transfer.ks").
	NOTIFY("m" + mission + " boot: run transfer script").
	RUN m8.transfer.ks.
	NOTIFY("finished transfer script").
}
