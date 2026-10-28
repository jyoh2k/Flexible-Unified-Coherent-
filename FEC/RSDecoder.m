function [ msg_out ]=  RSDecoder( msg_in, params )


    N= params.N;
    K= params.K;
    S= params.K-params.S; %% RSDecoder Matlab 2014a version.
    M= params.M;

    rsDecoder = comm.RSDecoder('BitInput',true);
    rsDecoder.CodewordLength =  (N-S) ;
    rsDecoder.MessageLength  =  (K-S) ;


    msg_out = zeros(1, ceil( size(msg_in,2)/M/(N-S)) * (K-S)*M );

    for ii=1:length(msg_in)/(M*(N-S))
        msg_out(1,(ii-1)*M*(K-S)+1:ii*M*(K-S))= ...
               step(rsDecoder, msg_in( (ii-1)*M*(N-S)+1:ii*M*(N-S))');
    end
end
