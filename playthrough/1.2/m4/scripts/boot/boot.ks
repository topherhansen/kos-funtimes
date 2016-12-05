FUNCTION NOTIFY {
  PARAMETER message.
  PRINT "kOS: " + message.
  HUDTEXT ("kOS: " + message, 5, 2, 20, WHITE, false).
}

NOTIFY("stock boot init").
NOTIFY("stock boot: wait 4").
WAIT 4.
NOTIFY("stock boot: load launch script").
COPYPATH("0:/stock.launch.ks","1:/stock.launch.ks").
NOTIFY("stock boot: run launch script").
RUN stock.launch.ks.
