declare function print_current
{
	print_orbit(ship:orbit).
}

declare function print_node
{
	if hasnode { print_orbit(nextnode:orbit). } else { print "no node to print". }
}

declare function print_orbit
{
	parameter orbitPrinter.
	print "name: " + orbitPrinter:name.
	print "APOAPSIS: " + orbitPrinter:APOAPSIS.
	print "PERIAPSIS: " + orbitPrinter:PERIAPSIS.
	print "BODY: " + orbitPrinter:BODY.
	print "PERIOD: " + orbitPrinter:PERIOD.
	print "INCLINATION: " + orbitPrinter:INCLINATION.
	print "ECCENTRICITY: " + orbitPrinter:ECCENTRICITY.
	print "SEMIMAJORAXIS: " + orbitPrinter:SEMIMAJORAXIS.
	print "SEMIMINORAXIS: " + orbitPrinter:SEMIMINORAXIS.
	print "LONGITUDEOFASCENDINGNODE: " + orbitPrinter:LONGITUDEOFASCENDINGNODE.
	print "ARGUMENTOFPERIAPSIS: " + orbitPrinter:ARGUMENTOFPERIAPSIS.
	print "TRUEANOMALY: " + orbitPrinter:TRUEANOMALY.
	print "MEANANOMALYATEPOCH: " + orbitPrinter:MEANANOMALYATEPOCH.
	print "TRANSITION: " + orbitPrinter:TRANSITION.
	print "POSITION: " + orbitPrinter:POSITION.
	print "VELOCITY: " + orbitPrinter:VELOCITY.
	print "HASNEXTPATCH: " + orbitPrinter:HASNEXTPATCH.
	if orbitPrinter:HASNEXTPATCH { 	print "NEXTPATCH: " + orbitPrinter:NEXTPATCH. }
	if orbitPrinter:HASNEXTPATCH { 	print "NEXTPATCHETA: " + orbitPrinter:NEXTPATCHETA. }
}

declare function circularize_node
{
	local r is 0.
	local n is 0.
	local p is 0.1.
	local targetEccentricity is 0.0001.

	// this needs to be able to seek both + and -
	set nd to node(time:seconds + eta:apoapsis, r, n, p). // t, r, n , p
	local ndAfter is reduce_eccentricity(nd, targetEccentricity, 100).

	set ndAfterMinus to reduce_eccentricity(ndAfter, targetEccentricity, 10).
	set ndAfterPlus to reduce_eccentricity(ndAfter, targetEccentricity, -10).
	set ndAfter to getSmallerEcc(ndAfterMinus, ndAfterPlus).
	
	set ndAfterMinus to reduce_eccentricity(ndAfter, targetEccentricity, 1).
	set ndAfterPlus to reduce_eccentricity(ndAfter, targetEccentricity, -1).
	set ndAfter to getSmallerEcc(ndAfterMinus, ndAfterPlus).

	set ndAfterMinus to reduce_eccentricity(ndAfter, targetEccentricity, .1).
	set ndAfterPlus to reduce_eccentricity(ndAfter, targetEccentricity, -.1).
	set ndAfter to getSmallerEcc(ndAfterMinus, ndAfterPlus).

	add ndAfter.
}

declare function planeMatch
{
	// make node with .1 normal
	// move node time by 500, 50, 5, .5 until targetBody:lan ~ node:lan targetBody:inclination ~ node:inclination
	// move node normal by 100, 10, 1, .1 until 
}

declare function getSmallerEcc
{
	parameter a. parameter b.

	add a.
	local aEcc is a:orbit:eccentricity.
	remove a.
	add b.
	local bEcc is b:orbit:eccentricity.
	remove b.
	if aEcc < bEcc { return a. } else { return b. }
}

