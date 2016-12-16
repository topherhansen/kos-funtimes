set desiredSpeed to 0.
set desiredHeading to prograde.

//set waypoints to lexicon().
//set waypoint to ship:geoposition.
//waypoints:add(0,waypoint).
//waypoints:add(1,waypoint).
//waypoints:add(2,waypoint).
//writejson(waypoints, "0:/start_json.txt").

set waypoints to readjson("1:/startpoint_json.txt").

// SET PID TO PIDLOOP(KP, KI, KD, MINOUTPUT, MAXOUTPUT).
set quickPID to PIDLoop(.16, 0.01, 0.3, -1, 1).
set pidThrottle to 0.

print "setup".
set done to 0.
panels on.
print "run".
brakes off.
set waypointIndex to 0.
set vectorDrawList to list().

until waypointIndex = waypoints:length
{
	set wI to 0.
	vectorDrawList:clear().
	CLEARVECDRAWS().
	until wI = waypoints:length
	{
		set waypoint to latlng(waypoints[wI]:lat, waypoints[wI]:lng).
		vectorDrawList:add(VECDRAWARGS(
	             waypoint:ALTITUDEPOSITION(waypoint:TERRAINHEIGHT+100),
        	     waypoint:POSITION - waypoint:ALTITUDEPOSITION(waypoint:TERRAINHEIGHT+100),
	             blue, "waypoint " + wI, 1, true)).
		set wI to wI + 1.
	}

	clearscreen.
	// setup current waypoint		
	// there's one there... don't worry
	set waypoint to latlng(waypoints[waypointIndex]:lat, waypoints[waypointIndex]:lng).
	set desiredHeading to waypoint:heading.
	set desiredSpeed to 8.
	
	lock wheelthrottle to pidThrottle.
	lock wheelsteering to desiredHeading.

	// drive towards it
	print "waypoints length: " + waypoints:length.
	print "waypoints current: " + waypointIndex.
	print "waypoint(lat,lng): " + waypoint:lat + ", " + waypoint:lng.
	print "waypoint:heading " +  waypoint:heading.
	print "waypoint:terrainheight " + waypoint:terrainheight.
	print "location: " + ship:geoposition:lat + ", " + ship:geoposition:lng.
	print "distance: " + (round(waypoint:distance, 1)).
	print "desired speed: " + (round(desiredSpeed, 1)).
	print "desired heading: " + (round(desiredHeading, 1)).
	print "actual heading: " + (round(ship:heading, 1)).
	print "ground speed : " + (round(groundSpeed,  1)).
	print "wheelthrottle: " + (round(wheelThrottle,  2)).
	print "heading: " + (round(ship:heading, 1)).
	set pidThrottle to quickPID:UPDATE(time:seconds, (ship:groundspeed - desiredSpeed)).
	wait 0.02.

		// drop waypoint if close enough and do science
	if waypoint:distance < 4
	{
		brakes on.
		set waypointIndex to waypointIndex + 1.
		NOTIFY("do science!").
		GetScienceData().
		brakes off.
	}
}

brakes on.
print "done: " + done.
wait 10.