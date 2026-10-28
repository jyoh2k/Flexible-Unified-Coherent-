function [out, phase] = Derot( en, in, txsignal, params  )



    head =params.NTrainingSymbol-100 ; 
    out = in ;
    if ( en == 0 | head < 0   )
        phase = zeros(size(in,1),1);
        return;
    end
    for ichannel=1:size(in,1)
        signal    = in(ichannel, head+1:head+100);
        ideal_tx  = txsignal.mapper2(ichannel , head+1:head+100);
        phase_dif = signal ./ ideal_tx;
        phase_sum = sum( phase_dif );
        rot_phase  = atan2(imag( phase_sum ), real( phase_sum));
%         figure; plot(unwrap(atan2( imag(phase_dif), real(phase_dif))));
        rot_phase = rot_phase + pi * 2;
        unit1 = pi/2;
        phase(ichannel) = floor(rot_phase / unit1 + 0.5) * unit1 ;  
        out(ichannel,:) = in(ichannel,:) * exp ( -1j * phase(ichannel) );
    end
    
    if ( en == 2 )
        signal    = out(:, head+1:head+100);
        ideal_tx  = txsignal.mapper2(: , head+1:head+100);
        rot0 = sum(real(signal(1,:)) .* real(ideal_tx(1,:)) +  real(signal(2,:)) .* real(ideal_tx(2,:)) ) + ...
            sum(imag(signal(1,:)) .* imag(ideal_tx(1,:)) +  imag(signal(2,:)) .* imag(ideal_tx(2,:)) ) ; 
        rot1 = sum(real(signal(1,:)) .* real(ideal_tx(2,:)) +  real(signal(2,:)) .* real(ideal_tx(1,:)) ) + ...
            sum(imag(signal(1,:)) .* imag(ideal_tx(2,:)) +  imag(signal(2,:)) .* imag(ideal_tx(1,:)) ) ; 
        if (rot1 > rot0  )
            out1 =out;
            out(2,:) = out1(1,:);
            out(1,:) = out1(2,:);
        end 
    end 
    
    if ( en ==3 )        
        signal    = in(:, head+1:head+100);
        ideal_tx  = txsignal.mapper2(: , head+1:head+100);
        [ out,  phase ] = get_derot1(in, signal, ideal_tx, 0);
        signal1   = out(:, head+1:head+100); 
        rot0 = sum(real(signal1(1,:)) .* real(ideal_tx(1,:)) +  real(signal1(2,:)) .* real(ideal_tx(2,:)) ) + ...
                    sum(imag(signal1(1,:)) .* imag(ideal_tx(1,:)) +  imag(signal1(2,:)) .* imag(ideal_tx(2,:)) ) ; 
        [ out2,  phase ] = get_derot1(in, signal, ideal_tx, 1);
        signal1   = out2(:, head+1:head+100); 
        rot1 = sum(real(signal1(1,:)) .* real(ideal_tx(2,:)) +  real(signal1(2,:)) .* real(ideal_tx(1,:)) ) + ...
                    sum(imag(signal1(1,:)) .* imag(ideal_tx(2,:)) +  imag(signal1(2,:)) .* imag(ideal_tx(1,:)) ) ; 
        if (rot1 > rot0  )
            out = [out2(2,:); out2(1,:);];
        end 
    end
      
end 

function [ out, phase ] = get_derot1(in, signal, ideal_tx, ch_switch)
     out  = in;
     if ( ch_switch == 1)
         ideal_tx = [ideal_tx(2,:); ideal_tx(1,:);];
     end 
     for ichannel=1:size(signal,1) 
        phase_dif = signal(ichannel,:)./ ideal_tx( ichannel,:) ;
        phase_sum = sum( phase_dif );
        rot_phase  = atan2(imag( phase_sum ), real( phase_sum)); 
        rot_phase = rot_phase + pi * 2;
        unit1 = pi/2;
        phase(ichannel) = floor(rot_phase / unit1 + 0.5) * unit1 ;
        out(ichannel,:) = in(ichannel,:) * exp ( -1j * phase(ichannel) ); 
     end 
end 