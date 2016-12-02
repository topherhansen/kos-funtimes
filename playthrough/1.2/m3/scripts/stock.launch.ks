// pidloop
SET g TO KERBIN:MU / KERBIN:RADIUS^2.
LOCK accvec TO SHIP:SENSORS:ACC - SHIP:SENSORS:GRAV.
LOCK gforce TO accvec:MAG / g.



LOCK STEERING TO HEADING(0, 90).

SET start TO 0.

FUNCTION TILT
{
	PARAMETER altitute.	PARAMETER angle.	PARAMETER geforce.

	SET Kp TO 0.01.		SET Ki TO 0.006.	SET Kd TO 0.006.
	SET PID TO PIDLOOP(Kp, Kp, Kd).

	NOTIFY("Locking heading to " + angle + " degrees").
	LOCK STEERING TO HEADING(90, angle).
	SET thrott TO 1.
	LOCK THROTTLE TO thrott.

	IF start = 0 {
	    STAGE. SET start TO 1.
	}

	//SET PID:SETPOINT TO geforce.
	UNTIL SHIP:ALTITUDE > altitute {
	    //SET thrott TO thrott + PID:UPDATE(TIME:SECONDS, gforce).
	    // pid:update() is given the input time and input and returns the output. gforce is the input.
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

TILT(2000,  75,   5).
TILT(10000, 65, 1.2).
TILT(20000, 45, 1.3).
TILT(35000, 5, 1.4).

LOCK THROTTLE TO 1.

NOTIFY("WAIT TO A > 75000").
WAIT UNTIL APOAPSIS > 75000.
LOCK THROTTLE TO 0.

NOTIFY("WAIT TO ETA < 25").
WAIT UNTIL ETA:APOAPSIS < 25.
LOCK STEERING TO HEADING(90,  0).
WAIT 5.
LOCK THROTTLE TO .2.

NOTIFY("WAIT TO P > 70000").
WAIT UNTIL PERIAPSIS > 70000.
LOCK THROTTLE TO 0.
NOTIFY("Orbit achieved").
WAIT 5.

IF STAGE:NUMBER = 3 STAGE.

WAIT 5.
SET antenna TO SHIP:PARTSDUBBED("HG-5 High Gain Antenna").
//antenna[0]:GETMODULE("ModuleDeployableAntenna"):DOEVENT("Extend Antenna").
FOR ant IN antenna {
    ant:GETMODULE("ModuleDeployableAntenna"):DOEVENT("Extend Antenna").
    // ant:GETMODULE("ModuleDeployableAntenna"):DOEVENT("Retract Antenna").
}

// point up for solar
LOCK STEERING TO Heading(0,0).
WAIT 10.
NOTIFY("Shutting down").
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0. SHUTDOWN.