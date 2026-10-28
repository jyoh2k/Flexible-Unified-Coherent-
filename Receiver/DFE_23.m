function [AOUT, dfeout, decided, coef1, coefp1, Rinv] = ...
     DFE_23(AIN, DIN1, is_training_seq, filtertap_update, prev_decided, coef, coefp, Rinv, params) 
 
%  Usage      : [AOUT, dfeout, coef, coefp] = DFE_23(  AIN, DIN1, is_training_seq,
%                                filtertap_update, prev_decided, coef, coefp, params)
%  Function   :
%     Decision feedback equalizer ( Decision directed FFE included)
%     2023 vesion
%
%  Port       :
%     1. AIN  :
%     2. DIN1  : Training seq.
%     3. is_training_seq  :
%     4. filtertap_update  :
%     5. prev_decided  :
%     6. coef  :
%     7. coefp :
%     8. param :
%     9. T :
%
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :
%
%  Equalization index
%  sidx = (is - 1 )* NStream + os ; % equation index 
%  For example, input stream : 3 , output stream:2  
%  sidx = 3: is = 2, os = 1 
% 

    %% Initialization
    PRL         = params.PRL;
    block_size  = params.block_size;
    OV          = params.OV;
    NStream     = params.NStream;
    T           = params.T;
    IStream     = size(AIN,1);
   
    ck          = complex( coef(:,1:params.Nffe));
    dk          = complex( coef(:,params.Nffe+1:params.Nffe+params.Nfbe));
    p           = complex( coef(:,params.Nffe+params.Nfbe+1:end));
    ckp         = complex( coefp(:,1:params.Nffe));
    dkp         = complex( coefp(:,params.Nffe+1:params.Nffe+params.Nfbe));
    pp          = complex( coefp(:,params.Nffe+params.Nfbe+1:end));
    ffe         = complex( zeros(params.NStream, PRL) );
    ffe1        = complex( zeros(params.NStream, PRL) );
    decided     = complex( zeros(params.NStream, PRL/OV)) ;
    equalized   = complex( zeros(params.NStream, PRL/OV));
    DIN         = [prev_decided(:,end) DIN1 ];
    
    coef1 = complex( zeros(size(coef)));
    coefp1 = complex( zeros(size(coef)));
    Rinv = complex(Rinv);
    %% Feedforware filter
    for os=1:params.NStream 
        for idx=1:PRL 
            ffe_mul = sum(AIN(:,idx:idx+params.Nffe -1) .* ck(os:NStream:end, :),2);
            ffe1(os, idx) = sum( ffe_mul ) ;        
        end
    end
    
    %% Feedback filter
    ak =complex( [prev_decided(:, end:-1:end-size(dk,2)+1) ]);
    fbe = complex(zeros(params.NStream, PRL/OV));
    is_block_start =  zeros(1, PRL/OV);
    if ( params.en_block_termination == 1 )      
        is_block_start = double( mod([1:PRL/OV], block_size) == 1);
    end
    if ( params.en_block_termination == 2 )      
        is_block_start = double( mod([1:PRL/OV], block_size) == 0);
    end

    [ffe, pilot_ang] = cpe ( ffe1, DIN1, is_training_seq, params  );
    [ffe]            = cpr ( ffe, p, params);

    for idx=1:PRL/OV 
        for os=1:params.NStream 
            if ( is_block_start(idx) == 1 )
                ak(:,1) = DIN(os,idx);
            end
            ak2 = ak;
            if( params.skewcomp_en == 2 )
                ak2 = [ak; conj(ak)];
            end
            fbe(os, idx) = sum(sum(ak2 .* dk(os:NStream:end,:)));  
            
            equalized(os,idx) = ffe(os, (idx-1)*OV+1)+fbe(os,idx);            
            [dec]= slicer( equalized(os,idx), DIN(os,idx+1),is_training_seq,idx,params);
            decided(os,idx) = dec ;
        end
        
        
        ak =[ decided(:,idx) ak(:,1: params.Nfbe -1)];
    end



     [errorcksum, errordksum, errorpsum,  error, Rinv]= ...
       FilterAlgorithm ( AIN, prev_decided, decided, equalized, Rinv, ck, dk, p, params);

     [cko, dko, po] = CoefUpdate( filtertap_update, ckp, dkp, pp, errorcksum, errordksum, errorpsum, params);
    
