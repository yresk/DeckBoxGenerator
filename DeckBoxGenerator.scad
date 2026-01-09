//
// DeckBoxGenerator v 1.0
//
// Author: Dekoa
//
// A customizable Deck Box Generator for OpenSCAD. 
//
// <<Requirements>>
//  OpenSCAD http://www.openscad.org
//  BOSL2 Library (Included with DeckBoxGenerator) https://github.com/revarbat/BOSL2
//
// <<Licensing>>
//  DeckBoxGenerator and the Included BOSL2 Library are licensed under the BSD 2-Clause License
//
// <<How to Use>>
//  This script will generate a TCG Deck Box based off of the dimensions provided within the
//  Configuration parameters. Size is primarily calculated per Inner Deck Box Measurements, Commander
//  slot Measurements, Thickness of the Walls, and Lid. Caution and proper backups are encouraged if 
//  modifying the original OpenSCAD file. When utilizaing in the OpenSCAD Program itself, the parameters 
//  are listed in the Customizer window. It is recommended to make any modifications to your deck box 
//  here. The default parameters is set up to have a larger than normal commander slot along the lid 
//  being secured by a Dovetail method, 3 magnets help hold the lid in place, while each side has either
//  simple coin depressions for decorations, or a plate depression for custom decoration as well. Please 
//  note that if parameters are non compliant (I.E. various components collide or are too big or too 
//  small), that the script's behavior will try and render it and may error out. Reset to Default 
//  parameters in order to start over.
//
// <<Important Notes!!>>
//  Deck Box Size is rendered based off IDB Parameters, Wall thickness, Commander Slot, and Lid Thickness.
//  If IDB or Commander is Shorter in Z-Axis than the other, Z-Axis Size takes Larger of the two.
//  Shorter Z-Axis Measurement between IDB or Commander will have Infil from the Bottom.
//  Wall thickness between Commander and IDB is Half of the box_wall_thick parameter.
//  Rounding/Clipping applies to Outer Box and Lid Only.
//  Rounding will apply over Clipping if both are Selected.
//  Side 1 is Y-Axis side closest to Origin.
//  Side 2 is X-Axis side furthest from Origin.
//  Side 3 is Y-Axis side furthest from Origin.
//  Side 4 is X-Axis side closest to Origin.
//  If commander Display is needed for slot, Apply Plate to side 4 and use corresponding depth.
//
// <<Minor Version Improvements>>
//  Build in slop tolerance
//  Build in box_lid_cut variable between 10% and 75% to adjust how much the lid cuts into the sides (default: 25%)
//  Able to Imprint Text onto Sides instead of plate
//  Able to Imprint Text onto Lid
//  Able to add Glass Pane slot for Commander Slot
//  Optimize, Function/Modularize, and change Move geometry to Translate Geometry (Completed ver 1.1)
//  Gridfinity base?
//  Separate more Box Lid stuff in Variables
//
// <<Major Version Improvements>>
//  Stackable Box/Lid Concept (requires slop tolerance)
//  Trinket/Die box Add On (Requires Stackable Box/Lid)
//  Commander Slot in Lid Version (requires Optimization)
//  Commander Slot able to be moved to other sides (Requires Optimization)
//  Add ability to imprint images/Logos
//

echo(dbg_version="1.0");
include <BOSL2/std.scad>
include <BOSL2/polyhedra.scad>
echo(bosl_version=bosl_version_str());
bosl_required("2.0.716");
$fa=$preview ? 5 : 2;
$fs=$preview ? 0.5 : 0.2;

//
// Configuration
//

/* [What to Make] */
// Renders the Deck Box. Deselect to prevent rendering.
make_box=true;
// Renders the Box Lid. Deselect to prevent rendering.
make_lid=true;

/* [Inner Box Dimensions] */
// Inner Deck Box length in the X-Axis Direction. Required.
idb_length_x=86;
// Inner Deck Box length in the Y-Axis Direction. Required.
idb_length_y=73;
// Inner Deck Box length in the Z-Axis Direction. Required.
idb_length_z=98;

