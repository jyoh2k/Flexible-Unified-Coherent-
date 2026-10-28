function [phase]=ATAN_cordic(in, params)
%  Usage      :  [phase] = ATAN_cordic( xv, yv)
%
%  Function   :
%     Calculation of  atan (y/x) via the CORDIC algorithm
%
%  Port 
%
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
% params.fixed_bit  =2;
%% n= Number of Iterations
n=15;
%% Look up table 
lutai = angle( 1+ 1j* 2 ./( 2.^[1:n]))  ;
lutai = fie_phase( lutai, params.T.ATANbit);
xv = real(in);
yv = imag(in);
%% Checking sign of yv
if yv<0

    ai=1;

else

    ai=-1;

end
%% First angle
zo=ai*pi/2;
%% Rotation by 90 degrees
xo=-ai*yv;
yo=ai*xv;
%% Loading the first angle value
if yo<0% Checking sign of y
    ai=1;
else
    ai=-1;
end
z=zo+ai*lutai(1);
zo=z; % z update
%% Micro-Rotations

    for i=1:n-1 
        if ( params.fixed_bit == 2 )  
        end
        [xo, yo, zo, ai] = cor_iter ( xo, yo, zo, ai,  i, lutai(i+1)); 
        xo = fie_r( xo, params.T.STFSum); 
        yo = fie_r( yo, params.T.STFSum); 
        zo = fie_phase( zo, params.T.ATANbit);
    end
  

    if ( params.fixed_bit == 2 )  
    end
    %% Values
    phase=-zo; % Angle
    
    
        if ( params.fixed_bit == 2 )  
        end
end

function [xo, yo, zo, ao] = cor_iter ( xi, yi, zi, ai,  i, lutai, params)

        xo=xi-yi*ai*(2^-(i-1));
        yo=yi+xi*ai*(2^-(i-1));
        if yo>=0 %Comprobación de signo

            ao=-1;

        else

            ao=+1;

        end
        zo=zi+ao*lutai;  
        
end 
 