declare function reduce_eccentricity
{
	parameter nd.
	parameter targetEccentricty.
	parameter progradeBump.

	add nd.

	local r is 0.
	local n is 0.
	local p is nd:prograde.
	local startEccentricity is nd:orbit:eccentricity.

	// print "reduce eccentricity: " + targetEccentricty + " " + progradeBump.

	until nd:orbit:eccentricity < targetEccentricty
	{
		remove nd.
		// print "bring it up by " + progradeBump.
		set p to p + progradeBump.
		set nd to node(time:seconds + eta:apoapsis, r, n, p).
		add nd.

		if nd:orbit:hasnextpatch or startEccentricity < nd:orbit:eccentricity
		{
			remove nd.
			set nd to node(time:seconds + eta:apoapsis, r, n, p - progradeBump).
			return nd.
		}
		// print "prograde: " + p.
		// print "estimated eccentricity: " + nd:orbit:eccentricity.
	}
	remove nd.
	return nd.
}

declare function exec_node
{
set nd to nextnode.

//print out node's basic parameters - ETA and deltaV
print "Node in: " + round(nd:eta) + ", DeltaV: " + round(nd:deltav:mag).

//calculate ship's max acceleration
set max_acc to ship:maxthrust/ship:mass.

// Now we just need to divide deltav:mag by our ship's max acceleration
// to get the estimated time of the burn.
//
// Please note, this is not exactly correct.  The real calculation
// needs to take into account the fact that the mass will decrease
// as you lose fuel during the burn.  In fact throwing the fuel out
// the back of the engine very fast is the entire reason you're able
// to thrust at all in space.  The proper calculation for this
// can be found easily enough online by searching for the phrase
//   "Tsiolkovsky rocket equation".
// This example here will keep it simple for demonstration purposes,
// but if you're going to build a serious node execution script, you
// need to look into the Tsiolkovsky rocket equation to account for
// the change in mass over time as you burn.
//
set burn_duration to nd:deltav:mag/max_acc.
print "Crude Estimated burn duration: " + round(burn_duration) + "s".


if nd:eta < burn_duration/2 - 30 
{
	NOTIFY("ETA < burn start - 30").
	return.
}

kuniverse:timewarp:warpto(time:seconds + nd:eta - burn_duration/2 - 30).
// wait until nd:eta <= (burn_duration/2 + 30).

lock np to nd:deltav. //points to node, don't care about the roll direction.
lock steering to np.


//now we need to wait until the burn vector and ship's facing are aligned
// wait until abs(np:pitch - facing:pitch) < 0.15 and abs(np:yaw - facing:yaw) < 0.15.

//the ship is facing the right direction, let's wait for our burn time
wait until nd:eta <= (burn_duration/2).




//we only need to lock throttle once to a certain variable in the beginning of the loop, and adjust only the variable itself inside it
set tset to 0.
lock throttle to tset.

set done to False.
//initial deltav
set dv0 to nd:deltav.
until done
{
    //recalculate current max_acceleration, as it changes while we burn through fuel
    set max_acc to ship:maxthrust/ship:mass.

    //throttle is 100% until there is less than 1 second of time left to burn
    //when there is less than 1 second - decrease the throttle linearly
    set tset to min(nd:deltav:mag/max_acc, 1).

    //here's the tricky part, we need to cut the throttle as soon as our nd:deltav and initial deltav start facing opposite directions
    //this check is done via checking the dot product of those 2 vectors
    if vdot(dv0, nd:deltav) < 0
    {
        print "End burn, remain dv " + round(nd:deltav:mag,1) + "m/s, vdot: " + round(vdot(dv0, nd:deltav),1).
        lock throttle to 0.
        break.
    }

    //we have very little left to burn, less then 0.1m/s
    if nd:deltav:mag < 0.1
    {
        print "Finalizing burn, remain dv " + round(nd:deltav:mag,1) + "m/s, vdot: " + round(vdot(dv0, nd:deltav),1).
        //we burn slowly until our node vector starts to drift significantly from initial vector
        //this usually means we are on point
        wait until vdot(dv0, nd:deltav) < 0.5.

        lock throttle to 0.
        print "End burn, remain dv " + round(nd:deltav:mag,1) + "m/s, vdot: " + round(vdot(dv0, nd:deltav),1).
        set done to True.
    }
}
unlock steering.
unlock throttle.
wait 1.

//we no longer need the maneuver node
remove nd.

//set throttle to 0 just in case.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
}