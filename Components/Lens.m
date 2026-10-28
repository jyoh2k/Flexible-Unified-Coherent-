function AOUT =  Lens( AIN, params)
%  Usage      : AOUT =  Lens( AIN, params)
%
%  Function   :
%     Antenna
%
%  Port  :
%     1. AIN        : Original signal
%     2. params     : Antenna parametered sim.
%     3. AOUT       : Amplified signal 
%
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :

  AOUT = AIN * db2mag( params.gain_dbi); 
        
end