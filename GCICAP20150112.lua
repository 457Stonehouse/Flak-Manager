--[[----------------------CAP/GCI Script---------------------------
by snafu 
Version: b6_5x
requires MIST3.5.37 or later by Grimes and Speed
Modifications for b6_1x by Stonehouse, Rivvern, Chameleon Silk May-July 2014, look for --XX tags
Modifications for b6_2x by Chameleon_Silk with some bug fixes by Stonehouse, look for --YY tags
Modifications for b6_3x by Stonehouse 7 July 2014 look for --XX3 tags	
Modifications for b6_4x by Stonehouse 10 July 2014 look for --XX4 tags
Modifications for b6_5x by Stonehouse 2 August 2014 look for --XX5 tags
Modifications for b6_6x by Stonehouse 9 August 2014 look for --XX6 tags
Modifications for b7 by Stonehouse 7 September 2014 look for --XX7 tags
Modifications for b8 by Stonehouse 16 September 2014 look for --XX8 tags
Modifications for b9 by Stonehouse 20 October 2014 look for --XX9 tags

So enhancements list is:

in release with 12/1/2015 version:
*using a parameter to make the script GCI only rather than CAP & GCI 
*Fix airbase logic so it's possible to have an airbase assigned to a coalition but not assigned for GCI CAP script use. ie a Human only base. 
*simple logistics to limit the number of CAP/GCI spawns available. ie allocation of unit pools, decrement on spawn and increment on landing for CAP and GCI aircraft only. No safe landing = reduction of pool permanently. 
*fix stuck aircraft logic, fix by setting stuckunitstable table entry to nil on landing event.
*bug in numberofspawnedandactiveinterceptorgroups accounting so too many GCIs are spawned,however found this not to be a bug but design choice - address by increasing taskinginterval 
*display GCI msgs in metric or imperial units
*parameter to control GCI messages being displayed or not
*clean up for human airfields as well as AI bases (based on [FSF]Ian's info http://forums.eagle.ru/showpost.php?p=2242571&postcount=5)
*parameterise debug so if debuggingmessages == true and color == debuggingside ('red' 'blue' or 'both') and allow parameter to only debug specific main function
*made current radar types available to both sides since often have EWR on both sides
*increased waypoint speeds

to do:
*might look at a parameter to make the players not be interception targets if people think this is useful for their mission design needs. 
*Revisit the radar side of things so that ship, ground and AWACs can be used/ Eventually hopefully change things so radar units are dynamically picked up from the mission rather than having to edit the scripts. 
*Investigate whether carriers could be set up as airbases for the purposes of this script. Not sure if the US one is functional but believe that the Russian one is. 
*Adding the recon script and CAS/anti ship flight functionality so that flights are launched against ground/naval targets picked up by recon in a similar fashion to GCI
*Seeing if I can get CAP and GCI flights to refrain from crossing borders if their target goes back into friendly territory 
*Improve error handling
*add better string handling for CAP and GCI unit names eg mist.stringMatch removes a bunch of characters, removes spaces, and can compare it all lower case. 
*add the ability for player to call for limited amounts of GCI missions to help them - "call for help"
*investigate possible performance improvements
*tidy up script and amendment log, write up actual user guide.





See below for Change log for modification details and Overview for usage notes	

--]]----------------------------------------------------------------------------------------------------------------------------------------------------------

--*******************************************************************************************************************************
--* Overview
--*******************************************************************************************************************************
--[[-----------------------------------------------------------------------------------------------------------------------------------------------------


Notes:

Airbase Names

ID CALLSIGN
12 Anapa-Vityazevo
13 Krasnodar-Center
14 Novorossiysk
15 Krymsk
16 Maykop-Khanskaya
17 Gelendzhik
18 Sochi-Adler
19 Krasnodar-Pashkovsky
20 Sukhumi-Babushara
21 Gudauta
22 Batumi
23 Senaki-Kolkhi
24 Kobuleti
25 Kutaisi
26 Mineralnye Vody
27 Nalchik
28 Mozdok
29 Tbilisi-Lochini
30 Soganlug
31 Vaziani
32 Beslan

currently enabled EWR units:  
55G6 EWR, 1L13 EWR ,Hawk sr, Patriot str 



This script intends the following:
A: To ease the generation of missions by providing a template, which can be repeatedly used and ported over from one mission to another.
B: To provide plausible air force presence of the two major conflicting coalitions in shape of constant CAP coverage of defined zones as proactive defence
C: To install GCI from defined airfields for a defined territory based on if an hostile aircraft was detected by ground based radar as counter active defence
D: To highly randomise movement and encounters along defined borderlines and have constant fight for air superiority over the defined territory


What the script does:

For the major coalitions the script launches a certain amount* of CAP flights from a random airfield** to randomly cover a certain amount* of zones*** defined in the ME. 
If early warning radar on Red side or on Blue side detects an enemy aircraft over the own territory****, 
it gets the closest friendly fighter flight without task or the closest CAP flight on station and orders this flight to engage the enemy aircraft.
If no CAP flight or fighter flight without task is airborne and available, the script spawns a random interceptor flight on one of the airfields designated by a trigger zone (see below) which is closest to the detected 
enemy aircraft and orders this interceptor flight to intercept the intruder. If the CAP enters the CAP zone is regarded as "on station" and will be available for the intercept tasking 
and can be assigned by the script to engage intruder. If the CAP flight leaves the CAP zone, the script launches a new CAP flight to maintain the required amount* of CAP flights in the CAP zones.
If the enemy intruder is shot down or leaves the friendly territory and no further intruder is detected by the radar, all interceptor flights and the CAP flights, which were taken off station to intercept an intruder are tasked to return to the closest friendly defined airfield.
The script repeatedly checks the flights, which were tasked to RTB and de-spawns the groups which have landed to de-clutter airfields. 
It also checks for traffic jams on the taxiways and will de-spawn stuck AI aircraft.
Note AWACS aircraft currently cannot act as radars for this script but other radar units can be set up as additional radars to the above. See line 436 and 456 if you want to add additional radar units. You need to know the unit type as
added to the mission file. This may or may not be the same as that shown in the mission editor.  


A flight always consists of 2-4 fighters, with skill level taken from template aircraft set up in the mission.

* = (to be defined in the header of the script)
** = Airfields on blue and airfields on red side that are marked with trigger zones in the ME are used by the script to launch AI flights. The trigger zones need to have the same name as the airfield. 
*** = trigger zones with defined names 'redCAPzone1', 'redCAPzone2',...'redCAPzoneN' or  'blueCAPzone1', 'blueCAPzone2',...'blueCAPzoneN' -- Note that the capitalisation is very important to get correct.
**** = borderline will be defined in the ME by the way points of ground group called "redborder" or "blueborder". If noborders = 1 then the checking for border violation is skipped and radar
       detection is all that is needed to have CAP and GCI attack the intruder.

What you have to do:
-set airfields to the appropriate coalition within the coalitions region of control. Airfields not designated as AI spawn locations (see next step) can be used as human only airfields and will also receive recovering AI flights.
-place trigger zones for each coalition over the airfields you want to have the CAP and intercept flights spawn and name the triggerzones exactly as the airfield name, set the airfield to the appropriate coalition.

-define Y in the script header 'numberofblueCAPzones = Y'
-define X in the script header 'numberofredCAPzones = X'
-place Y trigger zones for blue coalition and name them 'blueCAPzone1', 'blueCAPzone2',...'blueCAPzoneY'.
-place X trigger zones for red coalition and name them 'redCAPzone1', 'redCAPzone2',...'redCAPzoneX'.

-define the amount of CAP flights for each coalition which shall be constantly on station, via script header line with: 'numberofredCAPgroups = Z' and 'numberofblueCAPgroups = N'

Depending on the setting selected for the noborders parameter. If you have chosen noborders = 0 then you need to:
-create a red helicopter group with the name 'redborder' and define the red territory with the way points you place in the ME. The area enclosed with the waypoints will be considered as red held territory. Note: Deactivate the group by setting it on late activation
-create a blue helicopter group with the name 'blueborder' and define the blue territory with the way points you place in the ME. The area enclosed with the waypoints will be considered as blue held territory. Note: Deactivate the group by setting it on late activation
-Noborders = 1 represents a "hot" war in which the borders are no longer respected. In this case as soon as flights are picked up by radar they will be intercepted either by CAPs or GCI flights.
 
-Place red ground radar units in the red territory and blue ground radar units in the blue territory. See list above for available radar units.

-initiate MIST3.5.37 or later on the trigger page of the ME in the drop down menu on the right side
-create a trigger "MISSION START"-no condition-"DO SCRIPT FILE (load the MIST lua file)", "DO SCRIPT FILE (load this script LUA-file)"

-In the mission editor add a blue aircraft to the map somewhere out of the way. This task must be set to the CAP. Note that not all aircraft can be set to CAP in the mission editor. 
 This aircraft will be the first template blue CAP plane,tick the late activation box. Change the group name (at the top) to be something like CAP_blue1 and very importantly change the pilot name 
 (which is the unit name) to exactly be __CAP__blue1 (noting the case of the colour is lower). 
 Set the load out, skin and skill on this aircraft to be what you want your first type of blue CAP aircraft to be like. Don't forget to check and set internal fuel and ammo as you want.
-repeat for __CAP__blue2 and __CAP__blue3 and __CAP__blue4 
-repeat the previous step for __CAP_blue_1 again for the first blue GCI interceptor aircraft type. This time make the group name something like GCI_blue1 and 
 then make sure to make the pilot name exactly __GCI__blue1. Again set the load out, skin and skill.
-repeat the prior step for __GCI__blue2 and __GCI__blue3 and __GCI__blue4 

-repeat the prior blue steps for the red CAP aircraft and red GCI aircraft making the group names CAP_red1 and GCI_red1 etc. and pilot names excatly __CAP__red1 to __CAP__red4 and __GCI__red1 to __GCI__red4.
-Note that each of cap and gci aircraft are templates for what will spawn in the mission and each can be a different type, have a different loadout, skin and skill.
**Note it is important to make the pilot names for the 16 aircraft mentioned above **exactly** as shown otherwise your spawned CAP and GCI planes will likely not appear or be without fuel and not take off. 
  The group names are not that important and just make them easily distinguishable in the list of units. You must make them late activation and not set a trigger condition to activate them or else 
  these 16 aircraft will be counted towards the available interception aircraft for the side and prevent CAP and interceptors from spawning. 
  If you do not place all these 16 aircraft then your CAP and GCI planes will not spawn or will be problematic. 
**You must set the country of the template aircraft according to the red and blue coalition countries chosen in the mission editor as these are used to correctly spawn CAP and GCI units.
**If you have a low number of airbases eg 1 or 2 on a side then suggest you pick a low number of CAP groups and active intercepts as otherwise you will experience excessive traffic jams and accidents on the airbases as aircraft try to taxi.

Note:
If no borders = 0 it is not recommended to place the CAP zones for coalitions over hostile territory or too close the others coalition CAP zone, as long as you do not want to have a cold war going hot.
Pay attention to the size of your cap zones and whether the airbases you have chosen lie within the cap zone. If the airbase for a spawning flight is outside the zone then it will be regarded as "enroute to station"
and not available for intercept tasking until it gets into the zone and is regarded as on-station. If the airbase is within the zone then the flight is on station as soon as it's airborne. 
If a CAP flight is tasked for an intercept it is also no longer on station so the script will try to launch another CAP flight to replace the intercepting one or launch interceptors if intruders are detected.
CAP flights on station actively search the CAP zone and freely engage every hostile aircraft coming close to the zone.
On pursuit they enter hostile airspace and interceptors will take off on the opposing side.
In case the situation is not solved in due time the situation can escalate easily (just like in real life).
The interceptors will not be tasked to RTB as long as an hostile aircraft is detected in their airspace or simply detected if borders are not in use.

--]]
--*******************************************************************************************************************************
--* Change log
--*******************************************************************************************************************************
--[[
74t: 	-added do-end block and disable debugging message env.
b4: 	-CAP tasks ROE set to Return fire and task of "generatetask" modified to set ROE to OPEN FIRE WEAPON FREE
b5: 	-added option for CAP and interceptors to take off from runway, suggested by "Quip",
		-added option to limit number of interceptors spawned, if a certain amount of intercepts are ongoing
		-added function which shall remove AI plane/helicopter groups, which have a damaged unit on the ground in the trigger zones created around the airfields
b5_1: 	-corrected counter for spawn limiter
b5_2: 	-corrected the correction, thanks to eric963
b6t: 	testing version: -changed waypoint alt type from BARO to RADIO
		-first CAP in mission will spawn in air in the CAP zone
		-randomized flight size of the CAP and interceptor flights, they will now consist randomly either of 4 or of 2 planes or of choice, GCI might also spawn in the same size as the intruder group
b6_1x 	-fixed runway usage
		-spawns and way points now consider terrain height
		-bort numbers on aircraft
		-logic around airbase selection corrected
		-numberofspawnedandactiveinterceptorgroups initialisation
		-parameterise hiding of enemy aircraft for both sides
		-attempt to improve scope of some variables
		-added table of correct airfield names that are available to use above
		-changed back using BARO
b6_2x 	-added interceptor and CAP country parameter
		-added min and maximum CAP and intercept altitude parameter
		-fixed numberofCAPzones and Spawnmode capitalisation. Particularly Spawnmode where original script incorrectly used spawnmode at times.
		-added parameter to change behaviour of first wave of fighters at mission start	
b6_3x 	-fixed GCI aircraft so they use spawn mode
b6_4x 	-increased airbases to 4 to try and avoid taxiway problems and increase dynamics of mission, 
		-added logic to handle AI aircraft stuck on taxiways, 
		-changed scheduling of interceptmain to try to minimise taxiway problems
		-commented out the mist.tableShow lines as they are for debugging and might affect performance
b6_5x 	-added GCI bandit calls to players when a border violation is confirmed. Bearing & range to bullseye and ASL altitude given.
		-Revised scheduling of interceptmain again to a higher frequency
b6_6x   -Add parameterised skill for CAP and GCI pilots by side	
b7		-Make borders and border violation checks optional via the noborders variable, 
		-fix stuck aircraft time, 
		-add CAP and GCI template handling so these aircraft are now defined in the mission editor not the script and all types, skill and skin are taken from these template aircraft 
		removing the need for multiple versions and editing the script. 
		-Increased blue cap and gci planes to 4 to simplify logic and align blue and red sides.
		-corrected original logic so that aircraft manually placed in the mission editor, player aircraft and late activation aircraft are not picked as being available for interception tasks
b8		-pick up airbase info from map so users no longer need to edit script and also makes it possible to have different airbase setups for each side, add helos as possible targets, pick up country for red and blue cap and gci 
		aircraft from the 16 template aircraft. Note that this means theoretically, assuming you have set it up in the mission editor, that you can have 8 countries per side for aircraft spawning. ie 1 for each CAP and GCI template
		aircraft.
b9		-correct airbase logic to allow human only bases for a coalition (no trigger zone defined=human only base)
		-add parameters noblueCAPs and noredCAPs to allow a mission designer to suppress CAP flights on one or both sides
		-add logistics so that takeoffs reduce a side's supply pool and successful landings increase a side's supply pool of groups. This means as aircraft are 
		 destroyed the pool of available aircraft groups for a side diminishes.
		-fix stuck aircraft logic so it doesn't conflict with handling landed aircraft.
		-change task reset interval to much higher value to prevent the reset of max spawned and active intercepts leading to too many GCI flights spawning
		-parameterise the units (KM or NM) the GCI messages are delivered in
		-Add parameter to control whether GCI messages are displayed or not
		-make EWRs available to both sides
--]]---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

do

--************************************************************************************************************************************
--* Configuration Parameters that need to be set by mission designer start below
--************************************************************************************************************************************

--Start YY added this stuff to easily control CAP minimum & maximum altitudes and country selection
cap_max_alt = 7500											--CAP max alt in meters
cap_min_alt = 4500											--CAP min alt in meters
startairborne = 0	                               			--set to 1 for CAP flight to start airborne at script initialisation, 0 for taking off from airfield at start
--END YY

local numberofredCAPzones = 2								--input of numbers of defined CAP zones for Red side --YY capitalisation
local numberofblueCAPzones = 2								--input of numbers of defined CAP zones for Blue side --YY capitalisation
local numberofredCAPgroups = 2								--input of numbers of defined CAPs for red side
local numberofblueCAPgroups = 2								--input of numbers of defined CAPs blue red side
local numberofspawnedandactiveinterceptorgroupsRED = 2		--maximum number of at the same time ongoing active intercepts for Red side, NOTE: The counter will be reset with the "taskinginterval" and each time the airspace is clear
local numberofspawnedandactiveinterceptorgroupsBLUE = 2		--maximum number of at the same time ongoing active intercepts for blue side, NOTE: The counter will be reset with the "taskinginterval" and each time the airspace is clear
local CAPgroupsize = "randomized"			            	--["2";"4";"randomized"] if "randomized", the CAP groups consist of either 2 or 4 planes, if "2" it consists of 2 planes, if "4" it consists of 4 planes
local GCIgroupsize = "randomized"			                --["2";"4";"randomized"; "dynamic"] if "randomized", the GCI interceptor groups consist of either 2 or 4 planes, if "dynamic" it has the same size as the intercepted group, if "2" it consists of 2 planes, if "4" it consists of 4 planes
local nomessages = 0										--XX9 nomessages = 1 means suppress GCI warnings
local dspmsgtime = 3 										--XX5 display GCI messages in secs
local dspmsgunits = 0										--XX9 display GCI messages in KM (1) or NM (0)
local noborders = 0                                         --XX7 if noborders = 1 then don't worry about border checks only detection. if noborders = 0 then as normal
local Spawnmode = "parking" 								--option to define AI spawn situation, must be["parking"/"takeoff"/"air"]	and defines the way the fighters spawn --YY capitalisation
local hideenemy = false 								    --XX option to hide or reveal air units in the mission. This setting affects both sides. Valid values are true/false to make units hidden/unhidden, XX9 change to local var
noblueCAPs = 0												--XX9 if noblueCAPs = 1 then all blue CAP flights are suppressed and only GCI missions will launch, noblueCAPs=0 means CAPS & GCIs as normal
noredCAPs = 0											    --XX9 if noredCAPs = 1 then all red CAP flights are suppressed and only GCI missions will launch, noredCAPs=0 means CAPS & GCIs as normal
--XX9 next three parameters for logistics system
bluegroupsupply = 24										--XX9 initial blue aircraft group numbers 
redgroupsupply = 24											--XX9 initial red aircraft group numbers 
limitedlogistics = 0										--XX9 parameter specifying whether total supply of blue and red groups are limited. 1 = Yes 0 = No
--XX9 Do not make the next value too low!! or you will see groups despawn before all members take off. The number of secs a stuck aircraft group will sit there on the taxiway before it's group is removed; may need adjustment upwards to suit airfields with limited taxiways. 
stucktimelimit = 1080	
cleanupradius = 3000										--XX9 parameter for radius of cleanup of wrecks etc on airfields

--DEBUGGING options #### NOTE that to display table values the mist.tableShow lines must be uncommented as well as their associated Debug line
local debuggingmessages = false								--set to true if tracking messages shall be printed
env.setErrorMessageBoxEnabled(false)		       			--set to false if debugging message box, shall not be shown in game
local debuggingside = 'blue'									--set side for which tracking messages shall be printed, use 'both' if you want debug messages for both sides to be logged
local funnum = 8											--set to 0 for all otherwise set to specific number for function of interest
															-- airspaceviolation = 1
															-- getinterceptorairborne = 2
															-- spawninterceptor = 3
															-- generatetask = 4
															-- interceptorsRTB = 5
															-- CAPStatuscheck = 6
															-- spawnCAP = 7
															-- interceptmain = 8
															-- resettask = 9
															
															
--************************************************************************************************************************************
--**End of Configuration Parameters
--************************************************************************************************************************************

--****Settings below should only be changed if you understand the effect of the change.
local redCAPzone = 'redCAPzone'					            --Trigger zones defining the Red CAP area have to be name according to 'redCAPzone1', 'redCAPzone2',...'redCAPzone[numberofredCAPzones]
local blueCAPzone = 'blueCAPzone'					    	--Trigger zones defining the Blue CAP area have to be name according to 'blueCAPzone1', 'blueCAPzone2',...'blueCAPzone[numberofblueCAPzones]
local redborderlineunitname = 'redborder' 	            	--Name of group which way points define the red border
local blueborderlineunitname = 'blueborder' 	            --Name of group which way points define the blue border
local taskinginterval = 1800 					       		--Time interval in which ongoing intercepts are renewed, NOTE: Do not use too small a value as it interrupts intercepts and resets limit on active GCIs which can cause mission to be spammed by aircraft

--names of red interceptorbases
local redAFids = {}											--XX8
local redAF = {}
local redBases = {}											--XX9
redAFids = coalition.getAirbases(1) 						--XX8 get list of red airbases
for i = 1, #redAFids do
	if mist.DBs.zonesByName[redAFids[i]:getName()] then 	--XX9 only add airbase if trigger zone present too
		redAF[#redAF + 1] = {name=redAFids[i]:getName()}	--XX8 build name list
	end	
	if redAFids[i]:getName() then
		redBases[#redBases + 1] = {name=redAFids[i]:getName()}		--XX9 build list of all bases for clean up purposes
	end
end	

if #redAF < 1 then 											--XX8 check that at least one red base has been selected in editor
	env.warning("There are no red bases chosen, aborting.", false)
end

 
--names of blue interceptorbases

local blueAFids = {}										--XX8
local blueAF = {}
local blueBases = {}										--XX9
blueAFids = coalition.getAirbases(2) 						--XX8 get list of blue airbases
for i = 1, #blueAFids do
	if mist.DBs.zonesByName[blueAFids[i]:getName()] then 	--XX9 only add airbase if trigger zone present too
		blueAF[#blueAF + 1] = {name=blueAFids[i]:getName()}	--XX8 build name list
	end
	if blueAFids[i]:getName() then
		blueBases[#blueBases + 1] = {name=blueAFids[i]:getName()} --XX9 build list of all bases for clean up purposes
	end
end	

if #blueAF < 1 then 										--XX8 check that at least one blue base has been selected in editor
	env.warning("There are no blue bases chosen, aborting.", false)
end

--[[ Airfield debugging
--local airfieldsTable = mist.utils.tableShow(redAF)
--local msg1 = "red airfields: "..airfieldsTable
--trigger.action.outText(msg1, 60000000)
--env.info(msg1)

--local airfieldsTable = mist.utils.tableShow(blueAF)
--local msg2 = "blue airfields: "..airfieldsTable
--trigger.action.outText(msg2, 60000000)
--env.info(msg2)
--]]

--[[Supply debugging
local msg3 = "red initial supply: "..string.format(redgroupsupply)
trigger.action.outText(msg3, 100000)
env.info(msg3)
local msg4 = "blue initial supply: "..string.format(bluegroupsupply)
trigger.action.outText(msg4, 100000)
env.info(msg4)
--]]
--************************************************************************************************************************************
--Script logic begins NO MORE INPUT / EDITING BELOW IF YOU DON`T KNOW WHAT YOU ARE DOING PLEASE
--************************************************************************************************************************************

--initialisation of static script values 
redintgroupcounter = 0				--XX9 used to number red GCI flights from 1 to n
blueintgroupcounter = 0				--XX9 used to number blue GCI flights from 1 to n
blueCAPcounter = 0					--XX9 used to number blue CAP flights from 1 to n
redCAPcounter = 0					--XX9 used to number red CAP flights from 1 to n

previousredCAPspawnzonename = nil
previousblueCAPspawnzonename = nil
previousredCAPZonename = nil
previousblueCAPZonename = nil

borderviolationcheck = false		--Border violation initially false
intruder = {}						--Table of intruder info
intruder['red'] = {}
intruder['blue'] = {}

allEWRunits = {}					--Table of radar units

AvailableAirborne = {}				--Table of available air units
AvailableAirborne['red'] = {}
AvailableAirborne['blue'] = {}

possibleintercept = {}				--Table of possible interception targets
possibleintercept['red'] = {}
possibleintercept['blue'] = {}

intercept = {}						--Table of interceptions
intercept['red'] = {}
intercept['blue'] = {}

interceptspawnstatus ={}
interceptspawnstatus['red'] = {}
interceptspawnstatus['blue'] = {}

interceptstatus = {}
interceptstatus['red'] = {} 
interceptstatus['blue'] = {}

interceptorsRTBtable = {}
interceptorsRTBtable['red'] = {}
interceptorsRTBtable['blue'] = {}

interceptspawntotal = {}
interceptspawntotal['red'] = {}
interceptspawntotal['blue'] = {}

actualCAPtable = {}
actualCAPtable['red'] = {}
actualCAPtable['blue'] = {}

numberofspawnedandactiveinterceptorgroups = {}		   --Table controls how many active GCI flights are in mission, when reset new flights launch	
numberofspawnedandactiveinterceptorgroups['red'] = {}
numberofspawnedandactiveinterceptorgroups['blue'] = {} --XX changed from original where 'red' was used and seemingly a duplicate of prior line

stuckunitstable = {} --XX4 table of spawn times for each aircraft which is used to work out whether an aircraft is stuck on the ground and if so de-spawn it

--Logic begins

--setting the type of AI spawn, default is take off from ramp
if Spawnmode == "parking"
then
	RNW_type = "TakeOffParking"
	RNW_action = "From Parking Area"
elseif Spawnmode == "takeoff" --YY capitalisation
then
	RNW_type = "TakeOff"
	RNW_action = "From Runway"
elseif Spawnmode == "air" --YY capitalisation
then
	RNW_type = "Turning Point"
	RNW_action = "Turning Point"
end --Spawnmode


--build tables defining borderlines if needed
if noborders == 0 then --XX7
	redborderline =  mist.getGroupPoints(redborderlineunitname) --table of points defining red borderline
	redborderlinevec3 = {}
		for r = 1, #redborderline
		do
			redborderlinevec3[#redborderlinevec3 + 1] =
			{
			z = redborderline[r].y,
			x = redborderline[r].x,
			y = land.getHeight({x = redborderline[r].x, y = redborderline[r].y})
			}
			--trigger.action.smoke({x=redborderline[r].x, y=land.getHeight({x = redborderline[r].x, y = redborderline[r].y}), z=redborderline[r].y}, trigger.smokeColor.Green) --check smoke
			--trigger.action.smoke({x=redborderlinevec3[r].x, y=land.getHeight({x = redborderlinevec3[r].x, y = redborderlinevec3[r].z}), z=redborderlinevec3[r].z}, trigger.smokeColor.Red)--check smoke
		end --redborder waypoints

	blueborderline =  mist.getGroupPoints(blueborderlineunitname) --table of points defining blue borderline
	blueborderlinevec3 = {}
		for r = 1, #blueborderline
		do
			blueborderlinevec3[#blueborderlinevec3 + 1] =
			{
			z = blueborderline[r].y,
			x = blueborderline[r].x,
			y = land.getHeight({x = blueborderline[r].x, y = blueborderline[r].y})
			}
			--trigger.action.smoke({x=blueborderline[r].x, y=land.getHeight({x = blueborderline[r].x, y = blueborderline[r].y}), z=blueborderline[r].y}, trigger.smokeColor.Green)--check smoke
			--trigger.action.smoke({x=blueborderlinevec3[r].x, y=land.getHeight({x = blueborderlinevec3[r].x, y = blueborderlinevec3[r].z}), z=blueborderlinevec3[r].z}, trigger.smokeColor.Red)--check smoke
		end --blue border waypoints
end --XX7 no borders

------------function to get all aircraft & helos currently alive on map
function getallaircrafts(color)

	local side = color
	 
	Aircraftstable = {}

	if side == 'red'
		then
			Aircraftstable = {'[red][plane]','[red][helicopter]'}

	elseif side == 'blue'
		then
			Aircraftstable = {'[blue][plane]','[blue][helicopter]'}
	end

	
	local allairunitsstart = {}
	local allairunitsstart = mist.makeUnitTable(Aircraftstable)

	
	allairunits = {}

	for a = 1, #allairunitsstart
	do
		if (Unit.getByName(allairunitsstart[a]) ~= nil)   --XX seemed to be missing half the condition  
			then 
			local unitnum = Unit.getByName(allairunitsstart[a])

			if (Unit.isActive(unitnum) == true) 
			then
			allairunits[#allairunits + 1] =
					{
					name = allairunitsstart[a]
					}
			end
		end
	end
	if debuggingmessages == true and (side == debuggingside or debuggingside == 'both') then
		local allairunitsTable = mist.utils.tableShow(allairunits)
		Debug(side.." allairunits: " ..allairunitsTable, side) 
	end

return allairunits
end --getallaircrafts

-- lists all EWR groups in a table
function getallEWR(color)

	local side = color
	EWRtable= {}

	if side == 'red'
		then
			EWRtable = {'[red][vehicle]','[red][plane]','[red][ship]'}
	elseif side == 'blue'
		then
			EWRtable = {'[blue][vehicle]','[blue][plane]','[blue][ship]'}
	end

	local allEWRstart = {}
	local allEWRstart = mist.makeUnitTable(EWRtable)
	allEWRunits = {}

	if side == 'red'
	then
		for a = 1, #allEWRstart
		do

			if Unit.getByName(allEWRstart[a]) ~= nil
				then
					local possibleEWRunit = Unit.getByName(allEWRstart[a])
					local possibleEWRunittype =  Unit.getTypeName(possibleEWRunit)
					if possibleEWRunittype == "55G6 EWR" or possibleEWRunittype == "1L13 EWR" or possibleEWRunittype == "Hawk sr" or possibleEWRunittype == "Patriot str" --or possibleEWRunittype == "A-50"
						then
						local EWRgroup = Unit.getGroup(possibleEWRunit)
						allEWRunits[#allEWRunits + 1] =
								{
								group = EWRgroup
								}
					end
			end
		end

	elseif side == 'blue'
		then
			for c = 1, #allEWRstart
			do

				if Unit.getByName(allEWRstart[c]) ~= nil
					then
						local possibleEWRunit = Unit.getByName(allEWRstart[c])
						local possibleEWRunittype =  Unit.getTypeName(possibleEWRunit)
						if possibleEWRunittype == "55G6 EWR" or possibleEWRunittype == "1L13 EWR" or possibleEWRunittype == "Hawk sr" or possibleEWRunittype == "Patriot str" --or possibleEWRunittype == "E-2D" or possibleEWRunittype == "E-3A"
							then
							local EWRgroup = Unit.getGroup(possibleEWRunit)

							allEWRunits[#allEWRunits + 1] =
									{
									group = EWRgroup
									}
						end
				end
			end
		end

	if debuggingmessages == true and (side == debuggingside or debuggingside == 'both') then
		local allEWRunitsTable = mist.utils.tableShow(allEWRunits)
		Debug(side.." allEWRunits: "..allEWRunitsTable, side)
	end
return allEWRunits
end --getallEWR

---------------------------------CHECK for enemy aircraft in friendly air space and returns table of intruders aircraft inside friendly space
function airspaceviolation(color)

	local interceptorside = color

	if debuggingmessages == true and (side == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 1) then
		Debug("debuggingmessage stuck at airspaceviolation 1: counter:"..string.format(counter).."/ side: "..interceptorside, interceptorside)
	end
	
	if interceptorside == 'red'
		then
			if noborders == 0 then --XX7
				borderline = {}
				borderline = redborderlinevec3
			end --XX7
			getallaircrafts('blue')
			getallEWR('red')
	elseif interceptorside == 'blue'
		then
			if noborders == 0 then --XX7		
				borderline = {}
				borderline = blueborderlinevec3
			end --XX7
			getallaircrafts('red')
			getallEWR('blue')
	end
	intruder[interceptorside] = {} --resets table
	
	if debuggingmessages == true and (interceptorside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 1) then
		Debug("debuggingmessage stuck at airspaceviolation 2: counter:"..string.format(counter).."/ side: "..interceptorside, interceptorside)
	end
	
	if #allairunits > 0
		then
			if debuggingmessages == true and (interceptorside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 1) then
				Debug("debuggingmessage stuck at airspaceviolation 2-1: counter:"..string.format(counter).."/ side: "..interceptorside, interceptorside)
			end
			
			n = 0

			for i = 1,#allairunits
			do
				borderviolationcheck = false
				possibleintrudergroupdetected = false
				intrudergroupdetected = false
				
				if debuggingmessages == true and (interceptorside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 1) then
					Debug("debuggingmessage stuck at airspaceviolation 2a: counter:"..string.format(counter).."/ side: "..interceptorside, interceptorside)
				end
				
				if Unit.getByName(allairunits[i].name) ~= nil
					then
						local possibleintruder = Unit.getByName(allairunits[i].name)
						local possibleintruderpos = possibleintruder:getPosition().p
						local possibleintruderpos3 = {x=possibleintruderpos.x, y=possibleintruderpos.y, z=possibleintruderpos.z}
						local possibleintrudergroup = Unit.getGroup(possibleintruder)
						if #allEWRunits > 0
							then
							if debuggingmessages == true and (interceptorside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 1) then
								Debug("debuggingmessage stuck at airspaceviolation 2b: counter:"..string.format(counter).."/ side: "..interceptorside, interceptorside)
							end
							for j = 1, #allEWRunits
							do
								local possibleintruder = Unit.getByName(allairunits[i].name)
								if debuggingmessages == true and (interceptorside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 1) then
									Debug("debuggingmessage stuck at airspaceviolation 2b1: counter:"..string.format(counter).."/ side: "..interceptorside, interceptorside)
								end
								local EWRgroup = allEWRunits[j].group
								
								if debuggingmessages == true and (interceptorside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 1) then
									Debug("debuggingmessage stuck at airspaceviolation 2b2: counter:"..string.format(counter).."/ side: "..interceptorside, interceptorside)
								end
								
								local EWRgroupcontroller = EWRgroup:getController()
								
								if debuggingmessages == true and (interceptorside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 1) then
									Debug("debuggingmessage stuck at airspaceviolation 2b3: counter:"..string.format(counter).."/ side: "..interceptorside, interceptorside)
								end
								
								possibleintrudergroupdetected = Controller.isTargetDetected(EWRgroupcontroller, possibleintruder, RADAR)
								
								if debuggingmessages == true and (interceptorside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 1) then
									Debug("debuggingmessage stuck at airspaceviolation 2b4: counter:"..string.format(counter).."/ side: "..interceptorside, interceptorside)
								end
								
								if possibleintrudergroupdetected == true
									then
									intrudergroupdetected = true
									
									if debuggingmessages == true and (interceptorside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 1) then
										Debug("debuggingmessage stuck at airspaceviolation 2c: counter:"..string.format(counter).."/ side: "..interceptorside, interceptorside)
									end	
										
								end
							end
						end

						if debuggingmessages == true and (interceptorside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 1) then
							Debug("debuggingmessage stuck at airspaceviolation 3: counter:"..string.format(counter).."/ side: "..interceptorside, interceptorside)
						end
						
						if noborders == 0 then --XX7
							borderviolationcheck = mist.pointInPolygon(possibleintruderpos3, borderline)
						else --XX7
							borderviolationcheck = true --XX7
						end --XX7
						
						if debuggingmessages == true and (interceptorside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 1) then
							Debug("debuggingmessage stuck at airspaceviolation 4: counter:"..string.format(counter).."/ side: "..interceptorside, interceptorside)--last!!!!
						end
						
						if borderviolationcheck == true and intrudergroupdetected == true
							then
								n = n + 1
								local actualintrudername = allairunits[i].name
								local actualintruder = possibleintruder
								local actualintrudergroup = Unit.getGroup(actualintruder)
								local actualintrudergroupID = Group.getID(actualintrudergroup)
								local actualintruderID = Unit.getID(actualintruder)
								local actualintrudertype = Unit.getTypeName(actualintruder)
								local actualintruderpos = possibleintruderpos
								
								if debuggingmessages == true and (interceptorside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 1) then
									Debug("debuggingmessage stuck at airspaceviolation 4a: counter:"..string.format(counter).."/ side: "..interceptorside, interceptorside)
								end
								
								local actualintrudergroupsize = Group.getSize(actualintrudergroup)
								
								if debuggingmessages == true and (interceptorside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 1) then
									Debug("debuggingmessage stuck at airspaceviolation 4b: counter:"..string.format(counter).."/ side: "..interceptorside, interceptorside)
								end
								
								intruder[interceptorside][#intruder[interceptorside] + 1] =
																{
																name = actualintrudername,
																unit = actualintruder,
																group = actualintrudergroup,
																GroupID = actualintrudergroupID,
																UnitID = actualintruderID,
																unittype = actualintrudertype,
																pos = actualintruderpos,
																size = actualintrudergroupsize,
																number = n
																}
								--XX5 start alert message to interceptor side >>
								if nomessages == 0 then
									local _vars = {}
									local _msgunits = {}
									_msgunits[1] = actualintrudername
									local friendly = ' '
									_vars.units = _msgunits
									if interceptorside == 'blue' then
										_vars.ref = coalition.getMainRefPoint(coalition.side.BLUE)
										friendly = 'blue'
									else
										_vars.ref = coalition.getMainRefPoint(coalition.side.RED)
										friendly = 'red'
									end
								
									if dspmsgunits == 1 then
										_vars.metric = 1
									end
								
									_vars.alt = actualintruderpos.y
							
									local _coordinatestext = string.format("BULLSEYE %s", mist.getBRString(_vars))
									local _msg = "GCI ALERT!! BANDITS AT BEARING AND RANGE FROM ".._coordinatestext.." ASL" --XX7
							 
									local _msgtable={}
									_msgtable.text = _msg
									_msgtable.name = actualintrudergroupID.."GCI" --XX7
									_msgtable.msgFor = {coa={friendly}}
									_msgtable.displayTime = dspmsgtime
									--send the message			
									mist.message.add(_msgtable)
								end
								--<< XX5 end alert message logic

						end
				end
			end
	end

	if debuggingmessages == true and (interceptorside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 1) then
		IntruderTable = mist.utils.tableShow(intruder[interceptorside])
		Debug(interceptorside.." intruder: " ..IntruderTable.."-counter: "..string.format(counter), interceptorside)
	end

return intruder[interceptorside]
end --airspaceviolation

-----------------------------------------CHECK if interceptor is airborne and assigned to a possible intercept
function getinterceptorairborne(color)

	local interceptorside = color
	local grouptable = {} --XX7
	local redtemplate = "" --XX7
	local bluetemplate = "" --XX7
	local unitgci = 0 --XX7
	local grpunitgci = 0 --XX7
	local grpgciname = "" --XX7
	
--XX create new local var numintCAPgrps to replace numberofCAPgroups
	local numintCAPgrps = 0

	if interceptorside == 'red'
		then
			numintCAPgrps = numberofredCAPgroups --XX replace numintCAPgrps
			
			--XX7 >>
			redtemplate = "__GCI__"..interceptorside.."1"
			
			if debuggingmessages == true and (interceptorside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 2) then
				Debug("redtemplate = "..redtemplate, interceptorside)
			end
			
			unitgci = Unit.getByName(redtemplate)
			grpunitgci = unitgci:getGroup()
			grpgciname = grpunitgci:getName()
			grouptable = mist.getGroupData(grpgciname)
			interceptortype1=grouptable["units"][1]["type"]
				 
			redtemplate = "__GCI__"..interceptorside.."2"
			
			if debuggingmessages == true and (interceptorside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 2) then
				Debug("redtemplate = "..redtemplate, interceptorside)
			end
			
			unitgci = Unit.getByName(redtemplate)
			grpunitgci = unitgci:getGroup()
			grpgciname = grpunitgci:getName()
			grouptable = mist.getGroupData(grpgciname)
			interceptortype2=grouptable["units"][1]["type"]
				 
			redtemplate = "__GCI__"..interceptorside.."3"
			
			if debuggingmessages == true and (interceptorside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 2) then
				Debug("redtemplate = "..redtemplate, interceptorside)
			end
			
			unitgci = Unit.getByName(redtemplate)
			grpunitgci = unitgci:getGroup()
			grpgciname = grpunitgci:getName()
			grouptable = mist.getGroupData(grpgciname)
			interceptortype3=grouptable["units"][1]["type"]
			 	
			redtemplate = "__GCI__"..interceptorside.."4"
			
			if debuggingmessages == true and (interceptorside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 2) then
				Debug("redtemplate = "..redtemplate, interceptorside)
			end
			
			unitgci = Unit.getByName(redtemplate)
			grpunitgci = unitgci:getGroup()
			grpgciname = grpunitgci:getName()
			grouptable = mist.getGroupData(grpgciname)
			interceptortype4=grouptable["units"][1]["type"]
			 
			--<<XX7
		
			getallaircrafts('red')

	elseif interceptorside == 'blue'
		then
			numintCAPgrps = numberofblueCAPgroups
						
			--XX7 >>
			bluetemplate = "__GCI__"..interceptorside.."1"
			
			if debuggingmessages == true and (interceptorside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 2) then
				Debug("bluetemplate1 = "..bluetemplate, interceptorside)
			end
			
			unitgci = Unit.getByName(bluetemplate)
			
			if debuggingmessages == true and (interceptorside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 2) then
				Debug("bluetemplate2 = "..bluetemplate, interceptorside)
			end
			
			grpunitgci = unitgci:getGroup()
			
			if debuggingmessages == true and (interceptorside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 2) then
				Debug("bluetemplate3 = "..bluetemplate, interceptorside)
			end
			
			grpgciname = grpunitgci:getName()
			
			if debuggingmessages == true and (interceptorside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 2) then
				Debug("bluetemplate4 = "..bluetemplate, interceptorside)
			end
			
			grouptable = mist.getGroupData(grpgciname)
			
			if debuggingmessages == true and (interceptorside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 2) then
				Debug("bluetemplate5 = "..bluetemplate, interceptorside)
			end
			
			interceptortype1=grouptable["units"][1]["type"]

			if debuggingmessages == true and (interceptorside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 2) then
				Debug("bluetemplate6 = "..bluetemplate, interceptorside)
			end
			
			
			bluetemplate = "__GCI__"..interceptorside.."2"
			
			if debuggingmessages == true and (interceptorside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 2) then
				Debug("bluetemplate = "..bluetemplate, interceptorside)
			end
			
			unitgci = Unit.getByName(bluetemplate)
			grpunitgci = unitgci:getGroup()
			grpgciname = grpunitgci:getName()
			grouptable = mist.getGroupData(grpgciname)
			interceptortype2=grouptable["units"][1]["type"]
				 
			bluetemplate = "__GCI__"..interceptorside.."3"
			
			if debuggingmessages == true and (interceptorside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 2) then
				Debug("bluetemplate = "..bluetemplate, interceptorside)
			end
			
			unitgci = Unit.getByName(bluetemplate)
			grpunitgci = unitgci:getGroup()
			grpgciname = grpunitgci:getName()
			grouptable = mist.getGroupData(grpgciname)
			interceptortype3=grouptable["units"][1]["type"]
			 	
			bluetemplate = "__GCI__"..interceptorside.."4"
			
			if debuggingmessages == true and (interceptorside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 2) then
				Debug("bluetemplate = "..bluetemplate, interceptorside)
			end
			
			unitgci = Unit.getByName(bluetemplate)
			grpunitgci = unitgci:getGroup()
			grpgciname = grpunitgci:getName()
			grouptable = mist.getGroupData(grpgciname)
			interceptortype4=grouptable["units"][1]["type"]
			--<<XX7

			getallaircrafts('blue')
	end

	AvailableAirborne[interceptorside] = {}
	minimumoffset = nil--reset of minimum offset for function
	possibleintercept[interceptorside] = {}
	intercept[interceptorside] = {}
	
	if debuggingmessages == true and (interceptorside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 2) then
		Debug("debuggingmessage stuck at getinterceptorairborne 1: counter:"..string.format(counter).."/ side: "..interceptorside, interceptorside)
	end	
		
	if #allairunits > 0
	then
		
		if debuggingmessages == true and (interceptorside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 2) then
			Debug("debuggingmessage stuck at getinterceptorairborne 2: counter:"..string.format(counter).."/ side: "..interceptorside, interceptorside)
		end
		
		for k = 1, #allairunits
		do
			
			if debuggingmessages == true and (interceptorside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 2) then
				Debug("debuggingmessage stuck at getinterceptorairborne 3: counter:"..string.format(counter).."/ side: "..interceptorside, interceptorside)
			end
			
			if (Unit.getByName(allairunits[k].name) ~= nil) and (Unit.getPlayerName(Unit.getByName(allairunits[k].name)) == nil) --XX8 Player not added to list of possible interceptors
				then
					local unitnam = allairunits[k].name
					local possibleinterceptorunit = Unit.getByName(allairunits[k].name)
					local possibleinterceptorunitgroup = possibleinterceptorunit:getGroup()
					local possibleinterceptorunitgroupcontrl = Group.getController(possibleinterceptorunitgroup)
				
					if debuggingmessages == true and (interceptorside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 2) then
						Debug("debuggingmessage stuck at getinterceptorairborne 4: counter:"..string.format(counter).."/ side: "..interceptorside, interceptorside)
					end
					
					if possibleinterceptorunit:inAir() == true and Controller.hasTask(possibleinterceptorunitgroupcontrl) == false
						then
					
						if debuggingmessages == true and (interceptorside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 2) then
							Debug("debuggingmessage stuck at getinterceptorairborne 5: counter:"..string.format(counter).."/ side: "..interceptorside, interceptorside)
						end
						
							if ((Unit.getTypeName(possibleinterceptorunit) == interceptortype1) or  
							   (Unit.getTypeName(possibleinterceptorunit) == interceptortype2) or  
							   (Unit.getTypeName(possibleinterceptorunit) == interceptortype3) or  
							   (Unit.getTypeName(possibleinterceptorunit) == interceptortype4)) and
							   (Unit.getPlayerName(possibleinterceptorunit) == nil) and
							   (Unit.isActive(possibleinterceptorunit)) and 
							   (string.sub(unitnam,1,3) == "GCI")
								then
								
									if debuggingmessages == true and (interceptorside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 2) then
										Debug("debuggingmessage stuck at getinterceptorairborne 6: counter:"..string.format(counter).."/ side: "..interceptorside, interceptorside)
									end
									
									local availableintunitname = allairunits[k].name
									local availableintunit =  Unit.getByName(availableintunitname)
									local availableintunitID = Unit.getID(availableintunit)
									local availableintunitpos = availableintunit:getPosition().p
									local availableintgroup = Unit.getGroup(availableintunit)
									local availableintgrpID = Group.getID(availableintgroup)
									local availableintgrpctrl = Group.getController(availableintgroup)
									local availableinttype = Unit.getTypeName(availableintunit)
									local availableintunitnumber = k
									
									if debuggingmessages == true and (interceptorside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 2) then
										Debug("debuggingmessage stuck at getinterceptorairborne 7: counter:"..string.format(counter).."/ side: "..interceptorside, interceptorside)
									end
									
									AvailableAirborne[interceptorside][#AvailableAirborne[interceptorside] + 1] =
																			{
																			unit = availableintunit,
																			unitID = availableintunitID,
																			pos = availableintunitpos,
																			group = availableintgroup,
																			groupID = availableintgrpID,
																			ctrl = availableintgrpctrl,
																			planetype = availableinttype,
																			number = availableintunitnumber
																			}

							end
					end
			end
		end

		if #actualCAPtable[interceptorside] > 0
		then
		
			if debuggingmessages == true and (interceptorside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 2) then
				Debug("debuggingmessage stuck at getinterceptorairborne 8: counter:"..string.format(counter).."/ side: "..interceptorside, interceptorside)
			end
			x = #actualCAPtable[interceptorside] - numintCAPgrps + 1 --XX replace with numintCAPgrps
			for i = x, #actualCAPtable[interceptorside]
			do
				
				if debuggingmessages == true and (interceptorside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 2) then
					Debug("debuggingmessage stuck at getinterceptorairborne 9: counter:"..string.format(counter).."/ side: "..interceptorside, interceptorside)
				end
				
				if actualCAPtable[interceptorside][i].group ~= nil
				then
				
					if debuggingmessages == true and (interceptorside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 2) then
						Debug("debuggingmessage stuck at getinterceptorairborne 10: counter:"..string.format(counter).."/ side: "..interceptorside, interceptorside)
					end
					
					if actualCAPtable[interceptorside][i].status == "on station" --or actualCAPtable[interceptorside][i].status == "enroute to station"
					then
					
						if debuggingmessages == true and (interceptorside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 2) then
							Debug("debuggingmessage stuck at getinterceptorairborne 11: counter:"..string.format(counter).."/ side: "..interceptorside, interceptorside)
						end
						
						local availableintunit =  actualCAPtable[interceptorside][i].unit1
						local availableintunitID = Unit.getID(availableintunit)
						local availableintunitpos = availableintunit:getPosition().p
						local availableintgroup = Unit.getGroup(availableintunit)
						local availableintgrpID = Group.getID(availableintgroup)
						local availableintgrpctrl = Group.getController(availableintgroup)
						local availableinttype = Unit.getTypeName(availableintunit)
						local availableintunitnumber = #AvailableAirborne[interceptorside] + 1
						AvailableAirborne[interceptorside][#AvailableAirborne[interceptorside] + 1] =
																				{
																				unit = availableintunit,
																				unitID = availableintunitID,
																				pos = availableintunitpos,
																				group = availableintgroup,
																				groupID = availableintgrpID,
																				ctrl = availableintgrpctrl,
																				planetype = availableinttype,
																				number = availableintunitnumber
																				}

					end
				end
			end
		end
	end

	if debuggingmessages == true and (interceptorside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 2) then
		AvailableAirborneTableshow = mist.utils.tableShow(AvailableAirborne[interceptorside])
		Debug(interceptorside.." AvailableAirborne: " ..AvailableAirborneTableshow, interceptorside)
	end
	
	if #AvailableAirborne[interceptorside] > 0 and #intruder[interceptorside] > 0
		then
		
			if debuggingmessages == true and (interceptorside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 2) then
				Debug("debuggingmessage stuck at getinterceptorairborne 12: counter:"..string.format(counter).."/ side: "..interceptorside, interceptorside)
			end
			---for every  fighter airborne
			for k = 1, #AvailableAirborne[interceptorside] -- for every available airborne interceptor, who has no task, this should get nearest  intruder group and write this in the table
			do
			
				if debuggingmessages == true and (interceptorside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 2) then
					Debug("debuggingmessage stuck at getinterceptorairborne 13: counter:"..string.format(counter).."/ side: "..interceptorside, interceptorside)
				end
				
				local actualinterceptorgrp = AvailableAirborne[interceptorside][k].group
				local actualinterceptorgrpctrl = Group.getController(actualinterceptorgrp)
				local actualintpos = AvailableAirborne[interceptorside][k].pos
				for l = 1, #intruder[interceptorside]
				do
					
					if debuggingmessages == true and (interceptorside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 2) then
						Debug("debuggingmessage stuck at getinterceptorairborne 14: counter:"..string.format(counter).."/ side: "..interceptorside, interceptorside)
					end
					
					local actualintruderunit = intruder[interceptorside][l].unit
					local actualintrudergroup = intruder[interceptorside][l].group
					local actualintruderpos = intruder[interceptorside][l].pos
					local actualintrudersize = intruder[interceptorside][l].size
					local actualoffset = math.sqrt((actualintpos.x - actualintruderpos.x)*(actualintpos.x - actualintruderpos.x) + (actualintpos.z - actualintruderpos.z)*(actualintpos.z - actualintruderpos.z))
					
					if debuggingmessages == true and (interceptorside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 2) then
						Debug("debuggingmessage stuck at getinterceptorairborne 15: counter:"..string.format(counter).."/ side: "..interceptorside, interceptorside)
					end
										
					--if minimumoffset == nil
					if l == 1
						then
							minimumoffset = actualoffset
							closestintruderunit = actualintruderunit
							closestintruderunitpos = actualintruderpos
							closestinterceptorgrp = actualinterceptorgrp
							closestgrptointerceptgrp = actualintrudergroup
							closestgrpintrudergroupsize = actualintrudersize
					elseif l > 1 and minimumoffset > actualoffset
						then
							minimumoffset = actualoffset
							closestintruderunit = actualintruderunit
							closestintruderunitpos = actualintruderpos
							closestinterceptorgrp = actualinterceptorgrp
							closestgrptointerceptgrp = actualintrudergroup
							closestgrpintrudergroupsize = actualintrudersize
					end
				end

				
				if debuggingmessages == true and (interceptorside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 2) then
					Debug("debuggingmessage stuck at getinterceptorairborne 16: counter:"..string.format(counter).."/ side: "..interceptorside, interceptorside)
				end
				
				possibleintercept[interceptorside][#possibleintercept[interceptorside] + 1] =
															{
															targetunit = closestintruderunit,
															targetunitpos = closestintruderunitpos,
															grp = closestinterceptorgrp,
															targetgrp = closestgrptointerceptgrp,
															distance = minimumoffset,
															intrudersize = closestgrpintrudergroupsize,
															number = #possibleintercept[interceptorside] + 1
															}

			end

			if debuggingmessages == true and (interceptorside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 2) then
				possibleinterceptTable = mist.utils.tableShow(possibleintercept[interceptorside])
				Debug(interceptorside.." possibleintercept: " ..possibleinterceptTable, interceptorside)
			end
				
			if #possibleintercept[interceptorside] > 0
				then
				
					if debuggingmessages == true and (interceptorside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 2) then
						Debug("debuggingmessage stuck at getinterceptorairborne 17: counter:"..string.format(counter).."/ side: "..interceptorside, interceptorside)
					end
				
					for c = 1, #possibleintercept[interceptorside]
					do
						if c == 1
							then
								shortestdistance = possibleintercept[interceptorside][c].distance
								shortestdistanceID = possibleintercept[interceptorside][c].number
						end
						if c > 1 and possibleintercept[interceptorside][c].distance < shortestdistance
							then
								shortestdistance = possibleintercept[interceptorside][c].distance
								shortestdistanceID = possibleintercept[interceptorside][c].number
						end
					end
					
					if debuggingmessages == true and (interceptorside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 2) then
						Debug("debuggingmessage stuck at getinterceptorairborne 18: counter:"..string.format(counter).."/ side: "..interceptorside, interceptorside)
					end
					
					intercept[interceptorside][#intercept[interceptorside]+1] =  --table which contains pair of interceptor and intruder without task
								{
								targetunit = possibleintercept[interceptorside][shortestdistanceID].targetunit,
								targetunitpos = possibleintercept[interceptorside][shortestdistanceID].targetunitpos,
								grp = possibleintercept[interceptorside][shortestdistanceID].grp,
								targetgrp = possibleintercept[interceptorside][shortestdistanceID].targetgrp,
								distance = possibleintercept[interceptorside][shortestdistanceID].distance,
								IDnumber = possibleintercept[interceptorside][shortestdistanceID].number
								}

					if debuggingmessages == true and (interceptorside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 2) then
						interceptTable = mist.utils.tableShow(intercept[interceptorside])
						Debug(interceptorside.." interceptTable: " ..interceptTable, interceptorside)
					end

			end

	end

return intercept[interceptorside]
end --getinterceptorairborne

-----------------------------get closest airfield to  intruder
function getAFtable(color)

	local airfieldside = color
    --local AF = {}
	if airfieldside == 'red'
		then
			--airspaceviolation('red')

			AF = {}
			--XX8 load airfield table from red airfields >>
			for i = 1, #redAF do
				AF[#AF+1] = {name=redAF[i].name}
			end 
			 
			--XX8 <<
			
			if debuggingmessages == true and (airfieldside == debuggingside or debuggingside == 'both') then
				local airfldsTable = mist.utils.tableShow(AF)
				Debug("red Airfields: " ..airfldsTable, 'red')
			end
			
	elseif airfieldside == 'blue'
		then
			--airspaceviolation('blue')

			AF = {}
			--XX8 load airfield table from blue airfields >>
			for i = 1, #blueAF do
				AF[#AF+1] = {name=blueAF[i].name}
			end 
			--XX8 <<			
			
			if debuggingmessages == true and (airfieldside == debuggingside or debuggingside == 'both') then
				local airfldsTable = mist.utils.tableShow(AF)
				Debug("blue Airfields: " ..airfldsTable, 'blue')
			end
	end


	closestairfieldtable = nil
	closestairfieldtable = {}

	if  #intruder[airfieldside] > 0
		then
			for m = 1, #intruder[airfieldside]
			do
				local actualintrudergroup = intruder[airfieldside][m].group
				local actualintruderpos = intruder[airfieldside][m].pos

				for n = 1, #AF --XX8 
				do
					closestairfieldname = AF[n].name
					actualairfield = trigger.misc.getZone(closestairfieldname)
					actualairfieldpos = {}
					actualairfieldposx = actualairfield.point.x
					actualairfieldposz = actualairfield.point.z

					actualdistancetoairfield = math.sqrt((actualairfieldposx - actualintruderpos.x)*(actualairfieldposx - actualintruderpos.x) + (actualairfieldposz - actualintruderpos.z)*(actualairfieldposz - actualintruderpos.z))
					closestairfield = Airbase.getByName(closestairfieldname)
					closestairfieldID = closestairfield:getID()

					if n == 1
						then
							minimumdistancetoairfield = actualdistancetoairfield
							closestairfieldtable[m] =
																								{
																								distance = minimumdistancetoairfield,
																								AFname = closestairfieldname,
																								airfield = closestairfield,
																								airfieldID = closestairfieldID,
																								airfieldposx = actualairfieldposx,
																								airfieldposz = actualairfieldposz,
																								intrudergroup = actualintrudergroup
																								}
					elseif actualdistancetoairfield < minimumdistancetoairfield
						then
							minimumdistancetoairfield = actualdistancetoairfield
							closestairfieldtable[m] =
																								{
																								distance = minimumdistancetoairfield,
																								AFname = closestairfieldname,
																								airfield = closestairfield,
																								airfieldID = closestairfieldID,
																								airfieldposx = actualairfieldposx,
																								airfieldposz = actualairfieldposz,
																								intrudergroup = actualintrudergroup
																								}
					end
				end
			end
	end
return closestairfieldtable
end --getAFtable

--------------------------spawn  interceptor
function spawninterceptor(color)

	local interceptorside = color
	local interceptorskill = "Random" --XX6
	local payloadtable = {} --XX7
	local redgcitemplate = "" --XX7
	local bluegcitemplate = "" --XX7
	local grouptable = {} --XX7
	local unit_id = 0 --XX7
	local grpunit = 0 --XX7
	local grpname = "" --XX7
	local gci_country = nil --XX8
	local intgroupcounter = 0 --XX9

	if interceptorside == 'red'
		then
			maxnumberofspawnedandactiveinterceptorgroups = numberofspawnedandactiveinterceptorgroupsRED
			getinterceptorairborne('red')
			--interceptorcountry = redinterceptorcountry --XX8 YY changed to use variable set at top of script
			local RandomInterceptor = math.random(1,4)
			--XX7 template logic >>
			redgcitemplate = "__GCI__"..interceptorside..RandomInterceptor
			
			if debuggingmessages == true and (interceptorside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 3) then
				Debug("redgcitemplate = "..redgcitemplate,interceptorside)
			end
			
			payloadtable = mist.getPayload(redgcitemplate)
			unit_id = Unit.getByName(redgcitemplate)
			grpunit = unit_id:getGroup()
			grpname = grpunit:getName()
			grouptable = mist.getGroupData(grpname)
			gci_country = grouptable["countryId"] --XX8
			intercpetortype=grouptable["units"][1]["type"]
			intercpetorskin=grouptable["units"][1]["livery_id"]
			interceptorskill=grouptable["units"][1]["skill"]
			interceptorcountry=gci_country --XX8
			intpayload = payloadtable --XX7
			--<<XX7
	 

			getallaircrafts('red')
			getAFtable('red')

			elseif interceptorside == 'blue'
				then
					maxnumberofspawnedandactiveinterceptorgroups = numberofspawnedandactiveinterceptorgroupsBLUE
					getinterceptorairborne('blue')
					--airspaceviolation('blue')
					--interceptorcountry = blueinterceptorcountry --XX8 YY parameterise country
					local RandomInterceptor = math.random(1,4) --XX7
			 
					--XX7 template logic >>
					local bluegcitemplate = "__GCI__"..interceptorside..RandomInterceptor
				
					if debuggingmessages == true and (interceptorside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 3) then
						Debug("bluegcitemplate = "..bluegcitemplate,interceptorside)
					end

					payloadtable = mist.getPayload(bluegcitemplate)
					unit_id = Unit.getByName(bluegcitemplate)
					grpunit = unit_id:getGroup()
					grpname = grpunit:getName()
					grouptable = mist.getGroupData(grpname)
					gci_country = grouptable["countryId"] --XX8
					intercpetortype=grouptable["units"][1]["type"]
					intercpetorskin=grouptable["units"][1]["livery_id"]
					interceptorskill=grouptable["units"][1]["skill"]
					intpayload = payloadtable --XX7	
					interceptorcountry=gci_country --XX8
					--<<XX7
					
					getallaircrafts('blue')
					getAFtable('blue')

	end
	
	if debuggingmessages == true and (interceptorside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 3) then
		Debug("debuggingmessage stuck at spawninterceptor 1: counter:"..string.format(counter).."/ side: "..interceptorside, interceptorside)
		Debug("#AvailableAirborne: "..#AvailableAirborne[interceptorside].." #intruders: "..#intruder[interceptorside].." "..interceptorside, interceptorside)
	end
	
	if #AvailableAirborne[interceptorside] == 0 and #intruder[interceptorside] > 0 --check if intruder is in space and no fighter airborne CONDITION FAILING***
	then
		for a = 1, #intruder[interceptorside]--for every detected intruder do start the loop
		do
			local targetalreadyintercepted = false
			local Interceptorgroupname = "GCI-> "..intruder[interceptorside][a].name

			if intruder[interceptorside][a].group ~= nil
			then
				Interceptortrgtgrp = intruder[interceptorside][a].group
				local InterceptortrgtgrpID = Group.getID(Interceptortrgtgrp)

				for b = 1, #interceptspawnstatus[interceptorside] --check if intruder is already intercepted by a fighter spawned
				do
					if interceptspawnstatus[interceptorside][b].Target == Interceptortrgtgrp and targetalreadyintercepted == false
					then
						targetalreadyintercepted = true
					end
				end

				if #interceptstatus[interceptorside] > 0 and targetalreadyintercepted == false --if loop above did not set the  targetalreadyintercepted to "true" check if
				then
					for c = 1, #interceptstatus[interceptorside]
					do
						if interceptstatus[interceptorside][c].Target ~= nil and interceptstatus[interceptorside][c].TargetID ~= nil
						then
							currentintercepttargetgrpID = interceptstatus[interceptorside][c].TargetID
							if currentintercepttargetgrpID == InterceptortrgtgrpID and targetalreadyintercepted == false
								then
									targetalreadyintercepted = true
							end
						end
					end
				end
				
				if debuggingmessages == true and (interceptorside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 3) then
					Debug("debuggingmessage stuck at spawninterceptor 2: counter:"..string.format(counter).."/ side: "..interceptorside, interceptorside)
					Debug("check GCI conditions side2: "..interceptorside.." #number: "..string.format(#numberofspawnedandactiveinterceptorgroups[interceptorside]).." max: "..string.format(maxnumberofspawnedandactiveinterceptorgroups), interceptorside)
				end
				
				if Interceptortrgtgrp ~= nil and targetalreadyintercepted == false and #numberofspawnedandactiveinterceptorgroups[interceptorside] < maxnumberofspawnedandactiveinterceptorgroups
				then
					--XX9 if logistics not used or if side's in supply then allow add group.
					if debuggingmessages == true and (interceptorside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 3) then
						Debug("blue GCI supplyA:" ..string.format(bluegroupsupply), interceptorside)
						Debug("red GCI supplyA:" ..string.format(redgroupsupply), interceptorside)
					end
					
					if (limitedlogistics == 0) or 
					   (limitedlogistics == 1 and interceptorside == 'red' and redgroupsupply > 0) or 
					   (limitedlogistics == 1 and interceptorside == 'blue' and bluegroupsupply > 0) then
						
						if debuggingmessages == true and (interceptorside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 3) then
							Debug("blue GCI supplyB:" ..string.format(bluegroupsupply), interceptorside)
							Debug("red GCI supplyB:" ..string.format(redgroupsupply), interceptorside)
						end
						
						for z = 1, #closestairfieldtable
						do
							if	closestairfieldtable[z].intrudergroup == Interceptortrgtgrp
							then
								_airdromeId = closestairfieldtable[z].airfieldID
								closestairfieldposx = closestairfieldtable[z].airfieldposx
								closestairfieldposz = closestairfieldtable[z].airfieldposz
							end
						end
						--XX9 assign seperate GCI counters
						if interceptorside == 'red' then
							redintgroupcounter = redintgroupcounter + 1
							intgroupcounter = redintgroupcounter
						else
							blueintgroupcounter = blueintgroupcounter + 1
							intgroupcounter = blueintgroupcounter
						end
						
						if intruder[interceptorside][a].unit ~= nil
						then
							Intercepttrgtunit = intruder[interceptorside][a].unit
						end
						
						if debuggingmessages == true and (interceptorside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 3) then
							Debug("debuggingmessage stuck at spawninterceptor 3: counter:"..string.format(counter).."/ side: "..interceptorside, interceptorside)
						end
						
						local Intercepttrgtunitpos = Intercepttrgtunit:getPosition().p
						local Intercepttrgtunitposx = Intercepttrgtunitpos.x
						local Intercepttrgtunitposz = Intercepttrgtunitpos.z
						local Intercepttrgtunitposy = Intercepttrgtunitpos.y
						local Interceptgrpposx = closestairfieldposx
						local Interceptgrpposz = closestairfieldposz
						local Interceptgrpposy = land.getHeight({x = closestairfieldposx, y = closestairfieldposz})
						local interceptpointx = Interceptgrpposx + (Intercepttrgtunitposx-Interceptgrpposx)/6
						local interceptpointz = Interceptgrpposz + (Intercepttrgtunitposz-Interceptgrpposz)/6
						local interceptpointy = Interceptgrpposy + (Intercepttrgtunitposy-Interceptgrpposy)/6
						local endpointx = Interceptgrpposx + (Intercepttrgtunitposx-Interceptgrpposx)/4
						local endpointz = Interceptgrpposz + (Intercepttrgtunitposz-Interceptgrpposz)/4
						local endpointy = Interceptgrpposy + (Intercepttrgtunitposy-Interceptgrpposy)/4
						local InterceptortrgtgrpID = intruder[interceptorside][a].GroupID

						if debuggingmessages == true and (interceptorside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 3) then
							Debug("debuggingmessage stuck at spawninterceptor 4: counter:"..string.format(counter).."/ side: "..interceptorside, interceptorside)
						end
						
						if GCIgroupsize == "randomized"
						then
							strengthrandomizer = math.random(1,4)
							elseif GCIgroupsize == "2"
							then
							strengthrandomizer = 2
							elseif GCIgroupsize == "4"
							then
							strengthrandomizer = 4
							elseif GCIgroupsize == "dynamic"
							then
							strengthrandomizer = intruder[interceptorside][a].size
						end
						
						if limitedlogistics == 1 and interceptorside == 'red' and strengthrandomizer > redgroupsupply then
							strengthrandomizer = redgroupsupply
						end
						if limitedlogistics == 1 and interceptorside == 'blue' and strengthrandomizer > bluegroupsupply then
							strengthrandomizer = bluegroupsupply
						end
						
						if debuggingmessages == true and (interceptorside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 3) then
							Debug("debuggingmessage stuck at spawninterceptor 5: counter:"..string.format(counter).."/ side: "..interceptorside, interceptorside)
						end
						
						interceptorunitstable = {}
						for j = 1, strengthrandomizer
						do
							--XX3 Fix GCI spawning >>
							if Spawnmode == "parking"
							then
								RNW_type = "TakeOffParking"
								RNW_action = "From Parking Area"
								CAPspawnalt = land.getHeight{x = closestairfieldposx, y = closestairfieldposz} --XX consider terrain
								elseif Spawnmode == "takeoff" --YY capitalisation
								then
									RNW_type = "TakeOff"
									RNW_action = "From Runway"
									CAPspawnalt = land.getHeight{x = closestairfieldposx, y = closestairfieldposz} --XX consider terrain
									elseif Spawnmode == "air" --YY capitalisation
									then
										RNW_type = "Turning Point"
										RNW_action = "Turning Point"
										CAPspawnalt = 300 + land.getHeight{x = closestairfieldposx, y = closestairfieldposz} --XX consider terrain
							end
							--XX3 << End fix for GCI spawning		
							interceptorunitstable[j] = 		{
																["alt"] = CAPspawnalt, --XX3
																["heading"] = 0,
																["livery_id"] = intercpetorskin,
																["type"] = intercpetortype,
																["psi"] = 0,
																["onboard_num"] = "1"..string.format(j),
																["parking"] = string.format(j),
																["y"] = Interceptgrpposz + ((string.format(j)-1)*50),
																["x"] = Interceptgrpposx + ((string.format(j)-1)*50),
																["name"] =  Interceptorgroupname.."-Fl#"..intgroupcounter.."-"..string.format(j),
																["payload"] = intpayload,
																["speed"] = 350,
																["unitId"] =  math.random(9999,99999),
																["alt_type"] = "BARO",
																["skill"] = interceptorskill, --XX7 use template planes skill
															}
						end
						
						if debuggingmessages == true and (interceptorside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 3) then
							Debug("debuggingmessage stuck at spawninterceptor 6: counter:"..string.format(counter).."/ side: "..interceptorside, interceptorside)
						end
						
						local interceptordata = {
											["modulation"] = 0,
											["tasks"] =
											{
												}, -- end of ["tasks"]
											["task"] = "CAP",
											["uncontrolled"] = false,
											["route"] =
											{
												["points"] =
												{
													[1] =
													{
														["alt"] = CAPspawnalt, --XX3
														["type"] = RNW_type,
														["action"] = RNW_action,
														["alt_type"] = "BARO",
														["formation_template"] = "",
														["ETA"] = 0,
														["airdromeId"] = _airdromeId,
														["y"] = Interceptgrpposz,
														["x"] = Interceptgrpposx,
														["speed"] = 250,
														["ETA_locked"] = true,
														["task"] =
														{
															["id"] = "ComboTask",
															["params"] =
															{
																["tasks"] =
																{
																	[1] =
																	{
																		["number"] = 1,
																		["auto"] = true,
																		["id"] = "EngageTargets",
																		["enabled"] = true,
																		["key"] = "CAP",
																		["params"] =
																		{
																			["targetTypes"] =
																			{
																				[1] = "Air",
																			}, -- end of ["targetTypes"]
																			["priority"] = 0,
																		}, -- end of ["params"]
																	}, -- end of [1]

																}, -- end of ["tasks"]
															}, -- end of ["params"]
														}, -- end of ["task"]
														["speed_locked"] = true,
													}, -- end of [1]
													[2] =
													{
														["alt"] = interceptpointy,
														["type"] = "Turning Point",
														["action"] = "Turning Point",
														["alt_type"] = "BARO",
														["formation_template"] = "",
														["properties"] =
														{
															["vnav"] = 1,
															["scale"] = 0,
															["angle"] = 0,
															["vangle"] = 0,
															["steer"] = 2,
														}, -- end of ["properties"]
														["ETA"] = 118.26335192344,
														["y"] = interceptpointz,
														["x"] = interceptpointx,
														["speed"] = 350,
														["ETA_locked"] = false,
														["task"] =
														{
															["id"] = "ComboTask",
															["params"] =
															{
																["tasks"] =
																{
																	[1] =
																	{
																		["enabled"] = true,
																		["auto"] = false,
																		["id"] = "EngageGroup",
																		["number"] = 1,
																		["params"] =
																		{
																			["visible"] = false,
																			["groupId"] = InterceptortrgtgrpID,
																			["priority"] = 1,
																			["weaponType"] = 1069547520,
																		}, -- end of ["params"]
																	}, -- end of [1]
																	[2] =
																	{
																		["number"] = 2,
																		["auto"] = false,
																		["id"] = "WrappedAction",
																		["enabled"] = true,
																		["params"] =
																		{
																			["action"] =
																			{
																				["id"] = "Option",
																				["params"] =
																				{
																					["value"] = 2,
																					["name"] = 3,
																				}, -- end of ["params"]
																			}, -- end of ["action"]
																		}, -- end of ["params"]
																	}, -- end of [2]
																	[3] =
																	{
																		["number"] = 3,
																		["auto"] = false,
																		["id"] = "WrappedAction",
																		["enabled"] = true,
																		["params"] =
																		{
																			["action"] =
																			{
																				["id"] = "Option",
																				["params"] =
																				{
																					["value"] = 1,
																					["name"] = 4,
																				}, -- end of ["params"]
																			}, -- end of ["action"]
																		}, -- end of ["params"]
																	}, -- end of [3]
																	[4] =
																	{
																		["number"] = 4,
																		["auto"] = false,
																		["id"] = "WrappedAction",
																		["enabled"] = true,
																		["params"] =
																		{
																			["action"] =
																			{
																				["id"] = "Option",
																				["params"] =
																				{
																					["value"] = true,
																					["name"] = 6,
																				}, -- end of ["params"]
																			}, -- end of ["action"]
																		}, -- end of ["params"]
																	}, -- end of [4]
																	[5] =
																	{
																		["enabled"] = true,
																		["auto"] = false,
																		["id"] = "WrappedAction",
																		["number"] = 5,
																		["params"] =
																		{
																			["action"] =
																			{
																				["id"] = "Option",
																				["params"] =
																				{
																					["value"] = 264241152,
																					["name"] = 10,
																				}, -- end of ["params"]
																			}, -- end of ["action"]
																		}, -- end of ["params"]
																	}, -- end of [5]
																	[6] =
																	{
																		["number"] = 6,
																		["auto"] = false,
																		["id"] = "WrappedAction",
																		["enabled"] = true,
																		["params"] =
																		{
																			["action"] =
																			{
																				["id"] = "Option",
																				["params"] =
																				{
																					["value"] = 4,
																					["name"] = 1,
																				}, -- end of ["params"]
																			}, -- end of ["action"]
																		}, -- end of ["params"]
																	}, -- end of [6]
																}, -- end of ["tasks"]
															}, -- end of ["params"]
														}, -- end of ["task"]
														["speed_locked"] = true,
													}, -- end of [2]
													[3] =
													{
														["alt"] = endpointy,
														["type"] = "Turning Point",
														["action"] = "Turning Point",
														["alt_type"] = "BARO",
														["formation_template"] = "",
														["properties"] =
														{
															["vnav"] = 1,
															["scale"] = 0,
															["angle"] = 0,
															["vangle"] = 0,
															["steer"] = 2,
														}, -- end of ["properties"]
														["ETA"] = 118.26335192344,
														["y"] = endpointz,
														["x"] = endpointx,
														["speed"] = 300,
														["ETA_locked"] = false,
														["task"] =
														{
															["id"] = "ComboTask",
															["params"] =
															{
																["tasks"] =
																{

																}, -- end of ["tasks"]
															}, -- end of ["params"]
														}, -- end of ["task"]
														["speed_locked"] = true,
													}, -- end of [3]
												}, -- end of ["points"]
												}, -- end of ["route"]
											["groupId"] = math.random(10000,99999),
											["hidden"] = hideenemy, --XX hide enemy cap
											["units"] = interceptorunitstable,
											["y"] = Interceptgrpposz,
											["x"] = Interceptgrpposx,
											["name"] =  Interceptorgroupname.. intgroupcounter,
											["communication"] = true,
											["start_time"] = 0,
											["frequency"] = 124,
											}
						
						coalition.addGroup(interceptorcountry, Group.Category.AIRPLANE, interceptordata)
					
						--table to limit at the same time spawned interceptor groups
						numberofspawnedandactiveinterceptorgroups[interceptorside][#numberofspawnedandactiveinterceptorgroups[interceptorside] + 1] =
																					{
																					count = #numberofspawnedandactiveinterceptorgroups[interceptorside]
																					}

						local Interceptgrp = Group.getByName(Interceptorgroupname.. intgroupcounter)

						--table to track the spawned GCI fighter group since latest task reset
						interceptspawnstatus[interceptorside][#interceptspawnstatus[interceptorside] + 1] =
																					{
																					Interceptor = Interceptgrp,
																					Target = Interceptortrgtgrp,
																					TargetID = Group.getID(Interceptgrp)
																					}

						--table to track the of the total time spawned GCI fighter groups, CAP flights tasked to intercept by generatetask function will be added to the table
						interceptspawntotal[interceptorside][#interceptspawntotal[interceptorside] + 1] =
																					{
																					group = Interceptgrp,
																					unitname1 = Interceptorgroupname.."-Fl#"..intgroupcounter.."-1",
																					unitname2 = Interceptorgroupname.."-Fl#"..intgroupcounter.."-2"
																					}

						if debuggingmessages == true and (interceptorside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 3) then
							interceptspawnstatusTable = mist.utils.tableShow(interceptspawnstatus[interceptorside])
							Debug(interceptorside.." interceptspawnstatus:" ..interceptspawnstatusTable, interceptorside)
						end
						
						--XX9 fix strengthrandomizer conditions to match how aircraft are spawned
						if strengthrandomizer == 1 then --XX4 >>
							stuckunitstable[Interceptorgroupname.."-Fl#"..intgroupcounter.."-1"] = timer.getTime() --XX4 record spawn time of unit1
							elseif strengthrandomizer == 2 then --XX9
								stuckunitstable[Interceptorgroupname.."-Fl#"..intgroupcounter.."-1"] = timer.getTime() --XX4 record spawn time of unit1
								stuckunitstable[Interceptorgroupname.."-Fl#"..intgroupcounter.."-2"] = timer.getTime() --XX4 record spawn time of unit2
								elseif strengthrandomizer == 3 then --XX9
									stuckunitstable[Interceptorgroupname.."-Fl#"..intgroupcounter.."-1"] = timer.getTime() --XX4 record spawn time of unit1
									stuckunitstable[Interceptorgroupname.."-Fl#"..intgroupcounter.."-2"] = timer.getTime() --XX4 record spawn time of unit2
									stuckunitstable[Interceptorgroupname.."-Fl#"..intgroupcounter.."-3"] = timer.getTime() --XX4 record spawn time of unit3								
									elseif strengthrandomizer == 4 then --XX9
										stuckunitstable[Interceptorgroupname.."-Fl#"..intgroupcounter.."-1"] = timer.getTime() --XX4 record spawn time of unit1
										stuckunitstable[Interceptorgroupname.."-Fl#"..intgroupcounter.."-2"] = timer.getTime() --XX4 record spawn time of unit2
										stuckunitstable[Interceptorgroupname.."-Fl#"..intgroupcounter.."-3"] = timer.getTime() --XX4 record spawn time of unit3
										stuckunitstable[Interceptorgroupname.."-Fl#"..intgroupcounter.."-4"] = timer.getTime() --XX4 record spawn time of unit4
						end	--XX4 strengthrandomizer <<
					end --logistics
				end --less than max intercepts
			end --group ~= nil
		end --do for each intruder
	end --if there are interceptors and intruders
	
return interceptspawnstatus[interceptorside], stuckunitstable --XX4
end --spawninterceptor

---------------------------------------------Set intercept task for  Interceptor
function generatetask(color)

	local interceptorside = color
	if interceptorside == 'red'
		then
			getinterceptorairborne('red')
	elseif interceptorside == 'blue'
		then
			getinterceptorairborne('blue')
	end
	if #intercept[interceptorside] > 0
		then
			for a = 1, #intercept[interceptorside]
			do
				local targetalreadyintercepted = false
				if intercept[interceptorside][a].targetgrp ~= nil
					then
						local Interceptgrp = intercept[interceptorside][a].grp
						local Interceptortrgtpos = intercept[interceptorside][a].targetunitpos
						local Interceptortrgtgrp = intercept[interceptorside][a].targetgrp
						local InterceptortrgtgrpID = Group.getID(Interceptortrgtgrp)
						if #interceptstatus[interceptorside] > 0 and targetalreadyintercepted == false
							then
								for b = 1, #interceptstatus[interceptorside]
								do
									if interceptstatus[interceptorside][b].Target == Interceptortrgtgrp and targetalreadyintercepted == false
										then
											targetalreadyintercepted = true
									end
								end
						end

						if #interceptspawnstatus[interceptorside] > 0 and targetalreadyintercepted == false
							then
								for c = 1, #interceptspawnstatus[interceptorside]
								do
									if interceptspawnstatus[interceptorside][c].Target ~= nil and interceptspawnstatus[interceptorside][c].TargetID ~= nil
										then
											local currentintercepttargetgrp = interceptspawnstatus[interceptorside][c].Target
											local currentintercepttargetgrpID = interceptspawnstatus[interceptorside][c].TargetID
											if currentintercepttargetgrpID == InterceptortrgtgrpID and targetalreadyintercepted == false
												then
													targetalreadyintercepted = true
											end
									end
								end
						end
						if Interceptgrp ~= nil and Interceptortrgtgrp ~= nil and targetalreadyintercepted == false and Group.getID(Interceptortrgtgrp) ~= nil and Interceptortrgtpos ~= nil and Interceptgrp:getUnit(1) ~= nil
							then
								local Interceptgrppcontroller = Interceptgrp:getController()
								Controller.resetTask(Interceptgrppcontroller)
								local InterceptortrgtgrpID = Group.getID(Interceptortrgtgrp)
								local Interceptgrppos = Unit.getPosition(Interceptgrp:getUnit(1)).p
								
								if debuggingmessages == true and (interceptorside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 4) then
									Debug("debuggingmessage generatetask: script hung A-X1: counter:"..string.format(counter).."/interceptorside: "..interceptorside, interceptorside)--hang fixed???
								end
									
								local interceptpointx = Interceptgrppos.x + (-Interceptgrppos.x + Interceptortrgtpos.x)/2
								local interceptpointz = Interceptgrppos.z + (-Interceptgrppos.z + Interceptortrgtpos.z)/2
								local interceptpointy = Interceptortrgtpos.y
								local Intercepttask = {
														id = 'Mission',
														params = {
														route =
														{
															["points"] =
															{
															[1] =
																{
																	["alt"] = Interceptgrppos.y,
																	["type"] = "Turning Point",
																	["action"] = "Turning Point",
																	["alt_type"] = "BARO",
																	["formation_template"] = "",
																	["properties"] =
																	{
																		["vnav"] = 1,
																		["scale"] = 0,
																		["angle"] = 0,
																		["vangle"] = 0,
																		["steer"] = 2,
																	}, -- end of ["properties"]
																	["ETA"] = 118.26335192344,
																	["y"] = Interceptgrppos.z,
																	["x"] = Interceptgrppos.x,
																	["speed"] = 350,
																	["ETA_locked"] = false,
																	["task"] =
																	{
																		["id"] = "ComboTask",
																		["params"] =
																		{
																			["tasks"] =
																			{
																				[1] =
																				{
																					["number"] = 1,
																					["auto"] = false,
																					["id"] = "EngageTargetsInZone",
																					["enabled"] = true,
																					["params"] =
																					{
																						["targetTypes"] =
																						{
																							[1] = "Air",
																						}, -- end of ["targetTypes"]
																						["x"] = Interceptortrgtpos.x,
																						["priority"] = 0,
																						["y"] = Interceptortrgtpos.z,
																						["zoneRadius"] = math.sqrt((Interceptgrppos.x-Interceptortrgtpos.x)*(Interceptgrppos.x-Interceptortrgtpos.x)+(Interceptgrppos.z-Interceptortrgtpos.z)*(Interceptgrppos.z-Interceptortrgtpos.z)),
																					}, -- end of ["params"]
																				}, -- end of [1]
																				[2] =
																				{
																					["number"] = 2,
																					["auto"] = false,
																					["id"] = "WrappedAction",
																					["enabled"] = true,
																					["params"] =
																					{
																						["action"] =
																						{
																							["id"] = "Option",
																							["params"] =
																							{
																								["value"] = 1,
																								["name"] = 0,
																							}, -- end of ["params"]
																						}, -- end of ["action"]
																					}, -- end of ["params"]
																				}, -- end of [2]
																				[3] =
																				{
																					["number"] = 3,
																					["auto"] = false,
																					["id"] = "WrappedAction",
																					["enabled"] = true,
																					["params"] =
																					{
																						["action"] =
																						{
																							["id"] = "Option",
																							["params"] =
																							{
																								["value"] = 2,
																								["name"] = 3,
																							}, -- end of ["params"]
																						}, -- end of ["action"]
																					}, -- end of ["params"]
																				}, -- end of [3]
																				[4] =
																				{
																					["number"] = 4,
																					["auto"] = false,
																					["id"] = "WrappedAction",
																					["enabled"] = true,
																					["params"] =
																					{
																						["action"] =
																						{
																							["id"] = "Option",
																							["params"] =
																							{
																								["value"] = 3,
																								["name"] = 1,
																							}, -- end of ["params"]
																						}, -- end of ["action"]
																					}, -- end of ["params"]
																				}, -- end of [4]


																			}, -- end of ["tasks"]
																		}, -- end of ["params"]
																	}, -- end of ["task"]
																	["speed_locked"] = true,
																}, -- end of [1]
																[2] =
																{
																	["alt"] = interceptpointy,
																	["type"] = "Turning Point",
																	["action"] = "Turning Point",
																	["alt_type"] = "BARO",
																	["formation_template"] = "",
																	["properties"] =
																	{
																		["vnav"] = 1,
																		["scale"] = 0,
																		["angle"] = 0,
																		["vangle"] = 0,
																		["steer"] = 2,
																	}, -- end of ["properties"]
																	["ETA"] = 118.26335192344,
																	["y"] = interceptpointz,
																	["x"] = interceptpointx,
																	["speed"] = 350,
																	["ETA_locked"] = false,
																	["task"] =
																	{
																		["id"] = "ComboTask",
																		["params"] =
																		{
																			["tasks"] =
																			{
																				[1] =
																				{
																					["enabled"] = true,
																					["auto"] = false,
																					["id"] = "EngageTargetsInZone",
																					["number"] = 1,
																					["params"] =
																					{
																						["targetTypes"] =
																						{
																							[1] = "Air",
																						}, -- end of ["targetTypes"]
																						["x"] = Interceptortrgtpos.x,
																						["priority"] = 1,
																						["y"] = Interceptortrgtpos.z,
																						["zoneRadius"] = math.sqrt((Interceptgrppos.x-Interceptortrgtpos.x)*(Interceptgrppos.x-Interceptortrgtpos.x)+(Interceptgrppos.z-Interceptortrgtpos.z)*(Interceptgrppos.z-Interceptortrgtpos.z)),
																					}, -- end of ["params"]
																				}, -- end of [1]
																				[2] =
																				{
																					["number"] = 2,
																					["auto"] = false,
																					["id"] = "WrappedAction",
																					["enabled"] = true,
																					["params"] =
																					{
																						["action"] =
																						{
																							["id"] = "Option",
																							["params"] =
																							{
																								["value"] = 1,
																								["name"] = 0,
																							}, -- end of ["params"]
																						}, -- end of ["action"]
																					}, -- end of ["params"]
																				}, -- end of [2]
																				[3] =
																				{
																					["number"] = 3,
																					["auto"] = false,
																					["id"] = "WrappedAction",
																					["enabled"] = true,
																					["params"] =
																					{
																						["action"] =
																						{
																							["id"] = "Option",
																							["params"] =
																							{
																								["value"] = 2,
																								["name"] = 3,
																							}, -- end of ["params"]
																						}, -- end of ["action"]
																					}, -- end of ["params"]
																				}, -- end of [3]
																				[4] =
																				{
																					["number"] = 4,
																					["auto"] = false,
																					["id"] = "WrappedAction",
																					["enabled"] = true,
																					["params"] =
																					{
																						["action"] =
																						{
																							["id"] = "Option",
																							["params"] =
																							{
																								["value"] = 3,
																								["name"] = 1,
																							}, -- end of ["params"]
																						}, -- end of ["action"]
																					}, -- end of ["params"]
																				}, -- end of [4]
																			}, -- end of ["tasks"]
																		}, -- end of ["params"]
																	}, -- end of ["task"]
																	["speed_locked"] = true,
																}, -- end of [2]
															}, -- end of ["points"]
														}
													}
												}

								Controller.setTask(Interceptgrppcontroller, Intercepttask)
								interceptstatus[interceptorside][#interceptstatus[interceptorside] + 1] =
																			{
																			Interceptor = Interceptgrp,
																			Interceptorgrpname = Group.getName(Interceptgrp),
																			Target = Interceptortrgtgrp,
																			Targetgrpname  = Group.getName(Interceptortrgtgrp),
																			TargetID = Group.getID(Interceptortrgtgrp)
																			}
																			
								if debuggingmessages == true and (interceptorside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 4) then
									Debug("debuggingmessage generatetask: script hung A-X2: counter:"..string.format(counter).."/interceptorside: "..interceptorside, interceptorside)
								end
								
								for i = 1, #actualCAPtable[interceptorside]
								do
									if actualCAPtable[interceptorside][i].group ~= nil
									then
										if actualCAPtable[interceptorside][i].group == Interceptgrp and actualCAPtable[interceptorside][i].status == "on station"
										then
											actualCAPtable[interceptorside][i].status = "intercepting"
											interceptspawntotal[interceptorside][#interceptspawntotal[interceptorside] + 1] =
																					{
																					group = Interceptgrp,
																					unitname1 = Unit.getName(actualCAPtable[interceptorside][i].unit1),
																					unitname2 = Unit.getName(actualCAPtable[interceptorside][i].unit2)
																					}
										end
									end
								end
								
								if debuggingmessages == true and (interceptorside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 4) then
									interceptstatusTable = mist.utils.tableShow(interceptstatus[interceptorside])
									Debug(interceptorside.." interceptstatus : " ..interceptstatusTable, interceptorside)
								end
								
						end
			end
	end
	end

return interceptstatus[interceptorside]
end --generatetask

------------------------------------- Tasking interceptors to RTB if no border violation on going
function interceptorsRTB(color)

	local interceptorside = color
	local grouptable = {} --XX7
	local redtemplate = "" --XX7
	local bluetemplate = "" --XX7
	local unitgci = 0 --XX7
	local grpunitgci = 0 --XX7
	local grpgciname = "" --XX7
	--local AF = {}
	
	if interceptorside == 'red'
		then

			AF = {}
			--XX8 load airfields from red airfields>>
			AF = redAF
			
			--XX8 <<
			--XX7 >>
				 
			    redtemplate = "__GCI__"..interceptorside.."1"
				
				if debuggingmessages == true and (interceptorside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 5) then
					Debug("redtemplate = "..redtemplate, interceptorside)
				end	
					
				unitgci = Unit.getByName(redtemplate)
				grpunitgci = unitgci:getGroup()
				grpgciname = grpunitgci:getName()
				grouptable = mist.getGroupData(grpgciname)
				intercpetortype1=grouptable["units"][1]["type"]
				 
				redtemplate = "__GCI__"..interceptorside.."2"
				
				if debuggingmessages == true and (interceptorside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 5) then
					Debug("redtemplate = "..redtemplate, interceptorside)
				end
				
				unitgci = Unit.getByName(redtemplate)
				grpunitgci = unitgci:getGroup()
				grpgciname = grpunitgci:getName()
				grouptable = mist.getGroupData(grpgciname)
				intercpetortype2=grouptable["units"][1]["type"]
				 
				redtemplate = "__GCI__"..interceptorside.."3"
				
				if debuggingmessages == true and (interceptorside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 5) then
					Debug("redtemplate = "..redtemplate, interceptorside)
				end
				
				unitgci = Unit.getByName(redtemplate)
				grpunitgci = unitgci:getGroup()
				grpgciname = grpunitgci:getName()
				grouptable = mist.getGroupData(grpgciname)
				intercpetortype3=grouptable["units"][1]["type"]
			 	
				redtemplate = "__GCI__"..interceptorside.."4"
				
				if debuggingmessages == true and (interceptorside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 5) then
					Debug("redtemplate = "..redtemplate, interceptorside)
				end
				
				unitgci = Unit.getByName(redtemplate)
				grpunitgci = unitgci:getGroup()
				grpgciname = grpunitgci:getName()
				grouptable = mist.getGroupData(grpgciname)
				intercpetortype4=grouptable["units"][1]["type"]
			 
			--<<XX7

	elseif interceptorside == 'blue'
		then

			AF = {}
			--XX8 load airfields from blue airfields >>
			AF = blueAF
		
			--XX8 <<
			
			--XX7 >>
			 
				bluetemplate = "__GCI__"..interceptorside.."1"
				unitgci = Unit.getByName(bluetemplate)
				grpunitgci = unitgci:getGroup()
				grpgciname = grpunitgci:getName()
				grouptable = mist.getGroupData(grpgciname)
				intercpetortype1=grouptable["units"][1]["type"]
				 
				bluetemplate = "__GCI__"..interceptorside.."2"
				unitgci = Unit.getByName(bluetemplate)
				grpunitgci = unitgci:getGroup()
				grpgciname = grpunitgci:getName()
				grouptable = mist.getGroupData(grpgciname)
				intercpetortype2=grouptable["units"][1]["type"]
				 
				bluetemplate = "__GCI__"..interceptorside.."3"
				unitgci = Unit.getByName(bluetemplate)
				grpunitgci = unitgci:getGroup()
				grpgciname = grpunitgci:getName()
				grouptable = mist.getGroupData(grpgciname)
				intercpetortype3=grouptable["units"][1]["type"]
			 	
				bluetemplate = "__GCI__"..interceptorside.."4"
				unitgci = Unit.getByName(bluetemplate)
				grpunitgci = unitgci:getGroup()
				grpgciname = grpunitgci:getName()
				grouptable = mist.getGroupData(grpgciname)
				intercpetortype4=grouptable["units"][1]["type"]
			--<<XX7			

	end

	--[[ XX9 do check for noborders = 0 and interceptor in enemy territory here. If this true then RTB.
	--]]
	if #intruder[interceptorside] == 0 and #allairunits > 0
		then

			interceptstatus[interceptorside] = {}
			interceptspawnstatus[interceptorside] = {}
			
			if debuggingmessages == true and (interceptorside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 5) then
				Debug(" resetting RTB: "..interceptorside.." "..string.format(#numberofspawnedandactiveinterceptorgroups[interceptorside]),interceptorside)
			end
			
			numberofspawnedandactiveinterceptorgroups[interceptorside] = {} --resetting the group counter

			if #interceptspawntotal[interceptorside] > 0
				then
					for k = 1, #interceptspawntotal[interceptorside]
					do
						interceptornotRTB = true

						for l = 1, #interceptorsRTBtable[interceptorside]
						do
							if interceptspawntotal[interceptorside][k].group ~= nil and interceptspawntotal[interceptorside][k].group ~= interceptorsRTBtable[interceptorside][l].group and interceptornotRTB == true
								then
									interceptornotRTB = true
							elseif interceptspawntotal[interceptorside][k].group ~= nil and interceptspawntotal[interceptorside][k].group == interceptorsRTBtable[interceptorside][l].group
								then
									interceptornotRTB = false
							end
						end

						if interceptornotRTB == true and interceptspawntotal[interceptorside][k].group ~= nil and Unit.getByName(interceptspawntotal[interceptorside][k].unitname1) ~= nil and Unit.getByName(interceptspawntotal[interceptorside][k].unitname2) ~= nil
							then
							    local unitnam1 = interceptspawntotal[interceptorside][k].unitname1
								local unitnam2 = interceptspawntotal[interceptorside][k].unitname2
								local possibleinterceptorgroup = interceptspawntotal[interceptorside][k].group
								local possibleinterceptorunit1 = Unit.getByName(interceptspawntotal[interceptorside][k].unitname1)
								local possibleinterceptorunit2 = Unit.getByName(interceptspawntotal[interceptorside][k].unitname2)
								local possibleinterceptorunitgroupcontrl = Group.getController(possibleinterceptorgroup)
								if possibleinterceptorunit1:inAir() == true or possibleinterceptorunit2:inAir() == true
									then
										if (((Unit.getTypeName(possibleinterceptorunit1) == intercpetortype1) or 
										     (Unit.getTypeName(possibleinterceptorunit1) == intercpetortype2) or  
										     (Unit.getTypeName(possibleinterceptorunit1) == intercpetortype3) or  
										     (Unit.getTypeName(possibleinterceptorunit1) == intercpetortype4)) and
										     (Unit.getPlayerName(possibleinterceptorunit1) == nil) and
										     (Unit.isActive(possibleinterceptorunit1)) and 
							                 (string.sub(unitnam1,1,3) == "GCI")) or																 
										   (((Unit.getTypeName(possibleinterceptorunit2) == intercpetortype1) or  
										     (Unit.getTypeName(possibleinterceptorunit2) == intercpetortype2) or  
										     (Unit.getTypeName(possibleinterceptorunit2) == intercpetortype3) or  
										     (Unit.getTypeName(possibleinterceptorunit2) == intercpetortype4)) and
										     (Unit.getPlayerName(possibleinterceptorunit2) == nil) and
							                 (Unit.isActive(possibleinterceptorunit2)) and 
							                 (string.sub(unitnam2,1,3) == "GCI"))
										then
											if Unit.getByName(interceptspawntotal[interceptorside][k].unitname1) ~= nil and Unit.getByName(interceptspawntotal[interceptorside][k].unitname2) ~= nil
												then
													availableintunitname1 = interceptspawntotal[interceptorside][k].unitname1
													availableintunitname2 = interceptspawntotal[interceptorside][k].unitname2
													availableintunit1 =  Unit.getByName(availableintunitname1)
													availableintunitID1 = Unit.getID(availableintunit1)
													availableintunit2 =  Unit.getByName(availableintunitname2)
													availableintunitID2 = Unit.getID(availableintunit2)
													availableintunitpos = availableintunit1:getPosition().p
													availableintgroup = Unit.getGroup(availableintunit1)
													availableintgroupID = Group.getID(availableintgroup)
													availableintgrpctrl = Group.getController(availableintgroup)
												elseif Unit.getByName(interceptspawntotal[interceptorside][k].unitname1) ~= nil and Unit.getByName(interceptspawntotal[interceptorside][k].unitname2) == nil
													then
														availableintunitname1 = interceptspawntotal[interceptorside][k].unitname1
														availableintunitname2 = nil
														availableintunit1 =  Unit.getByName(availableintunitname1)
														availableintunitID1 = Unit.getID(availableintunit1)
														availableintunit2 =  nil
														availableintunitID2 = nil
														availableintunitpos = availableintunit1:getPosition().p
														availableintgroup = Unit.getGroup(availableintunit1)
														availableintgroupID = Group.getID(availableintgroup)
														availableintgrpctrl = Group.getController(availableintgroup)
												elseif Unit.getByName(interceptspawntotal[interceptorside][k].unitname1) == nil and Unit.getByName(interceptspawntotal[interceptorside][k].unitname2) ~= nil
													then
														availableintunitname1 = nil
														availableintunitname2 = interceptspawntotal[interceptorside][k].unitname2
														availableintunit1 =  nil
														availableintunitID1 = nil
														availableintunit2 =  Unit.getByName(availableintunitname2)
														availableintunitID2 = Unit.getID(availableintunit2)
														availableintunitpos = availableintunit2:getPosition().p
														availableintgroup = Unit.getGroup(availableintunit2)
														availableintgroupID = Group.getID(availableintgroup)
														availableintgrpctrl = Group.getController(availableintgroup)
												end

												closestairfieldtoRTBtable = {}
												for n = 1, #AF --XX8
												do
													closestairfieldname = AF[n].name
													actualairfield = trigger.misc.getZone(closestairfieldname)
													actualairfieldpos = {}
													actualairfieldposx = actualairfield.point.x
													actualairfieldposz = actualairfield.point.z

													actualdistancetoairfield = math.sqrt((actualairfieldposx - availableintunitpos.x)*(actualairfieldposx - availableintunitpos.x) + (actualairfieldposz - availableintunitpos.z)*(actualairfieldposz - availableintunitpos.z))
													closestairfield = Airbase.getByName(closestairfieldname)
													closestairfieldID = closestairfield:getID()
													if n == 1
														then
															minimumdistancetoairfield = actualdistancetoairfield
															Landdestinationposx = actualairfieldposx
															Landdestinationposz = actualairfieldposz
															LandAFID = closestairfieldID

													elseif n > 1 and actualdistancetoairfield < minimumdistancetoairfield
														then
															minimumdistancetoairfield = actualdistancetoairfield
															Landdestinationposx = actualairfieldposx
															Landdestinationposz = actualairfieldposz
															LandAFID = closestairfieldID
													end
												end

											local IntercepttaskRTB = {
																			id = 'Mission',
																			params ={
																			route = {
																							["points"] =
																							{
																							[1] =
																							{
																								["alt"] = availableintunitpos.y,
																								["type"] = "Turning Point",
																								["action"] = "Turning Point",
																								["alt_type"] = "BARO",
																								["formation_template"] = "",
																								["properties"] =
																								{
																									["vnav"] = 1,
																									["scale"] = 0,
																									["angle"] = 0,
																									["vangle"] = 0,
																									["steer"] = 2,
																								}, -- end of ["properties"]
																								["ETA"] = 0,
																								["y"] = availableintunitpos.z,
																								["x"] = availableintunitpos.x,
																								["speed"] = 350,
																								["ETA_locked"] = true,
																								["task"] =
																								{
																									["id"] = "ComboTask",
																									["params"] =
																									{
																										["tasks"] =
																										{
																											[1] =
																											{
																												["enabled"] = true,
																												["auto"] = false,
																												["id"] = "WrappedAction",
																												["number"] = 1,
																												["params"] =
																												{
																													["action"] =
																													{
																														["id"] = "Option",
																														["params"] =
																														{
																															["value"] = true,
																															["name"] = 6,
																														}, -- end of ["params"]
																													}, -- end of ["action"]
																												}, -- end of ["params"]
																											}, -- end of [1]
																											[2] =
																											{
																												["number"] = 2,
																												["auto"] = false,
																												["id"] = "WrappedAction",
																												["enabled"] = true,
																												["params"] =
																												{
																													["action"] =
																													{
																														["id"] = "Option",
																														["params"] =
																														{
																															["value"] = 4294967295,
																															["name"] = 10,
																														}, -- end of ["params"]
																													}, -- end of ["action"]
																												}, -- end of ["params"]
																											}, -- end of [2]
																											[3] =
																											{
																												["enabled"] = true,
																												["auto"] = false,
																												["id"] = "WrappedAction",
																												["number"] = 3,
																												["params"] =
																												{
																													["action"] =
																													{
																														["id"] = "Option",
																														["params"] =
																														{
																															["value"] = 1,
																															["name"] = 4,
																														}, -- end of ["params"]
																													}, -- end of ["action"]
																												}, -- end of ["params"]
																											}, -- end of [3]
																											[4] =
																											{
																												["enabled"] = true,
																												["auto"] = false,
																												["id"] = "WrappedAction",
																												["number"] = 4,
																												["params"] =
																												{
																													["action"] =
																													{
																														["id"] = "Option",
																														["params"] =
																														{
																															["value"] = 4,
																															["name"] = 1,
																														}, -- end of ["params"]
																													}, -- end of ["action"]
																												}, -- end of ["params"]
																											}, -- end of [4]
																											[5] =
																											{
																												["enabled"] = true,
																												["auto"] = false,
																												["id"] = "WrappedAction",
																												["number"] = 5,
																												["params"] =
																												{
																													["action"] =
																													{
																														["id"] = "Option",
																														["params"] =
																														{
																															["value"] = 3,
																															["name"] = 0,
																														}, -- end of ["params"]
																													}, -- end of ["action"]
																												}, -- end of ["params"]
																											}, -- end of [5]
																										}, -- end of ["tasks"]
																									}, -- end of ["params"]
																								}, -- end of ["task"]
																								["speed_locked"] = true,
																							}, -- end of [1]
																							[2] =
																							{
																								["alt"] = 0,
																								["type"] = "Land",
																								["action"] = "Landing",
																								["alt_type"] = "BARO",
																								["formation_template"] = "",
																								["properties"] =
																								{
																									["vnav"] = 1,
																									["scale"] = 0,
																									["angle"] = 0,
																									["vangle"] = 0,
																									["steer"] = 2,
																								}, -- end of ["properties"]
																								["ETA"] = 99.216474338165,
																								["airdromeId"] = LandAFID,
																								["y"] = Landdestinationposz,
																								["x"] = Landdestinationposx,
																								["speed"] = 350,
																								["ETA_locked"] = false,
																								["task"] =
																								{
																									["id"] = "ComboTask",
																									["params"] =
																									{
																										["tasks"] =
																										{
																										}, -- end of ["tasks"]
																									}, -- end of ["params"]
																								}, -- end of ["task"]
																								["speed_locked"] = true,
																							} -- end of [2]
																						}
																					}
																					}
																		}

											Controller.resetTask(availableintgrpctrl)
											Controller.setTask(availableintgrpctrl, IntercepttaskRTB)
											interceptorsRTBtable[interceptorside][#interceptorsRTBtable[interceptorside] + 1] =
																						{
																						groupname = Group.getName(availableintgroup),
																						group = availableintgroup,
																						ID = availableintgroupID,
																						unit1 = availableintunit1,
																						unitID1 = availableintunitID1,
																						unit2 = availableintunit2,
																						unitID2 = availableintunitID2
																						}
											
											if debuggingmessages == true and (interceptorside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 5) then
												interceptorsRTBTableshow = mist.utils.tableShow(interceptorsRTBtable[interceptorside])
												Debug(interceptorside.." interceptorsRTBtable: "..interceptorsRTBTableshow,interceptorside)
											end	
												
										end
								end
						end
					end
			end
	end

return interceptorsRTBtable[interceptorside]
end --interceptorsRTB

--------------------------------------------------function to check status of CAP and spawn new if necessary
function CAPStatusCheck(color)
	local CAPside = color
   --XX add new local var, concerned that numberofCAPgroups is getting corrupted by scope issues as used in CAPStatusCheck and spawnCAP
	local numstatusCAPgrps = 0
	
	if debuggingmessages == true and (CAPside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 6) then
		Debug("debuggingmessage CAPStatusCheck: script hung A-X0: counter:"..string.format(counter)..CAPside, CAPside)
	end

	if CAPside == 'red'
	then
		numstatusCAPgrps = numberofredCAPgroups --XX change numberofCAPgroups to numstatusCAPgrps
	elseif CAPside == 'blue'
	then
		numstatusCAPgrps = numberofblueCAPgroups --XX change numberofCAPgroups to numstatusCAPgrps
	end
	
	if debuggingmessages == true and (CAPside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 6) then
		Debug("debuggingmessage CAPStatusCheck: script hung A-X01: counter:"..string.format(counter), CAPside)
	end
	
	if #actualCAPtable[CAPside] == 0
	then
		for i = 1, numstatusCAPgrps --XX change numberofCAPgroups to numstatusCAPgrps
		do
			--XX9 if using logistics and side is in supply then allow add group
	
			if debuggingmessages == true and (CAPside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 6) then
				Debug("blue CAP supply:" ..string.format(bluegroupsupply), CAPside)
				Debug("red CAP supply:" ..string.format(redgroupsupply), CAPside)
			end
			
			if (limitedlogistics == 0) or 
			   (limitedlogistics == 1 and CAPside =='red' and redgroupsupply > 0) or 
			   (limitedlogistics == 1 and CAPside =='blue' and bluegroupsupply > 0) then	--XX9
			
				if debuggingmessages == true and (CAPside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 6) then
					Debug("debuggingmessage CAPStatusCheck: script hung A-X02: counter:"..string.format(counter)..CAPside, CAPside)
				end
				
				spawnCAP(CAPside)
				
				if debuggingmessages == true and (CAPside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 6) then
					Debug("debuggingmessage CAPStatusCheck: script hung A-X03: counter:"..string.format(counter), CAPside)
				end
				
			end
		end
	end

	if debuggingmessages == true and (CAPside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 6) then
		Debug("debuggingmessage CAPStatusCheck: script hung A-X1: counter:"..string.format(counter)..CAPside, CAPside)
	end
	
	if #actualCAPtable[CAPside] > 0
	then
		
		if debuggingmessages == true and (CAPside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 6) then
			Debug("debuggingmessage CAPStatusCheck: script hung B-X1: counter:"..string.format(counter).."/ CAPside: "..CAPside, CAPside)
		end
		
		z = #actualCAPtable[CAPside] - numstatusCAPgrps + 1 --XX change numberofCAPgroups to numstatusCAPgrps
		for j = z, #actualCAPtable[CAPside]
		do
		
			if debuggingmessages == true and (CAPside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 6) then
				Debug("debuggingmessage CAPStatusCheck: script hung C-X1: counter:"..string.format(counter).."/ CAPside: "..CAPside, CAPside)
			end
		
			if Group.getByName(actualCAPtable[CAPside][j].groupname) ~= nil
			then
				
				if debuggingmessages == true and (CAPside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 6) then
					Debug("debuggingmessage CAPStatusCheck: script hung D-X1: counter:"..string.format(counter).."/ CAPside: "..CAPside, CAPside)
				end
				
				if Unit.getByName(actualCAPtable[CAPside][j].unit1name) == nil or Unit.getByName(actualCAPtable[CAPside][j].unit2name) == nil
				then
					
					if debuggingmessages == true and (CAPside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 6) then
						Debug("debuggingmessage CAPStatusCheck: script hung E-X1: counter:"..string.format(counter).."/ CAPside: "..CAPside, CAPside)
					end
					
					actualCAPtable[CAPside][j].status = "limited"
					--XX9 if using logistics and side is in supply then allow add group
					
					if debuggingmessages == true and (CAPside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 6) then
						Debug("blue CAP supply:" ..string.format(bluegroupsupply), CAPside)
						Debug("red CAP supply:" ..string.format(redgroupsupply), CAPside)
					end
					
					if (limitedlogistics == 0) or 
					   (limitedlogistics == 1 and CAPside =='red' and redgroupsupply > 0) or 
					   (limitedlogistics == 1 and CAPside =='blue' and bluegroupsupply > 0) then	--XX9
					
						if debuggingmessages == true and (CAPside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 6) then
							Debug("debuggingmessage CAPStatusCheck: script hung E-X201: counter:"..string.format(counter).."/ CAPside: "..CAPside, CAPside)
						end
						
						spawnCAP(CAPside)
						
						if debuggingmessages == true and (CAPside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 6) then
							Debug("debuggingmessage CAPStatusCheck: script hung E-X202: counter:"..string.format(counter).."/ CAPside: "..CAPside, CAPside)
						end
					end
				else
				
					if debuggingmessages == true and (CAPside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 6) then
						Debug("debuggingmessage CAPStatusCheck: script hung E-X3: counter:"..string.format(counter).."/ CAPside: "..CAPside, CAPside)
					end
					
					local actualCAPunit = actualCAPtable[CAPside][j].unit1
					
					if debuggingmessages == true and (CAPside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 6) then
						Debug("debuggingmessage CAPStatusCheck: script hung E-X4: counter:"..string.format(counter).."/ CAPside: "..CAPside, CAPside)
					end
					
					local actualCAPposition = actualCAPunit:getPosition().p
					currentCAPzone = actualCAPtable[CAPside][j].CAPzone
					local waytogo = math.sqrt((currentCAPzone.point.x-actualCAPposition.x)*(currentCAPzone.point.x-actualCAPposition.x)-(currentCAPzone.point.z-actualCAPposition.z)*(currentCAPzone.point.z-actualCAPposition.z))
					
					if debuggingmessages == true and (CAPside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 6) then
						Debug("debuggingmessage CAPStatusCheck: script hung E-X5: counter:"..string.format(counter).."/ CAPside: "..CAPside, CAPside)
					end
					
					if actualCAPtable[CAPside][j].status == "enroute to station"
					then
						
						if debuggingmessages == true and (CAPside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 6) then
							Debug("debuggingmessage CAPStatusCheck: script hung F-X1: counter:"..string.format(counter).."/ CAPside: "..CAPside, CAPside)
						end
						
						if waytogo < currentCAPzone.radius
						then
							
							if debuggingmessages == true and (CAPside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 6) then
								Debug("debuggingmessage CAPStatusCheck: script hung F-X2: counter:"..string.format(counter).."/ CAPside: "..CAPside, CAPside)
							end
							
							actualCAPtable[CAPside][j].status = "on station"
						end
					end

					if actualCAPtable[CAPside][j].status == "on station" or actualCAPtable[CAPside][j].status == "intercepting"
					then
						
						if debuggingmessages == true and (CAPside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 6) then
							Debug("debuggingmessage CAPStatusCheck: script hung G-X1: counter:"..string.format(counter).."/ CAPside: "..CAPside, CAPside)
						end
						
						if waytogo > (1.2 * currentCAPzone.radius)
						then
							
							if debuggingmessages == true and (CAPside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 6) then
								Debug("debuggingmessage CAPStatusCheck: script hung H-X1: counter:"..string.format(counter).."/ CAPside: "..CAPside, CAPside)
							end
							
							actualCAPtable[CAPside][j].status = "off station"
							--XX9 if using logistics and side is in supply then allow add group
							
							if debuggingmessages == true and (CAPside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 6) then
								Debug("blue CAP supply:" ..string.format(bluegroupsupply), CAPside)
								Debug("red CAP supply:" ..string.format(redgroupsupply), CAPside)
							end
							
							if (limitedlogistics == 0) or 
							   (limitedlogistics == 1 and CAPside =='red' and redgroupsupply > 0) or 
							   (limitedlogistics == 1 and CAPside =='blue' and bluegroupsupply > 0) then	--XX9
							
								if debuggingmessages == true and (CAPside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 6) then
									Debug("debuggingmessage CAPStatusCheck: script hung H-X101: counter:"..string.format(counter).."/ CAPside: "..CAPside, CAPside)
								end
								
								spawnCAP(CAPside)
								
								if debuggingmessages == true and (CAPside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 6) then
									Debug("debuggingmessage CAPStatusCheck: script hung H-X102: counter:"..string.format(counter).."/ CAPside: "..CAPside, CAPside)
								end
								
							end
						end
					end

				end

			elseif Group.getByName(actualCAPtable[CAPside][j].groupname) == nil
			then
				--XX9 if using logistics and side is in supply then allow add group
				
				if debuggingmessages == true and (CAPside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 6) then
					Debug("blue CAP supply:" ..string.format(bluegroupsupply), CAPside)
					Debug("red CAP supply:" ..string.format(redgroupsupply), CAPside)
				end
					
				if (limitedlogistics == 0) or 
				   (limitedlogistics == 1 and CAPside =='red' and redgroupsupply > 0) or 
				   (limitedlogistics == 1 and CAPside =='blue' and bluegroupsupply > 0) then	--XX9
				   
					if debuggingmessages == true and (CAPside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 6) then
						Debug("debuggingmessage CAPStatusCheck: script hung H-X201: counter:"..string.format(counter).."/ CAPside: "..CAPside, CAPside)
					end	
					
					spawnCAP(CAPside)
					
					if debuggingmessages == true and (CAPside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 6) then
						Debug("debuggingmessage CAPStatusCheck: script hung H-X201: counter:"..string.format(counter).."/ CAPside: "..CAPside, CAPside)
					end
					
				end
			end
		end

	end
	
	if debuggingmessages == true and (CAPside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 6) then
		actualCAPtableTable = mist.utils.tableShow(actualCAPtable[CAPside])
		Debug(CAPside.." CAPStatusCheck: counter"..string.format(counter).."-table:" ..actualCAPtableTable, CAPside)
	end
	
end --CAPStatusCheck

----------------------------------------------function to spawn CAP
function spawnCAP(color)

	local CAPside = color
    local numberofCAPgroups = 0 --XX declare numberofCAPgroups as local to function
	local numberofCAPzones = 0 --XX declare numberofCAPzones as local to function
	local capskill = "Random" --XX6
	local cap_country = nil --XX8
	local payloadtable = {} --XX7
	local grouptable = {} --XX7
	local redcaptemplate = "" --XX7
	local bluecaptemplate = "" --XX7
	local captype = "" --XX7
	local capplanelivery = "1" --XX7
	local actualgroupdata={} --XX7
	local unit_id = nil --XX7
	local grpunit = nil --XX7
	local grpname = "" --XX7
	
	if debuggingmessages == true and (CAPside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 7) then 	
		Debug("debuggingmessage spawnCAP: script hung A-X0: counter:"..string.format(counter)..CAPside, CAPside)
	end
	
	if CAPside == 'red'
		then
			--CAPcountry = redcapcountry --YY parameterise country
			local randomcapplane = math.random(1,4)
			--XX7 template logic >>
			redcaptemplate = "__CAP__"..color..randomcapplane
 
			payloadtable = mist.getPayload(redcaptemplate)
			
			unit_id = Unit.getByName(redcaptemplate)
			grpunit = unit_id:getGroup()
			grpname = grpunit:getName()
			grouptable = mist.getGroupData(grpname)
			captype=grouptable["units"][1]["type"]
			capplanelivery=grouptable["units"][1]["livery_id"]
			capskill=grouptable["units"][1]["skill"]
			cap_country=grouptable["countryId"] --XX8
			
			if debuggingmessages == true and (CAPside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 7) then	
				actualgroupdata=mist.utils.tableShow(grouptable)
				Debug(CAPside.." groupdatatable: "..actualgroupdata, CAPside)
			end
				
			CAPplanetype = captype
			CAPplaneskin = capplanelivery
			CAPpayload = payloadtable
			CAPcountry=cap_country --XX8
			
			--<<XX7
--XX8 >>
			local airfldsel = {}
			local rj = 0
			local airbasedata = {}
			
			if #redAF > 1 then
				if previousredCAPspawnzonename == nil then
					for i = 1, #redAF do
						airfldsel[#airfldsel+1] = redAF[i]
					end
				else	
					for i = 1, #redAF do
						if redAF[i].name ~= previousredCAPspawnzonename then
							rj=rj+1
							airfldsel[rj] = redAF[i]
							
							if debuggingmessages == true and (CAPside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 7) then
								actualairfldsel=mist.utils.tableShow(airfldsel)
								Debug(CAPside.." actualairfldsel: "..actualairfldsel, CAPside)
							end	
								
						end
					end
				end	
				local airbasedata=mist.utils.tableShow(airfldsel)
				
				if debuggingmessages == true and (CAPside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 7) then
					Debug("red airbasetable: "..airbasedata, CAPside)
				end
				
				CAPairfieldname = airfldsel[math.random(1,#airfldsel)].name
				 
			else
				CAPairfieldname = redAF[1].name
				
			end
			
			if debuggingmessages == true and (CAPside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 7) then
				Debug("red capairfield= "..CAPairfieldname, CAPside)
			end
			
			previousredCAPspawnzonename = CAPairfieldname
--XX8 <<				


			local CAPairfield = Airbase.getByName(CAPairfieldname)
			--XX CAPairfieldID = CAPairfield:getID() moved down to make it the same as blue logic
			
			if debuggingmessages == true and (CAPside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 7) then
				Debug("debuggingmessage spawnCAP: script hung A-X3: counter:"..string.format(counter)..CAPside, CAPside)
			end
			
			actualCAPairfield = trigger.misc.getZone(CAPairfieldname)
			actualCAPairfieldpos = {}
			actualCAPairfieldposx = actualCAPairfield.point.x
			actualCAPairfieldposz = actualCAPairfield.point.z

			CAPairfieldID = CAPairfield:getID() --XX moved here from above
			redCAPcounter = redCAPcounter + 1
			CAPgroupname = "CAP-"..CAPside.." #"..redCAPcounter --XX7 change format of CAP group name to start with CAP
			
			if debuggingmessages == true and (CAPside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 7) then
				Debug("debuggingmessage spawnCAP: script hung A-X4: counter:"..string.format(counter)..CAPside, CAPside)
			end
			
			numberofCAPgroups = numberofredCAPgroups --XX remove local
			numberofCAPzones = numberofredCAPzones --XX remove local --YY change capitalisation to keep it uniform
			
			redCAPzonename = redCAPzone..math.random(1,numberofCAPzones)

			if redCAPzonename ~= previousredCAPZonename
			then
				actualCAPzone = trigger.misc.getZone(redCAPzonename)
			elseif redCAPzonename == previousredCAPZonename
			then
				redCAPzonename = redCAPzone..math.random(1,numberofCAPzones)
				actualCAPzone = trigger.misc.getZone(redCAPzonename)
			end

			previousredCAPZonename = redCAPzonename
			
			if debuggingmessages == true and (CAPside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 7) then
				Debug("debuggingmessage spawnCAP: script hung A-X5: counter:"..string.format(counter)..CAPside, CAPside)
			end
			
	elseif CAPside == 'blue'
		then
			--CAPcountry = bluecapcountry --XX8 YY parameterise country
			local randomcapplane = math.random(1,4)
			--XX7 template logic >>
			bluecaptemplate = "__CAP__"..color..randomcapplane
 
			payloadtable = mist.getPayload(bluecaptemplate)
			unit_id = Unit.getByName(bluecaptemplate)
			grpunit = unit_id:getGroup()
			grpname = grpunit:getName()
			grouptable = mist.getGroupData(grpname)
			captype=grouptable["units"][1]["type"]
			capplanelivery=grouptable["units"][1]["livery_id"]
			capskill=grouptable["units"][1]["skill"]
			cap_country=grouptable["countryId"] --XX8
			
			if debuggingmessages == true and (CAPside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 7) then
				actualgroupdata=mist.utils.tableShow(grouptable)
				Debug(CAPside.." groupdatatable: "..actualgroupdata, CAPside)
			end
			
			CAPplanetype = captype
			CAPplaneskin = capplanelivery
			CAPpayload = payloadtable
			CAPcountry=cap_country --XX8
			
			if debuggingmessages == true and (CAPside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 7) then
				Debug(CAPside.." CAPcountry: "..string.format(CAPcountry), CAPside)
			end	
				
			--<<XX7

--XX8 >>
			local airfldsel = {}
			local bj = 0

			if #blueAF > 1 then
				if previousblueCAPspawnzonename == nil then
					for i = 1, #blueAF do
						airfldsel[#airfldsel+1] = blueAF[i]
					end
				else	
					for i = 1, #blueAF do
						if blueAF[i].name ~= previousblueCAPspawnzonename then
							bj=bj+1
							airfldsel[bj] = blueAF[i]
						end
					end
				end
				CAPairfieldname = airfldsel[math.random(1,#airfldsel)].name	
			else
				CAPairfieldname = blueAF[1].name
			end
			
			if debuggingmessages == true and (CAPside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 7) then
				Debug("blue capairfield="..CAPairfieldname, CAPside)
			end
			
			previousblueCAPspawnzonename = CAPairfieldname
--XX8 <<



			local CAPairfield = Airbase.getByName(CAPairfieldname)

			actualCAPairfield = trigger.misc.getZone(CAPairfieldname)
			actualCAPairfieldpos = {}
			actualCAPairfieldposx = actualCAPairfield.point.x
			actualCAPairfieldposz = actualCAPairfield.point.z

			CAPairfieldID = CAPairfield:getID()
			blueCAPcounter = blueCAPcounter + 1
			CAPgroupname = "CAP-"..CAPside.." #"..blueCAPcounter --XX7 change CAP group name to start with CAP
			numberofCAPgroups = numberofblueCAPgroups --XX remove local
			numberofCAPzones = numberofblueCAPzones --XX remove local --YY fix capitalisation to keep it uniform

			if debuggingmessages == true and (CAPside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 7) then
				Debug("debuggingmessage spawnCAP: script hung A-X7: counter:"..string.format(counter)..CAPside, CAPside)
			end
			
			blueCAPzonename = blueCAPzone..math.random(1,numberofCAPzones)
            
			if debuggingmessages == true and (CAPside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 7) then
				Debug("blueCAPzonename0 = "..blueCAPzonename, CAPside)
			end
			
			if blueCAPzonename ~= previousblueCAPZonename
			then
				
				if debuggingmessages == true and (CAPside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 7) then
					Debug("blueCAPzonenameNil = "..blueCAPzonename, CAPside)
				end
				
				actualCAPzone = trigger.misc.getZone(blueCAPzonename)
			elseif blueCAPzonename == previousblueCAPZonename
			then
				blueCAPzonename = blueCAPzone..math.random(1,numberofCAPzones)
				
				if debuggingmessages == true and (CAPside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 7) then
					Debug("blueCAPzonenameEQ = "..blueCAPzonename, CAPside)
				end	
					
				actualCAPzone = trigger.misc.getZone(blueCAPzonename)
			end

			if debuggingmessages == true and (CAPside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 7) then
				Debug("debuggingmessage spawnCAP: script hung A-X8: counter:"..string.format(counter)..CAPside, CAPside)
			end	
				
			previousblueCAPZonename = blueCAPzonename
	end
	--XX actually spawn the CAP flight after doing the side related stuff like picking base and aircraft type and CAP zone to use
	actualCAPzonepos = {}
	actualCAPzoneposx = actualCAPzone.point.x
	actualCAPzoneposz = actualCAPzone.point.z

	if Spawnmode == "parking"
	then
		RNW_type = "TakeOffParking"
		RNW_action = "From Parking Area"
		CAPspawnalt = land.getHeight{x = actualCAPairfield.point.x, y = actualCAPairfield.point.z} --XX consider terrain
	elseif Spawnmode == "takeoff" --YY capitalisation
	then
		RNW_type = "TakeOff"
		RNW_action = "From Runway"
		CAPspawnalt = land.getHeight{x = actualCAPairfield.point.x, y = actualCAPairfield.point.z} --XX consider terrain
	elseif Spawnmode == "air" --YY capitalisation
	then
		RNW_type = "Turning Point"
		RNW_action = "Turning Point"
		CAPspawnalt = 3000 + land.getHeight{x = actualCAPzone.point.x, y = actualCAPzone.point.z} --XX consider terrain
	end
	
	if debuggingmessages == true and (CAPside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 7) then
		Debug("debuggingmessage spawnCAP: script hung A-X8a: counter:"..string.format(counter)..CAPside, CAPside)
	end
	
	if #actualCAPtable[CAPside] <= numberofCAPgroups --if this is the first set of CAP flights they shall spawn in the air in the CAPZone
	then
		if startairborne == 1 --YY if told to start airborne then do so else start on the runway.
		then
			actualCAPairfieldposx = actualCAPzoneposx
			actualCAPairfieldposz = actualCAPzoneposz
			RNW_type = "Turning Point"
			RNW_action = "Turning Point"
			CAPspawnalt = math.random(cap_min_alt,cap_max_alt) + land.getHeight{x = actualCAPzone.point.x, y = actualCAPzone.point.z} --XX randomise spawn alt considering terrain --YY min max cap alt
		end
		if startairborne == 0 --YY start on the runway
		then
			RNW_type = "TakeOff"
			RNW_action = "From Runway"
			CAPspawnalt = land.getHeight{x = actualCAPairfield.point.x, y = actualCAPairfield.point.z} --XX consider terrain
		end
	end

	if debuggingmessages == true and (CAPside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 7) then	
		Debug("debuggingmessage stuck at spawnCAP point 1: counter:"..string.format(counter).."/ side: "..CAPside, CAPside)
	end	
		
	CAPPatrolpointstable = {}
--XX change ["alt"] = 300 to ["alt"] = CAPspawnalt where CAPspawnalt is determined according to Spawnmode and if the first set of CAP flights
	CAPPatrolpointstable[1] =
												{
													["alt"] = CAPspawnalt,
													["type"] = RNW_type,
													["action"] = RNW_action,
													["alt_type"] = "BARO",
													["formation_template"] = "",
													["ETA"] = 0,
													["airdromeId"] = CAPairfieldID,
													["y"] = actualCAPairfieldposz,
													["x"] = actualCAPairfieldposx,
													["speed"] = 250,
													["ETA_locked"] = true,
													["task"] =
													{
														["id"] = "ComboTask",
														["params"] =
														{
															["tasks"] =
															{

															}, -- end of ["tasks"]
														}, -- end of ["params"]
													}, -- end of ["task"]
													["speed_locked"] = true,
												}
	
	if debuggingmessages == true and (CAPside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 7) then											
		Debug("debuggingmessage stuck at spawnCAP point 2: counter:"..string.format(counter).."/ side: "..CAPside, CAPside)
	end
	
	for i = 2,20
	do
--XX calculate waypoint co-ords here so that can consider terrain with simpler code
		local _WPz = actualCAPzoneposz + math.random(actualCAPzone.radius * -1, actualCAPzone.radius) --XX
		local _WPx = actualCAPzoneposx + math.random(actualCAPzone.radius * -1, actualCAPzone.radius) --XX
		CAPPatrolpointstable[i] =
												{
													["alt"] = math.random(cap_min_alt,cap_max_alt) + land.getHeight{x = _WPx, y = _WPz}, --XX 10000 became 8000
													["type"] = "Turning Point",
													["action"] = "Turning Point",
													["alt_type"] = "BARO",
													["formation_template"] = "",
													["properties"] =
													{
														["vnav"] = 1,
														["scale"] = 0,
														["angle"] = 0,
														["vangle"] = 0,
														["steer"] = 2,
													}, -- end of ["properties"]
													["ETA"] = 230.54689194991,
													--XX ["y"] = actualCAPzoneposz + math.random(actualCAPzone.radius * -1, actualCAPzone.radius),
													--XX ["x"] = actualCAPzoneposx + math.random(actualCAPzone.radius * -1, actualCAPzone.radius),
													["y"] = _WPz, --XX
													["x"] = _WPx, --XX
													["speed"] = 250,
													["ETA_locked"] = false,
													["task"] =
													{
														["id"] = "ComboTask",
														["params"] =
														{
															["tasks"] =
															{
																[1] =
																{
																	["number"] = 1,
																	["auto"] = false,
																	["id"] = "WrappedAction",
																	["enabled"] = true,
																	["params"] =
																	{
																		["action"] =
																		{
																			["id"] = "Option",
																			["params"] =
																			{
																				["value"] = 3,
																				["name"] = 0,
																			}, -- end of ["params"]
																		}, -- end of ["action"]
																	}, -- end of ["params"]
																}, -- end of [1]
																[2] =
																{
																	["number"] = 2,
																	["auto"] = false,
																	["id"] = "WrappedAction",
																	["enabled"] = true,
																	["params"] =
																	{
																		["action"] =
																		{
																			["id"] = "Option",
																			["params"] =
																			{
																				["value"] = true,
																				["name"] = 6,
																			}, -- end of ["params"]
																		}, -- end of ["action"]
																	}, -- end of ["params"]
																}, -- end of [2]
																[3] =
																{
																	["number"] = 3,
																	["auto"] = false,
																	["id"] = "WrappedAction",
																	["enabled"] = true,
																	["params"] =
																	{
																		["action"] =
																		{
																			["id"] = "Option",
																			["params"] =
																			{
																				["value"] = 3,
																				["name"] = 1,
																			}, -- end of ["params"]
																		}, -- end of ["action"]
																	}, -- end of ["params"]
																}, -- end of [3]
																[4] =
																{
																	["number"] = 4,
																	["auto"] = false,
																	["id"] = "WrappedAction",
																	["enabled"] = true,
																	["params"] =
																	{
																		["action"] =
																		{
																			["id"] = "Option",
																			["params"] =
																			{
																				["value"] = 1,
																				["name"] = 4,
																			}, -- end of ["params"]
																		}, -- end of ["action"]
																	}, -- end of ["params"]
																}, -- end of [4]
																[5] =
																{
																	["number"] = 5,
																	["auto"] = false,
																	["id"] = "WrappedAction",
																	["enabled"] = true,
																	["params"] =
																	{
																		["action"] =
																		{
																			["id"] = "Option",
																			["params"] =
																			{
																				["value"] = 2,
																				["name"] = 3,
																			}, -- end of ["params"]
																		}, -- end of ["action"]
																	}, -- end of ["params"]
																}, -- end of [5]
															}, -- end of ["tasks"]
														}, -- end of ["params"]
													}, -- end of ["task"]
													["speed_locked"] = true,
												}
	end
	
	if debuggingmessages == true and (CAPside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 7) then
		Debug("debuggingmessage stuck at spawnCAP point 2a: counter:"..string.format(counter).."/ side: "..CAPside, CAPside)
	end
	
	CAPPatrolunitstable = {}
	if CAPgroupsize == "randomized"
	then
		strengthrandomizer = math.random(1,2)
	elseif CAPgroupsize == "2"
	then
		strengthrandomizer = 1
	elseif CAPgroupsize == "4"
	then
		strengthrandomizer = 2
	end

	if limitedlogistics == 1 and CAPside == 'red' and (strengthrandomizer * 2) > redgroupsupply then
		strengthrandomizer = redgroupsupply
	end
	if limitedlogistics == 1 and CAPside == 'blue' and (strengthrandomizer * 2) > bluegroupsupply then
		strengthrandomizer = bluegroupsupply
	end

	if limitedlogistics == 1 and ((strengthrandomizer < 0) or (strengthrandomizer == 0) or (strengthrandomizer == 3)) then
		strengthrandomizer = 1
	end
	
	if debuggingmessages == true and (CAPside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 7) then
		Debug("debuggingmessage stuck at spawnCAP point 2b: counter:"..string.format(counter).."/ side: "..CAPside, CAPside)
	end
	
	if strengthrandomizer == 1
	then
--XX Note onboard_num should be different for each plane as this is the number displayed on the fuselage in game
		CAPPatrolunitstable =	{
												[1] =
												{
													["alt"] = CAPspawnalt,
													["heading"] = 0,
													["livery_id"] = CAPplaneskin,
													["type"] = CAPplanetype,
													["psi"] = 0,
													["onboard_num"] = "20",
													["parking"] = 1,
													["y"] = actualCAPairfieldposz,
													["x"] = actualCAPairfieldposx,
													["name"] =  CAPgroupname.." #1",
													["payload"] = CAPpayload,
													["speed"] = 350,
													["unitId"] =  math.random(9999,99999),
													["alt_type"] = "BARO",
													["skill"] = capskill, --XX7 now picks up template aircraft skill
												}, -- end of [1]
												 [2] =
												{
													["alt"] = CAPspawnalt,
													["heading"] = 0,
													["livery_id"] = CAPplaneskin,
													["type"] = CAPplanetype,
													["psi"] = 0,
													["onboard_num"] = "21",
													["parking"] = 2,
													["y"] = actualCAPairfieldposz,
													["x"] = actualCAPairfieldposx+50,
													["name"] =  CAPgroupname.." #2",
													["payload"] = CAPpayload,
													["speed"] = 350,
													["unitId"] =  math.random(9999,99999),
													["alt_type"] = "BARO",
													["skill"] = capskill, --XX7 now picks up template aircraft skill
													},
								}
	elseif strengthrandomizer == 2
	then
		CAPPatrolunitstable =	{
												[1] =
												{
													["alt"] = CAPspawnalt,
													["heading"] = 0,
													["livery_id"] = CAPplaneskin,
													["type"] = CAPplanetype,
													["psi"] = 0,
													["onboard_num"] = "20",
													["parking"] = 1,
													["y"] = actualCAPairfieldposz,
													["x"] = actualCAPairfieldposx,
													["name"] =  CAPgroupname.." #1",
													["payload"] = CAPpayload,
													["speed"] = 350,
													["unitId"] =  math.random(9999,99999),
													["alt_type"] = "BARO",
													["skill"] = capskill, --XX7 now picks up template aircraft skill
												}, -- end of [1]
												 [2] =
												{
													["alt"] = CAPspawnalt,
													["heading"] = 0,
													["livery_id"] = CAPplaneskin,
													["type"] = CAPplanetype,
													["psi"] = 0,
													["onboard_num"] = "21",
													["parking"] = 2,
													["y"] = actualCAPairfieldposz,
													["x"] = actualCAPairfieldposx+50,
													["name"] =  CAPgroupname.." #2",
													["payload"] = CAPpayload,
													["speed"] = 350,
													["unitId"] =  math.random(9999,99999),
													["alt_type"] = "BARO",
													["skill"] = capskill, --XX7 now picks up template aircraft skill
													},
												[3] =
												{
													["alt"] = CAPspawnalt,
													["heading"] = 0,
													["livery_id"] = CAPplaneskin,
													["type"] = CAPplanetype,
													["psi"] = 0,
													["onboard_num"] = "22",
													["parking"] = 3,
													["y"] = actualCAPairfieldposz+50,
													["x"] = actualCAPairfieldposx,
													["name"] =  CAPgroupname.." #3",
													["payload"] = CAPpayload,
													["speed"] = 350,
													["unitId"] =  math.random(9999,99999),
													["alt_type"] = "BARO",
													["skill"] = capskill, --XX7 now picks up template aircraft skill
												}, -- end of [1]
												 [4] =
												{
													["alt"] = CAPspawnalt,
													["heading"] = 0,
													["livery_id"] = CAPplaneskin,
													["type"] = CAPplanetype,
													["psi"] = 0,
													["onboard_num"] = "23",
													["parking"] = 4,
													["y"] = actualCAPairfieldposz+50,
													["x"] = actualCAPairfieldposx+50,
													["name"] =  CAPgroupname.." #4",
													["payload"] = CAPpayload,
													["speed"] = 350,
													["unitId"] =  math.random(9999,99999),
													["alt_type"] = "BARO",
													["skill"] = capskill, --XX7 now picks up template aircraft skill 
													},
								}
	end

	if debuggingmessages == true and (CAPside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 7) then
		Debug("debuggingmessage stuck at spawnCAP point 3: counter:"..string.format(counter).."/ side: "..CAPside, CAPside)
	end
	
	local CAPdata = 	{
											["modulation"] = 0,
											["tasks"] =
											{
											}, -- end of ["tasks"]
											["task"] = "CAP",
											["uncontrolled"] = false,
											["route"] =
													{
													["points"] = CAPPatrolpointstable,
													}, -- end of ["route"]
											["groupId"] = math.random(10000,99999),
											["hidden"] = hideenemy, --XX hide enemy cap
											["units"] = CAPPatrolunitstable,
											["y"] = actualCAPairfieldposz,
											["x"] = actualCAPairfieldposx,
											["name"] =  CAPgroupname,
											["communication"] = true,
											["start_time"] = 0,
											["frequency"] = 124,
											}
											
	
	if debuggingmessages == true and (CAPside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 7) then
		Debug("adding group for CAP "..CAPside, CAPside)												
	end
	
	coalition.addGroup(CAPcountry, Group.Category.AIRPLANE, CAPdata)

	actualCAPtable[CAPside][#actualCAPtable[CAPside]+1] =
							{
							groupname = CAPgroupname,
							group = Group.getByName(CAPgroupname),
							unit1 = Unit.getByName(CAPgroupname.." #1"),
							unit1name = CAPgroupname.." #1",
							unit2 = Unit.getByName(CAPgroupname.." #2"),
							unit2name = CAPgroupname.." #2",
							CAPzone = actualCAPzone,
							status = "enroute to station"
							}
							
	if debuggingmessages == true and (CAPside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 7) then							
		actualCAPtableTable = mist.utils.tableShow(actualCAPtable[CAPside])
		Debug(CAPside.." actualCAPtable: " ..actualCAPtableTable, CAPside)
	end
		
--[[-- actually spawn the group, record time at this point and then check in clear wreckage to see if 10 mins elapsed and not airborne
and if true then remove aircraft. In clear wreckage
function also know unit name so can retrieve this table entry and compare to current getTime() and if more than 10 mins elapsed can 
remove unit. Can do similar in GCI interceptor spawn.		
						
--]]--
--XX4 >>
	if strengthrandomizer == 1 then
		stuckunitstable[CAPgroupname.." #1"] = timer.getTime() --XX4 record spawn time of unit1
		stuckunitstable[CAPgroupname.." #2"] = timer.getTime() --XX4 record spawn time of unit2
	else
		stuckunitstable[CAPgroupname.." #1"] = timer.getTime() --XX4 record spawn time of unit1
		stuckunitstable[CAPgroupname.." #2"] = timer.getTime() --XX4 record spawn time of unit2
		stuckunitstable[CAPgroupname.." #3"] = timer.getTime() --XX4 record spawn time of unit3
		stuckunitstable[CAPgroupname.." #4"] = timer.getTime() --XX4 record spawn time of unit4
	end
--XX4 <<	

return actualCAPtable[CAPside], stuckunitstable --XX4
end --spawnCAP

-----------------------------------------------main function which calls the major sub functions according to schedule 
counter = 0 --for debugging counts

local function interceptmain(color)

	local side = color
	local noCAPs = 0 --XX9 

	
	--XX9 set noCAPs var for use >>
	if side == 'red' then
		noCAPs = noredCAPs
	end	
	if side == 'blue' then
		noCAPs = noblueCAPs
	end
	--<< XX9
	
	if debuggingmessages == true and (side == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 8) then
		Debug("debuggingmessage interceptmain 1 stuck at airspaceviolation: counter:"..string.format(counter).."/ side: "..side, side)
	end
		
	airspaceviolation(side)

	if debuggingmessages == true and (side == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 8) then
		Debug("debuggingmessage interceptmain 2 stuck at CAPStatusCheck: counter:"..string.format(counter).."/ side: "..side, side)
	end
	
	--XX9 if CAPs are turned off don't launch any >>
	if noCAPs == 0 then
		CAPStatusCheck(side)
	end
	
	if debuggingmessages == true and (side == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 8) then
		Debug("debuggingmessage interceptmain 3 stuck at getinterceptorairborne: counter:"..string.format(counter).."/ side: "..side, side)
	end
		
	getinterceptorairborne(side)

	if debuggingmessages == true and (side == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 8) then
		Debug("debuggingmessage interceptmain 4 stuck at generatetask: counter:"..string.format(counter).."/ side: "..side, side)
	end
		
	generatetask(side)

	if debuggingmessages == true and (side == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 8) then
		Debug("debuggingmessage interceptmain 5 stuck at spawninterceptor: counter:"..string.format(counter).."/ side: "..side, side)
	end
 
	spawninterceptor(side)

	if debuggingmessages == true and (side == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 8) then
		Debug("debuggingmessage interceptmain 6 stuck at interceptorsRTB: counter:"..string.format(counter).."/ side: "..side, side)
	end
	
	interceptorsRTB(side)

	if debuggingmessages == true and (side == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 8) then
		Debug("debuggingmessage interceptmain 7 stuck at clearApron: counter:"..string.format(counter).."/ side: "..side, side)
	end
	
	clearApron(side)

	if debuggingmessages == true and (side == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 8) then
		Debug("debuggingmessage interceptmain 8 stuck at airfieldwreckagecleanup: counter:"..string.format(counter).."/ side: "..side, side)
	end
	
	airfieldwreckagecleanup(side)

	if debuggingmessages == true and (side == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 8) then
		Debug("debuggingmessage interceptmain completed: counter:"..string.format(counter).."/ side: "..side, side)
	end
	
counter = counter + 1 --for debugging only
return timer.getTime() + 1
end --interceptmain

--schedule next iterations of interceptmain
timer.scheduleFunction(interceptmain, 'red', timer.getTime() + 10) --XX4
timer.scheduleFunction(interceptmain, 'blue', timer.getTime() + 5) --XX4

-----------------------------------------------------main function and resetting red tasks regularly
local function resettask(color)

	local interceptorside = color

	if #interceptstatus[interceptorside] > 0
		then
			for y = 1, #interceptstatus[interceptorside]
			do
				if interceptstatus[interceptorside][y].Interceptor ~= nil
				then
					local Interceptgrp = interceptstatus[interceptorside][y].Interceptor
					local Interceptgrppcontroller = Interceptgrp:getController()
					Controller.resetTask(Interceptgrppcontroller)--resetting task and make group available for new tasking and therefore refreshing intercept place
	
					if debuggingmessages == true and (interceptorside == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 9) then
						Debug(" resetting TASK: "..interceptorside.." "..string.format(#numberofspawnedandactiveinterceptorgroups[interceptorside]),interceptorside)
					end
					
					numberofspawnedandactiveinterceptorgroups[interceptorside] = {} --resetting the group counter
					
					if debuggingmessages == true and (side == debuggingside or debuggingside == 'both') and (funnum == 0 or funnum == 9) then
						Debug("debugging message resettask reset actual tasking: counter:"..string.format(counter).."/ interceptorside: "..interceptorside, interceptorside)
					end
					
				end
			end

		interceptstatus[interceptorside] = {}
	end
return timer.getTime() + taskinginterval --to be tuned
end --resettask

--schedule next iteration of resettask
timer.scheduleFunction(resettask, 'red', timer.getTime() + 300)
timer.scheduleFunction(resettask, 'blue', timer.getTime() + 300)
------------------------------------------------------------------------------------------------------------------------

landedaircraftsING = {}
arrivaltableINT = {}--Eventhandler detects planes who shut down engine, lists them and removes when engines are shut down

--------------------------------------------creating list of landed aircraft

function arrivaltableINT:onEvent(event)

	--XX9 CAP or GCI units spawning reduce supply
	if (world.event.S_EVENT_BIRTH == event.id)  
		then
		if event.initiator ~= nil and limitedlogistics == 1 then
			local airspawnunit = event.initiator
			local airspawnname = Unit.getName(airspawnunit)
			local desc = Unit.getDesc(airspawnunit)
			if desc.category == 0 and ((string.sub(airspawnname,1,3) == "GCI") or (string.sub(airspawnname,1,3) == "CAP")) then --category = 0 => aircraft
				if Unit.getPlayerName(airspawnunit) == nil then
					stuckunitstable[Unit.getName(airspawnunit)] = nil --XX9 reset stuckunitstable entry for a unit that get airborne
					--XX9 reduce supply for a side's logistics for a aircraft getting airborne 
					if (Unit.getCoalition(airspawnunit) == coalition.side.RED) then
						redgroupsupply = redgroupsupply - 1
					
						if debuggingmessages == true then
							local aside = 'red'
							Debug(" red spawn supply:" ..string.format(redgroupsupply), aside)
						end	
						
					else
						bluegroupsupply = bluegroupsupply - 1
						
						if debuggingmessages == true then
							local aside = 'blue'
							Debug("blue spawn supply:" ..string.format(bluegroupsupply), aside)
						end
						
					end
				end
			end	
		end
	end
	
	if (world.event.S_EVENT_LAND == event.id)
	then
		if event.initiator ~= nil
		then

			local landingunit = event.initiator
			local ldesc = Unit.getDesc(landingunit)
			local landingunitname = Unit.getName(landingunit)
			if ldesc.category == 0 and ((string.sub(landingunitname,1,3) == "GCI") or (string.sub(landingunitname,1,3) == "CAP")) then --category = 0 => aircraft
				if Unit.getPlayerName(landingunit) == nil
				then
					--XX9 give back a supply point for a side's logistics for a safely landed aircraft
					if limitedlogistics == 1 then
						if (Unit.getCoalition(landingunit) == coalition.side.RED) then
							redgroupsupply = redgroupsupply + 1
					
							if debuggingmessages == true then
								local lside = 'red'
								Debug("red landed supply:" ..string.format(redgroupsupply), lside)
							end
					
						else
							bluegroupsupply = bluegroupsupply + 1
					
							if debuggingmessages == true then
								local lside = 'blue'
								Debug("blue landed supply:" ..string.format(bluegroupsupply), lside)
							end	
						end
					end

					local actuallandinggroupname = Group.getName(Unit.getGroup(landingunit))
					landedaircraftsINGtablestatus = false
					if #landedaircraftsING > 0
					then
						for j = 1, #landedaircraftsING
						do
							if landedaircraftsING[j].groupname == actuallandinggroupname and landedaircraftsINGtablestatus == false
							then
								landedaircraftsINGtablestatus = true
							end
						end
					end
					if landedaircraftsINGtablestatus == false
					then
						landedaircraftsING[#landedaircraftsING + 1] =
																{
																groupname = actuallandinggroupname,
																unit = landingunit,
																unitname = Unit.getName(landingunit)
																}
					end
				end
			end
		end
	end
return landedaircraftsING, stuckunitstable, redgroupsupply, bluegroupsupply
end --arrivaltableINT

world.addEventHandler(arrivaltableINT) --trigger function arrivaltableINT on world event

-------------------------------------------------removing planes that safely landed and are not moving any more
function clearApron(color)

	local side = color

	if #landedaircraftsING > 0
	then
		for i = 1, #landedaircraftsING
		do
			if landedaircraftsING[i].unit ~= nil
			then
				local currentunitname = landedaircraftsING[i].unitname
				if Unit.getByName(currentunitname) ~= nil
				then
					local arrivalunit = Unit.getByName(currentunitname)
					local arrivalunitvel = arrivalunit:getVelocity()
					local absarrivalunitvel = math.abs(arrivalunitvel.x) + math.abs(arrivalunitvel.y) + math.abs(arrivalunitvel.z)
					if absarrivalunitvel < 1
					then
						if Unit.getGroup(arrivalunit) ~= nil
						then
							local shutdowngroup = Unit.getGroup(arrivalunit)
							shutdowngroup:destroy()
							
							if debuggingmessages == true and (side == debuggingside or debuggingside == 'both') then
								Debug("debugging message clearApron: group deleted: counter:", side)
							end
							
						end
					end
				end
			end
		end

	end
end --clearApron

-------------------------------------function checks the trigger zones around airfields, if a plane or helicopter is AI and damaged on the ground removes them

function airfieldwreckagecleanup(color)

	local airfieldside = color
	local Bases = {}
	if airfieldside == 'red'
		then

			Bases = {}
			--XX8 load airfields with red airfields >>
	 		for i = 1, #redBases do
				Bases[#Bases+1] = {name=redBases[i].name} 
			end 
			
			--XX8 <<

	elseif airfieldside == 'blue'
		then

			Bases = {}
			--XX8 load airfields with blue airfields >>
	 		for i = 1, #blueBases do
				Bases[#Bases+1] = {name=blueBases[i].name}
			end 		
			
			--XX8 <<
	end


	for index, unitData in pairs(mist.DBs.aliveUnits)
	do
		if unitData.category ~= nil and (unitData.category == "helicopter" or unitData.category == "plane")
		then
			
			if debuggingmessages == true and (airfieldside == debuggingside or debuggingside == 'both') then
				Debug("Debugmessage: Script stuck at cleanup 1", airfieldside)
			end	
				
			if unitData.unitName ~= nil
			then
				local currentaircraftunitname = unitData.unitName
				
				if debuggingmessages == true and (airfieldside == debuggingside or debuggingside == 'both') then
					Debug("Debugmessage: Script stuck at cleanup 2", airfieldside)
				end
				
				if Unit.getByName(currentaircraftunitname) ~= nil
				then
				
					if debuggingmessages == true and (airfieldside == debuggingside or debuggingside == 'both') then
						Debug("Debugmessage: Script stuck at cleanup 3", airfieldside)
					end
					
					local currentaircraftunit = Unit.getByName(currentaircraftunitname)
					
					if debuggingmessages == true and (airfieldside == debuggingside or debuggingside == 'both') then
						Debug("Debugmessage: Script stuck at cleanup 4", airfieldside)
					end
					
					if Unit.getPlayerName(currentaircraftunit) == nil
					then
--XX4 >>
						
						if debuggingmessages == true and (airfieldside == debuggingside or debuggingside == 'both') then
							Debug("Debugmessage: Script stuck at cleanup 4a", airfieldside)
						end
						
						local unitspawntime = stuckunitstable[currentaircraftunitname] --XX4
						local stucktime = 0 --XX4
						local nowtime = timer.getTime()
						
						if nowtime == nil then nowtime = 0 end
						
						if unitspawntime ~= nil then --XX4
						
							if debuggingmessages == true and (airfieldside == debuggingside or debuggingside == 'both') then
								Debug("Debugmessage: Script stuck at cleanup 4b", airfieldside)
							end
						
							stucktime = nowtime - unitspawntime --XX4
							
							if debuggingmessages == true and (airfieldside == debuggingside or debuggingside == 'both') then
								Debug("Debugmessage: Script stuck at cleanup 4c", airfieldside)
							end	
								
						end --XX4 <<
						local initunitstatus = currentaircraftunit:getLife0()
						
						if debuggingmessages == true and (airfieldside == debuggingside or debuggingside == 'both') then
							Debug("Debugmessage: Script stuck at cleanup 4d", airfieldside)
						end	
							
						local lowerstatuslimit = 0.95 * initunitstatus
						
						if debuggingmessages == true and (airfieldside == debuggingside or debuggingside == 'both') then
							Debug("Debugmessage: Script stuck at cleanup 5", airfieldside)
						end
						
						if (currentaircraftunit:inAir() == false and currentaircraftunit:getLife() <= lowerstatuslimit) --XX4
						or (currentaircraftunit:inAir() == false and stucktime >= stucktimelimit) --XX9 parameterise the time limit for stuck aircraft to be removed at
						then
						
							if debuggingmessages == true and (airfieldside == debuggingside or debuggingside == 'both') then
								Debug("Debugmessage: Script stuck at cleanup 6", airfieldside)
							end	
								
							local currentaircraftunitpos = currentaircraftunit:getPosition().p
							
							if debuggingmessages == true and (airfieldside == debuggingside or debuggingside == 'both') then
								Debug("Debugmessage: Script stuck at cleanup 7", airfieldside)
							end
							
							for n = 1, #Bases --XX8
							do
								--XX9 substitute Airbase.getByName("Batumi"):getPosition()
								--cleanairfieldname = AF[n].name
								--cleanairfield = trigger.misc.getZone(cleanairfieldname)
								cleanairfieldpos = {}
								local basename = Bases[n].name
								if basename ~= nil then
									if debuggingmessages == true and (airfieldside == debuggingside or debuggingside == 'both') then
										Debug("Debugmessage: Script stuck at cleanup 7a", airfieldside)
									end
									
									cleanairfieldpos = Airbase.getByName(basename):getPosition().p

									if debuggingmessages == true and (airfieldside == debuggingside or debuggingside == 'both') then
										Debug("Debugmessage: Script stuck at cleanup 7b", airfieldside)
									end	
										
									cleanairfieldposx = cleanairfieldpos.x
									cleanairfieldposz = cleanairfieldpos.z
								
									if debuggingmessages == true and (airfieldside == debuggingside or debuggingside == 'both') then
										Debug("Debugmessage: Script stuck at cleanup 8", airfieldside)
									end
								
									local cleandistancetoairfield = math.sqrt((cleanairfieldposx - currentaircraftunitpos.x)*(cleanairfieldposx - currentaircraftunitpos.x) + (cleanairfieldposz - currentaircraftunitpos.z)*(cleanairfieldposz - currentaircraftunitpos.z))
								
									if debuggingmessages == true and (airfieldside == debuggingside or debuggingside == 'both') then
										Debug("Debugmessage: Script stuck at cleanup 9", airfieldside)
									end
								
									if cleandistancetoairfield <= cleanupradius --XX9 substitute value for cleanairfield.radius
									then
										local currentaircraftgroup = Unit.getGroup(currentaircraftunit)
										currentaircraftgroup:destroy()
										stuckunitstable[currentaircraftunitname] = nil --XX4 remove table entry for deleted unit
										--XX9 give back a supply point for a side's logistics for a stuck aircraft
										if (currentaircraftunit:inAir() == false and stucktime >=stucktimelimit) then
											if airfieldside == 'red' then
												redgroupsupply = redgroupsupply + 1
											
												if debuggingmessages == true and (airfieldside == debuggingside or debuggingside == 'both') then
													Debug(airfieldside.." stuck supply:" ..string.format(redgroupsupply), airfieldside)
												end	
												
											else
												bluegroupsupply = bluegroupsupply + 1
											
												if debuggingmessages == true and (airfieldside == debuggingside or debuggingside == 'both') then
													Debug(airfieldside.." stuck supply:" ..string.format(bluegroupsupply), airfieldside)
												end	
												
											end
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end
return stuckunitstable, redgroupsupply, bluegroupsupply --XX4
end --airfieldwreckagecleanup

-----------------------------------Debugging, content must be string, side must be either 'red' or 'blue' or 'both'

function Debug(content, side)

	local message = content
	local color = side

	trigger.action.outText(message, 60000000)
	
	env.info(message)
end --Debug


end --script