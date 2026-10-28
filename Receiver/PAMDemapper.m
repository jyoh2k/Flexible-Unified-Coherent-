function [demapper_out]  =  PAMDemapper( demapper_in, sim, params ) 

%  Usage      : [demapper_out]  =  PAMDemapper( demapper_in, sim, params ) 
%  Function   :
%     1.  Simple Demapper      
%         
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :


    [d1, d2 ] = size ( demapper_in ); 
    num_bps =  params.Nbitspersymbol ;
    num_demap = d2 * num_bps ;
    demapper_out = zeros(d1,  num_demap ); 

    pam4 =[ 0 0 ; 0 1 ; 1 1; 1 0;];
    pam8 =[ 0 0 0; 0 0 1; 0 1 1; 0 1 0;
            1 1 0; 1 1 1; 1 0 1; 1 0 0;];
    pam16=[0 0 0 0; 0 0 0 1; 0 0 1 1; 0 0 1 0;
           0 1 1 0; 0 1 1 1; 0 1 0 1; 0 1 0 0;
           1 1 0 0; 1 1 0 1; 1 1 1 1; 1 1 1 0;
           1 0 1 0; 1 0 1 1; 1 0 0 1; 1 0 0 0;];

    for istream=1:d1
        if (num_bps == 2) 
            demapper_out(istream, 2:2:end) = pam4(demapper_in,2);
            demapper_out(istream, 1:2:end) = pam4(demapper_in,1);
        end
        if (num_bps == 3)
            demapper_out(istream, 3:3:end) = pam8(demapper_in,3);
            demapper_out(istream, 2:3:end) = pam8(demapper_in,2);
            demapper_out(istream, 1:3:end) = pam8(demapper_in,1);
        end
        if (num_bps == 4)
            demapper_out(istream, 4:4:end) = pam16(demapper_in,4);
            demapper_out(istream, 3:4:end) = pam16(demapper_in,3);
            demapper_out(istream, 2:4:end) = pam16(demapper_in,2);
            demapper_out(istream, 1:4:end) = pam16(demapper_in,1);
        end
    end
 
end
