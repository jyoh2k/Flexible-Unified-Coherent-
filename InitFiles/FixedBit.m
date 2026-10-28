function params = FixedBit(  params)

    params.mapper.T = fixed_mapper(params.fixed_type, params.mapper);
    params.tmapper.T = params.mapper.T ; 
    params.TXMatchedfilter.T = fixed_TXMatchedfilter( params.fixed_type,    params.TXMatchedfilter);
    params.txpreemp.T = fixed_txpreemp(params.fixed_type, params.txpreemp);
    params.txgain.T = fixed_TxGain(params.fixed_type, params.txgain);


    params.AGC.T = fixed_AGC(params.fixed_type, params.AGC);
    params.OFDE.T = fixed_OFDE(params.fixed_type, params.OFDE);
    params.DCCancel.T = fixed_DCCancel(params.fixed_type, params.DCCancel);
    params.RXMatchedfilter.T = fixed_RXMatchedfilter( params.fixed_type,    params.RXMatchedfilter);
    params.tpr.T = fixed_RxTPR( params.fixed_type, params.tpr);
    params.searchframe.T = fixed_searchframe( params.fixed_type, params.searchframe);
    params.cfr.T = fixed_cfr( params.fixed_type, params.cfr);
    params.cpr.T = fixed_cpr( params.fixed_type, params.cpr);
    params.searchfineframe.T = fixed_searchfineframe( params.fixed_type, params.searchfineframe);
    params.dfe.T = fixed_DFE( params.fixed_type, params.dfe);
    params.stbc.T = fixed_stbc( params.fixed_type, params.stbc);

    params = fixed_regiseter_set( params.fixed_type, params);
    

end

%register set 

function params = fixed_regiseter_set( fixed_type, params)
    if (  fixed_type == 1 )
        params.txgain.gain = fie_r (params.txgain.gain, params.txgain.T.Gain);
        params.dfe.betaf = fie_r (params.dfe.betaf, params.dfe.T.BETAF);
        params.stbc.betaf = fie_r (params.stbc.betaf, params.stbc.T.BETAF); 
        params.OFDE.freq_resp = fie_c (params.OFDE.freq_resp, params.OFDE.T.FRES);
        params.tpr.K1 =  fie_r (params.tpr.K1, params.tpr.T.K1);        
        params.tpr.K2 = fie_r (params.tpr.K2, params.tpr.T.K2);
    end
end

function T = fixed_mapper( fixed_type, params)
    en         = params.fixed_bit ~= 0 & fixed_type == 1;
    T.mapper    = fi1( en,fixed_type, [], true, 7, 6, 1, 1);
end

function T = fixed_TXMatchedfilter( fixed_type, params)
    en           = params.fixed_bit ~= 0 & fixed_type == 1;
    T.In         = fi1( en, fixed_type, [], true, 7,  6, 1, 1);
    T.Coef       = fi1( en, fixed_type, [], true, 7,  6, 1, 1);
    T.Mul        = fi1( en, fixed_type, [], true, 9,  8, 0, 0);
%     T.Out        = fi1( en, fixed_type, [], true, 8,  6, 0, 0);
    T.Out        = fi1( en, fixed_type, [], true, 8,  7, 1, 1);
end

function T = fixed_txpreemp( fixed_type, params)
    en           = params.fixed_bit ~= 0 & fixed_type == 1;
    T.In         = fi1( en, fixed_type, [], true, 0,  5, 0, 0);
    T.Coef       = fi1( en, fixed_type, [], true, 0,  5, 0, 0);
    T.Mul        = fi1( en, fixed_type, [], true, 0,  5, 0, 0);
    T.Out        = fi1( en, fixed_type, [], true, 0,  4, 1, 1);
end

function T = fixed_TxGain( fixed_type, params)
    en           = params.fixed_bit ~= 0 & fixed_type == 1;
    T.In         = fi1( en, fixed_type, [], true, 8, 7, 1, 1);
    T.Gain       = fi1( en, fixed_type, [], false,7, 6, 1, 1);
    T.Out        = fi1( en, fixed_type, [], true, 8, 7, 1, 1);
end

