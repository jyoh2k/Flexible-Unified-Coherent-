function [ MsgOut, Llength ]=  DVBS2Decoder( MsgIn, dvb )

%  Usage      : [ MsgOut ]=  DVBS2Decoder( MsgIn, dvb )
%  Function   :
%     1.   
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :

    if (dvb.en == 0 )
        MsgOut = MsgIn;
        return;
    end
        
    frameNumber = (size(MsgIn,2)/dvb.LDPCCodewordLength);
    CodeRate  = dvb.LDPCCodewordLength / dvb.BCHMessageLength;
    CodeLength = dvb.LDPCCodewordLength; 
    MsgLength  = dvb.BCHMessageLength; 
    MsgOut     = zeros(size(MsgIn,1), frameNumber * MsgLength);

    if ( mod(size(MsgIn,2), CodeLength ) ~= 0 )
       error(['Input data size' num2str(size(MsgIn,2)),' should be the multiples of Codeword' num2str(CodeLength) ]);
    end 

%% Inner Code 
    hLDPCDec = comm.LDPCDecoder(dvb.LDPCParityCheckMatrix, ...
    'IterationTerminationCondition', 'Parity check satisfied', ...
    'MaximumIterationCount',         dvb.LDPCNumIterations, ...
    'NumIterationsOutputPort',       true);


%% Outer code
     hBCHDec = comm.BCHDecoder('CodewordLength', dvb.BCHCodewordLength, ...
    'MessageLength', dvb.BCHMessageLength, ...
    'PrimitivePolynomialSource', 'Property', ...
    'PrimitivePolynomial', dvb.BCHPrimitivePoly, ...
    'GeneratorPolynomialSource', 'Property', ...
    'GeneratorPolynomial', dvb.BCHGeneratorPoly, ...
    'CheckGeneratorPolynomial', false);
%% Main body
    for ich=1:size(MsgIn,1)
        for ii=1:frameNumber
            bbFrameRx  = MsgIn(ich, (ii-1)*CodeLength+(1:CodeLength))';
            [ldpcDecOut numIter] = step(hLDPCDec,  bbFrameRx);
            bchDecOut            = step(hBCHDec,   ldpcDecOut);
            MsgOut(ich,(ii-1)*MsgLength+(1:MsgLength))= bchDecOut';
        end
    end
    
end
