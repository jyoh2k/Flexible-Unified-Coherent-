function [AOUT, params] = RxNL3LMS( AIN, trainingseq, equalized, params )  

%  Usage      : 
%
%  Function   :
%     LMS  for nonlinear symbol equalizer 
%
%  Port  :
%
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :
        
    %%  Initial value 
    [d1, d2] = size( AIN);
    OV         =  params.OV; 
    Npad        = params.Npostcursor; 
   
    AIN1        = [zeros(d1, Npad), AIN, zeros(d1, params.Nffe +10 )]; 
    d3 = min(size(trainingseq,2), size(AIN,2)); 
    AOUT        = zeros(params.NStream,  ceil(d2/params.OV) );
    
        

    if ( params.en == 0 )        
        AOUT = AIN;
        return;
    end

    prev_decided  = (zeros(params.NStream,params.Nfbe));

    [ck, dk, ek, fk, e3k, f3k] = coef_init(params.filtertap, params); 
%     equalized = AIN(:, 1:d3);
    AIN1 =AIN1(:,1:d3+params.Nffe-1);
    trainingseq = trainingseq(:, 1:d3);
    [errorcksum,errordksum, erroreksum, errorfksum, errore3ksum, errorf3ksum, ~ ]= ...
           LMS ( AIN1, prev_decided, trainingseq, equalized, ck, dk, ek, fk, e3k, f3k,   params );

    errordcsum = sum(sum(AIN)); % dc term
 
    params.ck  = params.ck     - params.betaf  * errorcksum ; 
    params.dk  = params.dk     + params.betab  * errordksum ; 
    params.ek  = params.ek     - params.betae  * erroreksum ; 
    params.e3k = params.e3k    - params.betae3 * errore3ksum ; 
    params.dc  = params.dc     - params.betadc * errordcsum ; 

    params.errorcksum = errorcksum;
    params.errordksum = errordksum;
    params.erroreksum = erroreksum;
    params.errore3ksum = errore3ksum;
    params.errordcsum = errordcsum;
    
end




function [errorcksum,errordksum, erroreksum, errorfksum, errore3ksum, errorf3ksum, dec_error ]= ...
           LMS ( AIN, prev_decided, decided, equalized, ck, dk, ek, fk, e3k, f3k,   params )

    PRL     =size(decided,2);
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
                errorcksum(sidx, idx)=sum( errorck(sidx, idx,: )) ;
            end
            for iW= 1:params.W % W : w=0:PE ...W-1: 
                offset = floor(params.Npostcursor - (params.Npbe-1) /2);
                for idx= 1:size(ek,2)
                    AIN1 = AIN(is, idx+offset +(0:OV:PRL-1));
                    AIN2 = AIN(is, idx+offset +(iW-1)+0+(0:OV:PRL-1));
                    errorek(sidx, idx, iW, :) = dec_error(os,:) .* conj(AIN1 .* AIN2 ); 
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
    if ( isreal(decided)) 
        errorcksum  = real(errorcksum);
        erroreksum  = real(erroreksum);
        errore3ksum = real(errore3ksum);
    end
end


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

