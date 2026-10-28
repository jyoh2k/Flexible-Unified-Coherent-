function [AOUT, dfeout, decided, coef1, coefp1, Rinv] = ...
     NL3DFE(AIN, DIN1, is_training_seq, filtertap_update, prev_decided, coef, coefp, Rinv, params) 
 
%  Usage      : [AOUT, dfeout, coef, coefp] = NLDFE(  AIN, DIN1, is_training_seq,
%                                filtertap_update, prev_decided, coef, coefp, params)
%  Function   :
%     Decision feedback equalizer ( Decision directed FFE included)
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
   
    [ck, dk, ek, fk, e3k, f3k] = coef_init(coef, params);
    [ckp, dkp, ekp, fkp, e3kp, f3kp] = coef_init(coefp, params);

    ffe         = complex( zeros(params.NStream, PRL) );     
    ffeout      = complex( zeros(params.NStream, PRL) );     
    decided     = complex( zeros(params.NStream, PRL/OV)) ;
    equalized   = complex( zeros(params.NStream, PRL/OV));
    DIN         = [prev_decided(:,end) DIN1 ];
    
    coef1 = complex( zeros(size(coef)));
    coefp1 = complex( zeros(size(coef)));
    Rinv = complex(Rinv);
    %% Feedforware filter
    for os=1:params.NStream 
        for idx=1:PRL 
            ffe_mul = AIN(:,idx:idx+params.Nffe -1) .* ck(os:NStream:end, :);
            ffe_mul = fie_c( ffe_mul, params.T.FFEMul) ;
            ffe_sum = sum(sum(ffe_mul, 2));
            ffe(os, idx) =  ffe_sum  ;
        end
    end
    ffe = fie_c( ffe, params.T.FFE) ;
    
    [vffe]  = volterra_fe  ( AIN,  ek, params);
    [v3ffe] = volterra3_fe ( AIN, e3k, params);

    %% Feedback filter
    ak =complex( [prev_decided(:, end:-1:end-size(dk,2)+1) ]);
    fbe  = complex(zeros(params.NStream, PRL/OV));
    vfbe = complex(zeros(params.NStream, PRL/OV));
    v3fbe = complex(zeros(params.NStream, PRL/OV));
    is_block_start =  zeros(1, PRL/OV);
    if ( params.en_block_termination == 1 )      
        is_block_start = double( mod([1:PRL/OV], block_size) == 1);
    end
    if ( params.en_block_termination == 2 )
        is_block_start = double( mod([1:PRL/OV], block_size) == 0);
    end



    for idx=1:PRL/OV 
        for os=1:params.NStream 
            if ( is_block_start(idx) == 1 )
                ak(:,1) = DIN(os,idx);
            end
            fbe(os, idx)  = sum(sum(ak .* dk(os:NStream:end,:)));
            fbe(os, idx) = fie_c ( fbe(os, idx), params.T.FBE);

            vfbe(os, idx) = sum(sum(ak(1:params.Npbe) .^ 2 .* fk(os:NStream:end,:))); % Volterra 2nd order
            vfbe(os, idx) = fie_c ( vfbe(os, idx), params.T.VFBE);
            v3fbe(os, idx) = sum(sum(ak(1:params.Np3be) .^3 .* f3k(os:NStream:end,:))); % Volterra  3rd order

            v3fbe(os, idx) = fie_c ( v3fbe(os, idx), params.T.V3FBE);
            equalized(os,idx) =  ffe(os, (idx-1)*OV+1) +   fbe(os,idx)+   ...    
                                vffe(os, (idx-1)*OV+1) +  vfbe(os,idx)+   ...
                               v3ffe(os, (idx-1)*OV+1) +  v3fbe(os,idx);

            equalized = fie_c(equalized, params.T.EQOut);
         
            ffeout(os, (idx-1)*OV+1) =  equalized(os,idx)  - sum(sum(ak(:,1:params.Nfilter) .* dk(os:NStream:end,1:params.Nfilter)));
            [dec]= slicer( equalized(os,idx), DIN(os,idx+1),is_training_seq,idx,params);
            decided(os,idx) = dec ;
        end
        
        
        ak =[ decided(:,idx) ak(:,1: params.Nfbe -1)];
    end




     [errorcksum, errordksum,erroreksum, errorfksum, ...
      errore3ksum, errorf3ksum, error, Rinv]= ...
       FilterAlgorithm ( AIN, prev_decided, decided, equalized, Rinv, ck, dk, ek, fk, e3k, f3k, params);


     [cko, dko, eko, fko, e3ko, f3ko] = CoefUpdate( filtertap_update, ckp, dkp, ekp, fkp, e3kp, f3kp, ...
                                        errorcksum, errordksum,erroreksum, errorfksum, ...
                                        errore3ksum, errorf3ksum, params);
    
