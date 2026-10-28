function [params]  =  Calculate_Sigma( demapper_in,  decided_in, params, T) 

%  Usage      : [params]  =  Calculate_Sigma( demapper_in,decided_in,  params, T) 
%  Function   :  Calculate standard deviation of each level to obtain
%  BMD(Bit metric decoder)
%
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :

    NStream  = size(demapper_in,1);   
    B_level  = params.B_level;   
    sigmai    = zeros(NStream,B_level); 
    sigmaq    = zeros(NStream,B_level); 
    meani    = zeros(NStream,B_level); 
    meanq    = zeros(NStream,B_level); 
    metric = demapper_in;
    for istream=1:NStream
        for idx=1:B_level
            sigmai(istream, idx) = std( real(demapper_in(istream, find(real(decided_in(istream,:)) == params.mapper_list(idx)))));
            sigmaq(istream, idx) =  std( imag(demapper_in(istream, find(imag(decided_in(istream,:)) == params.mapper_list(idx)))));
            meani(istream, idx) = mean( real(demapper_in(istream, find(real(decided_in(istream,:)) == params.mapper_list(idx)))));
            meanq(istream, idx) = mean( imag(demapper_in(istream, find(imag(decided_in(istream,:)) == params.mapper_list(idx)))));
    %         b_list = find(real(decided_in) == params.mapper_list(idx));
    %         metric(b_list) =( real(demapper_in(b_list))  ).^2;
        end
    end 
    sigmai = max(sigmai, 1e-3);
    sigmaq = max(sigmaq, 1e-3);
    params.sigmai    = sigmai;
    params.sigmaq    = sigmaq;
    params.meani    = meani;    
    params.meanq    = meanq;
end