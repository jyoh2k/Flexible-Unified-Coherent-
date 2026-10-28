function [out, dc_val] = DCCancel(params, in)%, dc_val_in )    

%  Usage      : [out, dc_val] = DCCancle(enDCCancle, in, dc_val_in)    
%  Function   :
%     1.       
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :

%     in         = fie_c(in, params.T.In);
    out =in;
    
    dc_val=complex(zeros( size(in,1)));
    if (  params.en  == 0 )

        if ( params.fixed_bit == 2 ) 
        end 

        return;
    end

    if ( nargin < 3 )
        for ii=1:size(in,1)
            dc_val(ii) = mean(in(ii,:));
        end
    else
        dc_val = dc_val_in ;
    end
    
    dc_val = fie_c(dc_val, params.T.Mean);
    
    for ii=1:size(in,1)
        out(ii,:) = in(ii,:) -dc_val(ii);
    end
    
    out         = fie_c(out, params.T.Out);
    
    %%
    if ( params.fixed_bit == 2 ) 
    end 

end