% dko(:, 2) =0;
    %% For debugging
    if ( sum(sum(abs(cko))) < 200  )
        coefo = [cko dko reshape(eko, size(eko,1), params.Ndpfe,1), fko, reshape(e3ko, size(e3ko,1), params.Ndp3fe,1), f3ko ];
        coef1(:, 1:size(coefo,2)) = coefo;        
        coefp1(:, 1:size(coefo,2)) = coefo;     
    else
        coef1 = coef;
        coefp1 = coefp;
    end

    dfeout.ffeout = ffeout;
    
    AOUT = ffe + vffe + v3ffe ;
    AOUT(:, 1:OV:end) = equalized;
    dfeout.decided = decided;
    dfeout.ffe_error = sum(errorcksum, 2);
    dfeout.error = sum(error, 2);
end

function [dec] = slicer ( in, din, is_training_seq, symbol_idx, params  )
    if ( is_training_seq == 1 )
        dec = din;
        return;
    end 

    is_block_end = 0;
    if ( params.en_block_termination == 1)      
        is_block_end = double(mod(symbol_idx, params.block_size) == 0);
    end 
    if ( params.en_block_termination == 2 )
        is_block_end = double(mod(symbol_idx, params.block_size) == 1);
    end

    if (is_block_end == 1 )
        %dec = params.term_symbol;
        dec = din;
    else
        if ( params.type == 4 )
            distance = abs(abs( in) -  abs(params.mapper_list ));
        else 
            distance = abs( in -  params.mapper_list        ).^2;
        end 
        distance = fie_c(distance, params.T.Slicer);
        [C, I] = min( distance  );
        dec =  params.mapper_list(I);
    end
end



function [cko, dko, eko, fko, e3ko, f3ko] = CoefUpdate( filtertap_update, ckp, dkp, ekp, fkp, e3kp, f3kp, ...
                                errorcksum, errordksum, erroreksum, errorfksum,...
                                errore3ksum, errorf3ksum, params)
    if ( filtertap_update )
        switch params.update_type
            case 1
                cko  = ckp     - params.betaf*errorcksum ;
                dko  = dkp     - params.betab*errordksum ;
                eko  = ekp     - params.betae*erroreksum ;
                fko  = fkp     - params.betag*errorfksum ;
                e3ko = e3kp     - params.betae3 * errore3ksum ;
                f3ko = f3kp     - params.betag3 * errorf3ksum ;
