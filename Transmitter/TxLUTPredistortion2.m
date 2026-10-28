function AOUT = TxLUTPredistortion2( AIN, params)    

%  Usage      : AOUT = TxPredistortion( AIN, params, T )    
%  Function   : LUT based  Predistortion 
%     1.       
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :
 
    AOUT = AIN;
    if ( params.en == 0 )
        return
    end

    AOUT(1,:)   = SubLUTPredistortion1( AIN(1,:), params);    
    if ( size(AIN,1) ==2 )  
        AOUT(2,:)   = SubLUTPredistortion2( AIN(2,:), params);    
    end 
end
 
function AOUT = SubLUTPredistortion1( AIN, params)   
% Lut format 
%  symbol n-2 -> symbol n-1  -> symbol n, offset, 
 lut = real(params.lut);
 AOUT = SubPredistortion(  real(AIN), lut, params.norm ); 
 if ( isreal(AIN)== 0)
    if ( isreal(params.lut) == 0 ) 
       lut(:,end) = imag(params.lut(:,end));
    end 
     AOUT = AOUT + 1j* SubPredistortion( imag(AIN), lut, params.norm ); 
 end 
end


 
function AOUT = SubLUTPredistortion2( AIN, params)   
% Lut format 
%  symbol n-2 -> symbol n-1  -> symbol n, offset, 
 lut = real(params.lut2);
 AOUT = SubPredistortion(  real(AIN), lut, params.norm ); 
 if ( isreal(AIN)== 0)
    if ( isreal(params.lut2) == 0 ) 
       lut(:,end) = imag(params.lut2(:,end));
    end 
     AOUT = AOUT + 1j* SubPredistortion( imag(AIN), lut, params.norm ); 
 end 
end


function AOUT = SubPredistortion(  AIN, lut, norm)    
    AOUT = AIN;
    constraint_memory = size(lut, 2)-2;
    mapper_in = zeros(constraint_memory +1, size(AIN,2));
    for ich=1:size(AIN,1)
    mapper_in(constraint_memory+1,:) = norm * AIN(ich, :);
        for imem=constraint_memory:-1:1
            mapper_in(imem,:) =  [0 mapper_in(imem+1, 1:end-1)];
        end
        %% Main part : offset 
        for ilut=1:size(lut, 1)
             idx =1:size(mapper_in,2);
             for imem=1:constraint_memory+1
                 idx = intersect( idx, find(mapper_in(imem,:) == lut( ilut, imem)));
             end
             AOUT(ich, idx) = AOUT(ich, idx)  + lut(ilut, constraint_memory+2);
        end     
    end
end

