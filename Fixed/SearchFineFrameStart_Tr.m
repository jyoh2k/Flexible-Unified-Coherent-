function [ out, fscs ] = SearchFineFrameStart_Tr( in, in1, params)
%  Usage      :  [ out, fscs ] = SearchFineFrameStart( in, params)  
%
%  Function   :
%     1. Search Frame start using cross correlation
%
%  Port  :
%     1. in         : Original signal
%     2. params     : parameter
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
    fscs.MaxPos   = 1;
    fscs.pol_est = 0;
    if ( params.en  == 0 )
        out = in(:, fscs.start_of_frame:end);    
        return;
    end

    if ( params.CFEtype  == 1 )
        out = in ;
        fscs.start_of_frame = 1;
        cor_pattern  = TxUpsample( params.sync_pattern(:,1:50), params.RXoversample, 0 );
        search_range = floor(params.ptn_rep_length * params.RXoversample * 1)   ;  % 
        offset = 0 ;
        search_range1 = params.search_range1;
        search_range2 = search_range1 +size(cor_pattern,2);
    else
        cor_pattern  = TxUpsample( params.sync_pattern(:,1:params.cor_length), params.RXoversample, 0 );
%         cor_pattern  =  params.sync_pattern(:,1:params.cor_length);
%         cor_pattern = reshape([(params.sync_pattern);  zeros(size(params.sync_pattern) );], 1, []); 
%           params.offset =  params.offset -10;
        offset = params.offset  * params.RXoversample;
%         params.search_range = 64;
        search_range1 = offset + 1 -26;
        search_range2 = search_range1 + size(cor_pattern,2) + params.search_range-1;
    end

    out1 = zeros(size(in,1), params.RXoversample * params.NFrameSymbol+100);
    metric_max=zeros(size(in,1)*2,1); 
    
    Msymt = 0;
    if ( params.type == 1)
        for itxstream=1:size(cor_pattern,1)
            for irxstream=1:size(in,1)
                search_idx = 1;
                k2 = 1: length(cor_pattern);
                [P2, R2, Msym, Msym1] = CrossCorr2D( in(irxstream,search_range1:1:search_range2), cor_pattern(itxstream,:), search_idx, k2  );
                [MaxVal(itxstream,irxstream ), MaxPos(itxstream,irxstream )] = max(Msym);
                start_of_frame(itxstream,irxstream )  = ( MaxPos(itxstream,irxstream) - 1 + offset ) * 1 + search_range1;
                Msymt = Msymt + Msym;
            end
        end
    end
    if ( params.type == 0)
        for itxstream=1:size(cor_pattern,1)
            for irxstream=1:size(in,1)
                search_idx = 1;
                k2 = 1: length(cor_pattern);
                [P2, R2, Msym, Msym1] = CrossCorr2D( in(irxstream,search_range1:1:search_range2), cor_pattern(itxstream,:), search_idx, k2  );
                [MaxVal(itxstream,irxstream ), MaxPos1] = max(Msym(1:params.RXoversample:end));
                MaxPos(itxstream,irxstream ) =( MaxPos1 - 1)* params.RXoversample+1  ; 
                start_of_frame(itxstream,irxstream )  = ( MaxPos(itxstream,irxstream) - 1 + offset ) * 1 + search_range1;
                Msymt = Msymt + Msym;
            end
        end
    end
        
    if ( params.type == 2) 
        search_idx = 1;
        k2 = 1: length(cor_pattern);
        [P2, R2, Msym, Msym1] = CrossCorr2D( in(:,search_range1:1:search_range2), cor_pattern(:,:), search_idx, k2  );
        [MaxVal , MaxPos1] = max(Msym(1:params.RXoversample:end));
        MaxPos =( MaxPos1 - 1)* params.RXoversample+1  ; 
        start_of_frame  = ( MaxPos - 1 + offset ) * 1 + search_range1;
         Msymt = Msym;
    end 
     if ( params.type == 3) 
        search_idx = 1;
        k2 = 1: length(cor_pattern);
        [P2, R2, Msym, Msym1] = CrossCorr2D_1bit( in(:,search_range1:1:search_range2), cor_pattern(:,:), search_idx, k2, params  );
        [MaxVal , MaxPos] = max(Msym ); 
        start_of_frame  = ( MaxPos - 1 + offset ) * 1 + search_range1;
         Msymt = Msym;
     end    
     
    [ out, fsfs] =StreamMap( in1, MaxPos, MaxVal, start_of_frame,params );
    fscs.metric   = Msymt;
    fscs.metric1   = Msym1;
    fscs.MaxPos   = fsfs.MaxPos;
    fscs.pol_est   = fsfs.pol_est;
    fscs.start_of_frame =start_of_frame;
    
%     figure;plot(Msymt, 'bs-');
    if ( params.fixed_bit == 2 )  
    end
end
 