% dko(:, 2) =0;
    %% For debugging
    if ( sum(sum(abs(cko))) < 200  )
        coef1  = complex( [cko dko po]);
        coefp1 = complex([cko dko po]);
    else
        coef1 = coef;
        coefp1 = coefp;
    end

    dfeout.ffeout = ffe;
    
    AOUT = ffe ;
    AOUT(:, 1:OV:end) = equalized;
    dfeout.decided = decided;
    dfeout.ffe_error = sum(errorcksum, 2);
    dfeout.error = sum(error, 2);
    dfeout.pilot_ang = pilot_ang;
end


function [out, pilot_angle] = cpe ( in, din, is_training_seq, params  )
    if (  params.type ~= 6  ) %  is_training_seq
        out = in;
        pilot_angle = zeros(size(in));
        return 
    end        

    if ( params.en_block_termination == 1 )
        is_block_end = find( mod([1:size(din,2)], params.block_size) == 0);
    end
    if ( params.en_block_termination == 2 )
        is_block_end = find( mod([1:size(din,2)], params.block_size) == 1);
    end
    pilot_ang = in(:,(is_block_end -1 )*params.OV +1) .* conj (din(:,is_block_end));
    pilot_ang = mean(mean(pilot_ang,1));
    pilot_ang = atan2(imag( pilot_ang ), real( pilot_ang));
    pilot_angle =  reshape( ones( size(in,2), 1 )  * pilot_ang, 1, size(in,2));
    pilot_angle = ones(size(in,1),1) * pilot_angle;
    out = in;
end

function [out ] = cpr ( in, phase, params  )
    if (  params.type ~= 7  ) %  is_training_seq
        out = in;
        return
    end

    phase_rotation = ones(size(in)) * phase(1);
    out = in .* phase(1);
end


function [dec] = slicer ( in, din, is_training_seq, symbol_idx, params  )
    if ( params.no_slicer == 1 )
        dec =  params.mapper_list(1);
        return;
    end
    if ( is_training_seq == 1 )
        dec = din;
        return;
    end

    is_block_end = 0;
    if ( params.en_block_termination == 1 )
        is_block_end = double(mod(symbol_idx, params.block_size) == 0);
    end
    if ( params.en_block_termination == 2 )
        is_block_end = double(mod(symbol_idx, params.block_size) == 1);
    end
    if (is_block_end == 1 )
        dec = din;
    else
        if ( params.type == 4 )
            distance = abs(abs( in) -  abs(params.mapper_list ));
            [C, I] = min( distance  );
            dec =  params.mapper_list(I);
        else
            distance = abs( in -  params.mapper_list        ).^2;
            [C, I] = min( distance  );
            dec =  params.mapper_list(I);
        end
    end
end

function [cko, dko, po ] = CoefUpdate( filtertap_update, ckp, dkp, pp, errorcksum, errordksum, errorpsum, params) 
    if ( filtertap_update )   
        po  = pp      - params.betap*errorpsum  ;
        po = po ./ abs(po);
        switch params.update_type
            case 1
                cko = ckp     - params.betaf*errorcksum ; 
                dko = dkp     - params.betab*errordksum ;
            case 4
                cko = ckp     - params.betaf*real(errorcksum) ; 
                dko = dkp     - params.betab*real(errordksum );  
            case 2
                cko = ckp     - params.betaf*errorcksum ; 
                dko = dkp     + params.betab*errordksum ;
                pxx =  errorcksum(1,:) ;
                pxy =  errorcksum(2,:) ;
                pxx1 =  errordksum(1,:)  ;
                pxy1 =  errordksum(2,:)   ;
                cko(1,:)= ckp(1,:)     - params.betaf*pxx ;
                cko(2,:)= ckp(2,:)     - params.betaf*pxy ;
                cko(3,:)= ckp(3,:)     + params.betaf*conj(pxy) ;
                cko(4,:)= ckp(4,:)     - params.betaf*conj(pxx) ;
                dko(1,:)= dkp(1,:)     - params.betab*pxx1 ;
                dko(2,:)= dkp(2,:)     - params.betab*pxy1 ;
                dko(3,:)= dkp(3,:)     + params.betab*conj(pxy1) ;
                dko(4,:)= dkp(4,:)     - params.betab*conj(pxx1) ;
            otherwise 
                cko  = 0 * ckp ;
                dko  = 0 * dkp ;
                sidx = [0:params.NStream-1] * ( params.NStream +1)+1;
                cko(sidx,:)= ckp(sidx,:)     - params.betaf*errorcksum(sidx,:) ; 
                dko(sidx,:)= dkp(sidx,:)     - params.betab*errordksum(sidx,:) ;
        end
    else
        cko = ckp   ; 
        dko = dkp   ;
        po  = pp    ;
    end
    
    if ( params.real_coef == 1 &&  params.type == 4 && params.skewcomp_en == 0 )
        cko = real(cko)   ; 
        dko = real(dko)    ;
    end