/* [Shared Box and Lid Config] */
// Thickness of the Box's Lid. Required.
box_lid_thick=9;
// Securing Method of the lid on X-Axis
box_lid_secure="dovetail"; //["none","groove","dovetail"]
// If true, removes back wall for lid slot. Adjust's Lid as well.
box_lid_noback=false;
// How many Magnet slots are in the Lid and Back Wall.
box_lid_magnet_amount=3; //[0,1,2,3,4,5]
// Depth into the wall/Lid for the Magnets.
box_lid_magnet_depth=2;
// Diameter of the Magnet Slots.
box_lid_magnet_diameter=6;
// How much Box lid cuts into back wall.(NOT IMPLEMENTED)
box_lid_lip=1; //[0:0.1:3]
// Defines how much Additional Tolerance for parts. Recesses add this amount, Additional parts subtract this amount.
slop_tolerance=0.1; //[0:0.1:2]

/* [Deck Box Config] */
// Thickness of the Walls of the Box. Required.
box_wall_thick=5; 
// Adds a commander slot. Wall between IDB and this is Half wall Thickness.
box_commander_slot=true;
// Adds a Card Grab to Sides 1 and 3.
box_cardgrab=true;
// Width of the Card Grab Slot.
box_cardgrab_width=26;
// Depth of the Card Grab Slot.
box_cardgrab_height=40;

/* [Box Lid Config] */
// Depth of the Lid Grab Divot. Set to 0 to Remove.
box_lid_divot_depth=4;
// Selection for Lid Feature.
box_lid_slot="coins"; //["none","coins","plate"]
// If Coins selected, how many showing.
box_lid_coinslots_amount=5; //[1,2,3,4,5,6,7,8]
// If Coins Selected, depth into lid.
box_lid_coinslots_depth=2;
// If Coins Selected, Diameter of coins.
box_lid_coinslots_diameter=20;
// If Coins Selected, Rotation in Degrees of where to render.
box_lid_coinslots_rotate=270; //[0:1:360]
// If Plate Selected, Width of Plate Insert, X-Axis.
box_lid_plateslot_width=81;
// If Plate Selected, Height of Plate Insert, Y-Axis.
box_lid_plateslot_height=68;
// If Plate Selected, Depth of Plate Insert into Lid, Z-Axis.
box_lid_plateslot_depth=2;

/* [Commander Slot Config] */
// Commander length in the X-Axis Direction.
cmd_length_x=75;
// Commander length in the Y-Axis Direction.
cmd_length_y=9;
// Commander length in the Z-Axis Direction.
cmd_length_z=111;

/* [Rounding/Clipping] */
// Rounds the Edges of the Deck box and Lid. Takes Priority.
edge_rounding=0; //[0:0.1:4]
// Clips/Chamfer's the Deck box and Lid.
edge_clipping=1.5; //[0:0.1:4]
// If Selected, will trim corners as well.
trim_corners=true;

/* [Deck Box Side1 Config] */
// Selection for Side 1 Feature.
box_side1_slot="coins"; //["none","coins","plate"]
// If Coins selected, how many showing.
box_side1_coinslots_amount=5; //[1,2,3,4,5,6,7,8]
// If Coins Selected, depth into Side.
box_side1_coinslots_depth=2;
// If Coins Selected, Diameter of coins.
box_side1_coinslots_diameter=20;
// If Coins Selected, Rotation in Degrees of where to render.
box_side1_coinslots_rotate=90; //[0:1:360]
// If Plate Selected, Width of Plate Insert, Y-Axis.
box_side1_plateslot_width=65;
// If Plate Selected, Height of Plate Insert, Z-Axis.
box_side1_plateslot_height=90;
// If Plate Selected, Depth of Plate Insert into Side, X-Axis.
box_side1_plateslot_depth=2;

/* [Deck Box Side2 Config] */
// Selection for Side 2 Feature.
box_side2_slot="plate"; //["none","coins","plate"]
// If Coins selected, how many showing.
box_side2_coinslots_amount=5; //[1,2,3,4,5,6,7,8]
// If Coins Selected, depth into Side.
box_side2_coinslots_depth=2;
// If Coins Selected, Diameter of coins.
box_side2_coinslots_diameter=20;
// If Coins Selected, Rotation in Degrees of where to render.
box_side2_coinslots_rotate=90; //[0:1:360]
// If Plate Selected, Width of Plate Insert, X-Axis.
box_side2_plateslot_width=65;
// If Plate Selected, Height of Plate Insert, Z-Axis.
box_side2_plateslot_height=90;
// If Plate Selected, Depth of Plate Insert into Side, Y-Axis.
box_side2_plateslot_depth=2;

