private ["_veh", "_classname", "_pos", "_dir", "_healthArray", "_gearArray"];

//EXECUTE AS SERVER !!!
//if (!isDedicated) exitWith { diag_log "ERROR restore vehicle not as server"; };

//reconstruct each vehicle stored in "GRAD_Retake_Tanoa_Vehicle"
{
    _x params ["_veh", "_pos", "_dir", "_healthArray", "_gearArray"];
    diag_log format ["Loaded Vehicle: %1", _x];
    diag_log format ["Loaded Vehicle: %1, Gear: %2", _veh, _gearArray];
    if (!isNil "_veh") then {
      //spawn vehicle
      _veh = createVehicle [_veh, _pos, [], 0, "CAN_COLLIDE"];
      _veh setDir _dir;
      _veh setPos _pos;

      //set health
      _health = _healthArray select 2;
      {
        diag_log format ["X: %1, Index: %2", _x, _forEachIndex];
          _veh setHitIndex [_forEachIndex, _x];
      } forEach _health;

      //inventory
      clearWeaponCargoGlobal _veh;
      clearItemCargoGlobal _veh;
      clearMagazineCargoGlobal _veh;
      clearBackpackCargoGlobal _veh;

      {
        diag_log format ["X: %1", _x];
        if (str _x != "[[],[]]") then {
          switch (_forEachIndex) do {
                      case 0: { {_veh addBackpackCargoGlobal [_x select 0, _x select 1]; } forEach _x; };
                      case 1: { {_veh addItemCargoGlobal [_x select 0, _x select 1]; } forEach _x; };
                      case 2: { {_veh addMagazineCargoGlobal [_x select 0, _x select 1]; } forEach _x; };
                      case 3: { {_veh addWeaponCargoGlobal [_x select 0, _x select 1]; } forEach _x; };
          };
        };
      } forEach _gearArray;
  };
} forEach (profileNamespace getVariable "SLB_Retake_Tanoa_Vehicle");
