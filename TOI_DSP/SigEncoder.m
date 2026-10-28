function [ sig_out]=  SigEncoder( sig_in,  params )
%  Usage      : 
%  Function   : [ sig_out]=  SigEncoder( sig_in,  params )
%     1.   Signal Encoder    
%           Hamming code: (31, 16)
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :
    
    if (params.en == 0 )
        sig_out = sig_in;
        return;
    end

    if (params.en == 1 ) % Hamming 
        [H, G] = hammgen(params.m);
        n = 2^(params.m) - 1;
        k = n -params.m;

        sig_out = sig_in;
        offset = 0;
        for idx=1:k:size(sig_in,2)
            sig_out(1,(1:n)+ offset) = mod( sig_in(1,(0:k-1)+idx) * G, 2);
            offset = offset + n;
        end 
    end
    if (params.en == 2 ) % BCH (62, 35) shortened BCH(63, 36)
        n = params.n;
        k = params.k;
        sig_out = sig_in;
        offset = 0;
        for idx=1:k:size(sig_in,2)            
            padded_msg    = [0, sig_in(1,(0:params.k-1)+idx)]; 
            codeword_gf =  bchenc( gf(padded_msg, 1), n+1, k+1);
            codeword_full = double(codeword_gf.x);
            sig_out(1,(1:n)+ offset) = codeword_full(2:end);   % 길이 62
            offset = offset + n;
        end 
    end

end

