function [demapper_out]  =  Bitmetricdecoder( demapper_in,  params, T) 

%  Usage      : [demapper_out]  =  Bitmetricdecoder( demapper_in, params, T) 
%  Function   :
%
%           params.sigma  : standard deviation of each level (real)
%                          standard deviation of each level (imag)
%           params.type_seq : number of transmitted signal for each level
%  Ref : Eq(9) in  Buchali, Fred, et al. "Rate adaptation and reach
%       increase by probabilistically shaped 64-QAM: An experimental demonstration."
%       Journal of Lightwave Technology 34.7 (2016): 1599-1609.         
%
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :

    B_level  = params.B_level; % log2( params.Nbitspersymbol /2 );
    B_bit     = log2(B_level);
    sigmai   = params.sigma;
    zero_idx = zeros(B_bit, B_level/2);
    one_idx  = zeros(B_bit, B_level/2);
    PBi_zero = zeros(1, B_bit);
    PBi_one  = zeros(1, B_bit);
    
%% contant value  
    mapper_out = params.mapper_list;
    mapper_in = zeros( length(mapper_out), params.Nbitspersymbol/params.QAM_factor);    
    for idx=1:length(mapper_out)
        demapperout =  QAMDemapper2(mapper_out(idx), params);  
        [mapper_in(idx, :) ] = demapperout(1,:);
    end
    
    demapper_out0 = zeros(1, size(demapper_in,2) * B_bit);
    PB = params.type_seq / sum(params.type_seq); 
    for idx=1:B_bit
         zero_idx(idx,:) = find( mapper_in( :,idx)== 0 );
         one_idx(idx,:) = find( mapper_in( :,idx)== 1 );
         PBi_zero(idx) = sum(PB(zero_idx(idx,:)));
         PBi_one(idx) = sum(PB(one_idx(idx,:)));  
         demapper_out0(1, idx:B_bit:end ) = log(PBi_zero(idx)) -  log(PBi_one(idx));    
    end
%%    
    demapper_out1 = zeros(1, size(demapper_in,2) * B_bit);
    for isymbol=1:size(demapper_in,2)         
        awgn_prob = ( demapper_in(1, isymbol) - mapper_out )   ./ ( 2* sigmai  ); % Ignore 1/sqrt(2*pi*sigma^2)
        awgn_prob = - awgn_prob.^2 ; 
        awgn_prob = exp(awgn_prob ) ./ sqrt( 2 * pi * sigmai .^2) ;
        for idx=1:B_bit
            zero_prob = sum( awgn_prob(zero_idx(idx,:)) .* PB(zero_idx(idx,:)) )/ PBi_zero(idx)  ;
            one_prob  = sum( awgn_prob(one_idx(idx,:)) .* PB(one_idx(idx,:)) )/ PBi_one(idx)  ;
            demapper_out1(1, (isymbol-1)* B_bit+idx) = log(zero_prob) -  log(one_prob);   
        end
    end
    
    demapper_out = demapper_out0 + demapper_out1;
end