function T = fixed_AGC( fixed_type, params)
    en           = params.fixed_bit ~= 0 & fixed_type == 1;
    T.In         = fi1( en, fixed_type, [], true, 8, 9, 1, 1);
    T.Gain       = fi1( en, fixed_type, [], true, 8, 3, 1, 1);
    T.Out        = fi1( en, fixed_type, [], true, 8,  6, 1, 1);
end

function T = fixed_OFDE( fixed_type, params)
    en           = params.fixed_bit ~= 0 & fixed_type == 1;
    T.In         = fi1( en, fixed_type, [], true, 8, 6, 1, 1);
    T.FFTW       = fi1( en, fixed_type, [], true, 8, 6, 1, 1);

    T.FFTM1      = fi1( en, fixed_type, [], true, 9, 7, 0, 1); % 9 
    T.FFTX1      = fi1( en, fixed_type, [], true, 10, 7, 0, 1); %10 

    T.FFTM2      = fi1( en, fixed_type, [], true, 10, 7, 0, 1); %10
    T.FFTX2      = fi1( en, fixed_type, [], true, 11, 7, 0, 1); %11
    T.FFTM3      = fi1( en, fixed_type, [], true, 11, 7, 0, 1); %11
    T.FFTX3      = fi1( en, fixed_type, [], true, 12, 7, 0, 1); %12

    T.FFTM4      = fi1( en, fixed_type, [], true, 12, 7, 0, 1); % 12
    T.FFTX4      = fi1( en, fixed_type, [], true, 11, 6, 0, 1); % 11

    T.FFTM5      = fi1( en, fixed_type, [], true, 11, 6, 0, 1); % 11
    T.FFTX5      = fi1( en, fixed_type, [], true, 11, 5, 0, 1); % 11

    T.FFTM6      = fi1( en, fixed_type, [], true, 11, 5, 0, 1);
    T.FFTX6      = fi1( en, fixed_type, [], true, 9, 3, 0, 1);
    T.FFTXO      = fi1( en, fixed_type, [], true, 8, 3, 1, 1);

    T.FIN        = fi1( en, fixed_type, [], true, 8, 3, 1, 1);
    T.FRES       = fi1( en, fixed_type, [], true, 8, 6, 1, 1); % 8
    T.FOUT       = fi1( en, fixed_type, [], true, 9, 3, 1, 1); % 9

    T.IFFTIn     = fi1( en, fixed_type, [], true, 9, 8, 1, 1); %9
    T.IFFTW      = fi1( en, fixed_type, [], true, 8, 6, 1, 1); %8

    T.IFFTM1     = fi1( en, fixed_type, [], true, 9, 8, 0, 1); %9
    T.IFFTX1     = fi1( en, fixed_type, [], true, 9, 8, 0, 1); %9

    T.IFFTM2     = fi1( en, fixed_type, [], true, 9, 8, 0, 1); %9
    T.IFFTX2     = fi1( en, fixed_type, [], true, 9, 7, 0, 1); %9
    
    T.IFFTM3     = fi1( en, fixed_type, [], true, 9, 7, 0, 1); %9
    T.IFFTX3     = fi1( en, fixed_type, [], true, 9, 7, 0, 1); %9

    T.IFFTM4     = fi1( en, fixed_type, [], true, 9, 7, 0, 1); %9
    T.IFFTX4     = fi1( en, fixed_type, [], true, 9, 6, 0, 1); %9

    T.IFFTM5     = fi1( en, fixed_type, [], true, 9, 6, 0, 1); %9
    T.IFFTX5     = fi1( en, fixed_type, [], true, 9, 6, 0, 1);%10

    T.IFFTM6     = fi1( en, fixed_type, [], true, 0, 5, 0, 1);%10
    T.IFFTX6     = fi1( en, fixed_type, [], true, 0, 5, 0, 1);%11
    T.IFFTOut    = fi1( en, fixed_type, [], true, 8, 6, 1, 1);%18
    T.Out        = fi1( en, fixed_type, [], true, 8, 6, 1, 1);%8

end

