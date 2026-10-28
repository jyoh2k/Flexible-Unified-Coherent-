function [ fecout, Llength]=  LDPCEncoder( msg_in, sim, params )

    fecout         = msg_in ;          % External FEC 
    Llength        = length(msg_in);   % length of used data
    
dvb.LDPCCodewordLength = 64800;
dvb.LDPCParityCheckMatrix = dvbs2ldpc(codeRate);
if isempty(numLDPCDecIterations)
    dvb.LDPCNumIterations = 50;
else
    dvb.LDPCNumIterations = numLDPCDecIterations;
end
    if (params.en == 0 )
        return;
    end
    [fecout1]=LDPC_encoder(msg_in) ;
    fecout(1:length(fecout1)) = fecout1;
    Llength = length(fecout1);  
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

dvb.LDPCCodewordLength = 64800;
dvb.LDPCParityCheckMatrix = dvbs2ldpc(codeRate);
if isempty(numLDPCDecIterations)
    dvb.LDPCNumIterations = 50;
else
    dvb.LDPCNumIterations = numLDPCDecIterations;
end
ldpcParam = setLdpcParameter;

% output should be multiple of 2448 and 62
% input should be multiple of 2256*31

% ±æÀÌ Á¶Àý 
Nblock = fix(length(in) / (ldpcParam.lenLdpcN*31)) * 31;
in = in(1:ldpcParam.lenLdpcK*Nblock) ;    
in_block = reshape(in,ldpcParam.lenLdpcK, length(in)/ldpcParam.lenLdpcK);

 %  Ä®·³ÀÌ ½ÅÈ£ÀÓ.
% [~,Nblock] = size(in_block);

codeword_block = zeros(ldpcParam.lenLdpcN,Nblock);
for block = 1 : Nblock    
codeword_block(:,block) = step(ldpcParam.enc,in_block(:,block));
end

codeword = reshape(codeword_block,1,ldpcParam.lenLdpcN*Nblock);




end