/* [Deck Box Side3 Config] */
// Selection for Side 3 Feature.
box_side3_slot="coins"; //["none","coins","plate"]
// If Coins selected, how many showing.
box_side3_coinslots_amount=5; //[1,2,3,4,5,6,7,8]
// If Coins Selected, depth into Side.
box_side3_coinslots_depth=2;
// If Coins Selected, Diameter of coins.
box_side3_coinslots_diameter=20;
// If Coins Selected, Rotation in Degrees of where to render.
box_side3_coinslots_rotate=90; //[0:1:360]
// If Plate Selected, Width of Plate Insert, Y-Axis.
box_side3_plateslot_width=65;
// If Plate Selected, Height of Plate Insert, Z-Axis.
box_side3_plateslot_height=90;
// If Plate Selected, Depth of Plate Insert into Side, X-Axis.
box_side3_plateslot_depth=2;

/* [Deck Box Side4 Config] */
// Selection for Side 4 Feature.
box_side4_slot="plate"; //["none","coins","plate"]
// If Coins selected, how many showing.
box_side4_coinslots_amount=5; //[1,2,3,4,5,6,7,8]
// If Coins Selected, depth into Side.
box_side4_coinslots_depth=2;
// If Coins Selected, Diameter of coins.
box_side4_coinslots_diameter=20;
// If Coins Selected, Rotation in Degrees of where to render.
box_side4_coinslots_rotate=90; //[0:1:360]
// If Plate Selected, Width of Plate Insert, X-Axis.
box_side4_plateslot_width=65;
// If Plate Selected, Height of Plate Insert, Z-Axis.
box_side4_plateslot_height=90;
// If Plate Selected, Depth of Plate Insert into Side, Y-Axis.
box_side4_plateslot_depth=6;

//
// Hidden/Calculated Variables
//

// Spacing for Lid Placement
spacing = (idb_length_x + (box_wall_thick * 2)) * 1.75;
// Determines which Height is Greater
larger_height = idb_length_z > cmd_length_z ? idb_length_z : cmd_length_z;
// Full Box Dimensions X-Axis
box_length_x = idb_length_x + (box_wall_thick * 2);
// Full Box Dimensions Y-Axis, Determines if Commander slot or not
box_length_y = box_commander_slot ? idb_length_y + (cmd_length_y * 1.05) + (box_wall_thick * 2.5) : idb_length_y + (box_wall_thick * 2);
// Full Box Dimensions Z-Axis, Determines if Commander slot or not
box_length_z = box_commander_slot ? larger_height + box_wall_thick + box_lid_thick : idb_length_z + box_wall_thick + box_lid_thick;

//
// Generation
//

if(make_box) drawDeckBox();
if(make_lid) left(spacing) drawLid();

/*
 * Box Generation Module
 * 
 * This module is used to Generate the Deck box.
 * Should not be called outside of this script.
 * TODO:
 *  Optimize and turn into further Modules
 */