function T = fixed_OFDE_64( fixed_type, params)
    en           = params.fixed_bit ~= 0 & fixed_type == 1;
    T.In         = fi1( en, fixed_type, [], true, 8, 6, 1, 1);
    T.FFTW       = fi1( en, fixed_type, [], true, 8, 6, 1, 1);

    T.FFTM1      = fi1( en, fixed_type, [], true, 9, 7, 0, 1);
    T.FFTX1      = fi1( en, fixed_type, [], true, 10, 7, 0, 1);

    T.FFTM2      = fi1( en, fixed_type, [], true, 10, 7, 0, 1);
    T.FFTX2      = fi1( en, fixed_type, [], true, 11, 7, 0, 1);
    T.FFTM3      = fi1( en, fixed_type, [], true, 11, 7, 0, 1);
    T.FFTX3      = fi1( en, fixed_type, [], true, 12, 7, 0, 1);

    T.FFTM4      = fi1( en, fixed_type, [], true, 12, 7, 0, 1);
    T.FFTX4      = fi1( en, fixed_type, [], true, 11, 5, 0, 1);

    T.FFTM5      = fi1( en, fixed_type, [], true, 11, 5, 0, 1);
    T.FFTX5      = fi1( en, fixed_type, [], true, 10, 4, 0, 1);

    T.FFTM6      = fi1( en, fixed_type, [], true, 10, 4, 0, 1);
    T.FFTX6      = fi1( en, fixed_type, [], true, 9, 3, 0, 1);
    T.FFTXO      = fi1( en, fixed_type, [], true, 8, 2, 1, 1);

    T.FIN        = fi1( en, fixed_type, [], true, 8, 2, 1, 1);
    T.FRES       = fi1( en, fixed_type, [], true, 8, 6, 1, 1);
    T.FOUT       = fi1( en, fixed_type, [], true, 9, 3, 1, 1);

    T.IFFTIn     = fi1( en, fixed_type, [], true, 9, 7, 1, 1);
    T.IFFTW      = fi1( en, fixed_type, [], true, 8, 6, 1, 1);

    T.IFFTM1     = fi1( en, fixed_type, [], true, 9, 7, 0, 1);
    T.IFFTX1     = fi1( en, fixed_type, [], true, 9, 7, 0, 1);

    T.IFFTM2     = fi1( en, fixed_type, [], true, 9, 7, 0, 1);
    T.IFFTX2     = fi1( en, fixed_type, [], true, 9, 6, 0, 1);
    
    T.IFFTM3     = fi1( en, fixed_type, [], true, 9, 6, 0, 1);
    T.IFFTX3     = fi1( en, fixed_type, [], true, 9, 5, 0, 1);

    T.IFFTM4     = fi1( en, fixed_type, [], true, 9, 5, 0, 1);
    T.IFFTX4     = fi1( en, fixed_type, [], true, 9, 5, 0, 1);

    T.IFFTM5     = fi1( en, fixed_type, [], true, 9, 5, 0, 1);
    T.IFFTX5     = fi1( en, fixed_type, [], true, 10, 5, 0, 1);

    T.IFFTM6     = fi1( en, fixed_type, [], true, 10, 5, 0, 1);
    T.IFFTX6     = fi1( en, fixed_type, [], true, 11, 5, 0, 1);
    T.IFFTOut    = fi1( en, fixed_type, [], true, 8, 3, 1, 1);
    T.Out        = fi1( en, fixed_type, [], true, 8, 5, 1, 1);

end

function T = fixed_DCCancel( fixed_type, params)
    en           = params.fixed_bit ~= 0 & fixed_type == 1;
    T.In         = fi1( en, fixed_type, [], true, 8,  9, 0, 0);
    T.Mean       = fi1( en, fixed_type, [], true, 8,  9, 1, 1);
    T.Out        = fi1( en, fixed_type, [], true, 8,  9, 0, 1);
end

function T = fixed_RXMatchedfilter( fixed_type, params)
    en           = params.fixed_bit ~= 0 & fixed_type == 1;
    T.In         = fi1( en, fixed_type, [], true, 8, 6, 1, 1);
    T.Coef       = fi1( en, fixed_type, [], true, 7,  6, 1, 1);
    T.Mul        = fi1( en, fixed_type, [], true, 13,  11, 0, 0); 
    T.Out        = fi1( en, fixed_type, [], true, 8, 6, 1, 1); 
end
 

function T = fixed_searchframe( fixed_type, params)
    en           = params.fixed_bit ~= 0 & fixed_type == 1;
    T.In         = fi1( en, fixed_type, [], true, 8, 6, 1, 1);
    T.Cor        = fi1( en, fixed_type, [], false, 9, 0, 0, 0);
    T.P1        = fi1( en, fixed_type, [], true, 9, 0, 0, 0);
    T.Msym       = fi1( en, fixed_type, [], false, 12, -3, 0, 0);
