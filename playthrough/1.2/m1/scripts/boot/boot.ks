FUNCTION NOTIFY {
  PARAMETER message.
  PRINT "kOS: " + message.
  HUDTEXT ("kOS: " + message, 5, 2, 20, WHITE, false).
}

NOTIFY("stock boot init").

SET MYRADAR TO ALT:RADAR.
NOTIFY("Expecting radar under 50").
NOTIFY("Radar: " + MYRADAR).
IF MYRADAR < 50 {
  NOTIFY("stock boot: wait 10").
  WAIT 10.
  NOTIFY("stock boot: load launch script").
  COPYPATH("0:/stock.launch.ks","1:/stock.launch.ks").
  NOTIFY("stock boot: load abort script").
  COPYPATH("0:/stock.abort.ks","1:/stock.abort.ks").
  NOTIFY("stock boot: run launch script").
  RUN stock.launch.ks.
} ELSE {
  NOTIFY("stock boot: maybe run abort script").
  RUN stock.abort.ks.
}
