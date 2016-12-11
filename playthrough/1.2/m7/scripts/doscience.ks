function GetScienceData
{
	// if data is collected twice, the container: collect all doesn't clear it
	DeleteStrayData().
	//	ListPartModules("Magnetometer Boom").
	UsePartAction("Experiment Storage Unit","ModuleScienceContainer","Collect All").
	UsePartEvent("Experiment Storage Unit","ModuleScienceContainer","Container: Collect All").
	UsePartAction("Magnetometer Boom","DMModuleScienceAnimate","deploy magnetometer").
	UsePartEvent("SETI ProbeSTACK 1","ModuleScienceExperiment","Log Temperature").
	UsePartEvent("PresMat Barometer","ModuleScienceExperiment","Log Pressure Data").
	UsePartEvent("Double-C Seismic Accelerometer","ModuleScienceExperiment","log seismic data").
	UsePartEvent("2HOT Thermometer","ModuleScienceExperiment","Log Temperature").

	UsePartEvent("Submersible Oceanography and Bathymetry","DMBathymetry","Collect Bathymetry Data").
	
	wait 5. // wait for animation to do science
	UsePartEvent("Magnetometer Boom","DMModuleScienceAnimate","log magnetometer data").
	UsePartAction("Magnetometer Boom","DMModuleScienceAnimate","retract magnetometer").	
	wait 5. // wait to ensure everything scienced before collection
	
	NOTIFY("Collect data!").
	UsePartEvent("Experiment Storage Unit","ModuleScienceContainer","Container: Collect All").	
	UsePartAction("Experiment Storage Unit","ModuleScienceContainer","Collect All").
}

function UsePart
{
	parameter partName.
	parameter moduleName.
	parameter eventActionName.

	UsePartEvent(partName, moduleName, eventActionName).
	UsePartAction(partName, moduleName, eventActionName).
}

function UsePartEvent
{
	parameter partName.
	parameter moduleName.
	parameter eventName.

	print "use part: " + partName + " " + moduleName + " " + eventName.

	SET antenna TO SHIP:PARTSDUBBED(partName).
	FOR ant IN antenna {
		print "has event: " + ant:GETMODULE(moduleName):hasevent(eventName).
		if ant:GETMODULE(moduleName):hasevent(eventName) { ant:GETMODULE(moduleName):DOEVENT(eventName). wait 0.1. }
	}
}

function UsePartAction
{
	parameter partName.
	parameter moduleName.
	parameter actionName.

	print "use part: " + partName + " " + moduleName + " " + actionName.

	SET antenna TO SHIP:PARTSDUBBED(partName).
	FOR ant IN antenna {
		if ant:GETMODULE(moduleName):hasaction(actionName) { ant:GETMODULE(moduleName):DOAction(actionName, true). wait 0.1. }
	}
}

function DeployAntenna
{
	UsePart("HG-5 High Gain Antenna", "ModuleDeployableAntenna", "Extend Antenna").
}


function DeleteStrayData
{
	UsePart("SETI ProbeSTACK 1","ModuleScienceExperiment","delete data").
	UsePart("PresMat Barometer","ModuleScienceExperiment","delete data").
	UsePart("Double-C Seismic Accelerometer","ModuleScienceExperiment","delete data").
	UsePart("2HOT Thermometer","ModuleScienceExperiment","delete data").
	UsePart("Magnetometer Boom","DMModuleScienceAnimate","discard Magnetometer data").
	// possibly discard bathymetry data
	UsePart("Submersible Oceanography and Bathymetry","DMBathymetry","discard bathymetry data").
	UsePart("Submersible Oceanography and Bathymetry","DMBathymetry","Delete Data").
}

function ListPartModules
{
	parameter partName.
	set p to ship:partsdubbed(partname).
	set mods to p[0]:modules.
	print partName + " has " + mods:length + " modules".
	print mods.
	for mo in mods
	{
		set mod to p[0]:getmodule(mo).
		print mod.
		set NAMELIST to "0:/namelist.txt".
		LOG (partName + ":" + mod) to NAMELIST.
		
		LOG ("These are all the things that I can currently USE GETFIELD AND SETFIELD ON IN " + MOD + ":") TO NAMELIST.
		LOG MOD:ALLFIELDS TO NAMELIST.
		
		LOG ("These are all the things that I can currently USE DOEVENT ON IN " +  MOD + ":") TO NAMELIST.
		LOG MOD:ALLEVENTS TO NAMELIST.
		
		LOG ("These are all the things that I can currently USE DOACTION ON IN " +  MOD + ":") TO NAMELIST.
		LOG MOD:ALLACTIONS TO NAMELIST.
	}
}