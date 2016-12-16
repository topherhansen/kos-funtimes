// pidloop
SET g TO KERBIN:MU / KERBIN:RADIUS^2.
LOCK accvec TO SHIP:SENSORS:ACC - SHIP:SENSORS:GRAV.
LOCK gforce TO accvec:MAG / g.

LOCK STEERING TO UP.

SET start TO 0.

FUNCTION TILT
{
	PARAMETER altitute.	PARAMETER angle.	PARAMETER desiredApoapsis.

	NOTIFY("Locking heading to " + angle + " degrees").
	LOCK STEERING TO HEADING(90, angle).
	SET thrott TO 1.
	LOCK THROTTLE TO thrott.

	IF start = 0 {
	    STAGE. SET start TO 1.
	}

	//SET PID:SETPOINT TO geforce.
	UNTIL SHIP:ALTITUDE > altitute or APOAPSIS > desiredApoapsis {
 	   WAIT 0.001.
	}
}

WHEN STAGE:LIQUIDFUEL < 0.1 AND STAGE:SOLIDFUEL < 0.1 THEN {
	IF start = 1 {
		NOTIFY("Ditching stage").
		STAGE.
		WAIT 1.
	}
	IF STAGE:NUMBER > 0 { PRESERVE. }
}

set desiredApo to 75000.

TILT(2000,  75,   desiredApo).
TILT(10000, 50, desiredApo).
TILT(25000, 20, desiredApo).
TILT(34000, 5, desiredApo).

LOCK THROTTLE TO 1.

NOTIFY("WAIT TO A > " + desiredApo).
WAIT UNTIL APOAPSIS > desiredApo.
LOCK THROTTLE TO 0.

LOCK STEERING TO prograde.

NOTIFY("WAIT TO ALT:RADAR > 70000").
WAIT UNTIL ALT:RADAR > 70000.

NOTIFY("Deploy Farring").
DeployFarring().
wait 1.

NOTIFY("deploy solar").
panels on.
wait 1.

NOTIFY("Create node for circularize.").
print ship:orbit:eccentricity.
circularize_node().

if hasnode { exec_node(). }

LOCK THROTTLE TO 0.
NOTIFY("Orbit achieved").
WAIT 5.

NOTIFY("deploy antenna").
DeployAntenna().

LOCK STEERING TO Heading(0,0).
LOCK THROTTLE TO 0.

NOTIFY("Ending Program").
WAIT 10.

NOTIFY("Setting pilot main throttle to 0").
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.