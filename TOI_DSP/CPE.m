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
    
    d2 = size(AIN,2);
    is_training_seq = ones(1, d2) ;    
    is_training_seq([1:d2] >   params.training_seq_size  ) = 2;
    is_training_seq([1:d2] >   params.signal_seq_size   ) = 0;
    is_training_seq([params.signal_seq_size +1:params.BLK * 2: d2]) =2;
    is_training_seq([params.signal_seq_size +2:params.BLK * 2: d2]) =2;
    
    cpe = cpeout; cpeout1 = 0;prev_cpeout1=0;
    for iblk=1:params.STEP:size(AIN,2)
        mapper_list = params.mapper_list;
        if ( iblk < (params.NSignalSymbol +params.NTrainingSymbol ) && ...
               iblk > params.NTrainingSymbol ) 
            mapper_list = params.smapper_list;
        end  
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
            range = params.BPS_range;
            BPS_error = zeros(1, B);
            AIN_blk = AIN(:, iblk:(iblk+params.STEP-1));             
            tr_idx = iblk:iblk+params.STEP-1;              
            for iB=0:B-1
                AIN_rot =  AIN_blk * exp( 1j * pi/2 * ( iB/B -1/2) * range ); 
                [ ~, distance_min ] = slicer_prl(  is_training_seq(tr_idx),  AIN_rot, params.mapper2(:,tr_idx), params);
                BPS_error(1,iB+1) = sum(sum(distance_min));
            end              
            [C, Idx] = min( BPS_error  );
            cpeout1  =  - pi/2 * ((Idx-1)/B -1/2)* range;
        end
        if ( type == 5 )   % Pilot based CPE
             idx=iblk: params.BLK *2:iblk+params.BLK * params.period *2  -1;
             idx =[idx (idx+1)];   
             idx = idx - params.BLK * 2;
             if ( min(idx) > 0 )
                 if ( max(idx) <=  size(AIN,2)  )
                    AIN_mpower_sum = AIN(1,idx) .* conj (params.mapper2(1,idx));
                    cpeout1  = atan2(imag( AIN_mpower_sum ), real( AIN_mpower_sum));
                    cpeout1 = mean(unwrap(cpeout1));
                 end
             end  
        end        
        if ( type == 6 )   % Pilot based CPE using autocorrelation            
             idx=iblk: params.BLK *2:iblk+params.BLK * params.period * 3  -1;
             idx =[idx (idx+1)];             
             interval = params.BLK * params.period *2  ;
             cpeout1 = 0; 
             idx = idx(idx <= size(AIN,2)) ;
             if ( min(idx-interval) > 0  ) 
                 if (  length(idx) > 4  )
                    AIN_mpower_sum = sum(AIN(:,idx) .* conj(AIN(:,idx-interval)),2) ;
                    cpeout1  = atan2(imag( AIN_mpower_sum ), real( AIN_mpower_sum));
                    cpeout1 = mean(unwrap(cpeout1));
                    cpeout1 = cpeout1 * params.STEP /  interval ;
                 end 
             end  
             cpeout1 = prev_cpeout1 + cpeout1;
             prev_cpeout1 = cpeout1(end);
        end 
        if ( type == 7 )   % PTBC BPS             
            B = params.BPS_step;  
            range = params.BPS_range;
            BPS_error = zeros(1, B);
            AIN_blk = AIN(:, iblk:(iblk+params.STEP-1));             
            tr_idx = iblk:iblk+params.STEP-1;              
            for iB=0:B-1
                cpr = exp( 1j * pi/2 * ( iB/B -1/2) * range );  
                AIN_rot = sum(AIN_blk .*  ([cpr;conj(cpr);     ] * ones(1, params.STEP)),1);
                [ ~, distance_min ] = slicer_prl(  is_training_seq(tr_idx),  AIN_rot,  params.mapper2(1,tr_idx) , params);
                BPS_error(1,iB+1) = sum(sum(distance_min));
            end              
            [C, Idx] = min( BPS_error  );
            cpeout1  =  - pi/2 * ((Idx-1)/B -1/2)* range;
        end    
        if ( type == 8 )   % Pilot based CPE using autocorrelation            
            % Current symbol time index
             idx=iblk: params.BLK *2:iblk+params.BLK * params.period *2  -1;             
             idx =[idx (idx+1)];   
             idx = idx - params.BLK * params.period ;  
             idx = idx(idx <= size(AIN,2)) ;
             % Reference symbol time index
             ref  = params.BLK * params.period * 2;
             idx1=1: params.BLK *2:1+params.BLK * params.period *2  -1;
             idx1 = [idx1 (idx1+1)];   
             idx1 = idx1 + ref - params.BLK * params.period * 2;
             cpeout1 = 0;    
             if ( mod(iblk-1,128) ~= 0 )
                  idx1 = idx1 + 64;
             end
             if ( min(idx) > params.BLK * params.period  ) 
                 if (  length(idx) ==  length(idx1)  )
                    AIN_mpower_sum = sum(AIN(:,idx) .* conj(AIN(:,idx1)),2) ;
                    cpeout1  = atan2(imag( AIN_mpower_sum ), real( AIN_mpower_sum));
                    cpeout1 = mean(unwrap(cpeout1)); 
                 end                  
                 prev_cpeout1 =  cpe((1 )* OV +1);
                 cpeout1 = prev_cpeout1 + cpeout1;
             end                
             if ( min(idx) <=  params.BLK * params.period && params.PTBC == 0   )                 
                AIN_mpower_sum = sum( AIN(:,idx1) .* conj (params.mapper2(:,idx1)),2);
                cpeout1  = atan2(imag( AIN_mpower_sum ), real( AIN_mpower_sum));
                cpeout1 = mean(unwrap(cpeout1));                   
             end
        end 
        if ( iblk < params.NTrainingSymbol   ) % Traning symbol 
            tr_idx = iblk:iblk+params.STEP-1;
            AIN_mpower_sum = sum( AIN(:,tr_idx) .* conj (params.mapper2(:,tr_idx)),2);
            cpeout1  = atan2(imag( AIN_mpower_sum ), real( AIN_mpower_sum));
            cpeout1 = mean(unwrap(cpeout1)); 
            prev_cpeout1 = cpeout1;         
        end
        cpe((iblk-1)*OV+1:(iblk+params.STEP-1)*OV)  =  cpeout1   ;
    end    % for iblk=1:params.STEP:size(AIN,2)
    cpeout =cpe(:, 1:size(AIN,2)*OV);
