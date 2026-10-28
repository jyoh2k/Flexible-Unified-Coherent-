function [ out, fscs ] = SearchFrameStart( in, params )

% if ( params.cfr.CFEtype  == 1 )
%     out = in ;
%     fscs.start_of_frame = 1;
%     return;
% end;
    fscs.start_of_frame = params.start_of_frame;
    fscs.MaxPos         = params.MaxPos;
    fscs.metric         = zeros(1, 1000);
    fscs.phaseoffset    = 0 ;
    out = in (:, 1+size(fscs.start_of_frame,2):end);

    if ( params.en  == 0 )
        return;
    end


if ( size(params.frame_header,1) ~= 0  )
    cor_pattern         = ones(size(in,1),1)*params.frame_header  ;
    search_range        = floor(params.frame_length * 1.3);
    k2                  = 1: size(cor_pattern,2);
    in1                 = in(:, 1:params.RXoversample:end);

    [P2, R2, Msym]      = CrossCorr( in1(:,1:search_range), cor_pattern, 1, k2  );
    Msym =  (abs( P2 ) .^2) ;
    [MaxVal, MaxPos]    = max(Msym);
    start_of_frame      = (MaxPos - 1+ length(cor_pattern)) * params.RXoversample  + 1 - 5 ; % Margin
    out                 = in(:, start_of_frame:end);

    fscs.start_of_frame = start_of_frame;
    fscs.MaxPos         = MaxPos ;
    fscs.metric         = Msym;
    return;
end 
if ( params.CFEtype  == 1 )
        cor_pattern =  reshape([(params.sync_pattern(1:100));  zeros(1,100 );], 1, []);
        cor_pattern  = TxUpsample( params.sync_pattern(:, 1:70), params.RXoversample, 0 );
        search_range = floor(params.ptn_rep_length * params.RXoversample   )  +15;   
        endidx = min(size(in,2),search_range);
        search_range1 = params.search_offset;
        fscs.phaseoffset =0 ;
%         search_range1 = 400;     
        search_idx = 1;
        k2 = 1: length(cor_pattern);
        [P2, R2, Msym] = CrossCorr2D( in(:,search_range1:1:endidx), cor_pattern, search_idx, k2  );         
        [MaxVal, MaxPos] = max(Msym);
        start_of_frame = ( MaxPos - 1 + params.offset ) * 1  + search_range1;
        out = in (:, start_of_frame:end);
        fscs.start_of_frame = start_of_frame+1;
        fscs.MaxPos = MaxPos  ;
        fscs.metric   = Msym;
    return;
end

if ( params.CFEtype  == 5 )
    CorLen     = size(params.sync_pattern,2)  ;
    Interval   = CorLen;
    search_idx = 1; search_end = min(round(params.frame_length*params.RXoversample+1000), size(in,2));
    [P1, R1, Msym, R2] = AutoCorr_1bit( in(:,1:params.RXoversample:search_end) ,search_idx, CorLen, Interval, params  );
    Msym =abs(P1) .^2;
    Msym = fie_r( Msym, params.T.Msym);
    [MaxVal, MaxPos] = max(Msym); 
%      MaxPoses = find(Msym > 10000); 
%      MaxPos = MaxPoses(1);
%      MaxVal = Msym(MaxPos);
    start_of_frame = ( MaxPos - 1 ) * params.RXoversample + 1;
%     disp(['start_of_frame full MaxVal ', num2str(start_of_frame), ',  ', num2str(MaxVal)]); 
    out = in ( :,start_of_frame:end);
    fscs.start_of_frame = MaxPos;
    fscs.MaxPos         = MaxPos ;
    fscs.metric = Msym;
    
end
    
    if ( params.fixed_bit == 2 ) 
    end
end


function [P1, R1, Msym, R2] = AutoCorr_1bit( in ,search_idx, CorLen, Interval,params )

%  Usage      : [P1, R1, Msym, R2] = AutoCorr_1bit( in ,search_idx, CorLen, Interval  )
%  Function   :
%     1.       
%  Author     : Rha, Hae Young.
%  Contact    : miroandi@kaist.ac.kr   
%  Known bugs :


        
        k = (1:CorLen)-1;
        InputLength = round( size(in,2)); 
        EndIdx=InputLength-CorLen;
        
                 
        
        in1           = in(:,search_idx :EndIdx+CorLen);
        in2          = (real(in1) < 0);
        in2          = (imag(in1) < 0)* 1j + in2;
        in_prev = in2(:, 1:end-Interval);
        in_cur  = in2(:, Interval+1:end);
       
        mulr =  (xor( imag(in_prev), imag(in_cur))) + (xor( real(in_prev), real(in_cur)));
        muli = not(xor( real(in_prev), imag(in_cur))) + (xor( imag(in_prev), real(in_cur)));
%         tmp = complex( tmpr, tmpi);
        P1_real = zeros(1, EndIdx- Interval) ;
        P1_imag = zeros(1, EndIdx- Interval);
        for isample= 1 :(EndIdx - Interval)
            P1_real(isample) = (sum( sum( mulr(:,isample+k))) );
            P1_imag(isample) = (sum( sum( muli(:,isample+k))) );
        end

        P1_real = fie_r( P1_real, params.T.Cor);
        P1_imag = fie_r( P1_imag, params.T.Cor);
        P1 = ( P1_real -size(in2,1)*length(k)) + 1j * ( P1_imag -size(in2,1)*length(k)); 
        P1 = fie_c( P1, params.T.P1);
 
        R1 =   1 ;   
        Msym =  (abs( P1 ) .^2)   ;   
        R2 =   (abs( in) .^2 );   
        Msym = fie_r( Msym, params.T.Msym);

        if ( params.fixed_bit == 2 ) 
        end
end