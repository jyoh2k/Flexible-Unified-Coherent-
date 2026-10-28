function [NGMI, GMI]  =  Calculate_NGMI( in, transmitted, params, T) 

%  Usage      : [params]  =  Calculate_NGMI( in, txsignal,  params, T) 
%  Function   :  Calculate normalized generalized mutual information
%
%  Ref : Eq.(1) and (6) in Cho, Junho, Laurent Schmalen, and Peter J. Winzer. 
%  "Normalized generalized mutual information as a forward error correction 
%   threshold for probabilistically shaped QAM." 2017 European Conference on
%   Optical Communication (ECOC). IEEE, 2017. 
%   Eq (1) GMI = entropy + channel noise impact
%
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs

    if ( isreal(transmitted)  )
        params.type_seqi  = real(params.type_seq) ;
        [GMI, entropy] = Calculate_GMI_sub( real(in), real(transmitted), params) ;
        B_bit = log2(length(real(params.type_seq)));    
        NGMI =  1 - ( entropy - GMI ) /B_bit   ;
         
    else
        params.type_seqi  = real(params.type_seq) ;
        [GMI_real, entropy_real] = Calculate_GMI_sub( real(in), real(transmitted), params) ;

        params.type_seqi  = imag(params.type_seq) ;
        [GMI_imag, entropy_imag] = Calculate_GMI_sub( imag( in), imag(transmitted), params) ;
        B_bit = log2(length(real(params.type_seq))+length(real(params.type_seq)));    
        NGMI =  1 - ( entropy_real - GMI_real ) /B_bit - ( entropy_imag - GMI_imag ) /B_bit ;
        GMI = GMI_real + GMI_imag;
    end 
end

 function [GMI, entropy]  =  Calculate_GMI_sub( in, transmitted, params) 

%  Usage      : [params]  =  Calculate_NGMI( in, txsignal,  params, T) 
%  Function   :  Calculate normalized generalized mutual information
%
%  Ref : Eq.(1) and (6) in Cho, Junho, Laurent Schmalen, and Peter J. Winzer. 
%  "Normalized generalized mutual information as a forward error correction 
%   threshold for probabilistically shaped QAM." 2017 European Conference on
%   Optical Communication (ECOC). IEEE, 2017. 
%   Eq (1) GMI = entropy + channel noise impact
%
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs


    PB = params.type_seqi / sum(params.type_seqi); 
    B_level  = length(PB);%params.level; % log2( params.Nbitspersymbol /2 );
    params.B_level = B_level; 
    B_bit     = log2(B_level); 
    zero_idx = zeros(B_bit, B_level/2);
    one_idx  = zeros(B_bit, B_level/2);
    PBi_zero = zeros(1, B_bit+1);
    PBi_one  = zeros(1, B_bit+1);        
    N          = size( in, 2);    
    mapper_out = params.mapper_list;
    mapper_in = zeros( length(mapper_out), params.Nbitspersymbol/params.QAM_factor);   
    %%   
    for idx=1:length(mapper_out)
        mapper_in(idx, :) =  QAMDemapper2(mapper_out(idx), params);  
    end 
    %% contant value 
    PB = params.type_seqi / sum(params.type_seqi); 
    for idx=1:B_bit
         zero_idx(idx,:) = find( mapper_in( :,idx)== 0 );
         one_idx(idx,:) = find( mapper_in( :,idx)== 1 );
         PBi_zero(idx) = sum(PB(zero_idx(idx,:)));
         PBi_one(idx) = sum(PB(one_idx(idx,:)));  
    end
 
    
    %% GMI calculation  (Real)
    
    params  =  Calculate_Sigma( in,  transmitted, params);  
    sigmai    = params.sigmai;
%     sigmai    = sigmai * sqrt(2);
    inreal = real(in);
    transmittedreal = real(transmitted);
    GMI_bit = zeros(1, size(in,2) * B_bit);
%     for isymbol=1:size(in,2) 
%         x = QAMDemapper2(transmittedreal(isymbol),  params, 0);
%         for idx=1:B_bit
%             
%             awgn_prob = ( inreal(1, isymbol) - mapper_out )   ./ (  sigmai    ); % Ignore 1/sqrt(2*pi*sigma^2)
%             awgn_prob = - 0.5 * awgn_prob.^2 ; 
%             awgn_prob = exp(awgn_prob) ./ sqrt( 2 * pi * sigmai .^2) ;
%             
%             zero_prob = sum( awgn_prob(zero_idx(idx,:)) .* PB(zero_idx(idx,:)) )   ;
%             one_prob  = sum( awgn_prob(one_idx(idx,:)) .* PB(one_idx(idx,:)) )   ;
%             if ( x(idx) == 0 )
%                 GMI_bit(1, (isymbol-1)* B_bit+idx) = sum(zero_prob)/sum(zero_prob+one_prob);   
%             else
%                 GMI_bit(1, (isymbol-1)* B_bit+idx) = sum(one_prob)/sum(zero_prob+one_prob);   
%             end            
%         end
%     end
%     
    
        x = QAMDemapper2(transpose(transmittedreal),  params);
        
        sigmai_prl =  transpose(ones(size(inreal,2),1) * sigmai);
        dist = ones(size(mapper_out,2),1)* inreal  - transpose(ones(size(inreal,2),1) * mapper_out);
        awgn_prob = ( dist)   ./ (  sigmai_prl ); % Ignore 1/sqrt(2*pi*sigma^2)
        awgn_prob = - 0.5 * awgn_prob.^2 ; 
        awgn_prob = exp(awgn_prob) ./ sqrt( 2 * pi * sigmai_prl .^2) ;
            
    for idx=1:B_bit
            zero_prob = sum((awgn_prob(zero_idx(idx,:), :) .* transpose(ones(size(inreal,2),1) *PB(zero_idx(idx,:)) )),1) ;
            one_prob  = sum((awgn_prob( one_idx(idx,:), :) .* transpose(ones(size(inreal,2),1) *PB( one_idx(idx,:)) )),1)  ;
            one_symbol_idx = find (x(:, idx)  == 1 );
            zero_symbol_idx = find (x(:, idx)  == 0 );
            prob_sum = zero_prob+one_prob;
            GMI_bit(1, (zero_symbol_idx-1)* B_bit+idx) = zero_prob(1,zero_symbol_idx) ./prob_sum(1,zero_symbol_idx);  
            GMI_bit(1, (one_symbol_idx-1)* B_bit+idx) = one_prob(1,one_symbol_idx) ./prob_sum(1,one_symbol_idx);  
    end
    
    GMI_bit = log2(GMI_bit);
%%     GMI = entropy + channel noise impact
    PB = PB(find(PB ~=0));
    entropy = - sum(PB .* log2(PB)) ;
    GMI =  entropy + real(1/N * sum(GMI_bit));
    NGMI = 1 - (  entropy - GMI )/log2(B_level) ; % Real only -> Imaginary part should be added.
    
    
end