end

function T = fixed_cfr( fixed_type, params)
    en           = params.fixed_bit ~= 0 & fixed_type == 1;
    T.In         = fi1( en, fixed_type, [], true, 8, 6, 1, 1);
    T.STFMul        = fi1( en, fixed_type, [], true, 11, 9, 1, 1);
    T.STFSum        = fi1( en, fixed_type, [], true, 14, 6, 1, 1); % 7,-1
    T.ATANbit       = fi1( en, fixed_type, [], true, 11, 8, 1, 1); %11,8,1,1
    T.PhaseOut     = fi1( en, fixed_type, [], true, 19, 16, 0, 0);    
%     T.CompPhase    = fi1( en, fixed_type, [], true, 12, 5, 0, 0);    
    T.CompPhase    = fi1( en, fixed_type, [], true, 8, 5, 0, 0);    
    T.CompRom      = fi1( en, fixed_type, [], true, 7, 6, 1, 1);    
    T.Out          = fi1( en, fixed_type, [], true, 8, 6, 1, 1);  
    
end

function T = fixed_cpr( fixed_type, params)
    en           = params.fixed_bit ~= 0 & fixed_type == 1;
    T.In         = fi1( en, fixed_type, [], true, 8, 6, 1, 1);    
    T.STFMul        = fi1( en, fixed_type, [], true, 11, 9, 1, 1); % 11,9
    T.STFSum        = fi1( en, fixed_type, [], true, 16, 8, 1, 1);   % 16,8
    T.ATANbit       = fi1( en, fixed_type, [], true, 17, 8, 1, 1);  % 13,(8)
    T.ATANbit1      = fi1( en, fixed_type, [], true, 17, 8, 0, 0);  % 13,(8)
%     T.PhaseOut     = fi1( en, fixed_type, [], true, 19, 16, 1, 1);    %19
    T.PhaseMul     = fi1( en, fixed_type, [], true, 11, 8, 0, 0);  %11
    T.CompPhase    = fi1( en, fixed_type, [], true, 8, 5, 0, 0);    %8
    T.CompRom      = fi1( en, fixed_type, [], true, 7, 6, 1, 1);    %7
    T.Out          = fi1( en, fixed_type, [], true, 8, 6, 1, 1);  
    
end

function T = fixed_searchfineframe( fixed_type, params)
    en           = params.fixed_bit ~= 0 & fixed_type == 1;
    T.In         = fi1( en, fixed_type, [], true, 8, 6, 1, 1);
    T.P1        = fi1( en, fixed_type, [], false, 9, 0, 0, 0);
    T.P2        = fi1( en, fixed_type, [], true, 9, 0, 0, 0); 
    T.XCorpwr       = fi1( en, fixed_type, [], false, 13, -8, 0, 0);  
end

function T = fixed_RxTPR( fixed_type, params)
    en           = params.fixed_bit ~= 0 & fixed_type == 1;

    T.In         = fi1( en, fixed_type, [], true, 8, 6, 1, 1);
    T.Tau_frac   = fi1( en, fixed_type, [], false, 6, 6, 1, 1);
    T.TPRFilter  = fi1( en, fixed_type, [], true, 8, 7, 1, 1);
    T.TPRMul     = fi1( en, fixed_type, [], true, 14,12, 0, 0);
    T.TPRSum     = fi1( en, fixed_type, [], true, 8, 6, 1, 1); 

    T.TED        = fi1( en, fixed_type, [], true, 11, 9, 0, 1); %11
    T.TEDSum     = fi1( en, fixed_type, [], true, 10, 4, 1, 1); % 8

    T.K1         = fi1( en, fixed_type, [], true, 16, 20, 1, 1); % 16
    T.K2         = fi1( en, fixed_type, [], true, 16, 25, 1, 1);%25

    T.Loop1      = fi1( en, fixed_type, [], true, 21, 24, 0, 0); %21,  23 = K1.fracl + In.fracl, 
    T.Loop       = fi1( en, fixed_type, [], true, 8+2, 6+3, 1, 1); % 8,6 frac should be same with tau
    T.Acc        = fi1( en, fixed_type, [], true, 21, 3, 0, 1); % 21, 3
    T.Tau        = fi1( en, fixed_type, [], true,  15, 6+3, 1, 1); %15,6 

