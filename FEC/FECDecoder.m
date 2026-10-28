function [ msg_out, Llength]=  FECDecoder( msg_in, params )

%  Usage      : [ msg_out ]=  FECDecoder( msg_in, params )
%  Function   :
%     1.   FEC Encoder    
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :


    if (params.en == 0 ) 
        msg_out = msg_in;
        Llength = length(msg_in);
        return;
    end

    if (params.FEC_mode == 0 ) %  DVBS2 
        [ msg_out ]= DVBS2Decoder( msg_in, params );
    end  
    if (params.FEC_mode == 1 )
        [ msg_out ]= RSDecoder( msg_in, params );
    end  
    if (params.FEC_mode == 2 )
        [msg_out]   =   LDPCDecoder(msg_in) ;
        fecout(1:length(msg_out)) = msg_out; 
    end
    if (params.FEC_mode == 3 ) % BCH code
        [msg_out]   =   BCHDecoder(msg_in) ; 
    end
    if (params.FEC_mode == 4 || params.FEC_mode == 5  || params.FEC_mode == 6)
        [ msg_out ]= RSDecoder( msg_in, params );
    end  
    
    Llength = length(msg_out);
end
