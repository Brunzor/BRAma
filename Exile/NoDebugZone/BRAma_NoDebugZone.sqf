/**
 * BRAma_NoDebugZone.sqf
 *
 * Zeus the Pants of Debug vehicle Farmers.
 *
 * Brun
 * BRAma.brunsolutions.com.au
 * © 2015 BRAma
 *
 */
 
switch (WorldName) do
{
    case "Esseker":   { BRAma_upperLimit = 12288; };
    case "Chernarus": { BRAma_upperLimit = 15360; };
    default           { BRAma_upperLimit = 20000; };	
};

BRAma_isInDebugZone = false;
BRAma_noDebugZoneTime = 30;
BRAma_noDebugZoneWarningTime = BRAma_noDebugZoneTime / 2;

//Warnings and Messages
BRAma_DebugZoneMessage1 = format["ATTENTION",  name player];
BRAma_DebugZoneMessage2 = format["You are falling off side of the Earth!"];
BRAma_DebugZoneMessage3 = format["You have %1 Seconds to Turn Back!",  BRAma_noDebugZoneTime];

BRAma_DebugZoneFinalMessage1 = format["FINAL WARNING TURN BACK NOW",  name player];
BRAma_DebugZoneFinalMessage2 = format["You have %1 Seconds to Comply!",  BRAma_noDebugZoneWarningTime];

BRAma_DebugZoneKillMessage1 = format["You Angered the Gods!"];
BRAma_DebugZoneKillMessage2 = format["Stay away from the edge of the earth!"];

[] spawn
{
    while {true} do
    {

		if (getposatl player select 0 <= 0 || getposatl player select 0 >= BRAma_upperLimit || getposatl player select 1 <= 0 || getposatl player select 1 >= BRAma_upperLimit)  then
		{    
			if (BRAma_isInDebugZone) then 
			{
				BRAma_isInDebugZone = false;					
			    [player, nil, true] spawn BIS_fnc_moduleLightning;				
				player setdamage 1;	

				[
					[
						[BRAma_DebugZoneKillMessage1,"<t align = 'center' shadow = '1' size = '0.8' font='OrbitronLight'>%1</t><br/>"],
						[BRAma_DebugZoneKillMessage2,"<t align = 'center' shadow = '1' size = '0.8' font='OrbitronLight'>%1</t><br/>",100]
					]
				] spawn BIS_fnc_typeText;
				
				uisleep 125; // Tapout timer
			}
			else
			{
				BRAma_isInDebugZone = true;
				
				[
					[
						[BRAma_DebugZoneMessage1,"<t align = 'left' shadow = '1' size = '0.8' font='OrbitronLight'>%1</t><br/><br/>"],
						[BRAma_DebugZoneMessage2,"<t align = 'left' shadow = '1' size = '0.6' font='OrbitronLight'>%1</t><br/><br/>"],
						[BRAma_DebugZoneMessage3,"<t align = 'left' shadow = '1' size = '0.6' font='OrbitronLight'>%1</t><br/>"]
					]
				] spawn BIS_fnc_typeText;
				
				uisleep BRAma_noDebugZoneWarningTime;				
								
				if (getposatl player select 0 <= 0 || getposatl player select 0 >= BRAma_upperLimit || getposatl player select 1 <= 0 || getposatl player select 1 >= BRAma_upperLimit)  then
					
				{
					
				[
					[
						[BRAma_DebugZoneFinalMessage1,"<t align = 'left' shadow = '1' size = '0.8' font='OrbitronLight'>%1</t><br/><br/>"],
						[BRAma_DebugZoneFinalMessage2,"<t align = 'left' shadow = '1' size = '0.6' font='OrbitronLight'>%1</t><br/><br/>"]
					]
				] spawn BIS_fnc_typeText;
				
				uisleep BRAma_noDebugZoneWarningTime;
				
				};
				
			};
		} else
		{
			uisleep BRAma_noDebugZoneTime;
			BRAma_isInDebugZone = false;	
		};

    };
};