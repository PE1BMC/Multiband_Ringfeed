// Experimental Multiband Circle Feed Rev1.0
// 2026-06-17 PE1BMC  Andries Lohmeijer
// Circle Feed concept is based on the design of Hans Holsink PE1CKK
// Dimensions and choke based upon the OM6AA design
// Beam forming ring Per-Simon Kildal
// Controlled Er for the stub with 3D printed slab
// This script calculates all dimensions generates the design
////////////////////////////////////////////////////////////////
// Use the directives below and choose the supported frequencies
// in the frequency array.
////////////////////////////////////////////////////////////////
// Circle loop antenna, looplength is a full wave
// 1/8 Lambda above the reflector
// The cone must be connected to a 50 Ohm 1/4 Lambda stub at 45 degrees
// Stub is a symmetrical feedline of 50 Ohm. 
// The material for this test is white PLA
// According to Tx-Line calculator the stub must be made of:
// h = 1.8 mm, w = 6 mm, Er= 1.75
// according to : https://doi.org/10.3390/s21030897 this needs an 
// infill of about 45% ,  loss tangent is about 0.004 !!
// 
// Beam Forming Ring to improve H plane and E plane balance
//
// Rendering directives
//
ROUND       = false;     // Use round radiators else Ribbon type
BFR         = true;     // Beam Forming Ring 
CHOKE       = true;      // A choke according to OM6AA ringfeed
                         // Choke overrides the reflector diameter setting
VISUAL      = true;     // Render a visualisation
PARTS       = false;     // Render all the parts
SUPPORT     = false;     // Create the Support Structure
REFLECTOR   = false;     // Create the Reflector
BFR_SUPPORTS= false;     // Create the BFR supports
STUB        = false;     // Create the slab for the stub
MOLD        = false;     // Create a mold to form the radiotors
FEED        = false;     // Render an image of a feedline 


// (Relative) Physical constant
speed_c     = 299792458;    // speed of light m/s
//
// Values to define a range of frequencies
//
f_start     = 1200;  // The start frequency
f_stop      = 1800;  // The stop frequency
f_step      = 100;   // The step frequency
//
// Or Choose discrete frequencies
//
FREQ   = [
//        410,      // Radio Astronomy (Pulsars)
//        433,      // HAM Band 70 cm
//        868,      // ISM Band
        1296,       // HAM band 23 cm /Radio Astronomy
        1420,       // Radio Astronomy Hydrogen line
//        1612,       // Radio Astronomy Hydroxyl line
//        1641,       // Radio Astronomy midband?   
        1670,       // Radio Astronomy Hydroxyl line        
        2200,       // Space to Earth
//        2320,       // HAM band 13 cm
        3200,       // Radio Astronomy Methine line 
//        3410,       // HAM band 9 cm
        4830,       // Radio Astronomy Formaldehyde
//        5750,       // HAM band 6cm
        6700,       // Radio Astronomy Methanol 
//       10362,       // HAM band 3 cm   

        ];

// Given starting dimensions
// Parameters for the multiband feeding stub according to PE1CKK
// See comment around line 110 for the constraints
//
Er          = 1.75;   // Controlled by Infill
stub_h      = 1.8;    // Substrate Thickness
stub_w      = 6.0;    // Impedance will be about 50 Ohm
stub_t      = 0.4;    // Stub conductor thickness ( Brass strip 6mm wide) 
gap         = stub_h+2*stub_t;  // Substract gap from loop length
//
// Beam Forming Ring according to Per-Simon Kildal
// The Beamforming ring improves symmetry between E and H plane curves
// Using dipoles or ring feeds the BFR is a means to optimize the G/T 
// Does it also work for multiple bands??
//
// BFR dimensioning "constants":
bfr_d       = 0.5637;    // BFR radius in Lambda
bfr_h       = 0.4678;    // BFR heigth above reflector plane
bfr_r       = 0.0169;    // BFR wire radius
//
// Reflector diameter between minimum 0.5 Lambda 
// An optimum according to Kildal is 1.1 lambda
// When using a Choke the refector kan be made smaller 
// 
reflector   = 0.75;      // Reflector diameter in Lambda
// 
// The following values are determined by practical constraints
// Which materials are available? can you solder it?
// 1.75 mm is 2.5 mm2 standard wire
//
wire_d      = 1.75;      // Loop wire diameter
//
// Experimental, a ribbon radiator might increase bandwidth
//
BAND        = [0.35,3];  // Thickness, Width of ribbon radiators
// 
// A Choke expects a reflector of 0.606 Lambda = Choke inner diameter
// Choke height is 0.13 Lambda
choke_h     = 0.13;      // Relative choke height about lambda/8
choke_d     = 0.606;     // Inner reflector diameter
//
/* Create dimension table based on start, step and stop
DIM_TABLE = [ for (f=[f_start:f_step:f_stop]) 
    [   f,                                  // frequency
        speed_c/(f*1000),                   // Lambda
        (speed_c/(f*1000)-gap)/3.14159],    // Loop Diameter
         ];
*/        
// Create dimension table based on FREQ list         
DIM_TABLE = [ for (f=FREQ) 
    [   f,                                  // frequency
        speed_c/(f*1000),                   // Lambda
        (speed_c/(f*1000)-gap)/3.14159,     // Loop Diameter
         speed_c/(f*1000)-gap],             // Loop Wire Length
         ];  