module drawDeckBox(){
	difference(){
        //Draws Outer Box and Clips or Rounds depending
		if(edge_rounding == 0 && edge_clipping==0){
			cuboid([box_length_x, box_length_y, box_length_z], anchor=FRONT+LEFT+BOT);
		}
		else if(edge_rounding == 0 && edge_clipping>0){
			cuboid([box_length_x, box_length_y, box_length_z], chamfer=edge_clipping, anchor=FRONT+LEFT+BOT, trimcorners=trim_corners);
		}
		else {
			cuboid([box_length_x, box_length_y, box_length_z], rounding=edge_rounding, anchor=FRONT+LEFT+BOT, trimcorners=trim_corners);
		}
		//Calculate if Lid needs a Back or not per box_lid_noback
        box_lid_length_y = box_lid_noback ? box_length_y * 1.2 : box_length_y - box_wall_thick + 1 + slop_tolerance;
        
        //If lid secure is Dovetail, Remove Lid
        if(box_lid_secure == "dovetail"){
            translate ([(box_wall_thick * 0.75) - slop_tolerance, - 0.1, box_length_z - box_lid_thick - slop_tolerance + 0.1]) prismoid(size1=[(idb_length_x + (box_wall_thick * 0.5) + slop_tolerance), box_lid_length_y + slop_tolerance + 0.1],size2=[idb_length_x + slop_tolerance, box_lid_length_y + slop_tolerance + 0.1], h=(box_lid_thick + slop_tolerance + 0.1), anchor=FRONT+LEFT+BOT);
        }
        //If lid secure is Groove, Remove Lid
        else if(box_lid_secure=="groove"){
            translate ([box_wall_thick - slop_tolerance, -0.1, box_length_z - box_lid_thick - slop_tolerance + 0.1]) cube([idb_length_x + slop_tolerance, box_lid_length_y + slop_tolerance, box_lid_thick + slop_tolerance], anchor=FRONT+LEFT+BOT);
            translate ([(box_wall_thick * 0.75) - slop_tolerance, -0.1, box_length_z - box_lid_thick - slop_tolerance + 0.1]) cube([(box_wall_thick * 0.25) + slop_tolerance, box_lid_length_y + slop_tolerance, (box_lid_thick * 0.5) + slop_tolerance], anchor=FRONT+LEFT+BOT);
            translate ([(box_length_x - box_wall_thick - 0.1) , -0.1, box_length_z - box_lid_thick - slop_tolerance + 0.1]) cube([(box_wall_thick * 0.25) + slop_tolerance, box_lid_length_y + slop_tolerance, (box_lid_thick * 0.5) + slop_tolerance], anchor=FRONT+LEFT+BOT);
        }
        
        //If lid secure is none, Remove Lid
        else {
            translate ([box_wall_thick, -0.1, box_length_z - box_lid_thick - slop_tolerance + 0.1]) cube([idb_length_x + slop_tolerance, box_lid_length_y + slop_tolerance + 0.1, box_lid_thick + slop_tolerance + 0.1], anchor=FRONT+LEFT+BOT);
        }
		
		//remove IDB
        if(box_commander_slot) {
            translate ([box_wall_thick, ((box_wall_thick * 1.5) + cmd_length_y), box_length_z - box_lid_thick + 0.2]) cube([idb_length_x + slop_tolerance, idb_length_y + slop_tolerance, (idb_length_z + 0.2) + slop_tolerance], anchor=FRONT+LEFT+TOP);
        }
        else {
            translate ([box_wall_thick, box_wall_thick, box_length_z - box_lid_thick + 0.2]) cube([idb_length_x + slop_tolerance, idb_length_y + slop_tolerance, (idb_length_z + 0.2) + slop_tolerance], anchor=FRONT+LEFT+TOP);
        }
        
        //If Commander Slot, remove it
		if (box_commander_slot){
			translate ([(((idb_length_x + (box_wall_thick * 2))- cmd_length_x)/2), box_wall_thick, box_length_z - box_lid_thick + 0.1]) cube([cmd_length_x + slop_tolerance, cmd_length_y + slop_tolerance, cmd_length_z  + slop_tolerance + 0.1], anchor=FRONT+LEFT+TOP);
		}
        
        //If Card Grab, Remove Card Grab
        if (box_cardgrab){
            translate([box_length_x/2, box_length_y - box_wall_thick - (idb_length_y/2), box_length_z - box_cardgrab_height + (box_cardgrab_width/2)]) renderCardGrab(box_length_x, box_cardgrab_width, box_cardgrab_height);
        }
        
        //If Magnets, Remove Magnet Slots
        if (box_lid_magnet_amount > 0) {
            translate([box_wall_thick, box_length_y - box_wall_thick - 0.1 + 1 + slop_tolerance, box_length_z - (box_lid_thick / 2) + slop_tolerance]) renderXLineMagnets(box_lid_magnet_amount, idb_length_x, box_lid_magnet_diameter + slop_tolerance, box_lid_magnet_depth + slop_tolerance);
        }
		
		//If Side 1 Slot is Plate and no Card Grab
        if (box_side1_slot == "plate" && box_cardgrab == false) {
            translate ([-0.1, (box_length_y/2), box_length_z/2]) cube([box_side1_plateslot_depth + slop_tolerance + 0.1, box_side1_plateslot_width + slop_tolerance, box_side1_plateslot_height + slop_tolerance], anchor=LEFT);
        }
        //If Side 1 Slot is Coins and no Card Grab
        else if (box_side1_slot == "coins" && box_cardgrab == false) {
            min_length = box_length_y > box_length_z ? box_length_z : box_length_y;
            coinslot_center_y = box_length_y/2;
            coinslot_center_z = box_length_z/2;
            coinslot_radius = (min_length / 2) - (box_side1_coinslots_diameter/2) - box_wall_thick;
            translate([-0.1, coinslot_center_y, coinslot_center_z]) renderXCoins(coinslot_radius, box_side1_coinslots_depth + slop_tolerance + 0.1, box_side1_coinslots_diameter + slop_tolerance, box_side1_coinslots_amount, box_side1_coinslots_rotate);
        }
        
        //If Side 1 Slot is Plate and Card Grab
        else if (box_side1_slot == "plate" && box_cardgrab == true) {
            translate([-0.1, box_length_y/2, (box_length_z - box_cardgrab_height)/2]) cube([box_side1_plateslot_depth + slop_tolerance + 0.1, box_side1_plateslot_width + slop_tolerance, box_side1_plateslot_height + slop_tolerance], anchor=LEFT);
        }
        //if Side 1 Slot is Coins and Card Grab
        else if (box_side1_slot == "coins" && box_cardgrab == true) {
            min_length = box_length_y > (box_length_z - box_cardgrab_height) ? (box_length_z - box_cardgrab_height) : box_length_y;
            coinslot_center_y = box_length_y/2;
            coinslot_center_z = (box_length_z - box_cardgrab_height)/2;
            coinslot_radius = (min_length / 2) - (box_side1_coinslots_diameter/2) - box_wall_thick;
            translate([-0.1, coinslot_center_y, coinslot_center_z]) renderXCoins(coinslot_radius, box_side1_coinslots_depth + slop_tolerance + 0.1, box_side1_coinslots_diameter + slop_tolerance, box_side1_coinslots_amount, box_side1_coinslots_rotate);
        }
        
        //If Side 2 slot is Plate
        if (box_side2_slot == "plate") {
            translate([box_length_x/2, box_length_y + .1, box_length_z/2]) cube([box_side2_plateslot_width + slop_tolerance, box_side2_plateslot_depth + slop_tolerance + 0.1, box_side2_plateslot_height + slop_tolerance], anchor=BACK);
        }
        
        //If Side 2 Slot is Coins
        else if (box_side2_slot == "coins") {
            min_length = box_length_x > box_length_z ? box_length_z : box_length_x;
            coinslot_center_x = box_length_x/2;
            coinslot_center_z = box_length_z/2;
            coinslot_radius = (min_length / 2) - (box_side2_coinslots_diameter / 2) - box_wall_thick;
            translate([coinslot_center_x, box_length_y - box_side3_coinslots_depth, coinslot_center_z]) renderYCoins(coinslot_radius, box_side2_coinslots_depth + slop_tolerance + 0.1, box_side2_coinslots_diameter + slop_tolerance, box_side2_coinslots_amount, box_side2_coinslots_rotate);
        }
        
        //If Side 3 Slot is Plate and No Card Grab
        if (box_side3_slot == "plate" && box_cardgrab == false) {
            translate([box_length_x +.1, box_length_y/2, box_length_z/2]) cube([box_side3_plateslot_depth + slop_tolerance + 0.1, box_side3_plateslot_width + slop_tolerance, box_side3_plateslot_height + slop_tolerance], anchor=RIGHT);
        }
        //If Side 3 Slot is Coins and No Card Grab
        else if (box_side3_slot == "coins" && box_cardgrab == false) {
            min_length = box_length_y > box_length_z ? box_length_z : box_length_y;
            coinslot_center_y = box_length_y/2;
            coinslot_center_z = box_length_z/2;
            coinslot_radius = (min_length / 2) - (box_side3_coinslots_diameter/2) - box_wall_thick;
            translate([box_length_x - box_side3_coinslots_depth, coinslot_center_y, coinslot_center_z]) renderXCoins(coinslot_radius, box_side3_coinslots_depth + slop_tolerance + 0.1, box_side3_coinslots_diameter + slop_tolerance, box_side3_coinslots_amount, box_side3_coinslots_rotate);
        }
        
        //if Side 3 slot is Plate and Card Grab
        if (box_side3_slot == "plate" && box_cardgrab == true) {
            translate([box_length_x +0.1, box_length_y/2, (box_length_z - box_cardgrab_height)/2]) cube([box_side3_plateslot_depth + slop_tolerance + 0.1, box_side3_plateslot_width + slop_tolerance, box_side3_plateslot_height + slop_tolerance], anchor=RIGHT);
        }
        
        //If Side 3 Slot is Coins and Card Grab
        else if (box_side3_slot == "coins" && box_cardgrab == true) {
            min_length = box_length_y > (box_length_z - box_cardgrab_height) ? (box_length_z - box_cardgrab_height) : box_length_y;
            coinslot_center_y = box_length_y/2;
            coinslot_center_z = (box_length_z - box_cardgrab_height)/2;
            coinslot_radius = (min_length / 2) - (box_side3_coinslots_diameter/2) - box_wall_thick;
            translate([box_length_x - box_side3_coinslots_depth, coinslot_center_y, coinslot_center_z]) renderXCoins(coinslot_radius, box_side3_coinslots_depth + slop_tolerance + 0.1, box_side3_coinslots_diameter + slop_tolerance, box_side3_coinslots_amount, box_side3_coinslots_rotate);
        }
        
        //If Side 4 slot is Plate
        if (box_side4_slot == "plate") {
            translate([box_length_x/2, -0.1, box_length_z/2]) cube([box_side4_plateslot_width + slop_tolerance, box_side4_plateslot_depth + slop_tolerance + 0.1, box_side4_plateslot_height + slop_tolerance], anchor=FRONT);
        }

        //If Side 4 slot is Coins
        else if (box_side4_slot == "coins") {
            min_length = box_length_x > box_length_z ? box_length_z : box_length_x;
            coinslot_center_x = box_length_x/2;
            coinslot_center_z = box_length_z/2;
            coinslot_radius = (min_length / 2) - (box_side4_coinslots_diameter / 2) - box_wall_thick;
            translate([coinslot_center_x, -0.1, coinslot_center_z]) renderYCoins(coinslot_radius, box_side4_coinslots_depth + slop_tolerance + 0.1, box_side4_coinslots_diameter + slop_tolerance, box_side4_coinslots_amount, box_side4_coinslots_rotate);
        }
    }
}

