/**
 * init.sqf
 *
 * BRAma Recipes allows ability to browse craftables
 * from your XM8Apps and check required components
 *
 *
 * Brun
 * BRAma.brunsolutions.com.au
 * © 2016 BRAma
 *
 */
 
disableSerialization;
_display = uiNameSpace getVariable ["RscExileXM8", displayNull];

//Hides all xm8 apps controlls then deletes them for a smooth transition
_xm8Controlls = [991,881,992,882,993,883,994,884,995,885,996,886,997,887,998,888,999,889,9910,8810,9911,8811,9912,8812];
{
    _fade = _display displayCtrl _x;
    _fade ctrlSetFade 1;
    _fade ctrlCommit 0.5;
} forEach _xm8Controlls;
{
    ctrlDelete ((findDisplay 24015) displayCtrl _x);
} forEach _xm8Controlls;


//Created the go back button and add the button click event handeler to it
//Note you do need to add all Idds for all the controlls you have created to the _Ctrls array
_GoBackBtn = _display ctrlCreate ["RscButtonMenu", 5504];
_GoBackBtn ctrlSetPosition [0.70,0.18,0.20,0.04];
_GoBackBtn ctrlCommit 0;
_GoBackBtn ctrlSetText "Go Back";
_GoBackBtn ctrlSetEventHandler ["ButtonClick", "call fnc_goBack"];

fnc_goBack = {
  _display = uiNameSpace getVariable ["RscExileXM8", displayNull];
  _Ctrls = [5501,5502,5503,5504,5505,5506,5507];
  {
      _ctrl = (_display displayCtrl _x);
      _ctrl ctrlSetFade 1;
      _ctrl ctrlCommit 0.25;
      ctrlEnable [_x, false];
  } forEach _Ctrls;
  execVM "xm8Apps\XM8Apps_Init.sqf";
  {
    ctrlDelete ((findDisplay 24015) displayCtrl _x);
  } forEach _Ctrls;
};


_RecipeList = _display ctrlCreate ["RscListBox", 5501];
_RecipeList ctrlSetPosition [0.085, 0.24, 0.38, 0.28]; // 0.57 Cant go full size due to bug only 7 lines clickable
_RecipeList ctrlSetEventHandler ["LBSelChanged", "_this call fnc_components_Load"];
_RecipeList ctrlCommit 0;

_ComponentsList = _display ctrlCreate ["RscListBox", 5502];
_ComponentsList ctrlSetPosition [0.48, 0.24, 0.42, 0.57];
_ComponentsList ctrlCommit 0;

_GoCraftBtn = _display ctrlCreate ["RscButtonMenu", 5503];
_GoCraftBtn ctrlSetPosition [0.48,0.18,0.21,0.04];
_GoCraftBtn ctrlCommit 0;
_GoCraftBtn ctrlSetText "Craft";
_GoCraftBtn ctrlSetEventHandler ["ButtonClick", "SelectedRecipe call ExileClient_gui_crafting_show;"];

_RecipeCategories = _display ctrlCreate ["RscCombo", 5505];
_RecipeCategories ctrlSetPosition [0.085,0.18,0.38,0.04];
_RecipeCategories ctrlSetEventHandler ["LBSelChanged", "_this call fnc_recipe_Load"];
_RecipeCategories ctrlCommit 0;

_RecipeTitle = _display ctrlCreate ["RscText", 5506];
_RecipeTitle ctrlSetPosition [0.085,0.14,0.38,0.04];
_RecipeTitle ctrlCommit 0;
_RecipeTitle ctrlSetText "BRAma Cookbook";

_RecipePic = _display ctrlCreate ["RscPictureKeepAspect", 5507];
_RecipePic ctrlSetPosition [0.085, 0.54, 0.38, 0.28];
_RecipePic ctrlCommit 0;
_RecipePic ctrlSetText "xm8Apps\BRAmaRecipes\BRAma.paa";

/***********************
 * Gather Categories From Recipe Config
 * otherwise put in Priceless category if set
 ***********************/	
	 