//
// Verbose the calulated dimensions
//
echo(DIM_TABLE);
max_nr     = len(DIM_TABLE)-1;

// Production/redenring parameters

nfaces      = 200;
tol         = 0.1;      // Tolerance
T           = 1  ;      // Wall Thickness
support_nr  = 6  ;
support_a   = 360/support_nr ; // repetion angle supports
bfrs_t      = 4;               // thickness of bfr support 
bfrs_w      = 8;               // thickness of bfr support 
bfrs_nr     = 4;               // repetion bfr supports

// Calculate the stub length
// The stub runs from the top ring towards the main axis
// The electrical length of the stub must be 90 degrees ( 1/4 Lambda )
// With TX-line a combination of width, height and conductor and dielectric
// constant was choosen 
// Get obtain the largest ring data from the table
//
r_low       = DIM_TABLE[0][2]/2 ;   // Lowest frequency ring radius
h_low       = DIM_TABLE[0][1]/8 ;   // Lowest frequency ring heigth
rh_ratio    = h_low/r_low ;         // Stub elevation ratio 
slope       = atan2(r_low,h_low);   // Calculate the stub angle
l_low       = sqrt(r_low*r_low + h_low*h_low); // Calculate the stub length
r_high      = DIM_TABLE[max_nr][2]/2 ;   // Highest frequency ring radius
lambda_low  = DIM_TABLE[0][1];      // Longest Lambda
// 
//  Calculate the relevant reflector diameters on basis of Lambda
//
reflector_d = lambda_low*reflector; // 1/2 Lambda refector diameter
reflector_c = lambda_low*choke_d+4*T;   // Reflector diameter with choke
choke_height= lambda_low*choke_h;   // Choke height
//
// Center support of the reflector plate
tube_od     = 20; // Mounting flange 
// Verbose values
echo("Number of bands    : ",len(DIM_TABLE));
echo("Longest Lambda     : ",DIM_TABLE[0][1]);
echo("Stub_length        : ",l_low);
echo("Gap in radiator    : ",gap);
echo("Reflector diameter : ",reflector_d);
echo("Reflector choked   : ",reflector_c);


//
// Calulates the stub profile that does center all radiators
//
STUB_PROFILE = [ 
        [0,0],
        [r_low,h_low],
        [r_low,h_low+wire_d/2+1],
        [r_low+stub_w/rh_ratio,h_low+wire_d/2+1],        
        [r_low+stub_w/rh_ratio,h_low],
        [stub_w/rh_ratio,0],        
    ];

//
// Generates a body profile for the radiator supports
//
SUPPORT_PROFILE = [
        [r_high-2,0],
        [r_high-2,(r_high-2)*rh_ratio+wire_d],
        [r_low+2, (r_low+2)*rh_ratio+wire_d],
        [r_low+2,0],
    ];
//
// Rib profile for a flat reflector
//
RIB_PROFILE = [
    [tube_od/2,0],
    [reflector_d/2,0],
    [reflector_d/2,T],
    [tube_od/2,5*T],
    [tube_od/2,0],       
];    
//
// Rib profile for a choked reflector
//
CHOKE_RIB_PROFILE = [
    [tube_od/2,0],
    [reflector_c/2,0],
    [reflector_c/2,T],
    [tube_od/2,5*T],
    [tube_od/2,0],       
];      