end
    

function [errorcksum, errordksum, errorpsum, error, next_Rinv]= FilterAlgorithm ( AIN, prev_decided, decided, equalized, Rinv, ck, dk, p, params)
    next_Rinv = complex(Rinv);
    errorpsum = 0;
    switch params.type
        case {1 6}
            if( params.skewcomp_en == 2 )
            [errorcksum, errordksum, error ]= LMS_complex ( AIN, prev_decided, decided, equalized, ck, dk, params.PRL,  params.OV );
            else
            [errorcksum, errordksum, error ]= LMS ( AIN, prev_decided, decided, equalized, ck, dk, params.PRL,  params.OV );
            end 
        case 2
            [errorcksum, errordksum, error ]= CMA ( AIN, equalized, ck, dk, params.PRL,  params.OV );
        case 3
            [errorcksum, errordksum, error ]= MMA ( AIN, equalized, ck, dk, params.PRL,  params.OV );
        case 5
            [errorcksum, errordksum, error, next_Rinv ]= RLS ( AIN, prev_decided, decided, equalized, Rinv, ck, dk, params );
        case 4
            if( params.skewcomp_en == 1 )
            [errorcksum, errordksum, error ]= RDE_real ( AIN, decided, equalized, ck, dk, params.PRL,  params.OV );  
            else
            [errorcksum, errordksum, error ]= RDE ( AIN, decided, equalized, ck, dk, params.PRL,  params.OV );
            end 
        case 7
            [errorcksum, errordksum, errorpsum, error ]= LMS_CPE ( AIN, prev_decided, decided, equalized, ck, dk, p, params.PRL,  params.OV );
        case 8 % for 4x4(2x2) real MIMO
            [errorcksum, errordksum, errorpsum, error ]= LMS_CPE1 ( AIN, prev_decided, decided, equalized, ck, dk, p, params.PRL,  params.OV );
        case 9
            [errorcksum, errordksum, error ]= RDE_real ( AIN, decided, equalized, ck, dk, params.PRL,  params.OV );  
        case {10}
            [errorcksum, errordksum, error ]= LMS_complex ( AIN, prev_decided, decided, equalized, ck, dk, params.PRL,  params.OV );
        otherwise 
            [errorcksum, errordksum, error ]= LMS ( AIN, prev_decided, decided, equalized, ck, dk, params.PRL,  params.OV );
    end
end


function [errorcksum, errordksum, dec_error ]= LMS ( AIN, prev_decided, decided, equalized, ck, dk, PRL,  OV )


    errorck =complex(zeros([size(ck), PRL/OV]));
    errordk =complex(zeros([size(dk), PRL/OV]));
    errorcksum =complex(zeros(size(ck)));
    errordksum =complex(zeros(size(dk)));
    dec = [prev_decided(:,end-size(dk,2)+1:end) decided(:,1:end)];
    dec_error = -decided + equalized;
   
    NStream = size(decided,1);
    for is= 1:size(AIN,1)
        for os= 1:NStream
            sidx = (is - 1 )* NStream + os ; % equation index 
            for idx= 1:size(ck,2)
           	 errorck(sidx, idx,:) = dec_error(os,:) .* conj(AIN(is, idx +(0:OV:PRL-1)));
                 errorcksum(sidx, idx)=sum( errorck(sidx, idx,: )) ;
            end
            for idx=1:size(dk,2)
                idx1 = size(dk,2) - idx + 1;
                errordk(sidx,idx,:) = dec_error(os,:) .* conj(dec(is, idx1+(0:size(dec_error,2)-1)));
                errordksum(sidx,idx)  = sum( errordk(sidx, idx, :) * 1) ;
            end
        end
    end
