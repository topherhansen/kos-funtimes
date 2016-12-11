set desiredSpeed to 10.
set desiredHeading to 90.

set quickPID to PIDLoop(2, 0.01, 0.3, -1, 1).
set pidThrottle to 0.
lock wheelthrottle to pidThrottle.
lock wheelsteering to desiredHeading.

// preserve?
when ag1 { set desiredHeading to desiredHeading -5. if heading < 0   { set desiredHeading to 360 - desiredHeading. preserve. } } 
when ag2 { set desiredHeading to desiredHeading +5. if heading > 360 { set desiredHeading to desiredHeading - 360. preserve. } }
when ag3 { set desiredSpeed to desiredSpeed - 1. preserve. }
when ag4 { set desiredSpeed to desiredSpeed + 1. preserve. }

set done to false.
when ag5 { set done to true. preserve. }

until done {
	print "desired speed: " + (round(desiredSpeed, 1)).
	print "ground speed : " + (round(groundSpeed,  1)).
	print "wheelthrottle: " + (round(wheelThrottle,  2)).
	print "heading: " + (round(ship:heading, 1)).
	set pidThrottle to quickPID:UPDATE(time:seconds, (desiredSpeed - ship:groundspeed)).
	wait 0.1.
	clearscreen;
}