["Retake Tanoa", "by Slant and Salbei ", "v1.0 ", "Loading Player ..."] call rt_fnc_missionIntro; 

[player] call rt_fnc_getPlayerFromDB;
[player] call rt_fnc_addBuyMenu;
["InitializePlayer", [player]] call BIS_fnc_dynamicGroups;