end



function [errorcksum, errordksum, dec_error ]= LMS_complex ( AIN, prev_decided, decided, equalized, ck, dk, PRL,  OV )


    errorck =complex(zeros([size(ck), PRL/OV]));
    errordk =complex(zeros([size(dk), PRL/OV]));
    errorcksum =complex(zeros(size(ck)));
    errordksum =complex(zeros(size(dk)));
    dec = [prev_decided(:,end-size(dk,2)+1:end) decided(:,1:end)];
    dec_error = -decided + equalized;
    dec =[dec; conj(dec);];
    NStream = size(decided,1);
    for is= 1:size(AIN,1)
        for os= 1:NStream
            sidx = (is - 1 )* NStream + os ; % equation index 
            for idx= 1:size(ck,2)
           	 errorck(sidx, idx,:) = dec_error(os,:) .* conj(AIN(is, idx +(0:OV:PRL-1)));
                 errorcksum(sidx, idx)=sum( errorck(sidx, idx,: )) ;
            end
            for idx=1:size(dk,2)
                idx1 = size(dk,2) - idx + 1;
                errordk(sidx,idx,:) = dec_error(os,:) .* conj(dec(is, idx1+(0:size(dec_error,2)-1)));
                errordksum(sidx,idx)  = sum( errordk(sidx, idx, :) * 1) ;
            end
        end
    end
end

function [errorcksum, errordksum, errorpsum, dec_error ]= LMS_CPE ( AIN, prev_decided, decided, equalized, ck, dk, p, PRL,  OV )


    errorck =complex(zeros([size(ck), PRL/OV]));
    errordk =complex(zeros([size(dk), PRL/OV]));
    errorp  =complex(zeros([size(p), PRL/OV]));
    errorcksum =complex(zeros(size(ck)));
    errordksum =complex(zeros(size(dk)));
    errorpsum =complex(zeros(size(p)));
    dec = [prev_decided(:,end-size(dk,2)+1:end) decided(:,1:end)];
    dec_error = -decided + equalized;

    NStream = size(decided,1);
    for is= 1:size(AIN,1)
        for os= 1:NStream
            sidx = (is - 1 )* NStream + os ; % equation index 
            for idx= 1:size(ck,2)
                 errorck(sidx, idx,:) = dec_error(os,:) .* conj(AIN(is, idx +(0:OV:PRL-1)));
                 errorcksum(sidx, idx)=sum( errorck(sidx, idx,: )) * p(sidx)  ;
            end
            for idx=1:size(dk,2)
                idx1 = size(dk,2) - idx + 1;
                errordk(sidx,idx,:) = dec_error(os,:) .* conj(dec(is, idx1+(0:size(dec_error,2)-1)));
                errordksum(sidx,idx)  = sum( errordk(sidx, idx, :) * 1) * p(sidx) ;
            end
            errorp(sidx,:) = dec_error(os,:) .* conj(equalized(is,:) /p(sidx) ) ;
            errorpsum(sidx) = sum(errorp(sidx,:));
        end
    end
       
    errorpsum = ones(size(errorpsum) ) * sum(errorpsum);
    % Compare errorpksum of sidx !!
%     errorcksum = errorcksum * p;
%     errordksum = errordksum * p;

end


