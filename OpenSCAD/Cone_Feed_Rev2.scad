// Reference Dipole Antenna design
// 2026-05-05 PE1BMC
// Cone Feed concepts based on the design of Hans Holsink PE1CKK
// Circle loop antenna, looplength is a full wave
// 1/8 Lambda from the reflector
// The cone must be connected to a 50 Ohm 1/4 Lambda stub at 45 degrees
// Stub is a symmetrical feedline of 50 Ohm. 
// The material for this test is white PLA
// According to Tx-Line calculator the stub must be made of:
// h = 1.4 mm, w = 5mm, Er= 1.7
// according to : https://doi.org/10.3390/s21030897 this needs an 
// infill of about 45% ,  loss tangent is about 0.004 !!
// 



f_upper     = 1800;         // The upper design frequency
f_lower     = 1200;
f_center    = (f_upper-f_lower)/2;
slices      = 0;
slice_h     = 2;

// Given starting dimensions
stub_h      = 1.4;       // Substrate Thickness
stub_w      = 5.0;    // Impedance will be about 50 Ohm
gap         = 2;  // Substract gap from loop length

// Calculations
speed_c     = 299792458;    // speed of light m/s
lambda_up   =  speed_c/(f_upper*1000); // wavelength [mm]
lambda_cen  =  speed_c/(f_center*1000); // wavelength [mm]
lambda_low  =  speed_c/(f_lower*1000); // wavelength [mm]

loop_up     =  lambda_up-gap;
loop_low    =  lambda_low-gap;
diam_up     =  loop_up/3.14159;
diam_low    =  loop_low/3.14159;

h_low       =  lambda_low/8;   // Distance to Groundplane
r_low       =  diam_low/2;     // The loop_low Radius
h_up        =  lambda_up/8;   // Distance to Groundplane
r_up        =  diam_up/2;     // The loop_low Radius

stub_low    =  sqrt(h_low^2 + r_low^2); // Stub length concentric 
stub_red    =  stub_low/(lambda_low/4); // Required reduction factor
// Calculate the Frustum net
RAD_l       =  stub_low;
RAD_s       =  sqrt(h_up^2 + r_up^2);
NET_angle   =  360*r_low/RAD_l;

 

// Production parameters

nfaces      = 200;
tol         = 0.1;                  // Tolerance
T           = 1  ;  // Wall Thickness


// Echo results of calcuations, any odd values???
echo("Upper Wavelength  : ",lambda_up," mm");
echo("Lower Wavelength  : ",lambda_low," mm");
echo("Largest cone dia. : ",diam_low," mm");
echo("Stub Length       : ",stub_low," mm");
echo("Reduction factor  : ",stub_red," ratio");
echo("NET angle         : ",NET_angle,"degrees");


RADIATOR_PROFILE = [
        [r_up,h_up],
        [r_low,h_low],
        [r_low-T,h_low],
        [r_up-T,h_up],       
        [r_up,h_up],
    ]; 

STUB_PROFILE = [ 
        [0,0],
        [r_low,h_low],
        [r_low+stub_w,h_low],
        [stub_w,0],        
    ];
    
SUPPORT_PROFILE = [
        [r_up-T,0],
        [r_up,0],
        [r_up,h_up+tol],
        [r_up-T,h_up+tol],       
    ];  

NET_PROFILE = [
        [RAD_s+tol,0],
        [RAD_l-tol,0],
        [RAD_l-tol,T],
        [RAD_s+tol,T],       
    ];      
    
module screw(d,h) {
    rotate([0,0,0])
           rotate_extrude($fn = nfaces)
            polygon( points=[
            [0,0],
            [d,0],
            [d/2,d/2],           
            [d/2,h],
            [0,h]
            ] ); 
}

 
module radiator(){
    translate([0,0,0])
       rotate([0,0,0])
           rotate_extrude(angle=360,$fn=nfaces)
              polygon(RADIATOR_PROFILE);
} 

module stub(){
   translate([-0.05,stub_h/2,0])
       rotate([90,0,0])
           linear_extrude(height = stub_h)
                polygon(STUB_PROFILE);
}

module support(){
    translate([0,0,0])
       rotate([0,0,62.5])
           rotate_extrude(angle=225,$fn=nfaces)
              polygon(SUPPORT_PROFILE);
}

module net_mold(){
    translate([0,0,0])
       rotate([0,0,0])
           rotate_extrude(angle=NET_angle,$fn=nfaces)
              polygon(NET_PROFILE);
}


module sliced_radiator(n){
fn=nfaces;
difference(){
   union(){
        radiator();    
   
// Add extra parts

}
// Cut out the slices
    for ( slice = [1:1:n]){
       range=h_low-h_up;                    // Calculate the space
          step=range/(n+1);     // Calculate the stepsize 
              h=h_up+slice*step-slice_h/2; 
                  translate([0,0,h])
                     linear_extrude(height = slice_h)
                        circle(d=diam_low); 
            }

}
}


module visual(){
    color("Coral", 1.0 )
        radiator();
    color("Gold", 1.0)
        stub();
    color("White", 0.3)
        support();
    color("Yellow", 1.0)
        net_mold();        
}


visual();
//radiator();
//sliced_radiator(slices);
//stub();
//support();
//net_mold();