%             case 2
%                 cko = ckp     - params.betaf*errorcksum ; 
%                 dko = dkp     + params.betab*errordksum ;
%                 eko = ekp     - params.betae*erroreksum ; 
%                 fko = fkp     + params.betag*errorfksum ;
%                 pxx =  errorcksum(1,:) ;
%                 pxy =  errorcksum(2,:) ;
%                 pxx1 =  errordksum(1,:)  ;
%                 pxy1 =  errordksum(2,:)   ;
%                 cko(1,:)= ckp(1,:)     - params.betaf*pxx ;
%                 cko(2,:)= ckp(2,:)     - params.betaf*pxy ;
%                 cko(3,:)= ckp(3,:)     + params.betaf*conj(pxy) ;
%                 cko(4,:)= ckp(4,:)     - params.betaf*conj(pxx) ;
%                 dko(1,:)= dkp(1,:)     - params.betab*pxx1 ;
%                 dko(2,:)= dkp(2,:)     - params.betab*pxy1 ;
%                 dko(3,:)= dkp(3,:)     + params.betab*conj(pxy1) ;
%                 dko(4,:)= dkp(4,:)     - params.betab*conj(pxx1) ;
%                 
%                 pxx =  erroreksum(1,:) ;
%                 pxy =  erroreksum(2,:) ;
%                 pxx1 =  errorfksum(1,:)  ;
%                 pxy1 =  errorfksum(2,:)   ;
%                 eko(1,:)= ekp(1,:)     - params.betaf*pxx ;
%                 eko(2,:)= ekp(2,:)     - params.betaf*pxy ;
%                 eko(3,:)= ekp(3,:)     + params.betaf*conj(pxy) ;
%                 eko(4,:)= ekp(4,:)     - params.betaf*conj(pxx) ;
%                 fko(1,:)= fkp(1,:)     - params.betag*pxx1 ;
%                 fko(2,:)= fkp(2,:)     - params.betag*pxy1 ;
%                 fko(3,:)= fkp(3,:)     + params.betag*conj(pxy1) ;
%                 fko(4,:)= fkp(4,:)     - params.betag*conj(pxx1) ;
            otherwise
                cko  = 0 * ckp ;
                dko  = 0 * dkp ;
                eko  = 0 * ekp ;
                fko  = 0 * fkp ;
                e3ko = 0 * e3kp ;
                f3ko = 0 * f3kp ;
                sidx = [0:params.NStream-1] * ( params.NStream +1)+1;
                cko(sidx,:)= ckp(sidx,:)     - params.betaf*errorcksum(sidx,:) ;
                dko(sidx,:)= dkp(sidx,:)     - params.betab*errordksum(sidx,:) ;
                eko(sidx,:)= ekp(sidx,:)     - params.betae*erroreksum(sidx,:) ;
                fko(sidx,:)= fkp(sidx,:)     - params.betag*errorfksum(sidx,:) ;
                e3ko(sidx,:)= e3kp(sidx,:)   - params.betae3*errore3ksum(sidx,:) ;
                f3ko(sidx,:)= f3kp(sidx,:)   - params.betag3*errorf3ksum(sidx,:) ;
        end
    else
        cko = ckp   ;
        dko = dkp    ;
        eko = ekp   ;
        fko = fkp    ;
        e3ko = e3kp   ;
        f3ko = f3kp    ;
    end

    if ( params.real_coef == 1 &&  params.type == 4)
        cko = real(cko)   ;
        dko = real(dko)    ;
        eko = real(eko)   ;
        fko = real(fko)    ;
        e3ko = real(e3ko)   ;
        f3ko = real(f3ko)    ;
    end
    cko  = fie_c( cko, params.T.CK );
    dko  = fie_c( dko, params.T.DK );;
    eko  = fie_c( eko, params.T.EK );
    fko  = fie_c( fko, params.T.FK );;
    e3ko = fie_c( e3ko, params.T.E3K );
    f3ko = fie_c( f3ko, params.T.F3K );
end


function [errorcksum, errordksum, erroreksum, errorfksum, errore3ksum, errorf3ksum, error, next_Rinv]= ...
          FilterAlgorithm ( AIN, prev_decided, decided, equalized, Rinv, ck, dk,  ek, fk, e3k, f3k, params)
    next_Rinv = complex(Rinv);
    erroreksum =complex(zeros(size(ek)));
    errorfksum =complex(zeros(size(fk)));
    errore3ksum =complex(zeros(size(e3k)));
    errorf3ksum =complex(zeros(size(f3k)));

    switch params.type
        case 1
            [errorcksum, errordksum,erroreksum, errorfksum, errore3ksum, errorf3ksum, error ]= ...
                        LMS ( AIN, prev_decided, decided, equalized, ck, dk,  ek, fk, e3k, f3k, params );
        case 2
            [errorcksum, errordksum, error ]= CMA ( AIN, equalized, ck, dk, params.PRL,  params.OV );
        case 3
            [errorcksum, errordksum, error ]= MMA ( AIN, equalized, ck, dk, params.PRL,  params.OV );
        case 5
            [errorcksum, errordksum, error, next_Rinv ]= RLS ( AIN, prev_decided, decided, equalized, Rinv, ck, dk, params );
        otherwise
            [errorcksum, errordksum, erroreksum, errorfksum, errore3ksum, errorf3ksum,  error ]= ...
              RDE ( AIN, decided, equalized, ck, dk, ek, fk, e3k, f3k, params );
%             [errorcksum, errordksum, error ]= RDE1 ( AIN, prev_decided, decided, equalized, ck, dk, params.PRL,  params.OV );
    end