function [errorcksum, errordksum, errorpsum, dec_error ]= LMS_CPE1 ( AIN, prev_decided, decided, equalized, ck, dk, p, PRL,  OV )


    errorck =complex(zeros([size(ck), PRL/OV]));
    errordk =complex(zeros([size(dk), PRL/OV]));
    errorp  =complex(zeros([size(p), PRL/OV]));
    errorcksum =complex(zeros(size(ck)));
    errordksum =complex(zeros(size(dk)));
    errorpsum =complex(zeros(size(p)));
    dec = [prev_decided(:,end-size(dk,2)+1:end) decided(:,1:end)];
    dec_error = -decided + equalized;

    NStream = size(decided,1);
    for is= 1:size(AIN,1)
        for os= 1:NStream
            sidx = (is - 1 )* NStream + os ; % equation index 
            for idx= 1:size(ck,2)
                 errorck(sidx, idx,:) = dec_error(os,:) .* conj(AIN(is, idx +(0:OV:PRL-1)));
                 errorcksum(sidx, idx)=sum( errorck(sidx, idx,: )) * p(sidx)  ;
            end
            for idx=1:size(dk,2)
                idx1 = size(dk,2) - idx + 1;
                errordk(sidx,idx,:) = dec_error(os,:) .* conj(dec(is, idx1+(0:size(dec_error,2)-1)));
                errordksum(sidx,idx)  = sum( errordk(sidx, idx, :) * 1) * p(sidx) ;
            end 
        end
    end
            
   equalized = complex( equalized(1:2:end, :), equalized(2:2:end, :));
   decided = complex( decided(1:2:end, :), decided(2:2:end, :));
   dec_error1    = -decided + equalized;
    for is= 1:size(AIN,1)/2
        for os= 1:NStream/2
            sidx = (is - 1 )* NStream/2 + os ; % equation index  
            errorp(sidx,:) = dec_error1(os,:) .* conj(equalized(is,:) /p(sidx) ) ;
            errorpsum(sidx) = sum(errorp(sidx,:));
        end
    end
    
    errorpsum = ones(size(errorpsum) ) * sum(errorpsum);
    % Compare errorpksum of sidx !!
%     errorcksum = errorcksum * p;
%     errordksum = errordksum * p;

end

function [errorcksum, errordksum, error ]= CMA ( AIN, equalized, ck, dk, PRL,  OV )


    errorck    = complex( zeros([size(ck), PRL/OV]));
    errorcksum = complex( zeros(size(ck)));
    errordksum = complex( zeros(size(dk)));
    error      = 1 -  equalized .* conj ( equalized );
    sign_err   = sign(-error);

    NStream = size(equalized,1);
    for is= 1:size(AIN,1)
        for os= 1:NStream
            sidx = (is - 1 )* NStream + os ; % equation index 
            for idx= 1:size(ck,2)
                errorck(sidx, idx, :) = error(os,:) .* equalized(os,:) .* conj(AIN(is, idx +(0:OV:PRL-1)));
                errorcksum(sidx, idx)  =  -sum( errorck(sidx, idx,: )) ;
            end
        end
    end

end

function [errorcksum, errordksum, error ]= MMA ( AIN, equalized, ck, dk, PRL,  OV )

    errorck    = complex( zeros([size(ck), PRL/OV]));
    errorcksum = complex( zeros(size(ck)));
    errordksum = complex( zeros(size(dk)));

    R1 = 1/sqrt(10)* sqrt(1+1);
    R2 = 1/sqrt(10)* sqrt(1+3^2);
    R3 = 1/sqrt(10)* sqrt(3^2+3^2);
    A1 = 0.5 * (R1+R2);
    A2 = 0.5 * (R3-R1);
    A3 = 0.5 * (R3-R2);

    B = abs(equalized ) -A1;
    C = abs(B ) -A2;
    error      = abs(C ) - A3;
    sign_err   = sign(C) .* sign( B ) .* sign(equalized);

    NStream = size(equalized,1);
    for is= 1:size(AIN,1)
        for os= 1:NStream
            sidx = (is - 1 )* NStream + os ; % equation index 
            for idx= 1:size(ck,2)
                errorck(sidx, idx, :) = error(os,:) .* sign_err(os,:) .* conj(AIN(is, idx +(0:OV:PRL-1)))  ;
                errorcksum(sidx, idx)  =   sum( errorck(sidx, idx,: )) ;
            end
        end
    end

end