/*
 * Lid Generation Module
 * 
 * This module is used to Generate the Deck box Lid.
 * Should not be called outside of this script.
 * TODO:
 *  Render using new Modules made at the bottom
 */

module drawLid(){
    //Calculate if Lid needs a Back or not per box_lid_noback
    commander_calculation = box_commander_slot == true ? (box_wall_thick * 1.5) + cmd_length_y : box_wall_thick;
    box_lid_length_y = box_lid_noback == true ? box_length_y : idb_length_y + commander_calculation + 1 + slop_tolerance;
	difference() {
        union() {
            //If no Edge Rounding or Edge Clipping
			if(edge_rounding == 0 && edge_clipping==0) {
                cuboid([idb_length_x - slop_tolerance, box_lid_length_y - slop_tolerance, (box_lid_thick - slop_tolerance)], anchor=FRONT+LEFT+BOT);
			}
				
			//No Edge Rounding, Edge Clipping
			else if(edge_rounding == 0 && edge_clipping>0) {
                cuboid([idb_length_x - slop_tolerance, box_lid_length_y - slop_tolerance, (box_lid_thick - slop_tolerance)], anchor=FRONT+LEFT+BOT, chamfer=edge_clipping, edges=[FRONT+TOP]);
			}
				
			//Edge Rounding, Ignores Edge Clipping
			else {
                cuboid([idb_length_x - slop_tolerance, box_lid_length_y - slop_tolerance, (box_lid_thick - slop_tolerance)], anchor=FRONT+LEFT+BOT, rounding=edge_rounding, edges=[TOP+FRONT]);
            }
                
			if(box_lid_secure == "dovetail"){
                translate([-(box_wall_thick * 0.25), (box_wall_thick * .75), 0]) prismoid(size1=[(idb_length_x + (box_wall_thick * 0.5) - slop_tolerance), box_lid_length_y - (box_wall_thick * .75) - slop_tolerance],size2=[idb_length_x - slop_tolerance, box_lid_length_y - (box_wall_thick * .75) - slop_tolerance], h=(box_lid_thick - slop_tolerance), anchor=FRONT+LEFT+BOT);
			}
			else if(box_lid_secure=="groove"){
                cuboid([(box_wall_thick * 0.25) - slop_tolerance, box_lid_length_y - slop_tolerance, (box_lid_thick * 0.5) - slop_tolerance], anchor=FRONT+RIGHT+BOT);
                translate([idb_length_x - slop_tolerance, 0, 0,]) cube([(box_wall_thick * 0.25) - slop_tolerance, box_lid_length_y - slop_tolerance, (box_lid_thick * 0.5) - slop_tolerance], anchor=FRONT+LEFT+BOT);
			}
		}
        
        //TODO: Check Magnet Slots and see if they are Rendering at Back with lip properly or not.
        //Removes Magnet Slots
        if (box_lid_magnet_amount > 0) {
            translate([0, box_lid_length_y - box_lid_magnet_depth - slop_tolerance, ((box_lid_thick) / 2) - slop_tolerance]) renderXLineMagnets(box_lid_magnet_amount, idb_length_x - slop_tolerance, box_lid_magnet_diameter + slop_tolerance, box_lid_magnet_depth + slop_tolerance);
        }

        //Removes Box Lid Divot
        if (box_lid_divot_depth > 0) {
            translate([(idb_length_x / 2), box_lid_divot_depth + box_wall_thick, box_lid_thick]) xcyl(r=box_lid_divot_depth + slop_tolerance, h=idb_length_x - (box_wall_thick * 2) + slop_tolerance);
        }
                    
        //If Lid Slot is Plate
        if (box_lid_slot == "plate") {
            translate([(idb_length_x - slop_tolerance) / 2, box_lid_length_y - ((box_lid_length_y - (box_lid_divot_depth * 2) - (box_wall_thick) - slop_tolerance)/2), box_lid_thick - slop_tolerance + 0.1]) cuboid([box_lid_plateslot_width + slop_tolerance, box_lid_plateslot_height + slop_tolerance, box_lid_plateslot_depth + slop_tolerance + 0.1]);
        }
                    
        //If Lid Slot is Coins
        else if (box_lid_slot == "coins") {
            min_length = idb_length_x > (box_lid_length_y - (box_wall_thick * 2) - (box_lid_divot_depth*2)) ? (box_lid_length_y - (box_wall_thick * 2) - (box_lid_divot_depth*2)) : idb_length_x;
            coinslot_center_x = idb_length_x/2;
            coinslot_center_y = box_lid_length_y - ((box_lid_length_y - (box_lid_divot_depth * 2) - box_wall_thick)/2);
            coinslot_radius = (min_length / 2) - (box_lid_coinslots_diameter / 2);
            translate([coinslot_center_x - slop_tolerance, coinslot_center_y - slop_tolerance, box_lid_thick - box_lid_coinslots_depth - slop_tolerance]) renderZCoins(coinslot_radius - slop_tolerance, box_lid_coinslots_depth + slop_tolerance, box_lid_coinslots_diameter + slop_tolerance, box_lid_coinslots_amount, box_lid_coinslots_rotate);
        }
    }
}

