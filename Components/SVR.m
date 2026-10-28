function esignal_bw =  SVR( osignal,  params)

%  Usage      : esignal =  SVR( osignal,  params)
%  Function   : Stokes Vector Receiver
%     1. Four output      
%        - Pol |X|^2
%        - Pol |Y|^2
%        - Pol 2Re|X Y*|
%        - Pol 2IM|X Y*|
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :

    Xpol =  osignal(1,:);
    
    if ( size(osignal,1) == 1)
        Ypol =  zeros(size(Xpol));
    else
        Ypol =  osignal(2,:);
    end

    esignal(1,:) = abs(Xpol) .^ 2;
    esignal(2,:) = abs(Ypol) .^ 2;
    esignal(3,:) = real(Xpol.*conj(Ypol));
    esignal(4,:) = imag(Xpol.*conj(Ypol));

    %% Add AWGN noise : shot noise in the detector
    if ( params.nonoise == 0  )
        opt2ele_noise = AddNoise( esignal, params.noise_power_dBm);
        esignal = esignal + real(opt2ele_noise)*sqrt(2);
    end

    %% TIA 
    esignal = esignal * db2mag(params.gain_dB);
    
    %% Bandwidth effect
    esignal_bw = ChBandwidth( esignal, params.FilterCoef, params.bandwidth_en);
    
%       [esignal_bw, dc_val] = DCCancel(1, esignal_bw);

end
