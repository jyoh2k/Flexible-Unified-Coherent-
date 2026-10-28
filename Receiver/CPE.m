function [cpeout] = CPE( AIN, params)
%  Usage      :  [AOUT, cfrout] = CPE( AIN, params)
%
%  Function   :
%     Carrier phase estimation algorithm
%
%  Port
%     1. AIN        : Original signal
%     2. params     : CPR (carrier phase recovery) parameter
%     3. cpeout     : Estimated phase 
%
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   



    type = params.CPEtype;
    OV   = params.OV;
   
    cpeout = zeros(1,  size(AIN,2)*OV);
    
    if ( params.en == 0 ) 
        return; 
    end
    
    cpe = cpeout; cpeout1 = 0;prev_cpeout1=0;
    for iblk=1:params.STEP:size(AIN,2)
        window_2 = floor((params.BLK - params.STEP) /2) ;
        idx1 = max(params.NTrainingSymbol+1, iblk - window_2 );
        idx2 = min(size(AIN,2), iblk + params.STEP - 1 + window_2 );
        AIN_blk = AIN(1, idx1:idx2);  
        if ( type == 1 ) %  4-th power Viterbi-Viterbi 
            m = 4;
            AIN_blk = AIN_blk * exp(-1j * pi/4);
            AIN_mpower = (AIN_blk ./abs(AIN_blk) ).^ m;    
            AIN_mpower_sum = sum( sum( AIN_mpower ));
            cpeout1  = atan2(imag( AIN_mpower_sum ),real(AIN_mpower_sum))/m;
        end 
        if ( type == 2 )   
            m = 8;
            [AIN_blk] = partitioning(AIN_blk, params);
            AIN_mpower = (AIN_blk ./abs(AIN_blk) ).^ m;
            AIN_mpower_sum =  sum( AIN_mpower );
            cpeout1 = atan2(imag( AIN_mpower_sum ), real( AIN_mpower_sum))/m;
        end 
        if ( type == 3 )   
            m = 4;
            [AIN_blk] = partitioning1(AIN_blk, params);
            AIN_mpower = (AIN_blk ./abs(AIN_blk) ).^ m;
            AIN_mpower_sum =  sum( AIN_mpower );
            cpeout1  = atan2(imag( AIN_mpower_sum ), real( AIN_mpower_sum))/m;
        end      
        if ( type == 4 )   % BPS 
            B = params.BPS_step;  
            BPS_error = zeros(1, B);
            for iB=0:B-1
                AIN_rot =  AIN_blk * exp( 1j * pi/2 * ( iB/B -1/2) );
                [decided, distance_min] = slicer( AIN_rot, params);
                BPS_error(1,iB+1) = sum(sum(distance_min));
            end 
            [C, Idx] = min( BPS_error  );
            cpeout1  =  - pi/2 * ((Idx-1)/B -1/2);
        end
        if ( type == 5 )   % Pilot based CPE
            AIN_mpower_sum = AIN(1,iblk) * conj (params.mapper2(1,iblk));
            cpeout1  = atan2(imag( AIN_mpower_sum ), real( AIN_mpower_sum));
            cpeout1 = mean(unwrap(cpeout1));
        end
        
        if ( type == 8 )   % Pilot based CPE : PTBC block format
             idx=iblk: params.BLK *2:iblk+params.BLK * params.period *3  -1;
%              idx=iblk: params.BLK *2:iblk+params.STEP-1;
             idx =[idx (idx+1)];  
             interval = params.BLK * params.period  ; 
             if ( min(idx-interval) > 0  ) 
                 if ( max(idx) <=  size(AIN,2)  )
                    AIN_mpower_sum = AIN(1,idx) .* conj (params.mapper2(1,idx));
                    cpeout1  = atan2(imag( AIN_mpower_sum ), real( AIN_mpower_sum));
                    cpeout1 = mean(unwrap(cpeout1));
                 end
             end 
        end
        if ( type == 7 )   % Pilot based CPE using autocorrelation
             idx=iblk: params.BLK :iblk+params.BLK * params.period    -1;       
             interval = params.BLK * params.period  ;
             cpeout1 = 0; 
             if ( min(idx-interval) > 0  ) 
                 if ( max(idx) <=  size(AIN,2)  )
                    AIN_mpower_sum = sum(AIN(1,idx) .* conj(AIN(1,idx-interval))) ;
                    cpeout1  = atan2(imag( AIN_mpower_sum ), real( AIN_mpower_sum));
                    cpeout1 = mean(unwrap(cpeout1));
                    cpeout1 = cpeout1 * params.STEP /  interval ;
