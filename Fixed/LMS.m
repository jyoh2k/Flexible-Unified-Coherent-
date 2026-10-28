function [errorsum] = LMS ( AIN, prev_decided, decided, equalized, ...
                            ck, dk, ek, fk, e3k, f3k, dc1, dc2,  params )

    PRL     =params.PRL * params.OV;
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
    errordc2sum = complex(zeros(size(dc2)));
    dec = [prev_decided(:,end-size(dk,2)+1:end) decided(:,1:end)];
%     if ( params.skewcomp_en == 2 )
%         dec =[dec; conj(dec);];
%     end 
    dec_error = -decided + equalized;
    decided2 = [prev_decided(:,end-params.Npbe+1:end) decided(:,1:end)];
    decided3 = [prev_decided(:,end-params.Np3be+1:end) decided(:,1:end)];
    dec_error = fie_c(dec_error, params.T.ERRORK);  
    LMSOV = params.LMSOV;
   
    NStream = size(decided,1);
    for is= 1:size(AIN,1)
        for os= 1:NStream
            sidx = (is - 1 )* NStream + os ; % equation index 
            for idx= 1:size(ck,2)
                errorck(sidx, idx,:) = dec_error(os,:) .* conj(AIN(is, idx +(0:OV:PRL-1)) + dc2(os+(is-1)*NStream));
                errorck(sidx, idx,:) = fie_c(errorck(sidx, idx,:), params.T.ERRORCK);  
                errorcksum(sidx, idx)=sum( errorck(sidx, idx, 1:LMSOV:end) );
            end
            for iW= 1:params.W % W : w=0:PE ...W-1: 
                offset = floor(params.Npostcursor - (params.Npfe-1) /2);
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
                offset = floor(params.Npostcursor - (params.Np3fe-1) /2);
                for iW2= iW1:params.W3
                    iW = iW+1;
                    for idx= 1:size(e3k,2) % Np3fe
                        AIN1 = AIN(is, idx+offset +(0:OV:PRL-1));
                        AIN2 = AIN(is, idx+offset +(iW1-1)+0+(0:OV:PRL-1));
                        AIN3 = AIN(is, idx+offset +(iW2-1)+0+(0:OV:PRL-1));
                        errore3k(sidx, idx, iW, :) = dec_error(os,:) .* conj(AIN1 .* AIN2 .* AIN3 );
%                         errore3k(sidx, idx, iW, :) = fie_c(errore3k(sidx, idx, iW, :), params.T.ERRORE3K); 
                        errore3ksum(sidx, idx, iW)=sum( errore3k(sidx, idx, iW, :)) ;
                    end
                end
            end
            for idx=1:size(dk,2)
                idx1 = size(dk,2) - idx + 1;
                errordk(sidx,idx,:) = dec_error(os,:) .* conj(dec(is, idx1+(0:size(dec_error,2)-1)));
                errordk(sidx,idx,:) = fie_c(errordk(sidx,idx,:),params.T.ERRORDK);
                errordksum(sidx,idx)  = sum( errordk(sidx, idx,  1:LMSOV:end ) * 1) ;
            end
            for idx=1:size(fk,2)
                idx1 = size(fk,2) - idx + 1;
                errorfk(sidx,idx,:) = dec_error(os,:) .* conj(decided2(is, idx1+(0:size(dec_error,2)-1)) .^2);
                errorfk(sidx,idx,:) = fie_c( errorfk(sidx,idx,:), params.T.ERRORFK);
                errorfksum(sidx,idx)  = sum( errorfk(sidx, idx, :) * 1) ;
            end
            for idx=1:size(f3k,2)
                idx1 = size(f3k,2) - idx + 1;
                errorf3k(sidx,idx,:) = dec_error(os,:) .* conj(decided3(is, idx1+(0:size(dec_error,2)-1)) .^3);
                errorf3k(sidx,idx,:) = fie_c( errorf3k(sidx,idx,:), params.T.ERRORF3K);
                errorf3ksum(sidx,idx)  = sum( errorf3k(sidx, idx, :) * 1) ;
            end
%             errordc2(sidx, :) = dec_error(os,:) * sum(conj(ck(is, :)));
%             errordc2sum(sidx)=sum( errordc2(sidx, : )) ;
        end        
    end

    errorcksum =fie_c( errorcksum, params.T.ERRORCKSUM);
    errordksum =fie_c( errordksum, params.T.ERRORDKSUM);
    erroreksum =fie_c( erroreksum, params.T.ERROREKSUM);
    errorfksum =fie_c( errorfksum, params.T.ERRORFKSUM);
    errore3ksum =fie_c( errore3ksum, params.T.ERRORE3KSUM);
    errorf3ksum =fie_c( errorf3ksum, params.T.ERRORF3KSUM);
    errorsum.errorcksum   = errorcksum;
    errorsum.errordksum   = errordksum;
    errorsum.erroreksum   = erroreksum;
    errorsum.errorfksum   = errorfksum;
    errorsum.errore3ksum  = errore3ksum;
    errorsum.errorf3ksum  = errorf3ksum;
    errorsum.errordc2sum  = errordc2sum;
    errorsum.dec_error    = dec_error;  

    
    if ( params.fixed_bit == 2 )
    end

end