_RecipeCategories = [];

for '_j' from 0 to (count (missionConfigFile >> "CfgCraftingRecipes"))-1 do
{
	_CategoryConfig = (missionConfigFile >> "CfgCraftingRecipes") select _j;
	
	_RecipeCategory = getText(_CategoryConfig >> "category");	

	if!(_RecipeCategory in _RecipeCategories)then{_RecipeCategories pushBack _RecipeCategory;};		
	_RecipeCategory = "Uncategorised";
	if!(_RecipeCategory in _RecipeCategories)then{_RecipeCategories pushBack _RecipeCategory;};

};

	{
	 (_display displayCtrl 5505) lbAdd Format["%1",_x];
	 (_display displayCtrl 5505) lbSetData [_forEachIndex,_x];	
	} foreach _RecipeCategories;
	
	lbSort (_display displayCtrl 5505);

fnc_recipe_Load = {
_display = uiNameSpace getVariable ["RscExileXM8", displayNull];

lbClear 5502;
lbClear 5501;
(_display displayCtrl 5507) ctrlSetText "xm8Apps\BRAmaRecipes\BRAma.paa";

_CategoryCtrl = _this select 0;
_SelectedCategory 	= _CategoryCtrl lbData (lbCurSel _CategoryCtrl);


for '_j' from 0 to (count (missionConfigFile >> "CfgCraftingRecipes"))-1 do
{
	_CategoryConfig = (missionConfigFile >> "CfgCraftingRecipes") select _j;	
	_pictureItemClassName = getText(_CategoryConfig >> "pictureItem");
	_RecipeCategory = getText(_CategoryConfig >> "category");
	_RecipeClass = configName _CategoryConfig;	
	_currentRecipeName = getText(_CategoryConfig >> "name");	
	_pictureItemConfig = configFile >> "CfgMagazines" >> _pictureItemClassName;
	_recipePicture = getText(_pictureItemConfig >> "picture");	

	if (_RecipeCategory == _SelectedCategory) then
	{
		_lbsize = lbSize (_display displayCtrl 5501);
		(_display displayCtrl 5501) lbAdd Format["%1",_currentRecipeName];
		(_display displayCtrl 5501) lbSetPicture [_lbsize,_recipePicture];
		(_display displayCtrl 5501) lbSetData [_lbsize,_RecipeClass];
	}
	else 
	{
		if (_SelectedCategory == "Uncategorised" && _RecipeCategory == "") then
		{
			_lbsize = lbSize (_display displayCtrl 5501);
			(_display displayCtrl 5501) lbAdd Format["%1",_currentRecipeName];
			(_display displayCtrl 5501) lbSetPicture [_lbsize,_recipePicture];
			(_display displayCtrl 5501) lbSetData [_lbsize,_RecipeClass];
		};		
	};
		
};
	
	lbSort (_display displayCtrl 5501);
	
};

