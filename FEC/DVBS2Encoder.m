function [ MsgOut ]=  DVBS2Encoder( MsgIn, dvb )

%  Usage      : [ MsgOut ]=  DVBS2Encoder( MsgIn, params )
%  Function   :
%     1.   
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :

    if (dvb.en == 0 )
        MsgOut = MsgIn;
        return;
    end
        
    if ( mod(size(MsgIn,2),dvb.BCHMessageLength) ~= 0 )
       error(['Input data size' num2str(size(MsgIn,2)),' should be the multiples of message word' num2str(dvb.BCHMessageLength) ]);
    end 

    frameNumber = (size(MsgIn,2)/dvb.BCHMessageLength);
    CodeRate  = dvb.LDPCCodewordLength / dvb.BCHMessageLength;
    CodeLength = dvb.LDPCCodewordLength; 
    MsgOut     = zeros(size(MsgIn,1), frameNumber * CodeLength);

%% Outer code

    hBCHEnc = comm.BCHEncoder('CodewordLength', dvb.BCHCodewordLength, ...
    'MessageLength', dvb.BCHMessageLength, ...
    'PrimitivePolynomialSource', 'Property', ...
    'PrimitivePolynomial', dvb.BCHPrimitivePoly, ...
    'GeneratorPolynomialSource', 'Property', ...
    'GeneratorPolynomial', dvb.BCHGeneratorPoly, ...
    'CheckGeneratorPolynomial', false);

%% Inner Code 
    hLDPCEnc = comm.LDPCEncoder(dvb.LDPCParityCheckMatrix);

    for ich=1:size(MsgIn,1)
        for ii=1:frameNumber
            bbFrameTx  = MsgIn(ich, (ii-1)*dvb.BCHMessageLength +(1:dvb.BCHMessageLength) );
            bchEncOut            = step(hBCHEnc,   bbFrameTx');
            ldpcEncOut           = step(hLDPCEnc,  bchEncOut);
            MsgOut(ich,(ii-1)*CodeLength+(1:CodeLength))= ldpcEncOut';
        end
    end
    
end