end

function T = fixed_DFE( fixed_type, params)
    en           = params.fixed_bit ~= 0 & fixed_type == 1;
    T.CK         = fi1( en, fixed_type, [], true, 0, 10, 1, 1);
    T.DK         = fi1( en, fixed_type, [], true, 0, 10, 1, 1);

    T.FFEMul     = fi1( en, fixed_type, [], true, 0, 11, 0, 0);
    T.FFE        = fi1( en, fixed_type, [], true, 0, 6, 0, 1);

    T.FBE        = fi1( en, fixed_type, [], true, 0, 6  , 0, 1);

    T.Slicer     = fi1( en, fixed_type, [], true, 0,  2, 1, 1);
    T.EQOut      = fi1( en, fixed_type, [], true, 0, 5, 1, 1);

    T.ERRORCK         = fi1( en, fixed_type, [], true, 0, 6, 0, 0);
    T.ERRORCKSUM  = fi1( en, fixed_type, [], true, 0, 4, 1, 1);
    T.ERRORDK         = fi1( en, fixed_type, [], true, 0, 6, 0, 0);
    T.ERRORDKSUM  = fi1( en, fixed_type, [], true, 0, 12, 1, 1);

    T.BETAF         = fi1( en, fixed_type, [], false, 0, 20, 1, 1);

end


function T = fixed_NL3DFE( fixed_type, params)
    en           = params.fixed_bit == 1 & fixed_type == 1;
    T.CK         = fi1( en, fixed_type, [], true, 12, 10, 1, 1);
    T.DK         = fi1( en, fixed_type, [], true, 12, 10, 1, 1);
    T.EK         = fi1( en, fixed_type, [], true, 10, 14, 1, 1);
    T.FK         = fi1( en, fixed_type, [], true, 0, -3, 0, 0);
    T.E3K        = fi1( en, fixed_type, [], true, 0, -3, 0, 0);
    T.F3K        = fi1( en, fixed_type, [], true, 0, -3, 0, 0);

    T.FFEMul     = fi1( en, fixed_type, [], true, 16, 11, 0, 0);
    T.FFE        = fi1( en, fixed_type, [], true, 11, 6, 0, 1);


    T.VFEIn      = fi1( en, fixed_type, [], true, 9, 5, 0, 0);
    T.VFEMul     = fi1( en, fixed_type, [], true, 18, 13, 0, 0);
    T.VFEMulSum  = fi1( en, fixed_type, [], true, 15, 11, 0, 0);
    T.VFEOut     = fi1( en, fixed_type, [], true, 9, 5, 0, 1);

    T.V3FEIn     = fi1( en, fixed_type, [], true, 0, -3, 0, 0);
    T.V3FEMul    = fi1( en, fixed_type, [], true, 0, -3, 0, 0);
    T.V3FEMulSum = fi1( en, fixed_type, [], true, 0, -3, 0, 0);
    T.V3FEOut    = fi1( en, fixed_type, [], true, 0, -3, 0, 0);

    T.FBE        = fi1( en, fixed_type, [], true, 10, 6  , 0, 1);
    T.VFBE       = fi1( en, fixed_type, [], true, 0, -3, 0, 0);
    T.V3FBE      = fi1( en, fixed_type, [], true, 0, -3, 0, 0);

    T.Slicer     = fi1( en, fixed_type, [], true, 5,  2, 1, 1);
    T.EQOut      = fi1( en, fixed_type, [], true, 9, 5, 1, 1);

    T.ERRORCK         = fi1( en, fixed_type, [], true, 13, 6, 0, 0);
    T.ERRORCKSUM  = fi1( en, fixed_type, [], true, 10, 4, 1, 1);
    T.ERRORDK         = fi1( en, fixed_type, [], true, 15, 6, 0, 0);
    T.ERRORDKSUM  = fi1( en, fixed_type, [], true, 16, 12, 1, 1);
    T.ERROREK         = fi1( en, fixed_type, [], true, 16, 9, 0, 0);
    T.ERROREKSUM  = fi1( en, fixed_type, [], true, 8, 0, 1, 1);

    T.BETAF         = fi1( en, fixed_type, [], false, 8, 20, 1, 1);
    T.BETAB         = fi1( en, fixed_type, [], false, 8, 20, 1, 1);
    T.BETAE         = fi1( en, fixed_type, [], false, 8, 20, 1, 1);