%% Radius directed equalizer
function [errorcksum, errordksum, abs_error ]= RDE ( AIN, decided, equalized, ck, dk, PRL,  OV )


    errorck    = complex( zeros([size(ck), PRL/OV]));
    errorcksum = complex( zeros(size(ck)));
    errordksum = complex( zeros(size(dk)));
    abs_error  = decided .* conj(decided) -  equalized .* conj ( equalized );

    NStream = size(equalized,1);
    for is= 1:size(AIN,1)
        for os= 1:NStream
            sidx = (is - 1 )* NStream + os ; % equation index 
            for idx= 1:size(ck,2)
                errorck(sidx, idx, :) = abs_error(os,:) .* equalized(os,:) .* conj(AIN(is, idx +(0:OV:PRL-1)));
                errorcksum(sidx, idx) = -sum( errorck(sidx, idx,: )) ;
            end
        end
    end     
end

%% Radius directed equalizer
function [errorcksum, errordksum, abs_error1 ]= RDE_real ( AIN, decided, equalized, ck, dk, PRL,  OV )


    errorck    = complex( zeros([size(ck), PRL/OV]));
    errorcksum = complex( zeros(size(ck)));
    errordksum = complex( zeros(size(dk)));
    decided1 = complex(decided(1:2:end, :) , decided(2:2:end, :) );
    equalized1 = complex(equalized(1:2:end, :) , equalized(2:2:end, :) );
    abs_error  = decided1 .* conj(decided1) -  equalized1 .* conj ( equalized1 );
    abs_error1 = zeros(size(abs_error,1)*2, size(abs_error,2));
    abs_error1(1:2:end, :) =  abs_error;
    abs_error1(2:2:end, :) =  abs_error;
   
    NStream = size(equalized,1);
    for is= 1:size(AIN,1)
        for os= 1:NStream
            sidx = (is - 1 )* NStream + os ; % equation index 
            for idx= 1:size(ck,2)
                errorck(sidx, idx, :) = abs_error1(os,:) .* equalized(os,:) .* conj(AIN(is, idx +(0:OV:PRL-1)));
                errorcksum(sidx, idx) = -sum( errorck(sidx, idx,: )) ;
            end
        end
    end     
end


function [errorcksum, errordksum, dec_error ]= RDE1 ( AIN, prev_decided, decided, equalized, ck, dk, PRL,  OV )


    errorck =complex(zeros([size(ck), PRL/OV]));
    errordk =complex(zeros([size(dk), PRL/OV]));
    errorcksum =complex(zeros(size(ck)));
    errordksum =complex(zeros(size(dk)));
    decided = abs(decided);
    prev_decided = abs(prev_decided);
    equalized = abs(equalized);
    AIN = abs(AIN);
    dec = [prev_decided(:,end-size(dk,2)+1:end) decided(:,1:end)];
    dec_error = -decided + equalized;
   
    NStream = size(decided,1);
    for is= 1:size(AIN,1)
        for os= 1:NStream
            sidx = (is - 1 )* NStream + os ; % equation index 
            for idx= 1:size(ck,2)
           	 errorck(sidx, idx,:) = dec_error(os,:) .* conj(AIN(is, idx +(0:OV:PRL-1)));
                 errorcksum(sidx, idx)=sum( errorck(sidx, idx,: )) ;
            end
            for idx=1:size(dk,2)
                idx1 = size(dk,2) - idx + 1;
                errordk(sidx,idx,:) = dec_error(os,:) .* conj(dec(is, idx1+(0:size(dec_error,2)-1)));
                errordksum(sidx,idx)  = sum( errordk(sidx, idx, :) * 1) ;
            end
        end
    end
end

%%