end

function [decided, distance_min] = slicer( in, mapper_list)
        distance = abs( ( ones(length(mapper_list),1) * in - mapper_list * ones(1, length(in)) )) .^2;
        [C, I] = min( distance  );
        decided =  mapper_list(I);
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
end



function [decided, min_distance] = slicer_prl( is_trainseq,  equalized, trainseq_prl, params)

    PRL = size(trainseq_prl,2);   
    decided = trainseq_prl;   
    symbol_idx   = 1:PRL;        
    tridx = find(is_trainseq == 1); 
    sigidx = find(is_trainseq == 2); 
    sigidx = setdiff(sigidx, tridx);
    dataidx = setdiff(symbol_idx, union(tridx,sigidx)); 
    
    decided =trainseq_prl;
    for chidx = 1:size(trainseq_prl,1)
        for idx=dataidx
            distance = abs( equalized(chidx,idx) -  params.mapper_list   ).^2;
            [C, I] = min( distance  );
            decided(chidx,idx) =  params.mapper_list(I);
        end

        for idx=sigidx
            distance = abs( equalized(chidx,idx) -  params.smapper_list   ).^2;
            [C, I] = min( distance  );
            decided(chidx, idx) =  params.smapper_list(I);
        end 
         
    end 
     
    
    min_distance = sum(sum(abs ( decided - equalized ) .^2));
end 
   
