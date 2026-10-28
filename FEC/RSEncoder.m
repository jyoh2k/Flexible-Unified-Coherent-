function [ msg_out, Llength ]=  RSEncoder( msg_in, params )

%  Usage      : [ msg_out ]=  RSEncoder( msg_in, params )
%  Function   :
%     1.   
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :

    if (params.en == 0 )
        msg_out = msg_in;
        return;
    end
        

    N= params.N;
    K= params.K;
    S= params.K-params.S; %% RSEncoder Matlab 2014a version.
    M= params.M;

    rsEncoder = comm.RSEncoder('BitInput',true);
    rsEncoder.CodewordLength =  (N-S) ;
    rsEncoder.MessageLength  =  (K-S) ;

    msg_out =  zeros(1, ceil( length(msg_in)/(M*(K-S))) *  M*(N-S));

    for ii=1:floor(length(msg_in)/(M*(K-S)))
        msg_out(1,(ii-1)*M*(N-S)+1:ii*M*(N-S))= ...
                                step(rsEncoder, msg_in( (ii-1)*M*(K-S)+1:ii*M*(K-S))');
    end
    
    Llength = ii*M*(N-S);
end