function [ out, fsfs] =StreamMap( in, MaxPos, MaxVal, start_of_frame,params )
%  Usage      :  [ fsfs] =StreamMap( MaxPos, MaxVal, fsfs )
%
%  Function   :
 
     idx =params.RXoversample * params.NFrameSymbol+1000;
    if ( size(MaxPos,1) == 1 )
        out1 =  in(:, start_of_frame:end);
        out = out1(:, 1:idx);
        fsfs.MaxPos = MaxPos;
        fsfs.MaxVal = MaxVal;
        fsfs.start_of_frame = start_of_frame;
        fsfs.pol_est = 0;
        return;
    end 
    
    if ( (MaxVal(1,1)+MaxVal(2,2) < MaxVal(1,2) + MaxVal(2,1))) 
        fsfs.MaxPos(1) = MaxPos(1,2);
        fsfs.MaxPos(2) = MaxPos(2,1);
        fsfs.start_of_frame(1) = start_of_frame(1,2);
        fsfs.start_of_frame(2) = start_of_frame(2,1);
        out1 = in(2, fsfs.start_of_frame(1):end);
        out = out1(:,1:idx);
        out1 = - in(1, fsfs.start_of_frame(2):end);
        out(2,:) = out1(:,1:idx);
        rot = 1;
    else
        fsfs.MaxPos(1) = MaxPos(1,1);
        fsfs.MaxPos(2) = MaxPos(2,2);        
        fsfs.start_of_frame(1) = start_of_frame(1,1);
        fsfs.start_of_frame(2) = start_of_frame(2,2);
        out1 = in(1, fsfs.start_of_frame(1):end);
        out = out1(:,1:idx);
        out1 = in(2, fsfs.start_of_frame(2):end);
        out(2,:) = out1(:,1:idx);
        rot = 0;
    end 
    
     fsfs.pol_est = rot ; 

end

function [P2, R2, Msym, Msym1] = CrossCorr2D( in ,cor_pattern, search_idx, k2, params )

%  Usage      : [P2, R2, Msym] = CrossCorr2D( in ,cor_pattern, search_idx, k2   )
%  Function   :
%     1.       
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com  
%  Known bugs :



    InputLength = round( size(in,2));
    CorLen = size(cor_pattern,2);
    EndIdx=InputLength-CorLen; 
    Msym = zeros(1, EndIdx);
    Msym1 = zeros(size(in,1)*size(cor_pattern,1), EndIdx); 
    idx1=1;
     for iTx=1:size(in,1)
         for iRx=1:size(cor_pattern,1)
             [P2, R2, Msym1(idx1,:)] = CrossCorr( in(iTx,:), cor_pattern(iRx,:), search_idx, k2, params);
             Msym = Msym1(idx1,:) + Msym;
             idx1 = idx1 +1 ;
         end
     end
        
end


function [P2, R2, Msym, Msym1] = CrossCorr2D_1bit( in ,cor_pattern, search_idx, k2, params )

%  Usage      : [P2, R2, Msym] = CrossCorr2D( in ,cor_pattern, search_idx, k2   )
%  Function   :
%     1.       
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com  
%  Known bugs :



    InputLength = round( size(in,2));
    CorLen = size(cor_pattern,2);
    EndIdx=InputLength-CorLen; 
    Msym = zeros(1, EndIdx);
    Msym1 = zeros(size(in,1)*size(cor_pattern,1), EndIdx); 
    idx1=1;
     for iTx=1:size(in,1)
         for iRx=1:size(cor_pattern,1)
             [P2, R2, Msym1(idx1,:)] = CrossCorr_1bit( in(iTx,:), cor_pattern(iRx,:), search_idx, k2, params);
             Msym = Msym1(idx1,:) + Msym;
             idx1 = idx1 +1 ;
         end
     end
        
end


function [P2, R2,  CorPwr] = CrossCorr_1bit( in ,cor_pattern, search_idx, k2, params  )


    InputLength = round( size(in,2));
    CorLen = size(cor_pattern,2);
    EndIdx=InputLength-CorLen;
    P1 = zeros(1,EndIdx);    
    
    in_1bit          = (imag(in) < 0)* 1j + (real(in) < 0);
    cor_pattern_1bit = (imag(cor_pattern) < 0)* 1j + (real(cor_pattern) < 0);
    cor_pattern_1bit = ones(size(in_1bit, 1),1) * cor_pattern_1bit;

    for d = search_idx:EndIdx
            tmpr =  (xor( imag(in_1bit(:, d-1+k2)), imag(cor_pattern_1bit))) + (xor( real(in_1bit(:, d-1+k2)), real(cor_pattern_1bit)));
            tmpi = not(xor( real(in_1bit(:, d-1+k2)), imag(cor_pattern_1bit))) + (xor( imag(in_1bit(:, d-1+k2)), real(cor_pattern_1bit)));
            tmpr = tmpr(1:2:end);
            tmpi = tmpi(1:2:end);
            tmp = complex( tmpr, tmpi);
            P1(d) =sum( sum( tmp));
    end  

    P1 = fie_c( P1, params.T.P1); 
    P2 = P1 - size(in,1)*length(cor_pattern)/2*(1+1j); 
    P2 = fie_c( P2, params.T.P2); 
    CorPwr = P2 .* conj (P2);
    CorPwr = fie_r( CorPwr, params.T.XCorpwr);
    R2 = P2;

    if ( params.fixed_bit == 2 ) 
    end
end

function [P2, R2, Msym] = CrossCorr( in ,cor_pattern, search_idx, k2, params )

%  Usage      : [P2, R2, Msym] = CrossCorr( in ,cor_pattern, search_idx, k2   )
%  Function   :
%     1.       
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com  
%  Known bugs :
    InputLength = round( size(in,2));
    CorLen = size(cor_pattern,2);
    EndIdx=InputLength-CorLen;
    P2 = zeros(1,EndIdx);
    R2 = P2;   
%     cor_pattern = fie_c(cor_pattern, params.T.Cor);
    in = fie_c(in, params.T.In);
    for d = search_idx:EndIdx
        P2(d) = sum(abs(sum(real( cor_pattern .* conj(in(:,d-1+k2))),2))+ ... 
                abs(sum(imag( cor_pattern .* conj(in(:,d-1+k2))),2))) ;
        R2(d) = sum(sum(abs(in(:,d+k2)) .^2 ));             
    end   
    Msym =  (abs( P2 ) .^2) ./  (R2 .^2) ;   
        
end
