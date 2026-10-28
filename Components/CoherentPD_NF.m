function esignal_bw =  CoherentPD_NF( osignal,  params)

%  Usage      : esignal =  CoherentPD_NF( osignal,  params)
%  Function   :
%     1.       
%  Reponsivity = quantum_efficiency * electon_charge / ( h_Plank * freq )
%              ~ quantum_efficiency * lambda (um unit)/ 1.23985 
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :

%     %% PD 
%     if ( params.passband  == 1  )
%         current = (params.responsivity  * abs(osignal).^2 );
%     else
%         current = (params.responsivity  * real(osignal).^2 );
%         current = current + 1j *(params.responsivity  * imag(osignal).^2 );
%     end
%     current_sat = min( params.max_current, real(current));
%     current_sat = current_sat + 1j * min( params.max_current, imag(current));
%     esignal = params.resistor * ( current_sat );
    
    esignal = osignal;


    %% TIA 
    esignal = esignal * db2mag(params.gain_dB);
    
    %% Bandwidth effect
    esignal_bw = ChBandwidth( esignal, params.FilterCoef, params.bandwidth_en);
    
   %% Add AWGN noise : shot noise in the detector
    if ( params.nonoise == 0  )
        mW =1e-3;
        if ( params.bandwidth_en ==  1)
            BW                = params.bandwidth ;
        else
            BW                = params.SampleFreq ;
        end
        noise_density_dBm = params.NF_dB + (-174  + 10 * log10(BW) + params.gain_dB);
        noise_density     = 10^(noise_density_dBm/10) * mW; 
        opt2ele_noise             = sqrt( noise_density )*randn(size(esignal_bw)) ; 
        if ( params.passband  == 0  )
            esignal_bw = esignal_bw + (opt2ele_noise) ;
        else
            esignal_bw = esignal_bw + real(opt2ele_noise)*sqrt(2);
        end
    end
end