//
// This module controls calls the display functions
//
module show(){
if (VISUAL) {
    visual();
    }
if (PARTS) {
    parts();
    } 
if (SUPPORT) { 
    support();   
    }
if (BFR_SUPPORTS) { 
        for ( i = [0:1:bfrs_nr-1] ){
            translate([i*bfrs_t*4-110,-80,0])
            if (CHOKE) {
                bfr_support(reflector_c);
            }
            else
            {
                bfr_support(reflector_d);
            } // end of IF statement
        }  // end of for loop 
    }  // end of if  

if (REFLECTOR) { 
    reflector();   
    }
if (STUB) { 
    stub_flat();   
    }    
if (MOLD) { 
    mold();   
    }     
if (FEED) { 
    feedline();   
    }         
}

    
module support(){
fn=nfaces;
difference(){
   union(){
// Set up vertical supports
    for ( angle = [support_a/2:support_a:390] ){
      difference(){
      // Single support first element
        translate([0,0,0])
            rotate([90,0,angle])
                linear_extrude(height = T)
                    polygon(SUPPORT_PROFILE);
      // Row of holes
        for (pos = DIM_TABLE){
           radius=pos[2]/2;  // radiator radius
           height=pos[1]/8;  // 1/8 Lambda above groundplane 
           if (ROUND) {
           
            // Round hole       
            rotate([0,0,angle])
               translate([radius,-T-tol,height])
                  rotate([-90,0,0])          
                     linear_extrude(height = T+2*tol,$fn=nfaces)
                        circle(d=wire_d+tol);
            // Sleeve to the hole                 
            rotate([0,0,angle])
               translate([radius,-T-tol,height+wire_d/2+1-tol])
                  rotate([-90,0,0])          
                     linear_extrude(height = T+2*tol,$fn=nfaces)
                        square([wire_d/1.5+tol,wire_d+1],center=true );
                 }
             else          
                 { 
            // Sleeves in the support                
             rotate([0,0,angle])
               translate([radius,-T-tol,height])
                   rotate([-90,slope,0])          
                      linear_extrude(height = T+2*tol,$fn=nfaces)
                         square([BAND[0]+tol,BAND[1]+tol],center=true );
            // Opening towards the sleeve
             rotate([0,0,angle])
               translate([radius-0.7,-T-tol,height+1])
                   rotate([-90,slope,0])          
                      linear_extrude(height = T+2*tol,$fn=nfaces)
                         square([2,BAND[1]-0.3],center=true );            
 
               }    // end of if - then        
            }       // end of for loop of radiators  
         }          // end of difference    
      }             // end of for loop ( supports )    

   
// Base circle
   translate([0,0,0])
     linear_extrude(height = T/2)
        circle(r = r_low+2,$fn=nfaces);
// Outer ring
    rotate_extrude(angle=360,$fn=nfaces)
       translate([r_low+2-T/4,0,0])
          square([T/2,10]);          

    }     // end of union 
// Cut out inner ring
   translate([0,0,-tol])
     linear_extrude(height = T/2+2*tol)
        circle(r = r_high-2,$fn=nfaces);
// Punch Alignment holes 
    for ( angle = [45:90:360] ){
       rotate([0,0,angle]) 
          translate([(r_low+r_high)/2,0,-tol]) 
             linear_extrude(height = T+2*tol)
                circle(d=3.2,$fn=nfaces);    
    
        }  // end of for loop 
// Punch space for SMA connector
     translate([r_low+stub_w/2,0,-tol])
            linear_extrude(height= 10+3*T)
                circle(d=15,$fn=nfaces);     
  
    }      // end of difference
}          // end of module 

// 
// A module to create a mould to fit the (round) Radiators
// The radiator is cut to length ( Wavelength-gap)
// The inner diameter is calculated
// A circular pyramid is generated
//
module mold(){
fn=nfaces;
difference(){
   union(){
// Set up the base layer
   translate([0,0,0])
      linear_extrude(height = 2*T)
         circle(r = r_low+wire_d,$fn=nfaces);
    for (i=[0:1:max_nr]){
       if (ROUND) {
            radius=DIM_TABLE[i][2]/2;  // radiator radius
               translate([0,0,0])
                  linear_extrude(height = 2*T+(i+1)*2*wire_d)
                     circle(r = radius-wire_d/2 ,$fn=nfaces);
           }     
       else
           {
            radius=(DIM_TABLE[i][2]-BAND.x)/2;  // radiator radius
            dx = BAND.y*sin(slope); 
            dy = BAND.y*cos(slope);
               translate([0,0,2*T+i*(dy+2*T)])
                  rotate_extrude(angle=360, $fn=nfaces)
                     polygon([
                        [0,0],
                        [radius+dx/2,0],
                        [radius-dx/2,dy],
                        [radius-dx/2,dy+2*T],                        
                        [0,dy+2*T],
                        [0,0],
                     ]);
                     
           }
       
       }          
    }
// Cut out the Inner circle
   translate([0,0,-tol])
      linear_extrude(height = 2*T+(max_nr+1)*2*BAND.y+2*tol)
         circle(r = r_high-2-wire_d/2,$fn=nfaces);
    }         
// Add the stub thickness
}    
 
