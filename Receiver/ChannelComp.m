function [out, pilot, eq_out, frameout ]=  ChannelComp( in, H, params, frameout )

%  Usage      :   [out, H, ce ]=  ChannelEst( in, params )
%  Function   :
%     1.       
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :

    
    %% Initialization
    cpe           = zeros(1,size(in,2));
    bcpe          = zeros(1,size(in,2));
    cpe_err   = zeros(1,size(in,2));
    timingoffset  = zeros(1,size(in,2));
    acc_cpe       = zeros(1,size(in,2));
    acc_to        = zeros(1,size(in,2));
    pilot = zeros(size(in,1), length(params.PilotIndex)*params.NDataSymbol);
    out = zeros(size(in,1), length(params.DataSubcarrierIndex)*params.NDataSymbol);
    eq_out = zeros(size(in,1), params.NFFT*params.NDataSymbol);
    %%
    for isym=1:params.NDataSymbol 
        tidx = (isym-1)*params.NFFT +1;
        tidx1= (isym)*params.NFFT +1;
   
        onesymbol      = in( :, (isym -1)*params.NFFT +(1:params.NFFT));
        
        [ onesymbol ]=  SFOComp_1Symbol( onesymbol, timingoffset(1,tidx), params.tpr );

        onesymbol_comp = ChannelComp_1Symbol( onesymbol, H, params);

        [onesymbol_cpr, cpe(1, tidx), cpe_err(1,tidx)] = CPR_1Symbol( onesymbol_comp, acc_cpe(1,tidx), params);

        [onesymbol_spo, timingoffset(1,tidx1), acc_to(1, tidx1) ] = ...
                         SPR_1Symbol( onesymbol_cpr, timingoffset(1,tidx), acc_to(1, tidx), params);
  
        [onesymbol_bcpr, bcpe(1, tidx), cpe_err ]=  BlindCPR_1Symbol( onesymbol_spo, acc_cpe, params );      
        
        pilot( :, (isym-1)*length(params.PilotIndex)+(1:length(params.PilotIndex)))= onesymbol_bcpr(:, ( params.PilotIndex));
        out  ( :, (isym-1)*length(params.DataSubcarrierIndex)+(1:length(params.DataSubcarrierIndex)))= onesymbol_bcpr(:, ( params.DataSubcarrierIndex));
        eq_out  ( :, (isym-1)*params.NFFT+(1:length(params.SubcarrierIndex)))= onesymbol_bcpr(:, ( params.SubcarrierIndex));
   
        acc_cpe(1, tidx1)=  acc_cpe(1, tidx)+ cpe(1, tidx);
        
    end 

     
    %%
    frameout.cprout.phase = cpe;
    frameout.cprout.cpe_blk  = cpe;
    frameout.cprout.acc_error  = cpe_err;
    frameout.tprout.tau = -timingoffset(1:params.NFFT:end) * params.NFFT/ (1+params.CP_ratio)/2/pi ;
    frameout.tprout.phase = -timingoffset(1:params.NFFT:end)* params.NFFT;
    frameout.tprout.acc  = -acc_to(1:params.NFFT:end)* params.NFFT;    
    
end 

function out = ChannelComp_1Symbol( in, H, params)
   out = in ;
   for sc=params.SubcarrierIndex
       out(:, sc) =  H(:, :, sc) * in(:, sc);    
   end
end 

function [out, cpe, cpe_err ]=  CPR_1Symbol( in, acc_cpe, params )

        [cpe, cpe_err] = CPEEst_1Symbol( in,  params);
        if ( params.cpr.en == 1)
            out  = CPEComp_1Symbol( in, cpe, acc_cpe, params.cpr);
        else
            out = in;
        end 
end 


function [out, cpe, cpe_err ]=  BlindCPR_1Symbol( in, acc_cpe, params )

        [cpe, cpe_err] = BlindCPEEst_1Symbol( in(:, params.DataSubcarrierIndex),  params);
         if ( params.cpr.bcpr_en == 1)
            out  = CPEComp_1Symbol( in, cpe, acc_cpe, params.cpr);
         else
             out = in;
         end
end 

function [out, to_out, acc_error ]=  SPR_1Symbol( in, to_in, acc_error, params )
        to  = SFOEst_1Symbol( in,  params); 
        [to_out,  acc_error] = LoopFilter( to_in, to, acc_error, params.tpr);
         out = SFOComp_1Symbol( in, to, params.tpr);    
         
end 

function [cpe, cpe_err ]=  CPEEst_1Symbol( in, params )
    tx_pilot =  params.PilotSym;
    rx_pilot = in(:, params.PilotIndex) ; 
    cpe = angle(mean(mean( (tx_pilot .* rx_pilot) )));
    cpe_err = sqrt(mean(mean(abs(tx_pilot -rx_pilot ) .^2)));  
end 
       
function [out ]= CPEComp_1Symbol( in, cpe,  acc_cpe, params)
    out = in;
    if ( params.en )
        out  =  exp( -1j*1*(cpe)) .* in;
    end  
end 

function [ to ]=  SFOEst_1Symbol( in, params )
    pilot     = in(:,params.PilotIndex );
    pilot_mul =  (  params.PilotSym ).* conj(pilot);
%     PilotIndex = [params.PilotIndex(1:end /2)];
%     PilotIndex=[PilotIndex (-1.* PilotIndex(end:-1:1))];
    PilotIndex = ones(size(in,1),1) * params.PilotIndex ;
    to  = -atan2(sum(sum ( PilotIndex .* imag( pilot_mul))),sum(sum ( PilotIndex.^2 .* real( pilot_mul)))) ;
  % to  = mean(angle(pilot ./params.PilotSymbol) ./ params.PilotIndex); 
end 

function [ out ]=  SFOComp_1Symbol( in, to, params )
    if ( params.en  == 1 || params.en  == 3 )
        out = in .* (ones(size(in,1), 1)* exp(- 1j * to * [(1:params.NFFT/2-1) -params.NFFT/2:0]));
    else
        out = in;
    end
end 

function [tauout,  acc_error] = LoopFilter( tauin, phase_error, acc_error, params)

    %% Loop filter
    tau_error = params.K1  * phase_error + params.K2 * acc_error;

    %% update filter or equalizer coefficient
    tauout = tauin +  tau_error  ;
    
    acc_error = acc_error +  phase_error ;

end
     

function [cpe, cpe_err ]=  BlindCPEEst_1Symbol( in, params )    
    rx_pilot = in ; 
    tx_pilot = in ; 
    for itx=1:params.NTXStream
        for isd=1:params.Nsd
            mapper_t.Nbitspersymbol = params.Nbpsc_sc(itx,isd);
            params.mapper_list         = QAMMapperList (  mapper_t) ;
            tx_pilot(itx,  isd) =   slicer( in(itx,isd),  params);  
        end
    end
    cpe = angle(mean(mean( (rx_pilot ./ tx_pilot) )));
    cpe_err = sqrt(mean(mean(abs(tx_pilot -rx_pilot ) .^2)));  
end 


function [cpe, cpe_err ]=  BlindCPEEst_1Symbol_old( in, params )
    tx_pilot =   slicer( in,  params);    
    rx_pilot = in ; 
    cpe = angle(mean(mean( (rx_pilot ./ tx_pilot) )));
    cpe_err = sqrt(mean(mean(abs(tx_pilot -rx_pilot ) .^2)));  
end 

function out = slicer(in, params)
        distance = abs( ( ones(length(params.mapper_list),1) * in - params.mapper_list * ones(1, length(in)) )) .^2;

        [C, I] = min( distance  );
        out =  transpose(params.mapper_list(I));
end