/*
 * CardGrab Render Module
 * 
 * Use this module to render a Simple Card Grab Geometry.
 * NOTE: Use a Difference in order to have this remove from the object
 * NOTE: Slot width is rendered using the Diameter of an xCyl, not a Radius.
 * 
 * Arguments:
 *   - box_width: width of the box to calculate the punch through value at 1.1 times.
 *   - slot_width: width of the CardGrab Slot. Rendered using a DIAMETER, not a Radius.
 *   - slot_height: Height of the CardGrab Slot. Height is calculated at Cylinder Horizontal.
 * 
 */

module renderCardGrab(box_width, slot_width, slot_height) {
    xcyl(h=box_width*1.1, d=(slot_width));
    cube([box_width*1.1, slot_width, slot_height*1.1], anchor=BOT);
}

/*
 * Magnet Slots X Axis Render Module
 * 
 * Use this module to render a line of magnet slots along the X Axis.
 * NOTE: Use a Difference in order to have this remove from the object
 * NOTE: Slot width is rendered using the Diameter of an yCyl, not a Radius.
 * 
 * Arguments:
 *   - magnet_amount: Amount of Magnets within the line to render
 *   - x_length: total length in x access direction to render in slots.
 *   - magnet_diameter: diameter of the magnets.
 *   - magnet_depth: depth of the Magnets.
 * 
 */
