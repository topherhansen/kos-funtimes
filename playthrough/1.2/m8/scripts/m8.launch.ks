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

TILT(2000,  70,   desiredApo).
TILT(15000, 45, desiredApo).
TILT(25000, 15, desiredApo).
TILT(30000, 5, desiredApo).

LOCK THROTTLE TO 1.

NOTIFY("WAIT TO A > " + desiredApo).
WAIT UNTIL APOAPSIS > desiredApo.
LOCK THROTTLE TO 0.

NOTIFY("WAIT TO ETA < 25").
WAIT UNTIL ETA:APOAPSIS < 25.
LOCK STEERING TO prograde.
WAIT 5.
LOCK THROTTLE TO 1.

NOTIFY("WAIT TO P > 70000").
WAIT UNTIL PERIAPSIS > 70000.
LOCK THROTTLE TO 0.
NOTIFY("Orbit achieved").
WAIT 5.

SET antenna TO SHIP:PARTSDUBBED("HG-5 High Gain Antenna").
//antenna[0]:GETMODULE("ModuleDeployableAntenna"):DOEVENT("Extend Antenna").
FOR ant IN antenna {
    ant:GETMODULE("ModuleDeployableAntenna"):DOEVENT("Extend Antenna").
    // ant:GETMODULE("ModuleDeployableAntenna"):DOEVENT("Retract Antenna").
}

NOTIFY("deploy solar").
panels on.
LOCK STEERING TO Heading(0,0).
LOCK THROTTLE TO 0.
NOTIFY("End Program").
WAIT 10.
NOTIFY("Setting pilot main throttle to 0").
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.