% RLS does not work!
function [errorcksum, errordksum, dec_error, next_Rinv ]= RLS ( AIN, prev_decided, decided, equalized, Rinv, ck, dk, params)
%
%  Function   : RLS coefficient update as follows.
%           
%     C    = Rinv * uvec / (lambda + uvec' * Rinv * uvec )
%     Rinv = 1/lambda ( Rinv - C*uvec'*Rinv)
%
%  These variable dimension should support 1) MIMO 2)Parallelism
% 
%  Dimension 
%     C     : (NStream*IStream, Ndfe, PRL )
%     Rinv  : (NstreamxIStream, Ndfe, Ndfe)
%   

    PRL         = params.PRL;
    OV          = params.OV;
    Ndfe = params.Nffe + params.Nfbe;

    errorck =complex(zeros([size(ck), PRL/OV]));
    errordk =complex(zeros([size(dk), PRL/OV]));
    errorcksum =complex(zeros(size(ck)));
    errordksum =complex(zeros(size(dk)));
    dec = [prev_decided(:,end-size(dk,2)+1:end) decided(:,1:end)];
    if ( params.betab == 0 )
        dec = dec * 0 ;
    end
    dec_error = -decided + equalized;
    [C]= RLSUpdateRate ( AIN, dec, Rinv, params) ;
    C1 = complex(zeros(size(C,2), size(C,3))); 
    P = complex(zeros(size(Rinv,2), size(Rinv,2))); 
    % Filter update 
    NStream = size(decided,1);
    for is= 1:size(AIN,1)
        for os= 1:NStream
            sidx = (is - 1 )* NStream + os ; % equation index 
            C1(:,:) = C(sidx, :, :) ;
            for idx= 1:size(ck,2)
             	errorck(sidx, idx,:) = C1( idx, :) .* dec_error(os, :) ;
                errorcksum(sidx, idx)=sum( errorck(sidx, idx, : )) ;
            end
            for idx=1:size(dk,2)
                errordk(sidx, idx,:) = C1(params.Nffe+idx, :) .* dec_error(os, :) ;
                errordksum(sidx,idx)  = sum( errordk(sidx, idx, :) * 1) ;
            end
        end
    end

    next_Rinv =complex( zeros(size( Rinv)));
    Ndfe = params.Nffe + params.Nfbe;
%     Ndfe = params.Nffe;
    uvec = complex(zeros( Ndfe,1));
    Pupd = complex(zeros(PRL/OV, Ndfe));
    % Rinv = 1/lambda ( Rinv - C*uvec'*Rinv)
    for is= 1:size(AIN,1)
        for os= 1:NStream
            sidx = (is - 1 )* NStream + os ; % equation index 
            P(:,:) = Rinv(sidx, :, :);
            for idx= 1:Ndfe %params.Nffe
                for idx1=2:2 %1: PRL/OV
                    idx2=idx1 + idx; 
                    uvec(:,1) = [AIN(is, (idx1-1)*OV+(1:params.Nffe)) dec(is, idx1:idx1+params.Nfbe-1)];
                    Pupd(idx1, :) =  C(sidx, idx,  idx1) * uvec'* P; %  1 x (1x Ndfe) x (Ndfe x Ndfe)
                end
                next_Rinv(sidx, idx, :) = Rinv(sidx, idx, :) - permute( sum(Pupd, 1), [1 3 2] ); %  Ndfe X Ndfe 
            end
        end
    end

      
    
 
%     next_Rinv =  Rinv  - next_Rinv ; 
    
    next_Rinv = 1/params.lambda * next_Rinv ;
    next_Rinv = complex( next_Rinv );
end

% RLS intermediate signal R-1 * received signal
function [K  ]= RLSUpdateRate ( AIN, decided, Rinv, params) 
    PRL         = params.PRL;
    block_size  = params.block_size;
    OV          = params.OV;
    NStream     = params.NStream;
    IStream     = size(AIN,1);

    Ndfe = params.Nffe + params.Nfbe;
    K   = complex( zeros(NStream*IStream, Ndfe, PRL/OV ));
    Ndfe = params.Nffe + params.Nfbe;  
    P   = complex( zeros(Ndfe, Ndfe));
    uvec= complex( zeros(Ndfe, 1));
 
    %% Ndfe = Nffe+Nfbe; 
    for is= 1:size(AIN,1)
        for os= 1:NStream
            sidx = (is - 1 )* NStream + os ; % equation index 
            P(:,:) = Rinv(sidx, :,:); % (dimension ; (NstreamxIStream) X Ndfe X Ndfe )
            for idx=1:PRL/OV 
                uvec(:,1) = [AIN(is, (idx-1)*OV+(1:params.Nffe)) decided(is, idx:idx+params.Nfbe-1) ] ;
                K(sidx, 1:Ndfe, idx)  = (P*uvec) /( params.lambda +  uvec' * P * uvec  );
            end
        end
    end
end 