// This module generates a visualisation of the stub brass-isolator-brass
// According to the calculated tub Profile
// It is centered around the x-axis
//

module stub(){
// Left brass conductor
    color("Gold", 1.0)      
        translate([-stub_w/(rh_ratio*2),stub_h/2+stub_t,0])
            rotate([90,0,0])
                linear_extrude(height = stub_t)
                    polygon(STUB_PROFILE);
// Insert dielectricum
    color("Blue", 0.6)      
        translate([-stub_w/(rh_ratio*2),stub_h/2,0])
            rotate([90,0,0])
                linear_extrude(height = stub_h)
                    polygon(STUB_PROFILE);
// Right brass conductor
    color("Gold", 1.0)      
        translate([-stub_w/(rh_ratio*2),stub_h/2-stub_h,0])
            rotate([90,0,0])
                linear_extrude(height = stub_t)
                    polygon(STUB_PROFILE);    
}
//
// This module generates a slice of dielectricum for the stub
//
module stub_flat(){
   translate([0,0,0])
       rotate([0,0,51.5])
           linear_extrude(height = stub_h)
                polygon(STUB_PROFILE);
}
 
//
// Module to generate a round radiator
//
module round_radiator(r,d,h){
// Difference between radiator and stub 
  difference(){ 
    // The radiator  
    color("Silver", 1.0)    
        translate([0,0,h])
            rotate([0,0,0])
                rotate_extrude(angle=360,$fn=nfaces)
                    translate([r,0,0])
                        circle(d=d);
    // cut out the stub
   stub();   
  }
} 
//
// Module to generate a round radiator
//
module ribbon_radiator(r,d,h){
// Difference between radiator and stub 
  difference(){ 
    // The radiator      
    translate([0,0,h])
       rotate([0,0,0])
           rotate_extrude(angle=360,$fn=nfaces)
              translate([r,0,0])
                 rotate([0,0,-slope])
                    square(BAND, center=true);
    // cut out the stub
   stub();   
  }      
} 
//
// This module generates all the radiators from table
// Either rond or Ribbon type
//
module radiators(){
   if (ROUND) {
     for (pos = DIM_TABLE){
        radius=pos[2]/2;  // radiator radius
        height=pos[1]/8;  // 1/8 Lambda above groundplane
        round_radiator(radius,wire_d,height);}
     }
     else
     {
     for (pos = DIM_TABLE){
        radius=pos[2]/2;  // radiator radius
        height=pos[1]/8;  // 1/8 Lambda above groundplane
        ribbon_radiator(radius,wire_d,height);}
     }    
}
// 
// Calculates and visualizes a Beam Forming Ring
//bfr_d   BFR radius in Lambda
//bfr_h   BFR heigth above reflector plane
//bfr_r   BFR wire radius
//
//
module bfr(){
    // The BFR
    r = bfr_d*lambda_low;
    h = bfr_h*lambda_low;
    d = bfr_r*lambda_low; 
echo("BFR Diameter       : ",2*r);
echo("BFR Height         : ",h);
echo("BFR Tube Diameter  : ",d);    
    