end




function [errorcksum, errordksum, erroreksum, errorfksum, errore3ksum, errorf3ksum, dec_error ]= ...
           LMS ( AIN, prev_decided, decided, equalized, ck, dk, ek, fk, e3k, f3k,   params )

    PRL     =params.PRL;
    OV      =params.OV;
    errorck     = complex(zeros([size(ck), PRL/OV]));
    errordk     = complex(zeros([size(dk), PRL/OV]));
    errorek     = complex(zeros([size(ek,1),size(ek,2), size(ek,3), PRL/OV]));
    errorfk     = complex(zeros([size(fk), PRL/OV]));
    errore3k    = complex(zeros([size(e3k,1),size(e3k,2), size(e3k,3), PRL/OV]));
    errorf3k    = complex(zeros([size(f3k), PRL/OV]));
    errorcksum  = complex(zeros(size(ck)));
    errordksum  = complex(zeros(size(dk)));
    erroreksum  = complex(zeros(size(ek)));
    errorfksum  = complex(zeros(size(fk)));
    errore3ksum = complex(zeros(size(e3k)));
    errorf3ksum = complex(zeros(size(f3k)));
    dec = [prev_decided(:,end-size(dk,2)+1:end) decided(:,1:end)];
    dec_error = -decided + equalized;
    decided2 = [prev_decided(:,end-params.Npbe+1:end) decided(:,1:end)];
    decided3 = [prev_decided(:,end-params.Np3be+1:end) decided(:,1:end)];

   
    NStream = size(decided,1);
    for is= 1:size(AIN,1)
        for os= 1:NStream
            sidx = (is - 1 )* NStream + os ; % equation index 
            for idx= 1:size(ck,2)
                errorck(sidx, idx,:) = dec_error(os,:) .* conj(AIN(is, idx +(0:OV:PRL-1)));
                errorck(sidx, idx,:) = fie_c( errorck(sidx, idx,:), params.T.ERRORCK);
                errorcksum(sidx, idx)=sum( errorck(sidx, idx,: )) ;
            end
            for iW= 1:params.W % W : w=0:PE ...W-1: 
                offset = floor(params.Npostcursor - (params.Npbe-1) /2);
                for idx= 1:size(ek,2)
                    AIN1 = AIN(is, idx+offset +(0:OV:PRL-1));
                    AIN2 = AIN(is, idx+offset +(iW-1)+0+(0:OV:PRL-1));
                    errorek(sidx, idx, iW, :) = dec_error(os,:) .* conj(AIN1 .* AIN2 ); 
                    errorek(sidx, idx, iW, :) = fie_c( errorek(sidx, idx, iW, :), params.T.ERROREK);
                    erroreksum(sidx, idx, iW)=sum( errorek(sidx, idx, iW, :)) ;
                end
            end
            iW = 0;
            for iW1= 1:params.W3
                offset = floor(params.Npostcursor - (params.Np3be-1) /2);
                for iW2= iW1:params.W3
                    iW = iW+1;
                    for idx= 1:size(e3k,2) % Np3fe
                        AIN1 = AIN(is, idx+offset +(0:OV:PRL-1));
                        AIN2 = AIN(is, idx+offset +(iW1-1)+0+(0:OV:PRL-1));
                        AIN3 = AIN(is, idx+offset +(iW2-1)+0+(0:OV:PRL-1));
                        errore3k(sidx, idx, iW, :) = dec_error(os,:) .* conj(AIN1 .* AIN2 .* AIN3 );
                        errore3ksum(sidx, idx, iW)=sum( errore3k(sidx, idx, iW, :)) ;
                    end
                end
            end
            for idx=1:size(dk,2)
                idx1 = size(dk,2) - idx + 1;
                errordk(sidx,idx,:) = dec_error(os,:) .* conj(dec(is, idx1+(0:size(dec_error,2)-1)));
                errordk(sidx,idx,:) = fie_c( errordk(sidx,idx,:), params.T.ERRORDK);
                errordksum(sidx,idx)  = sum( errordk(sidx, idx, :) * 1) ;
            end
            for idx=1:size(fk,2)
                idx1 = size(fk,2) - idx + 1;
                errorfk(sidx,idx,:) = dec_error(os,:) .* conj(decided2(is, idx1+(0:size(dec_error,2)-1)) .^2);
                errorfksum(sidx,idx)  = sum( errorfk(sidx, idx, :) * 1) ;
            end
            for idx=1:size(f3k,2)
                idx1 = size(f3k,2) - idx + 1;
                errorf3k(sidx,idx,:) = dec_error(os,:) .* conj(decided3(is, idx1+(0:size(dec_error,2)-1)) .^3);
                errorf3ksum(sidx,idx)  = sum( errorf3k(sidx, idx, :) * 1) ;
            end
        end        
    end
                
    errorcksum = fie_c( errorcksum, params.T.ERRORCKSUM);
    errordksum = fie_c( errordksum, params.T.ERRORDKSUM);
    erroreksum = fie_c( erroreksum, params.T.ERROREKSUM);
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
function [errorcksum, errordksum, erroreksum, errorfksum, errore3ksum, errorf3ksum, abs_error ]= RDE ( AIN, decided, equalized, ck, dk, ek,fk, e3k, f3k, params )

    OV         = params.OV; 
    PRL        = params.PRL;
    errorck    = complex( zeros([size(ck), PRL/OV]));
    errorek    = complex(zeros([size(ek,1),size(ek,2), size(ek,3), PRL/OV]));
    errore3k    = complex(zeros([size(e3k,1),size(e3k,2), size(e3k,3), PRL/OV]));
    errorcksum = complex( zeros(size(ck)));
    errordksum = complex( zeros(size(dk)));
    erroreksum = complex(zeros(size(ek)));
    errorfksum = complex(zeros(size(fk)));
    errore3ksum = complex(zeros(size(e3k)));
    errorf3ksum = complex(zeros(size(f3k)));
    abs_error  = decided .* conj(decided) -  equalized .* conj ( equalized );
    W = size(ek, 3);


    NStream = size(equalized,1);
    for is= 1:size(AIN,1)
        for os= 1:NStream
            sidx = (is - 1 )* NStream + os ; % equation index 
            for idx= 1:size(ck,2)
                errorck(sidx, idx, :) = abs_error(os,:) .* equalized(os,:) .* conj(AIN(is, idx +(0:OV:PRL-1)));
                errorcksum(sidx, idx) = -sum( errorck(sidx, idx,: )) ;
            end
            for iW= 1:params.W % W : w=0:PE ...W-1: 
                offset = floor(params.Npostcursor - (params.Npbe-1) /2);
                for idx= 1:size(ek,2)
                    AIN1 = AIN(is, idx+offset +(0:OV:PRL-1));
                    AIN2 = AIN(is, idx+offset +(iW-1)+0+(0:OV:PRL-1));
                    errorek(sidx, idx, iW, :) = abs_error(os,:) .* equalized(os,:) .* conj(AIN1 .* AIN2 ); 
                    erroreksum(sidx, idx, iW)=sum( errorek(sidx, idx, iW, :)) ;
                end
            end
            iW = 0;
            for iW1= 1:params.W3
                offset = floor(params.Npostcursor - (params.Np3be-1) /2);
                for iW2= iW1:params.W3
                    iW = iW+1;
                    for idx= 1:size(e3k,2) % Np3fe
                        AIN1 = AIN(is, idx+offset +(0:OV:PRL-1));
                        AIN2 = AIN(is, idx+offset +(iW1-1)+0+(0:OV:PRL-1));
                        AIN3 = AIN(is, idx+offset +(iW2-1)+0+(0:OV:PRL-1));
                        errore3k(sidx, idx, iW, :) = abs_error(os,:) .* equalized(os,:) .* conj(AIN1 .* AIN2 .* AIN3 );
                        errore3ksum(sidx, idx, iW)=sum( errore3k(sidx, idx, iW, :)) ;
                    end
                end
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

