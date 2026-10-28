function [cko, dko, eko, fko, e3ko, f3ko, dc1o, dc2o] = ...
        CoefUpdate( filtertap_update, ckp, dkp, ekp, fkp, e3kp, f3kp, dc1p, dc2p, errorsum, params) 
    
    errorcksum   = errorsum.errorcksum;
    errordksum   = errorsum.errordksum;
    erroreksum   = errorsum.erroreksum;
    errorfksum   = errorsum.errorfksum;
    errore3ksum  = errorsum.errore3ksum;
    errorf3ksum  = errorsum.errorf3ksum;
    
    if ( filtertap_update )
        if ( params.type == 5 ) % RLS 
            cko  = ckp     + errorcksum;            
            dko  = dkp   + errordksum;            
            eko = ekp   + erroreksum;
            fko = fkp    ;
            e3ko = e3kp + errore3ksum ;
            f3ko = f3kp    ;
            dc1o = dc1p + params.betadc1 * errordc1sum;
            dc2o = 0 ;
        else 
            dc1o = dc1p ;%- params.betadc1 * errordc1sum;
            dc2o =  dc2p; %- params.betadc2 * errordc2sum;
            switch params.update_type
                case 1
                    cko  = ckp     - params.betaf*errorcksum ;
                    dko  = dkp     - params.betab*errordksum ;
                    eko  = ekp     - params.betae*erroreksum ;
                    fko  = fkp     - params.betag*errorfksum ;
                    e3ko = e3kp     - params.betae3 * errore3ksum ;
                    f3ko = f3kp     - params.betag3 * errorf3ksum ; 
                case 4
                    cko  = ckp     - params.betaf*real(errorcksum) ;
                    dko  = dkp     - params.betab*real(errordksum) ;
                    eko  = ekp     - params.betae*real(erroreksum) ;
                    fko  = fkp     - params.betag*real(errorfksum) ;
                    e3ko = e3kp     - params.betae3 * real(errore3ksum) ;
                    f3ko = f3kp     - params.betag3 * real(errorf3ksum) ;
                case 2
                    cko = ckp     - params.betaf*errorcksum ; 
                    dko = dkp     + params.betab*errordksum ;
                    eko = ekp     - params.betae*erroreksum ; 
                    fko = fkp     + params.betag*errorfksum ;
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
                    
                    pxx =  erroreksum(1,:) ;
                    pxy =  erroreksum(2,:) ;
                    pxx1 =  errorfksum(1,:)  ;
                    pxy1 =  errorfksum(2,:)   ;
                    eko(1,:)= ekp(1,:)     - params.betaf*pxx ;
                    eko(2,:)= ekp(2,:)     - params.betaf*pxy ;
                    eko(3,:)= ekp(3,:)     + params.betaf*conj(pxy) ;
                    eko(4,:)= ekp(4,:)     - params.betaf*conj(pxx) ;
                    fko(1,:)= fkp(1,:)     - params.betag*pxx1 ;
                    fko(2,:)= fkp(2,:)     - params.betag*pxy1 ;
                    fko(3,:)= fkp(3,:)     + params.betag*conj(pxy1) ;
                    fko(4,:)= fkp(4,:)     - params.betag*conj(pxx1) ;
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
        end 
    else
        cko = ckp   ;
        dko = dkp    ;
        eko = ekp   ;
        fko = fkp    ;
        e3ko = e3kp   ;
        f3ko = f3kp    ;
        dc1o = dc1p   ;
        dc2o = dc2p    ;
    end
    if ( params.real_coef == 1 &&  params.type == 4 && params.skewcomp_en == 0)
        cko = real(cko)   ;
        dko = real(dko)    ;
        eko = real(eko)   ;
        fko = real(fko)    ;
        e3ko = real(e3ko)   ;
        f3ko = real(f3ko)    ;
        dc1o = real(dc1o)   ;
        dc2o = real(dc2o)    ;
    end
    
    cko1 = fie_c(cko, params.T.CK);
    dko1 = fie_c(dko, params.T.DK);
    
    
    if ( params.fixed_bit == 2 )
    end
end
