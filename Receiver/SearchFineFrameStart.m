function [ out, fscs ] = SearchFineFrameStart( in, params)
%  Usage      :  [ out, fscs ] = SearchFineFrameStart( in, params )  
%
%  Function   :
%     1. Search Frame start using cross correlation
%
%  Port  :
%     1. in         : Original signal
%     2. params     : parameter
%     3. T          : Reserved for fixed sim.
%     4. out        : Recovered signal
%     5. fscs       : Synchronization results (For debugging use)
%
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :


    out                   = in;
    fscs.phaseoffset      = 0;
    fscs.start_of_frame   = params.start_of_frame;
    fscs.metric   = 1;
    fscs.MaxPos   = params.MaxPos;
    fscs.pol_est = 0;
    if ( params.en  == 0 )         
        out = in(:, fscs.start_of_frame:end);    
        idx = min( params.RXoversample * params.NFrameSymbol+100, size(out, 2)); % 100 Margin 
        out = out (:, 1:idx);
        return;
    end

    if ( params.CFEtype  == 1 ) 
        fscs.start_of_frame = 1;
        cor_pattern  = TxUpsample( params.sync_pattern, params.RXoversample, 0 );
        search_range = floor(params.ptn_rep_length * params.RXoversample * 1)   ;  % 
        search_range = params.search_range;
        offset = 0 ;
        search_range1 = params.search_range1;
    else
        cor_pattern  = TxUpsample( params.sync_pattern, params.RXoversample, 0 );
%         cor_pattern = reshape([(params.sync_pattern);  zeros(size(params.sync_pattern) );], 1, []);
        search_range =  1500 * params.RXoversample;
        search_range1 = 32 + 120;
        offset = length(cor_pattern);
    end
 
    
    search_idx = 1;
    k2 = 1: length(cor_pattern);
    [P2, R2, Msym, Msym1] = CrossCorr2D( in(:,search_range1:1:search_range+length(cor_pattern)), cor_pattern, search_idx, k2  );
    [MaxVal, MaxPos] = max(Msym);
	start_of_frame = ( MaxPos - 1 + offset ) * 1 + search_range1;
    in2 = [zeros(size(in,1), params.offset) in];
    out = in2 (:, start_of_frame:end);    
    idx = min( params.RXoversample * params.NFrameSymbol+100, size(out, 2)); % 100 Margin    
    out = out (:, 1:idx);
    fscs.start_of_frame = start_of_frame;
    fscs.MaxPos = MaxPos;
    fscs.metric   = Msym;
    fscs.metric1   = Msym1;
    fscs.metric_max   = Msym1;
    

    [out , fscs] =StreamMap( out, fscs,  params, '' );
 
%     [ out,  cpe ] =PhaseInit( in, out,  Msym, MaxPos, search_range1,  params );
   

 
end

function [ out,  cpe ] =PhaseInit( in, out,  Msym, MaxPos, search_range1,  params, T )
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

    if ( params.CFEtype  ~= 1 )    
        cor_pattern1     = (params.sync_pattern)  ;
        start_of_frame = ( MaxPos -1 ) * 1 + search_range1 ;
        second_tr = in(:, start_of_frame:params.RXoversample:start_of_frame +(length(cor_pattern1) * params.RXoversample-1));
    else
        cor_pattern1     = (params.sync_pattern(:,1:32))  ;
        second_tr =  out(:, 1:params.RXoversample:params.RXoversample*32);
    end
    phase_off = second_tr .* conj ( cor_pattern1);
    cpe = mean(unwrap(angle(phase_off))); 

    phase_off = second_tr ./ cor_pattern1 ;
    phase_off1 = sum(sum(phase_off));
    cpe = atan2( imag(phase_off1), real(phase_off1));
    out = out *  exp ( -1j * cpe );
end


