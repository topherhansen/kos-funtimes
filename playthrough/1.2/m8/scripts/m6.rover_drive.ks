set desiredSpeed to 5.
set desiredHeading to 15.

set quickPID to PIDLoop(2, 0.01, 0.3, -1, 1).
set pidThrottle to 1.
lock wheelthrottle to pidThrottle.
lock wheelsteering to desiredHeading.

print "setup".
set done to 0.

print "run".

on ag1 { preserve. set desiredHeading to abs(mod(desiredHeading - 15 + 360, 360)). } 
on ag2 { preserve. set desiredHeading to abs(mod(desiredHeading + 15, 360)). }
on ag3 { preserve. set desiredSpeed to desiredSpeed - 1. }
on ag4 { preserve. set desiredSpeed to desiredSpeed + 1. }

on ag5  { preserve. brakes on. set done to 1. }
on ag6  { preserve. LOG(SHIP:LATITUDE + "," + SHIP:LONGITUDE) to "0:/waypoints.txt". }

until 0 {
	clearscreen.
	print "desired speed: " + (round(desiredSpeed, 1)).
	print "desired heading: " + (round(desiredHeading, 1)).
	print "ground speed : " + (round(groundSpeed,  1)).
	print "wheelthrottle: " + (round(wheelThrottle,  2)).
	print "heading: " + (round(ship:heading, 1)).
	set pidThrottle to quickPID:UPDATE(time:seconds, (ship:groundspeed - desiredSpeed)).
	wait 0.1.
	if done > 0 { break. }
}

print "done: " + done.
wait 10.