end

function T = fixed_stbc( fixed_type, params)
    en           = params.fixed_bit ~= 0 & fixed_type == 1;

    T.In         = fi1( en, fixed_type, [], true, 8, 6, 1, 1);
    % Init
    T.trainIn       = fi1( en, fixed_type, [], true, 5, 3, 0, 0); 
    T.trainIn1       = fi1( en, fixed_type, [], true, 4, 3, 0, 0);
    T.trainH_mul    = fi1( en, fixed_type, [], true, 9, 6, 0, 0);
    T.trainH_pwr    = fi1( en, fixed_type, [], false, 8, 4, 1, 1);  
    T.trainH_norm    = fi1( en, fixed_type, [], false, 8, 3, 1, 1); %6
    T.trainH    = fi1( en, fixed_type, [], true, 10, 6, 1, 1);  
    T.H         = fi1( en, fixed_type, [], true, 13, 11, 1, 1);
    T.HMul         = fi1( en, fixed_type, [], true, 13-4, 11-4, 1, 1);
    
   % Decoder
    T.DecIn      = fi1( en, fixed_type, [], true, 8, 6, 0, 1); 
    T.DecMul     = fi1( en, fixed_type, [], true, 14, 11, 0, 0);
    T.DecOut     = fi1( en, fixed_type, [], true, 8, 6, 0, 1);     
    
   % Slicer 
    T.EQ     = fi1( en, fixed_type, [], true, 8,  6, 1, 1);
    T.Slicer     = fi1( en, fixed_type, [], true, 8,  6, 1, 1);

    T.DecErr       = fi1( en, fixed_type, [], true, 9, 6, 0, 0);
    T.ErrorH       = fi1( en, fixed_type, [], true, 13, 6, 1, 1);
    T.ErrorHSum   = fi1( en, fixed_type, [], true, 10, 4, 1, 1);

    T.EQOut      = fi1( en, fixed_type, [], true, 8, 6, 1, 1);

    T.CPE        = fi1( en, fixed_type, [], true,  8, 6, 1, 1);%8
    T.Dist       = fi1( en, fixed_type, [], false, 7, 7, 0, 1);%7
    T.DistSum    = fi1( en, fixed_type, [], false, 9, 7, 0, 1);%9

   % phase correction
    T.BETAF      = fi1( en, fixed_type, [], false, 16, 20, 1, 1);

end

function T = fi1( en, fixed_type, in, signed,wordl,fracl, round, sat )
  if ( en == 0 )
      wordl = 0;
  end
  if ( strcmp(fixed_type , 'fixed_designer') )
    F1 =  fimath('RoundingMethod', 'Floor', ...
    'OverflowAction', 'Wrap', ...
    'ProductMode', 'FullPrecision', ...
    'SumMode', 'KeepLSB');
    F_rnd =  fimath('RoundingMethod', 'Nearest', ...
        'OverflowAction', 'Wrap', ...
        'ProductMode', 'FullPrecision', ...
        'SumMode', 'KeepLSB');
    F_rnd_sat =  fimath('RoundingMethod', 'Nearest', ...
    'OverflowAction', 'Saturate', ...
    'ProductMode', 'FullPrecision', ...
    'SumMode', 'KeepLSB');
    F_sat =  fimath('RoundingMethod', 'Floor', ...
    'OverflowAction', 'Saturate', ...
    'ProductMode', 'FullPrecision', ...
    'SumMode', 'KeepLSB');
      if ( wordl == 0 )
          T =double([]);
      else
      if ( round == 0 && sat == 0 )
          T =fi([], signed, wordl, fracl, F1);
      end
      if ( round == 1 && sat == 0 )
          T =fi([], signed, wordl, fracl, F_rnd);
      end
      if ( round == 0 && sat == 1 )
          T =fi([], signed, wordl, fracl, F_sat);
      end
      if ( round == 1 && sat == 1 )
          T =fi([], signed, wordl, fracl, F_rnd_sat);
      end
      end

  else
      T.signed = signed;
      T.wordl  = wordl;
      T.fracl  = fracl;
      T.round  = round;
      T.sat    = sat;
  end
end