fnc_components_Load = {
_display = uiNameSpace getVariable ["RscExileXM8", displayNull];

_equippedMagazines = magazines player;
_SelectedRecipeCtrl = _this select 0;
SelectedRecipe 	= _SelectedRecipeCtrl lbData (lbCurSel _SelectedRecipeCtrl);

_components 				   = getArray(missionConfigFile >> "CfgCraftingRecipes" >> SelectedRecipe  >> "components");
_Tools 						   = getArray(missionConfigFile >> "CfgCraftingRecipes" >> SelectedRecipe  >> "tools");
_requiredInteractionModelGroup = getText(missionConfigFile >> "CfgCraftingRecipes" >> SelectedRecipe  >> "requiredInteractionModelGroup");
_requiresOcean 				   = getNumber(missionConfigFile >> "CfgCraftingRecipes" >> SelectedRecipe  >> "requiresOcean");
_requiresFire 				   = getNumber(missionConfigFile >> "CfgCraftingRecipes" >> SelectedRecipe  >> "requiresFire");
_returnedItems 				   = getArray(missionConfigFile >> "CfgCraftingRecipes" >> SelectedRecipe  >> "returnedItems");

lbClear 5502;

	/***********************
	 * Populate Components *
	 ***********************/	 
	  (_display displayCtrl 5502) lbAdd Format["====== COMPONENTS ======"];
      {
        _Quantity = _x select 0;
        _Component = _x select 1;
        
		_ComponentDispName = getText (configfile >> "CfgMagazines" >> _Component >> "displayName");
		_ComponentPicture  = getText (configfile >> "CfgMagazines" >> _Component >> "picture");			
		
		//Exile Code
		_equippedComponentQuantity = { _x == _Component} count _equippedMagazines;
		if (_equippedComponentQuantity < _Quantity ) then
		{
			(_display displayCtrl 5502) lbAdd Format["%3 - [%1/%2]",  _equippedComponentQuantity, _Quantity, _ComponentDispName];
			_lbsize = lbSize (_display displayCtrl 5502);
			(_display displayCtrl 5502) lbSetColor [_lbsize-1, [0.918, 0, 0,1]];
		}
		else
		{ 
			(_display displayCtrl 5502) lbAdd Format["%3 - [%1/%2]",  _equippedComponentQuantity, _Quantity, _ComponentDispName];
			_lbsize = lbSize (_display displayCtrl 5502);
			(_display displayCtrl 5502) lbSetColor [_lbsize-1, [0.698, 0.925, 0,1]];			
		};		
		
		
        
		(_display displayCtrl 5502) lbSetPicture [_forEachIndex+1,_ComponentPicture];
		(_display displayCtrl 5502) lbSetData [_forEachIndex+1,_Component];
		
      } forEach _components;
	  
	  
	/***********************
	 * Populate Tools *
	 ***********************/	  
	  if (count _Tools > 0)  then { (_display displayCtrl 5502) lbAdd Format["====== TOOLS ======"]; };
	  
      {	
		
        _Tool = _x;
        
		_ToolDispName = getText (configfile >> "CfgMagazines" >> _Tool >> "displayName");
		_ToolPicture  = getText (configfile >> "CfgMagazines" >> _Tool >> "picture");			
		
		//Exile Code
		_equippedToolQuantity = { _x == _Tool } count _equippedMagazines;
		if (_equippedToolQuantity == 0 ) then
		{
			(_display displayCtrl 5502) lbAdd Format["%1 - [MISSING]",_ToolDispName];
			_lbsize = lbSize (_display displayCtrl 5502);
			(_display displayCtrl 5502) lbSetColor [_lbsize-1, [0.918, 0, 0,1]];			
		}
		else 
		{
			(_display displayCtrl 5502) lbAdd Format["%1 - [OK]",_ToolDispName];
			_lbsize = lbSize (_display displayCtrl 5502);
			(_display displayCtrl 5502) lbSetColor [_lbsize-1, [0.698, 0.925, 0,1]];			
			
		};		
        
		_lbsize = lbSize (_display displayCtrl 5502);
		(_display displayCtrl 5502) lbSetPicture [_lbsize-1,_ToolPicture];
		(_display displayCtrl 5502) lbSetData [_lbsize-1,_Tool];
      } forEach _Tools;	  
	  
	  
	/***********************
	 * Populate Required   *
	 ***********************/
	  if (_requiredInteractionModelGroup != "" || _requiresOcean == 1 || _requiresFire == 1)  then { (_display displayCtrl 5502) lbAdd Format["====== REQUIRES ======"]; };
	  
	/***********************
	 * Populate Models   *
	 ***********************/
	 
	  if (_requiredInteractionModelGroup != "")  then 
	  {
		_foundObject = false;
		
		_interactionModelGroupConfig = missionConfigFile >> "CfgInteractionModels" >> _requiredInteractionModelGroup;
		_RequiredDispName = getText(_interactionModelGroupConfig >> "name");
		_interactionModelGroupModels = getArray(_interactionModelGroupConfig >> "models");
	
		//Exile Code
		if ([ASLtoAGL (getPosASL player), 10, _interactionModelGroupModels] call ExileClient_util_model_isNearby) then
		{
			(_display displayCtrl 5502) lbAdd Format["%1 - [OK]",_RequiredDispName];
			_lbsize = lbSize (_display displayCtrl 5502);
			(_display displayCtrl 5502) lbSetColor [_lbsize-1, [0.698, 0.925, 0,1]];			
			_foundObject = true;	
		}
		else 
		{
			if ( _interactionModelGroupModels call ExileClient_util_model_isLookingAt ) then
			{
				(_display displayCtrl 5502) lbAdd Format["%1 - [OK]",_RequiredDispName];
				_lbsize = lbSize (_display displayCtrl 5502);
				(_display displayCtrl 5502) lbSetColor [_lbsize-1, [0.698, 0.925, 0,1]];			
				_foundObject = true;	
			};
		};
		if !(_foundObject) then
		{
			(_display displayCtrl 5502) lbAdd Format["%1 - [MISSING]",_RequiredDispName];
			_lbsize = lbSize (_display displayCtrl 5502);
			(_display displayCtrl 5502) lbSetColor [_lbsize-1, [0.918, 0, 0,1]];				
		};
	
		_lbsize = lbSize (_display displayCtrl 5502);
		(_display displayCtrl 5502) lbSetData [_lbsize-1,_requiredInteractionModelGroup];
	  };
	  
	/***********************
	 * Populate Ocean   *
	 ***********************/
	 
	  if (_requiresOcean == 1)  then 
	  {
			//Exile Code
			if !(surfaceIsWater getPos player) then 
			{
				(_display displayCtrl 5502) lbAdd Format["%1 - [MISSING]", "Ocean"];
				_lbsize = lbSize (_display displayCtrl 5502);
				(_display displayCtrl 5502) lbSetColor [_lbsize-1, [0.918, 0, 0,1]];				
			}
			else 
			{
				(_display displayCtrl 5502) lbAdd Format["%1 - [OK]", "Ocean"];
				_lbsize = lbSize (_display displayCtrl 5502);
				(_display displayCtrl 5502) lbSetColor [_lbsize-1, [0.698, 0.925, 0,1]];				
			};

	  };	  
	  
	/***********************
	 * Populate Fire   *
	 ***********************/
	 
	  if (_requiresFire == 1)  then 
	  {
			//Exile Code
			if !([player, 4] call ExileClient_util_world_isFireInRange) then 
			{
				(_display displayCtrl 5502) lbAdd Format["%1 - [MISSING]", "Fire"];
				_lbsize = lbSize (_display displayCtrl 5502);
				(_display displayCtrl 5502) lbSetColor [_lbsize-1, [0.918, 0, 0,1]];				
			}
			else
			{
				(_display displayCtrl 5502) lbAdd Format["%1 - [OK]", "Fire"];
				_lbsize = lbSize (_display displayCtrl 5502);
				(_display displayCtrl 5502) lbSetColor [_lbsize-1, [0.698, 0.925, 0,1]];			
			};			

	  };	

	/***********************
	 * Populate Returns   *
	 ***********************/
	 
	 (_display displayCtrl 5502) lbAdd Format["====== RETURNS ======"];
      {
        _Quantity = _x select 0;
        _Component = _x select 1;
        
		_ComponentDispName = getText (configfile >> "CfgMagazines" >> _Component >> "displayName");
		_ComponentPicture  = getText (configfile >> "CfgMagazines" >> _Component >> "picture");
		
		(_display displayCtrl 5502) lbAdd Format["%2 - [%1]",  _Quantity, _ComponentDispName];
		
        _lbsize = lbSize (_display displayCtrl 5502);
		(_display displayCtrl 5502) lbSetPicture [_lbsize-1,_ComponentPicture];
		(_display displayCtrl 5502) lbSetData [_lbsize-1,_Component];
		(_display displayCtrl 5507) ctrlSetText _ComponentPicture;
      } forEach _returnedItems; 
	  
	    
	  
};