function [vffe] = volterra_fe ( in1, ek, params  )
    PRL         = params.PRL;
    vffe    = complex( zeros(params.NStream, PRL));
    if ( params.W == 0 || params.Npfe ==0 )
        return;
    end

    in1 = fie_c(in1, params.T.VFEIn);
    offset = floor(params.Npostcursor - (params.Npbe-1) /2);
    vffe_mul_sum = complex(zeros(1,1));
    in     = in1(:, offset+1:end);
    for os=1:params.NStream 
        for idx=1:PRL 
            for iW=1:params.W 
                vffe_mul =   in1(:,idx+offset+(0:params.Npfe -1)) .* ...
                              in1(:,(iW-1)+0+(idx+offset)+(0:params.Npfe -1)) .* ...
                                   ek(os:params.NStream:end, :, iW) ;
                vffe_mul = fie_c( vffe_mul, params.T.VFEMul);
                vffe_mul_sum = sum( vffe_mul, 2);
                vffe_mul_sum = fie_c( vffe_mul_sum, params.T.VFEMulSum);
                vffe(os, idx) = vffe(os,idx) + vffe_mul_sum;
            end
        end
    end
                
    vffe = fie_c( vffe, params.T.VFEOut);
end

function [v3ffe] = volterra3_fe ( in1, e3k, params  )
    PRL         = params.PRL;
    v3ffe    = complex( zeros(params.NStream, PRL));
    if ( params.W3 == 0 || params.Np3fe ==0 )
        return;
    end

    offset = floor(params.Npostcursor - (params.Np3be-1) /2);
    in1 = fie_c(in1, params.T.V3FEIn);
    in     = in1(:, offset+1:end);
    v3ffe_mul_sum = complex(zeros(1,1));
    for os=1:params.NStream
        for idx=1:PRL
            iW=0;
            for iW1=1:params.W3
               for iW2=iW1:params.W3
                   iW=iW+1;
                   v3ffe_mul =  in1(:,idx+offset+(0:params.Np3fe -1)) .* ...
                                in1(:,(iW1-1)+0+(idx+offset)+(0:params.Np3fe -1)) .* ...
                                in1(:,(iW2-1)+0+(idx+offset)+(0:params.Np3fe -1)) .* ...
                                e3k(os:params.NStream:end, :, iW) ;
                   v3ffe_mul = fie_c( v3ffe_mul, params.T.V3FEMul);
                   v3ffe_mul_sum = sum( v3ffe_mul, 2);
                   v3ffe_mul_sum = fie_c( v3ffe_mul_sum, params.T.V3FEMulSum);
                   v3ffe(os, idx) = v3ffe(os,idx) + v3ffe_mul_sum;
                end
            end
        end
    end
    v3ffe = fie_c( v3ffe, params.T.V3FEOut);
