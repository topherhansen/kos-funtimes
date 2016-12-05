SET start TO 0.

WHEN STAGE:LIQUIDFUEL < 0.1 AND STAGE:SOLIDFUEL < 0.1 THEN {
	IF start = 1 {
		NOTIFY("Ditching stage").
		STAGE.
		WAIT 1.
	}
	IF STAGE:NUMBER > 0 { PRESERVE. }
}

NOTIFY("SET MINMUS TARGET").
set target to minmus.

if hasnode { exec_node(). }

WAIT 5. NOTIFY("keep alive").
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.