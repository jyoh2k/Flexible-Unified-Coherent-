function [ out , FilterCoef ]=  LPF( in, params )

%  Usage      : [ out  ]=  LPF( in, params )
%
%  Function   :
%     1. out :output 
%     2. in : input 
%     3. params : parameters
%
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :
%
%%  filter 


%the Chebyshev optimizes the roll-off, 
%the Butterworth optimizes the passband flatness, 
%the Bessel optimizes the step response.

    out = in ;

    if ( params.en == 0 )
        return;
    end

    GHz =1e9;
    NBandwidth = params.CutoffFreq /params.SampleFreq  ;
    if ( NBandwidth > 0.49)
        error(['LPF cutoff frequency ' num2str(params.CutoffFreq /GHz) 'GHz can not be larger than' num2str(params.SampleFreq /2/GHz) ' GHz. ']);
    end 
    FilterTapNum =25;
    switch params.en
       case 1
        Fs = 100*1e9;                           % Sampling Frequency
        BW = NBandwidth * Fs * 10;
        [b,a] = besself(FilterTapNum,BW);          % Bessel analog filter design
        [b1,a1] = bilinear(b, a,Fs);
        FilterCoef.b = b1;
        FilterCoef.a = a1;
       case 2
        [FilterCoef.b,FilterCoef.a]= butter(FilterTapNum,  NBandwidth * 2, 'low');
       case 3 
        [FilterCoef.b,FilterCoef.a]  = cheby2(FilterTapNum,100,NBandwidth * 2,'low'); 
        case 4            
            Fs = params.SampleFreq; 
            F2 = (params.CutoffFreq  + 0.02 * params.SampleFreq)  ;
            F1 = (params.CutoffFreq   - 0.02 * params.SampleFreq)  ;
            Hd = fdesign.lowpass('Fp,Fst,Ap,Ast',F1,F2,1,60,Fs);
            d = design(Hd,'equiripple'); 
            FilterCoef =d;
       otherwise 
    end
% fvtool
% fdatool
if ( params.en < 4 ) 
        for jj=1:size(in,1)
            inr =  [ real(in(jj,:)) ];
            ini =  [ imag(in(jj,:)) ];
            filteroutr = filter(  FilterCoef.b,  FilterCoef.a, inr );
            filterouti = filter(  FilterCoef.b,  FilterCoef.a, ini );
            out(jj,:) = complex( filteroutr, filterouti);
        end
else
        for jj=1:size(in,1)
            inr =  [ real(in(jj,:)) ];
            ini =  [ imag(in(jj,:)) ];
            filteroutr = filter(  d, inr );
            filterouti = filter(  d, ini );
            out(jj,:) = complex( filteroutr, filterouti);
        end
end




end
