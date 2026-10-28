

function [dec] = slicer ( in, din, is_training_seq, symbol_idx, params  )
    if ( is_training_seq == 1 )        
        if ( params.cost_function == 4 )
            dec = din;            
            dec = in * abs(dec)/ abs(in);
        else
            dec = din;
        end
        
        return;
    end 
    if ( params.no_slicer == 1 )
        dec =  in;
        return;
    end

    is_block_end = 0;
    if ( params.en_block_termination == 1)      
        is_block_end = double(mod(symbol_idx, params.block_size) == 0);
    end 
    if ( params.en_block_termination == 2 )
        is_block_end = double(mod(symbol_idx, params.block_size) == 1);
    end

    if (is_block_end == 1 )
        dec = din;
    else
        if ( params.cost_function == 4 )
            distance = abs(abs( in) -  abs(params.mapper_list ));
            [~, I] = min( distance  );
            dec =  params.mapper_list(I);            
        else 
            distance = abs( (in  )-  params.mapper_list        ).^2;
            [~, I] = min( distance  );
            if ( in == 2) % Hardware implementation 
                I = 4;
            end 
            if ( in == 0) % Hardware implementation 
                I = 3;
            end 
            if ( in == -2) % Hardware implementation 
                I = 2;
            end 
            dec =  params.mapper_list(I);
        end 
    end
    if ( params.cost_function == 4 )
        dec = in * abs(dec)/ abs(in);
    end 
end
