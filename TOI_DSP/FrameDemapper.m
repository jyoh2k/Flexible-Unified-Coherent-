function [demapperout, recovered, recovered2, corrected]=  FrameDemapper( in, txsignal, params )

%  Usage      : 
%  Function   : Demapper
%             1. Training symbol
%             2. Signal symbol
%             3. Data symbol
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :


    recovered1 = in(:,1:params.RXoversample:end);
    recovered1 = recovered1(:, 1:params.NSymbol);
    [recovered2, phase] = Derot( 0, recovered1, txsignal, params  ); 
    
    %STBC Diversity Decoder 
    [recovered2]=  STBCDivDec( recovered2, txsignal,  params.stbcdivdec );
    
    % Data symbols
    recovered2_in = recovered2(:,params.NTrainingSymbol+params.NSignalSymbol+1:end);
    recovered2_1 = RemovePilotSymbol( recovered2_in,   params.pilot );
    recovered = SingleStreamOut( recovered2_1,  params);
    [ddemapperout]  =  QAMDemapper( recovered, params ); 

    % Training symbols
    recovered2_in = recovered2(1,1:params.NTrainingSymbol);
    if ( size(recovered2,1) == 2) 
        recovered2_in(1,2:2:end) = recovered2(2,1:2:params.NTrainingSymbol);
    end 
    recovered2_1 = RemovePilotSymbol( recovered2_in,   params.pilot );
    recovered_tr = SingleStreamOut( recovered2_1,  params);
    [tdemapperout]  =  QAMDemapper( recovered_tr, params.tmapper ); 

    % Signal symbols
    recovered2_in = recovered2(1,params.NTrainingSymbol+(1:params.NSignalSymbol));
    if ( size(recovered2,1) == 2) 
        recovered2_in(1,2:2:end) = recovered2(2,params.NTrainingSymbol+(1:2:params.NSignalSymbol));
    end 
    recovered2_1 = RemovePilotSymbol( recovered2_in,   params.pilot );
    recovered_sig = SingleStreamOut( recovered2_1,  params);
    [sdemapperout]  =  QAMDemapper( recovered_sig, params.tmapper ); 
    [sdemapperout_fec, corrected] = SigDecoder( sdemapperout, params.signal );

    demapperout = [ tdemapperout sdemapperout_fec ddemapperout];
    recovered =[ recovered_tr recovered_sig recovered];

end 