%                     cpeout1 = max(-0.2, min(0.2, cpeout1));
                 end 
             end  
             cpeout1 = prev_cpeout1 + cpeout1;
             prev_cpeout1 = cpeout1;
        end
        if ( type == 6 )   % Pilot based CPE using autocorrelation
            
             idx=iblk: params.BLK *2:iblk+params.BLK * params.period *3  -1;
             idx =[idx (idx+1)];
             interval = params.BLK * params.period *2  ;
             cpeout1 = 0; 
             if ( min(idx-interval) > 0  ) 
                 if ( max(idx) <=  size(AIN,2)  )
                    AIN_mpower_sum = sum(AIN(1,idx) .* conj(AIN(1,idx-interval))) ;
                    cpeout1  = atan2(imag( AIN_mpower_sum ), real( AIN_mpower_sum));
                    cpeout1 = mean(unwrap(cpeout1));
                    cpeout1 = cpeout1 * params.STEP /  interval ;
                 end 
             end  
             cpeout1 = prev_cpeout1 + cpeout1  *[1:params.STEP*params.OV]/(params.STEP*params.OV);
             prev_cpeout1 = cpeout1(end);
        end
        if ( iblk < params.NTrainingSymbol ) % Traning symbol 
            tr_idx = iblk:iblk+params.STEP-1;
            AIN_mpower_sum = sum( AIN(1,tr_idx) .* conj (params.mapper2(1,tr_idx)));
            cpeout1  = atan2(imag( AIN_mpower_sum ), real( AIN_mpower_sum));
            cpeout1 = mean(unwrap(cpeout1));            
        end
        cpe((iblk-1)*OV+1:(iblk+params.STEP-1)*OV)  =  cpeout1   ;
    end    % for iblk=1:params.STEP:size(AIN,2)
    cpeout =cpe(:, 1:size(AIN,2)*OV);
end

function [decided, distance_min] = slicer( in, params)
        distance = abs( ( ones(length(params.mapper_list),1) * in - params.mapper_list * ones(1, length(in)) )) .^2;
        [C, I] = min( distance  );
        decided =  params.mapper_list(I);
        distance_min = C;
end

function [AINt] = partitioning(AIN, params)
        middle_ring_idx =[ find(  abs(AIN) > 0.7  &  abs(AIN) < 1.1708) ] ;
        inner_ring_idx =[ find(  abs(AIN) < 0.7 ) ];
        outer_ring_idx = [  find(  abs(AIN) > 1.1708) ] ;
        AINt = AIN;
        AINt(inner_ring_idx) =AIN(inner_ring_idx) * exp(-1j * pi/4) ;
        AINt(outer_ring_idx) =AIN(outer_ring_idx) * exp(-1j * pi/4) ;
        AINt(middle_ring_idx) =AIN(middle_ring_idx) * exp(-1j * pi/8) ;
end

function [AINt] = partitioning1(AIN, params)
        middle_ring_idx =[ find(  abs(AIN) > 0.7  &  abs(AIN) < 1.1708) ] ;
        inner_ring_idx =[ find(  abs(AIN) < 0.7 ) ];
        outer_ring_idx = [  find(  abs(AIN) > 1.1708) ] ;
        AINt = [AIN([inner_ring_idx outer_ring_idx]) * exp(-1j * pi/4) ]  ;
%         AINt = [AIN(inner_ring_idx) * exp(-1j * pi/4) AIN(outer_ring_idx) * exp(-1j * pi/4)]  ;
%         AINt(inner_ring_idx) =AIN(inner_ring_idx) * exp(-1j * pi/4) ;
%         AINt(outer_ring_idx) =AIN(outer_ring_idx) * exp(-1j * pi/4) ;
%         AINt(middle_ring_idx) =AIN(middle_ring_idx) * exp(-1j * pi/8) ;
end