    color("Silver", 1.0)    
        translate([0,0,h])
            rotate([0,0,0])
                rotate_extrude(angle=360,$fn=nfaces)
                    translate([r,0,0])
                        circle(d=d);

} 
//
// This module creates a printable support structure
//
module bfr_support(bd){    // bd = base diameter
    // The BFR
    r = bfr_d*lambda_low;
    h = bfr_h*lambda_low;
    d = bfr_r*lambda_low; 
    bh = choke_height;      // Choke height = base height
    
    
// Create the support profile    
    BFR_PROFILE = [
        [bd/2,0],
        [bd/2,bh],
        [r-bfrs_t/2,h],
        [r+bfrs_t/2,h],       
        [bd/2+bfrs_t,bh],
        [bd/2+bfrs_t,0],
        [bd/2,0],       
    ];        
//echo(BFR_PROFILE);
    difference(){
       union(){
          linear_extrude(height=bfrs_w)
              polygon(BFR_PROFILE);       // basic suppport
          linear_extrude(height=bfrs_w,$fn=nfaces)
             translate([r,h,0])
                circle(r=d/2+2*T);            // BFR_ mounthole
          if (!CHOKE) {
             linear_extrude(height=bfrs_w)
                polygon([
                [bd/2,0],
                [bd/2,20],
                [bd/2-2*bfrs_t,10],
                [bd/2-2*bfrs_t,0],
                [bd/2+bfrs_t,0],
                [bd/2+bfrs_t,-T],
                [bd/2,-T],                
                ]);       // reflector mount feed             
          
          } // end of if statement     
       } // end of union
    // Punch the BFR mounthole
       translate([r,h,-tol])
          linear_extrude(height=bfrs_w+2*tol,$fn=nfaces)
             circle(r=d/2+2*tol);
     // Punch the BFR support mountholes in the side
       translate([bd/2-tol,bh*0.25,bfrs_w/2])
           rotate([0,90,0])
              linear_extrude(height=bfrs_t+2*tol,$fn=nfaces)
                  circle(d=3.2+tol);
       translate([bd/2-tol,bh*0.75,bfrs_w/2])
           rotate([0,90,0])
              linear_extrude(height=bfrs_t+2*tol,$fn=nfaces)
                  circle(d=3.2+tol);
     // Punch the mounthole in the bottom of the support
       translate([bd/2-bfrs_t,0,bfrs_w/2])
           rotate([-90,0,0])
              linear_extrude(height=12,$fn=nfaces)
                  circle(d=2.2+tol);                             
    }    // end of difference
}        // end of module    
//
// This module places n supports for the BFR around the reflector
//       
module bfr_supports(){
// calculate angle step
    angle_step  =360/bfrs_nr;
    for ( angle = [0:angle_step:360] ){
        rotate([0,0,angle])
        if (CHOKE) {
            translate([0,bfrs_w/2,0])        
               rotate([90,0,0]) 
                  bfr_support(reflector_c);
        }
        else
        {
            translate([0,bfrs_w/2,0])         
               rotate([90,0,0]) 
                  bfr_support(reflector_d);
        } // end of IF statement
              
    }  // end of for loop 

}


module rib() {
     translate([0,0,0])
        rotate([90,0,0])
            linear_extrude(height=2*T)
                polygon(RIB_PROFILE);
}

module reflector() {
$fn = nfaces;
difference() { 
union(){
    if (CHOKE) {
    // Refector without ribs, thicken reflector plate  
     translate([0,0,0])
        rotate([0,0,0])
           linear_extrude(height=2*T)
              circle(d= reflector_c);   
    // Choke ring 
     translate([0,0,-choke_height])
        rotate([0,0,0])
           rotate_extrude(angle=360, $fn=nfaces)
              translate([reflector_c/2-2*T,0,0])
                 square([T*2,choke_height]);
     }
     else
     {
// Create Reflectorplate Facedown to printing bed
     translate([0,0,0])
        rotate([0,0,0])
            linear_extrude(height=1.5*T)
                circle(d= reflector_d);
                
     translate([0,0,0])
        rotate([0,0,0])
            linear_extrude(height= 15)
                circle(d= tube_od); 
       
// Add support ribs
    for ( i= [1:1:8]){
     rotate([0,0,45*(i-1)])
         translate([0,0,1.5*T-tol]) 
            rib();}
       }       
}

                 
// Add feedpoint 1/4" SMA connector
  rotate([0,0,22.5])
     translate([r_low+stub_w/2,0,-tol])
            linear_extrude(height= 3*T)
                circle(d=6.35+2*tol);
// Punch Alignment holes 
    for ( angle = [67.5:90:360] ){
       rotate([0,0,angle]) 
          translate([(r_low+r_high)/2,0,-tol]) 
             linear_extrude(height = 4*T+2*tol)
                circle(d=3.2,$fn=nfaces); } 
// Punch BFR support mountholes

    angle_step  =360/bfrs_nr; // calculate angle step
    for ( angle = [22.5:angle_step:360] ){
        rotate([0,0,angle])
        if (CHOKE) {
        translate([reflector_c/2+tol,0,-choke_height*0.25])        
           rotate([0,-90,0]) 
              linear_extrude(height=3*T+2*tol,$fn=nfaces)
                 circle(d=3.2+tol);                  
        translate([reflector_c/2+tol,0,-choke_height*0.75])        
           rotate([0,-90,0]) 
              linear_extrude(height=3*T+2*tol,$fn=nfaces)
                 circle(d=3.2+tol);                   
        }
        else
        {
        translate([reflector_d/2-bfrs_t,0,-tol])         
           rotate([0,0,0]) 
              linear_extrude(height=4*T+2*tol,$fn=nfaces)
                 circle(d=3.2+tol); 
        } // end of IF statement
              
    }  // end of for loop                 
                
                
// Punch Central mounthole
    translate([0,0,1]) 
       linear_extrude(height = 20+2*tol)
          circle(d=5.2,$fn=nfaces);               
    
}
}

