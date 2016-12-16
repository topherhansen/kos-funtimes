FUNCTION NOTIFY {
  PARAMETER message.
  PRINT "kOS: " + message.
  HUDTEXT ("kOS: " + message, 5, 2, 20, WHITE, false).
}

NOTIFY("m4 boot pad init").
NOTIFY("m4 boot: wait 4").
WAIT 4.
NOTIFY("m4 boot: load launch script").
COPYPATH("0:/m6.rover_drive.ks","1:/m6.rover_drive.ks").
NOTIFY("m4 boot: run launch script").
RUN m6.rover_drive.ks.
