
function [out, mapperout]=  OFDMMapper( in,  params )

%  Usage      : [out]=  OFDMMapper( in,  params )
%  Function   :
%
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :


    % Set unused subcarrier to zero   
    if ( params.en_bit_alloc == 1)
        mapperout = zeros(  params.NTXStream, params.Nsd, params.NDataSymbol );
        in1 = reshape(in, 1, params.Nbpsym, params.NDataSymbol);
        for itx=1:params.NTXStream
            for isd=1:params.Nsd
                mapper_t.Nbitspersymbol = params.Nbpsc_sc(itx,isd);
                mapperout(itx, isd,:) = QAMMapper( in1(1, params.mapper.sc_index_min(itx,isd):params.mapper.sc_index_max(itx,isd), :),  mapper_t); 
            end 
        end 
        data_symbol = reshape( mapperout, params.NTXStream, params.Nsd, params.NDataSymbol );
        mapperout = reshape(mapperout,  1, params.NTXStream * params.Nsd * params.NDataSymbol );
    else
        mapperout     = QAMMapper( in,  params.mapper); 
        data_symbol = reshape( mapperout, params.NTXStream, params.Nsd, params.NDataSymbol );
    end 
    
    one_symbol = zeros( params.NTXStream,  params.NFFT, params.NDataSymbol  );    
    one_symbol(:, params.DataSubcarrierIndex, :)= data_symbol(:,:, :);
    out=reshape(one_symbol, 1, params.NTXStream * params.NFFT * params.NDataSymbol );

end 

