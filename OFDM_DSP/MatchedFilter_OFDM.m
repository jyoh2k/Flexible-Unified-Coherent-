function [ out  ]=  MatchedFilter_OFDM( in, params )

%  Usage      : [ out  ]=  MatchedFilter( in, params )
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
%% Matched filter 
    out       = TxUpsample( in, 2, 0 ); 
    if ( params.en == 0 )        
         return ;
    end

    if ( params.en == 1 )     % SRRC 
        params.time_resp = rcosdesign( params.alpha, params.span, params.sps,'sqrt');
    end      % RC
    if ( params.en == 2 )     % RC
        params.time_resp = rcosdesign( params.alpha, params.span, params.sps,'normal');  
    end 
    if ( params.en == 3 )     % Hanning
%         b =  params.time_resp;  
    end 
%     params.time_resp =b;
    for idim=1:size(in,1)
        out_filter  = upfirdn(in(idim,:), params.time_resp, params.p, params.q );
        txout_filter_1=  out_filter( (length(params.time_resp)-1)/(params.p *2 ) + ( 1:length(in)*2));
        out(idim,:) = txout_filter_1  * params.p / 2 ;
    end
end