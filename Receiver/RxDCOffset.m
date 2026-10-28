function [out, dc_val, mean_power] = RxDCOffset(params, in, dc_val_in )    

%  Usage      : [out, dc_val] = RxDCOffset(params, in, dc_val_in)    
%  Function   :
%     1.       
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :

    out = in;
    dc_val=complex(zeros( size(in,1)));
    mean_power =  mean(mean( abs(in) .^ 2)); 
    if (  params.en == 0 )
        return;
    end

    if ( dc_val_in == 0 )
        if ( params.window_size == 0 ) 
            for ii=1:size(in,1)
                dc_val(ii) = mean(in(ii,:));
            end
        else 
            num_block = ceil(size(in,2) / params.window_size);
            zeropad = num_block * params.window_size - size(in,2);           
            dc_val = zeros(size(in));
             for ii=1:size(in,1)
                 in_pad = reshape([in(ii,:) zeros(1, zeropad)], params.window_size, num_block);
                dc_mean =  mean(in_pad,1);
                dc_mean_filter = filter(params.filter,1, dc_mean);
                dc_mean = ones(params.window_size,1) * dc_mean_filter(1,1:size(dc_mean,2));
                dc_mean = reshape(dc_mean, 1, params.window_size * num_block);
                dc_val(ii,:) = dc_mean(1, 1:size(in,2));
             end                    
        end
    else
        dc_val = dc_val_in ;
    end


    for ii=1:size(in,1)
        out(ii,:) = in(ii,:) -dc_val(ii, :);
    end
    mean_power = mean(mean( abs(out) .^ 2)); 

end