module renderXLineMagnets(magnet_amount, x_length, magnet_diameter, magnet_depth) {
    for(a = [1 : 1 : magnet_amount]){
        translate([(x_length/(magnet_amount + 1)) * a, 0, 0]) ycyl(h=magnet_depth, d=magnet_diameter, anchor=FRONT);
    }
}

/*
 * Coin Slots X Axis Render Module
 * 
 * Use this module to render the Coin Slots along the X Axis.
 * NOTE: Use a Difference in order to have this remove from the object
 * NOTE: Slot width is rendered using the Diameter of an xCyl, not a Radius.
 * NOTE: Starting position is in North Position on 2D Axis and rotates Counter Clockwise.
 *       Default starting angle (90) has final coin rendered at 0 degrees.
 * 
 * Arguments:
 *   - radius: radius of the coinslots circle.
 *   - coin_Depth: Depth of the coins.
 *   - coin_Diameter: Diameter of the Coins.
 *   - coin_Amount: Amount of coins to render in the Circle.
 *   - start_angle: Points where to start the angle of the render.
 * 
 */
module renderXCoins(radius, coin_Depth, coin_Diameter, coin_Amount, start_Angle) {
    if(coin_Amount > 1) {
        coinslot_Degree = 360 / coin_Amount;
        for(i = [1: 1: coin_Amount]) {
            translate([0, (radius * cos((coinslot_Degree * i) + start_Angle)), (radius * sin((coinslot_Degree * i) + start_Angle))]) xcyl(h=coin_Depth, d=coin_Diameter, anchor=LEFT);
        }
    }
    else {
        xcyl(h=coin_Depth, d=coin_Diameter, anchor=FRONT);
    }
}

