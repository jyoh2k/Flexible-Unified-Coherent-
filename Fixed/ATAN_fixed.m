
function [phase_1] = ATAN_fixed( STFoffset, ATANINbit, ATANbit)   %#codegen
    if ( size( ATANINbit ,1) ~= 0 )
        if (  ATANbit.wordl == 0 )
            phase_1 = angle(fie_c(STFoffset, ATANINbit)) ;
            return;
        end
    end 
%     if ( size( ATANINbit ,1) == 0 ) % Fixed designer
%         aout = angle( double( STFoffset));
%         phase_1  = fie_phase( aout,  ATANbit);
%         return ;
%     end 
        
    STFoffset = STFoffset * 2^ ATANINbit.fracl;
    
    STFoffsetr=  abs(real(STFoffset));
    STFoffseti=  abs(imag(STFoffset));
    
    if ( real(STFoffset) < 0 && imag(STFoffset ) <= 0 )
            phase = pi;
    else 
        if ( real(STFoffset) <= 0 && imag(STFoffset ) > 0 ) 
            phase = pi/2 ;
            STFoffseti=  abs(real(STFoffset));
            STFoffsetr=  abs(imag(STFoffset));
        else
            if ( real(STFoffset) >= 0 && imag(STFoffset ) < 0  )
                phase = pi/2 * 3;    
                STFoffseti=  abs(real(STFoffset));
                STFoffsetr=  abs(imag(STFoffset));
            else
                phase = 0;
            end
        end
    end
    
   for ii=1:6
    if ( STFoffsetr >= 2^(ATANINbit.fracl) || ...
            STFoffseti >= 2^(ATANINbit.fracl ))
        STFoffsetr = floor(STFoffsetr /2 );
        STFoffseti = floor(STFoffseti /2 );
    end  
   end 
    
    [phase_1] = ATANROM_fixed( STFoffsetr, STFoffseti, ATANINbit, ATANbit);  
    phase_1 = phase_1 + phase ;
    phase_1  = fie_phase( phase_1,  ATANbit);
end

