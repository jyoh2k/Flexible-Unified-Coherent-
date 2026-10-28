function [out, dc_val, mean_power] = RXDCOffset(params, in, dc_val_in )    

%  Usage      : [out, dc_val] = RXDCOffset(params, in, dc_val_in)    
%  Function   :
%     1.       
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :


    out =fie_c(in, params.T.In);
    dc_val=complex(zeros( size(in,1)));
    mean_power =  mean(mean( abs(in) .^ 2)); 
    if (  params.en == 0 )
        return;
    end

    if ( dc_val_in == 0 )
        for ii=1:size(in,1)
            dc_val(ii) = mean(in(ii,:));
        end
    else
        dc_val = dc_val_in ;
    end

    dc_val = fie_c( dc_val, params.T.Mean);

    for ii=1:size(in,1)
        out(ii,:) = in(ii,:) -dc_val(ii);
    end
    mean_power = mean(mean( abs(out) .^ 2)); 

    out    = fie_c( out, params.T.Out);
    
    
    if ( params.fixed_bit == 2 ) 
    end 
    
end
