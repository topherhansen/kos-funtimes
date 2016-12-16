FUNCTION NOTIFY {
  PARAMETER message.
  PRINT "kOS: " + message.
  HUDTEXT ("kOS: " + message, 5, 2, 20, WHITE, false).
}

NOTIFY("m4 boot pad init").
NOTIFY("m4 boot: wait 4").
WAIT 4.
NOTIFY("m4 boot: load launch script").
NOTIFY("copy rover script").
COPYPATH("0:/m7.rover_drive.ks", "1:/m7.rover_drive.ks").
NOTIFY("copy start waypoints").
COPYPATH("0:/startpoint_json.txt", "1:/startpoint_json.txt").
NOTIFY("copy science library").
COPYPATH("0:/doscience.ks","1:/doscience.ks").
NOTIFY("m4 boot: run launch script").
RUN doscience.ks.
RUN m7.rover_drive.ks.
