function [out]=  STBCDivDec( in, txsignal,  params )

%  Usage      : [out]=  STBCDivDec( in,  params )
%  Function   :
%
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :

    if ( params.en == 0 )
        out = in ;
        return
    end

    if ( size(in,1) ~= 2 || mod(size(in,2),2) ~= 0 ) 
        error(' STBC diverse decoder accepts only two streams.');
    end

    if ( params.mrc == 0 )
        out = zeros(1, size( in,2));
        out(1,1:2:end) = in(1, 1:2:end) + conj (in(2, 2:2:end));
        out(1,2:2:end) = in(2, 1:2:end) - conj (in(1, 2:2:end));

        out = out /2 ;
    else

        head = params.head;     
        tail = params.tail ;     
        for idx=1:2
            signal    = in(idx, head+1:tail);
            ideal_tx  = txsignal.mapper3(idx, head+1:tail);
            ideal_rx  = txsignal.mapper3(idx, head+1:tail);
            [EVM_dB(idx), ~, ~] = calculate_EVM('', signal, ideal_tx , ideal_rx );
        end 
        MRC_ratio = db2pow(-EVM_dB) /sum(db2pow(-EVM_dB) );
        out = zeros(1, size( in,2));
        out(1,1:2:end) = MRC_ratio(1) * in(1, 1:2:end) + MRC_ratio(2) * conj (in(2, 2:2:end));
        out(1,2:2:end) = MRC_ratio(2) * in(2, 1:2:end) - MRC_ratio(1) *  conj (in(1, 2:2:end));
    
    end  
    
  
        
end 