module feedline() {

// Start with the flange nut
 color("Gold",1)
    linear_extrude(height=2, $fn=6)
       circle(d = 12.7);
// Add the base tube of the semirigid
    linear_extrude(height=8.5, $fn=nfaces)
       circle(d = 3.5);
// Bottom part of the connector
    difference(){
       union(){
        color("Gold",1)
            rotate([-180,0,0])
                linear_extrude(height=11, $fn=nfaces)
                     circle(d = 5.5);
         color("Gold",1)
            translate([0,0,-1])
              rotate([-180,0,0])
                  linear_extrude(height=9, $fn=nfaces)
                     circle(d = 6.35);                    
             }        
            rotate([-180,0,0])
                linear_extrude(height=11+tol, $fn=nfaces)
                     circle(d = 4.5);                
    
    }    
//  Inner tube of the connector
        color("white",1)
            rotate([-180,0,0])
                linear_extrude(height=9-tol, $fn=nfaces)
                     circle(d = 4.5);
//  Inner contact
    difference(){
        color("Gold",1)
            rotate([-180,0,0])
                linear_extrude(height=9, $fn=nfaces)
                     circle(d = 1.5);
              rotate([-180,0,0])
                linear_extrude(height=11+tol, $fn=nfaces)
                     circle(d = 1.1);                
                } 
// ring                
  color("Gold",1)
    translate([0,0,-2.5])
       linear_extrude(height=0.5, $fn=nfaces)
          circle(d = 10);
// nut          
  color("Silver",1)
    translate([0,0,-4])
       linear_extrude(height=1.5, $fn=6)
          circle(d = 9.5);
// Semi rigid
    difference(){
        color("Silver",1)
           linear_extrude(height=h_low-3, $fn=nfaces)
               circle(d = 2.5);
           linear_extrude(height=h_low-3+tol, $fn=nfaces)
                     circle(d = 2);                
                } 
                
        color("WhiteSmoke",0.5)        
           linear_extrude(height=h_low-2, $fn=nfaces)
                     circle(d = 2); 


          
}

module visual(){
    color("Silver", 1.0)
    radiators();
    stub();
    support();
    color("Coral", 1.0)
       rotate([180,0,22.5])
          reflector();
    rotate([0,0,0])
       translate([r_low+stub_w/2,0,-tol])
          feedline();    
    if (BFR) { 
       bfr();
       bfr_supports();
    }      
}

module parts(){
color("LightGrey",1)
   translate([-r_low-15,reflector_d/2+r_low,0])
      support();
color("Lime",1)   
   translate([r_low+15,reflector_d/2+r_low,0])
      mold();
color("Blue",0.5)      
   translate([0,reflector_d/2+10,0])
      stub_flat();
if (CHOKE) {      
    color("Coral",1)   
       translate([0,0,2*T])
          rotate([180,0,22.5])
             reflector();
   }
else
   {
    color("Coral",1)   
       reflector();   
   }
// The BFR supports
        for ( i = [0:1:bfrs_nr-1] ){
            translate([i*bfrs_t*4+10,0,0])
            if (CHOKE) {
                bfr_support(reflector_c);
            }
            else
            {
                bfr_support(reflector_d);
            } // end of IF statement
        }  // end of for loop    
   
}

show();