/*
 * Coin Slots Y Axis Render Module
 * 
 * Use this module to render the Coin Slots along the Y Axis.
 * NOTE: Use a Difference in order to have this remove from the object
 * NOTE: Slot width is rendered using the Diameter of an yCyl, not a Radius.
 * NOTE: Starting position is in North Position on 2D Axis and rotates Counter Clockwise.
 *       Default starting angle (90) has final coin rendered at 0 degrees.
 * 
 * Arguments:
 *   - radius: radius of the coinslots circle.
 *   - coin_Depth: Depth of the coins.
 *   - coin_Diameter: Diameter of the Coins.
 *   - coin_Amount: Amount of coins to render in the Circle.
 *   - start_angle: Points where to start the angle of the render.
 * 
 */
module renderYCoins(radius, coin_Depth, coin_Diameter, coin_Amount, start_Angle) {
    if(coin_Amount > 1) {
        coinslot_Degree = 360 / coin_Amount;
        for(i = [1: 1: coin_Amount]) {
            translate([(radius * cos((coinslot_Degree * i) + start_Angle)), 0,(radius * sin((coinslot_Degree * i) + start_Angle))]) ycyl(h=coin_Depth, d=coin_Diameter, anchor=FRONT);
        }
    }
    else {
        ycyl(h=coin_Depth, d=coin_Diameter, anchor=LEFT);
    }
}

/*
 * Coin Slots Z Axis Render Module
 * 
 * Use this module to render the Coin Slots along the Z Axis.
 * NOTE: Use a Difference in order to have this remove from the object
 * NOTE: Slot width is rendered using the Diameter of an zCyl, not a Radius.
 * NOTE: Starting position is in North Position on 2D Axis and rotates Counter Clockwise.
 *       Default starting angle (90) has final coin rendered at 0 degrees.
 * 
 * Arguments:
 *   - radius: radius of the coinslots circle.
 *   - coin_Depth: Depth of the coins.
 *   - coin_Diameter: Diameter of the Coins.
 *   - coin_Amount: Amount of coins to render in the Circle.
 *   - start_angle: Points where to start the angle of the render.
 * 
 */
module renderZCoins(radius, coin_Depth, coin_Diameter, coin_Amount, start_Angle) {
    if(coin_Amount > 1) {
        coinslot_Degree = 360 / coin_Amount;
        for(i = [1: 1: coin_Amount]) {
            translate([(radius * cos((coinslot_Degree * i) + start_Angle)), (radius * sin((coinslot_Degree * i) + start_Angle)), 0]) zcyl(h=coin_Depth, d=coin_Diameter, anchor=BOT);
        }
    }
    else {
        zcyl(h=coin_Depth, d=coin_Diameter, anchor=BOT);
    }
}