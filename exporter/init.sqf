if (isClass (configFile >> "CfgPatches" >> "Ares")) then
{
	[
		"Retake", 
		"Export for Retake",
		{
			_objectsToFilter = curatorEditableObjects (allCurators select 0);
			_emptyObjects = [];
			_emptyVehicles = [];
			_groups = [];
			{
				_ignoreFlag = false;
				if ((typeOf _x) in Ares_EditableObjectBlacklist || _x == player || isPlayer _x) then
				{
					systemChat format ["Objekt on Blacklist: %1 - %2", _x, typeof(_x)];
					_ignoreFlag = true;
				};

				if (!_ignoreFlag) then
				{
					["Processing object: %1 - %2", _x, typeof(_x)] call Ares_fnc_LogMessage;
					_ignoreFlag = true;
					_isUnit = (_x isKindOf "CAManBase")
						|| (_x isKindOf "car")
						|| (_x isKindOf "tank")
						|| (_x isKindOf "air")
						|| (_x isKindOf "StaticWeapon")
						|| (_x isKindOf "ship");
					if (_isUnit) then
					{
						if (_x isKindOf "CAManBase") then
						{
							["Is a man."] call Ares_fnc_LogMessage;
							if ((group _x) in _groups) then
							{
								["In an old group."] call Ares_fnc_LogMessage;
							}
							else
							{
								["In a new group."] call Ares_fnc_LogMessage;
								_groups pushBack (group _x);
							};
							
						}
						else
						{
							if (count crew _x > 0) then
							{
								["Is a vehicle with units."] call Ares_fnc_LogMessage;
								if ((group _x) in _groups) then
								{
									["In an old group."] call Ares_fnc_LogMessage;
								}
								else
								{
									["In a new group."] call Ares_fnc_LogMessage;
									_groups pushBack (group _x);
								};
							}
							else
							{
								["Is an empty vehicle."] call Ares_fnc_LogMessage;
								_emptyVehicles pushBack _x;
							};
						};
					}
					else
					{
						if (_x isKindOf "Logic") then
						{
							["Is a logic. Ignoring."] call Ares_fnc_LogMessage;
						}
						else
						{
							["Is an empty vehicle."] call Ares_fnc_LogMessage;
							_emptyObjects pushBack _x;
						};
					};
				}
				else
				{
					["Ignoring object: %1 - %2", _x, typeof(_x)] call Ares_fnc_LogMessage;
				};
			} forEach _objectsToFilter;
			
			_output = [];
			if (!_includeUnits) then { _groups = []; };
			if (!_includeEmptyVehicles) then { _emptyVehicles = []; };
			if (!_includeEmptyObjects) then { _emptyObjects = []; };
			_totalUnitsProcessed = 0;
			_outputVehicle pushBack "_vehicleArray = [";
			{
				_outputVehicle pushBack format [
					"[%1, %2, %3, %4, %5],"
					(typeOf _x),
					(position _x),
					(getPosASL _x),
					(vectorDir _x),
					(vectorUp _x)
				];
			} forEach _emptyObjects + _emptyVehicles;
			_output pushBack "_unitsArray = [";
			{
				_sideString = "";
				switch (side _x) do
				{
					case east: {_sideString = "east"; };
					case west: {_sideString = "west"; };
					case resistance: {_sideString = "resistance"; };
					case civilian: {_sideString = "civilian"; };
					default {_sideString = "?"; };
				};
				_output pushBack format ["[%1, [", _sideString];
				_groupVehicles = [];
				// Process all the infantry in the group
				{
					if (vehicle _x == _x) then
					{
						_output pushBack format [
							"[%1, %2, %3, %4, %5, %6],",
							(typeOf _x),
							(position _x),
							(skill _x),
							(rank _x),
							(getDir _x),
							(getPosASL _x)
						];
					}
					else
					{
						if (not ((vehicle _x) in _groupVehicles)) then
						{
							_groupVehicles pushBack (vehicle _x);
						};
					};
					_totalUnitsProcessed = _totalUnitsProcessed + 1;
				} forEach (units _x);
				
				_count = count _output;
				_output deleteAt _count;
				_output pushBack "],"
				// Create the vehicles that are part of the group.
				{
					_outputVehicle pushBack format [
						"[%1, %2, %3, %4, %5],"
						(typeOf _x),
						(position _x),
						(getPosASL _x),
						(vectorDir _x),
						(vectorUp _x))
					];
				} forEach _groupVehicles;
				
				// Set group behaviours
				_output pushBack format [
					"[%1, %2, %3, %4], [",
					(formation _x),
					(combatMode _x),
					(behaviour (leader _x)),
					(speedMode _x)];
					
				{
					if (_forEachIndex > 0) then {
						_output pushBack format [
							"[%1, %2,",
							(waypointPosition _x),
							(waypointType _x),
							if ((waypointSpeed _x) != 'UNCHANGED') then {" "+(waypointSpeed _x)+","} else { ", " },
							if ((waypointFormation _x) != 'NO CHANGE') then { " " + (waypointFormation _x) + "," } else { ", " },
							if ((waypointCombatMode _x) != 'NO CHANGE') then { " " + (waypointCombatMode _x) + "" } else { "" }
							"]"
							];
					};
				} forEach (waypoints _x)
				_output pushBack "],";
			} forEach _groups;
			
			_count = count _output;
			_output deleteAt _count;
			_output pushBack "]";
			
			{
				_markerName = "Ares_Imported_Marker_" + str(_forEachIndex);
				_output pushBack format [
					"[%1,%2,%3,%4,%5,%6,%7",
					_markerName,
					(getMarkerPos _x),
					(markerShape _x),
					(markerType _x),
					(markerDir _x),
					(getMarkerColor _x),
					(markerAlpha _x),
					if ((markerShape _x) == "RECTANGLE" ||(markerShape _x) == "ELLIPSE") then { " " + str(markerSize _x) + ","; } else { ","; },
					if ((markerShape _x) == "RECTANGLE" ||(markerShape _x) == "ELLIPSE") then { " " + str(markerBrush _x) + "]"; } else { " ]";}
					];
			} forEach allMapMarkers;
			
		_count = count _outputVehicle;
		_outputVehicle deleteAt _count;
		_outputVehicle pushBack "];";
		
		_output pushBack "_triggerArray = [";
		{
			if (typeOf _x isEqualTo "EmptyDetector") then {
				_output pushBack format [
				"[%1, %2, %3, %4, %5, %6],",
				triggerType _x,
				getPos _x,
				triggerActivation _x,
				triggerArea _x,
				triggerStatements _x,
				triggerTimeout _x
				];
			};
		} forEach vehicles;
		
		_count = count _output;
		_output deleteAt _count;
		_output pushBack "];";

		_output = _output + _outputVehicle
		_text = "";
		{
			_text = _text + _x;
			[_x] call Ares_fnc_LogMessage;
		} forEach _output;
		missionNamespace setVariable ['Ares_CopyPaste_Dialog_Text', _text];
		dialog = createDialog "Ares_CopyPaste_Dialog";
		["Generated SQF from mission objects (%1 object, %2 groups, %3 units)", count _emptyObjects, count _groups, _totalUnitsProcessed] call Ares_fnc_ShowZeusMessage;
	] call Ares_fnc_RegisterCustomModule;
};