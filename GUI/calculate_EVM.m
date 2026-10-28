function [ EVM_dB, error_const_idx, cmp_length] = calculate_EVM(params, signal, ideal_tx, ideal_rx )

%  Usage      : calucate_EVM 
%  Function   : 
%     1.       
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :
 
    cmp_length      = min(length(signal), length(ideal_rx));
    cmp_length      = min(cmp_length,  length(ideal_tx));
    error           = ideal_rx(1:cmp_length) - signal(1:cmp_length) ;
    EVM_dB          = 10*log10(sum(abs(error) .^2 )/sum(abs(signal(1:cmp_length)) .^2 ));
    error_const_idx = find(ideal_rx(1:cmp_length)  ~= ideal_tx(1:cmp_length)) ;
end
 
