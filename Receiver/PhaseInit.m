
function [ out,  cpe ] =PhaseInit( in,  trainingseq,  params, T )
%  Usage      :   [ out,  phase_est ] = PhaseInit( in, params, T )
%
%  Function   :
%     1.  To speed up convergence of data-aided equalization  
%     2.  Initial phase rotation should be compensated anyway.
%
%  Port  :
%     1. in         : Original signal
%     2. params     : parameter
%     3. T          : Reserved for fixed sim.
%     4. out        : Derotated signal
%     5. phase_est       : Estimated phase rotation 
%
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :


    [d1, d2] = size( in); 
    OV         =  params.OV;
    out        =  in;
    cpe        = 0;
   
    if ( params.en == 0 )
        return
    end
    
     if ( params.NTrainingSymbol < 40 )
        return
    end
      
    

    offset = (params.NTrainingSymbol - 20) ;
    
   
    IN1 = in(:,( offset)*OV+(1:OV:40));
    IN2 = trainingseq(:,  offset +(1:20));
    
   
    phase_off = IN1 .* conj ( IN2);
    cpe = mean(mean(unwrap(angle(phase_off)))); 

    phase_off = IN1 ./ IN2 ;
    phase_off1 = sum(sum(phase_off));
    cpe = atan2( imag(phase_off1), real(phase_off1));
    out = out *  exp ( -1j * cpe );
end
