function in = ResetFcn(in)
flightplan = [2      0,   0;... / No. of WPs - Ole convention
              150,   0, -60;...
              350,   0, -40;...
              zeros(18,3)];
 
obstacles =  [1,     0,   0,  0;...
              0,     0,   0,  0;
              250,   0, -50,  30;...
              zeros(19,4)]; 
              


r0 = [0; 0; -50];
Dir0 = [0;0];
VK = 25;
end