end

%
%function [vfbe] = volterra_be ( dec, fk, params  )
%    PRL         = params.PRL;
%    vfbe    = complex( zeros(params.NStream, PRL));
%    if (  params.Npbe ==0 )
%        return;
%    end
%    for os=1:params.NStream 
%        for idx=1:PRL 
%            vfbe_mul = sum(dec(:,idx:idx+params.Npbe -1) .* ...
%                          (dec(:,(w-1)+(idx:idx+params.Npbe -1)) .* ...
%                               fk(os:NStream:end, :),2);
%            vfbe(os, idx) = vfbe(os,idx) + sum(vfbe_mul);
%        end
%    end
%end

function [ck, dk, ek, fk, e3k, f3k] = coef_init(coef, params)

    ck          = complex( coef(:,1:params.Nffe));
    dk          = complex( coef(:,params.Nffe+(1:params.Nfbe)));
    ek2          = ( coef(:,params.Nffe+params.Nfbe+(1:params.Ndpfe)));
    ek         = complex(zeros(params.Npfe, params.W));
    ek          = complex( reshape(ek2, size(coef,1),params.Npfe, params.W));
    fk          = complex( coef(:,params.Nffe+params.Nfbe+params.Ndpfe+(1:params.Npbe)));

    offidx = params.Nffe+params.Nfbe+params.Ndpfe+params.Npbe;
    e3k2        = ( coef(:,offidx +(1:params.Ndp3fe)));
    e3k        = complex(zeros(params.Np3fe, 0.5 * params.W3 * (params.W3+1)));
    e3k         = complex( reshape(e3k2, size(coef,1),params.Np3fe, 0.5 *  params.W3 * (params.W3+1)));
    offidx = params.Nffe+params.Nfbe+params.Ndpfe+params.Npbe + params.Ndp3fe;
    f3k         = complex( coef(:,offidx +(1:params.Np3be)));
end

