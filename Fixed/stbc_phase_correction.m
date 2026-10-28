
function [equalized,cpe1,cpe2 ]= stbc_phase_correction ( is_trainseq, stbc_eq, decided,  equalized_in, cpe_in, trainseq_prl, params)
    cpe = 1; 
    PRL1 = params.BPS_window;
    range = params.BPS_range;
    is_pilot =  get_pilot_idx (is_trainseq, params) ;
    equalized = equalized_in;
    if ( is_trainseq == 1)
        cpe1 =cpe_in(1);cpe2 =1;
        equalized = equalized_in;
        return;
    end
    equalizedt  = complex(zeros(2,PRL1));
    for iblk=1:PRL1:size(stbc_eq,2) 
            AIN_blk = stbc_eq(:, iblk:iblk+PRL1-1);
            is_pilot_blk = is_pilot(:, iblk:iblk+PRL1-1);
            trainseq_blk = trainseq_prl(:, iblk:iblk+PRL1-1);
            B = params.BPS_step;
            BPS_error = 100 * ones(1, B+1);
            for iB=0:B
                cpe = cpe_in(1) * exp( 1j * pi/2 * ( iB/B -1/2)*range) * ones(1,size(AIN_blk,2));
                cpe = fie_c (cpe, params.T.CPE);
                 for os=1:2 
                    equalizedt(os,1:PRL1) = sum(AIN_blk(os:2:end, :) .* [cpe; conj(cpe);], 1);
                 end 
                 equalizedt = fie_c (equalizedt, params.T.EQ);
                [decided, distance_min] = slicer( is_pilot_blk, equalizedt, trainseq_blk, params);
                distance_min = fie_r(distance_min, params.T.Dist);
                BPS_error(1,iB+1) = sum(sum(distance_min));
                BPS_error = fie_r(BPS_error, params.T.DistSum);      
            end
            [C, Idx] = min( BPS_error  ); 
            cpe1 = cpe_in(1) * exp( 1j * pi/2 * ( (Idx-1)/B -1/2)*range ) * ones(1,size(AIN_blk,2));
            cpe1 = fie_c (cpe1, params.T.CPE);
            cpe = cpe1;
            for os=1:2 
                equalized(os,iblk:iblk+PRL1-1) = sum(AIN_blk(os:2:end, :) .* [cpe; conj(cpe);], 1);
            end   
            equalized = fie_c (equalized, params.T.EQ);
                
             if ( params.fixed_bit == 2 )   
                end
    end
    cpe1 =cpe(1);cpe2 =1;
     
end



function is_pilot =  get_pilot_idx (is_trainseq, params) 
    PRL = params.PRL/2;
    is_block_end = zeros(1, PRL*2);
    symbol_idx   = 1: PRL;
    is_pilot = ones(size(symbol_idx));
    if ( is_trainseq ==1 ) 
        return;
    end 
    if ( params.en_block_termination == 1 )
         is_block_end = find(mod(symbol_idx, params.block_size) ~= 1);
    end
    if ( params.en_block_termination == 2 )
          is_block_end = find(mod(symbol_idx, params.block_size) ~= 1);
    end
    if ( params.en_block_termination == 4 )
          is_block_end = find(mod(symbol_idx, params.block_size) ~= 1);
    end
    is_pilot (:, is_block_end)=0;
    
end 
    

function [decided, distance_min] = slicer(is_pilot, in, training_seq, params)
%         distance = abs( ( ones(length(params.mapper_list),1) * in - params.mapper_list * ones(1, length(in)) )) .^2;
%         [C, I] = min( distance  );
%         decided =  params.mapper_list(I);
%         distance_min = C;
         in1 = reshape(in,1,size(in,2)*size(in,1));
        decr = slicer1d_16QAM(real(in1), params);
        deci = slicer1d_16QAM(imag(in1), params);
        decided =  complex(decr, deci); 
        decided = reshape(decided, size(in));
        for idx=1:size(in,2)
            if ( is_pilot(idx))
                decided(:,idx) = training_seq(:,idx);
            end
        end
        distance_min =  abs (in - decided) .^2;
        
end



function dec = slicer1d_16QAM(eq, params)
        mapper1_list = fie_r(params.mapper1_list, params.T.Slicer );
        distance = abs( ( ones(length(mapper1_list),1) * eq - mapper1_list * ones(1, length(eq)) )) .^2; 
        [C, I] = min( distance  );
        dec =  mapper1_list(I);
end