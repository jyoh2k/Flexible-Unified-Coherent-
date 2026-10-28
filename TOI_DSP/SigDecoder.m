function [ sig_out, corrected]=  SigDecoder( sig_in,  params )
%  Usage      : 
%  Function   : [ sig_out, corrected]=  SigDecoder( sig_in,  params )
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

        offset    = 0;
        corrected = 0;
        sig_in1 = [sig_in zeros(size(sig_in,1), 20)];

        for idx=1:n:size(sig_in,2)
           %sig_out(1,(1:k)+ offset) = mod( (sig_in(1,(0:n-1)+idx) * H', 2);
            [sig_out_cor, corrected1] =  hammingdecode(sig_in1(1,(0:n-1)+idx), H);
            sig_out(1,(1:k)+ offset) = sig_out_cor(1,n-k+1:n);
            offset = offset + k;
            if ( corrected1  )
                corrected  = 1;
            end 
        end 
    end
    if (params.en == 2 ) % BCH (62, 35) shortened BCH(63, 35)
        offset    = 0;
        corrected = 0;
        n = params.n;
        k = params.k;
        sig_in1 = [sig_in zeros(size(sig_in,1), 20)];
        for idx=1:n:size(sig_in,2)            
            rx_full = [0, sig_in1(1,(0:n-1)+idx)];
            [dec_gf, cnumerr] = bchdec(gf(rx_full, 1), n+1, k+1);      
            if cnumerr >= 0
                dec_full = double(dec_gf.x);
                dec_info = dec_full(2:k+1);
            else
                dec_info = rx_full(2:k+1);
            end
            sig_out(1,(1:k)+ offset) = dec_info;            
            offset = offset + k;
        end
        corrected = corrected  + cnumerr;
    end
end


function [rx_cor, corrected] =  hammingdecode ( rx, H)
    s = mod(H * rx', 2);     % m×1 syndrome vector
    % hammgen's H is systematic ([I | P]), so the syndrome value is not the bit position:
    % the erroneous bit is the column of H equal to the syndrome
    [~, errIdx] = ismember(s', H', 'rows');
    rx_cor = rx;
    corrected = 0;
    if errIdx ~= 0
%         fprintf('Syndrome indicates error at bit %d\n', errIdx);
%  Correct the error
        rx_cor(errIdx) = ~rx_cor(errIdx);
        corrected = 1;
%     else
%         fprintf('No errors detected by syndrome.\n');
    end 
end

 
