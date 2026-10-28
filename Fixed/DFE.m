function [AOUT, dfeout, decided, coef1, coefp1, P_mat] = ...
     DFE(AIN, training_seq, is_training_seq, filtertap_update, prev_decided, coef, coefp, P_mat, params) 
 
%  Usage      : [AOUT, dfeout, coef, coefp] = DFE1(  AIN, training_seq, is_training_seq,
%                                filtertap_update, prev_decided, coef, coefp, params)
%  Function   :
%     Decision feedback equalizer ( Decision directed FFE included)
%
%  Port       :
%     1. AIN  :
%     2. training_seq  : Training seq.
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
    OV          = params.OV;    
    T           = params.T; 
  
    
    coef1  = complex( zeros(size(coef)));
    coefp1 = complex( zeros(size(coef)));
    P_mat  = complex(P_mat);

    %%    Main part 
    [ck, dk, ek, fk, e3k, f3k, dc1, dc2] = coef_init(coef, params);
    [ckp, dkp, ekp, fkp, e3kp, f3kp, dc1p, dc2p] = coef_init(coefp, params);

    ck1 = fie_c(ck, params.T.CK);
    dk1 = fie_c(dk, params.T.DK); 
    [ffesum ] = feedforward_filter ( AIN, ck1, ek, e3k, dc1, dc2,  params);

    %% Feedback filter
    [equalized, decided, ffeout, ffeout1] = feedback_filter(ffesum, training_seq, prev_decided, dk1, fk, f3k, is_training_seq, params);


     [errorsum, P_mat]= FilterAlgorithm ( AIN, prev_decided, decided, ...
            equalized, P_mat, ck1, dk1, ek, fk, e3k, f3k, dc1, dc2, params);


     [cko, dko, eko, fko, e3ko, f3ko, dc1o, dc2o] = CoefUpdate( ...
                     filtertap_update, ckp, dkp, ekp, fkp, ...
                   e3kp, f3kp, dc1p, dc2p, errorsum, params);
    
    %% For debugging
    if ( sum(sum(abs(cko))) < 200  )
        coefo = [cko dko reshape(eko, size(eko,1), params.Ndpfe,1), ...
                 fko, reshape(e3ko, size(e3ko,1), params.Ndp3fe,1), ...
                 f3ko, dc1o, dc2o ];
        coef1(:, 1:size(coefo,2)) = coefo;        
        coefp1(:, 1:size(coefo,2)) = coefo;     
    else
        coef1 = coef;
        coefp1 = coefp;
    end

    dfeout.ffeout = ffeout;
    dfeout.ffeout1 = ffeout1;
    
    AOUT = ffesum ;
    AOUT(:, 1:OV:end) = equalized;
    dfeout.decided = decided;
    dfeout.ffe_error = sum(errorsum.errorcksum, 2);
    dfeout.error = sum(errorsum.dec_error, 2);
end

% function [ffeout, ffe, vffe, v3ffe ] = feedforward_filter  ...
%                                 ( AIN, ck, ek, e3k, dc1, dc2,  params  )
%     PRL         = params.PRL * params.OV;
%     NStream     = params.NStream;
%     ffe         = complex( zeros(params.NStream, PRL) );     
%     %% Feedforware filter
%     for os=1:params.NStream 
%         for idx=1:PRL 
%             ffe_mul = sum((AIN(:,idx:idx+params.Nffe -1) + dc2(os:NStream:end)* ones(1,params.Nffe ) ).* ck(os:NStream:end, :),2);
%             ffe(os, idx) = sum( ffe_mul ) ;        
%         end
%         ffe(os, :) = ffe(os,:) + dc1(os);      
%     end
%     
%     [vffe]  = volterra_fe  ( AIN,  ek, params);
%     [v3ffe] = volterra3_fe ( AIN, e3k, params);
%     ffeout = ffe + vffe + v3ffe;
% end

% function   [equalized, decided, ffeout, ffeout1 ] = feedback_filter...
%                              ( ffesum, DIN1, prev_decided, dk, fk, f3k, is_training_seq, params) 
%     PRL         = params.PRL;
%     OV          = params.OV;  
%     block_size  = params.block_size;    
%     NStream     = params.NStream;
%     training_seq         = [prev_decided(:,end) DIN1 ];
% 
%     ak =complex( [prev_decided(:, end:-1:end-size(dk,2)+1) ]);
%     ffeout      = complex( zeros(params.NStream, PRL * OV) );
%     ffeout = ffesum;
%     ffeout1= ffesum;
%     fbe  = complex(zeros(params.NStream, PRL));
%     vfbe = complex(zeros(params.NStream, PRL));
%     v3fbe = complex(zeros(params.NStream, PRL));
%     is_block_start =  zeros(1, PRL);
%     if ( params.en_block_termination == 1 )      
%         is_block_start = double( mod([1:PRL], block_size) == 1);
%     end
%     if ( params.en_block_termination == 2 )
%         is_block_start = double( mod([1:PRL], block_size) == 0);
%     end
%     equalized = complex(zeros(params.NStream, PRL));
%     decided = complex(zeros(params.NStream, PRL));
%     for idx=1:PRL 
%         for os=1:params.NStream 
%             if ( is_block_start(idx) == 1 )
%                 ak(:,1) = training_seq(os,idx);
%             end
%             ak2=ak;
%             if (params.skewcomp_en == 2 )
%                ak2 = [ak; conj(ak)];
%             end
%             fbe(os, idx)   = sum(sum(ak2 .* dk(os:NStream:end,:)));
%             vfbe(os, idx)  = sum(sum(ak2(:, 1:params.Npbe) .^ 2 .* fk(os:NStream:end,:))); % Volterra 2nd order
%             v3fbe(os, idx) = sum(sum(ak2(:, 1:params.Np3be) .^3 .* f3k(os:NStream:end,:))); % Volterra  3rd order
% 
%             equalized(os,idx) =  ffesum(os, (idx-1)*OV+1) +  ...
%                                 fbe(os,idx)+ vfbe(os,idx)+ v3fbe(os,idx);
% 
%             ffeout(os, (idx-1)*OV+1) = equalized(os,idx) - sum(sum(ak2(:,1:params.Nfilter) .* dk(os:NStream:end,1:params.Nfilter))); 
%             decided(os,idx) = slicer( equalized(os,idx), training_seq(os,idx+1),is_training_seq,idx,params);
%         end
%         
%         
%         ak =[ decided(:,idx) ak(:,1: params.Nfbe -1)];
%     end
% end
% 
% 
% function [dec] = slicer ( in, din, is_training_seq, symbol_idx, params  )
%     if ( is_training_seq == 1 )        
%         if ( params.cost_function == 4 )
%             dec = din;            
%             dec = in * abs(dec)/ abs(in);
%         else
%             dec = din;
%         end
%         
%         return;
%     end 
%     if ( params.no_slicer == 1 )
%         dec =  in;
%         return;
%     end
% 
%     is_block_end = 0;
%     if ( params.en_block_termination == 1)      
%         is_block_end = double(mod(symbol_idx, params.block_size) == 0);
%     end 
%     if ( params.en_block_termination == 2 )
%         is_block_end = double(mod(symbol_idx, params.block_size) == 1);
%     end
% 
%     if (is_block_end == 1 )
%         dec = din;
%     else
%         if ( params.cost_function == 4 )
%             distance = abs(abs( in) -  abs(params.mapper_list ));
%             [~, I] = min( distance  );
%             dec =  params.mapper_list(I);            
%         else 
%             distance = abs( in -  params.mapper_list        ).^2;
%             [~, I] = min( distance  );
%             dec =  params.mapper_list(I);
%         end 
%     end
%     if ( params.cost_function == 4 )
%         dec = in * abs(dec)/ abs(in);
%     end 
% end



% function [cko, dko, eko, fko, e3ko, f3ko, dc1o, dc2o] = ...
%         CoefUpdate( filtertap_update, ckp, dkp, ekp, fkp, e3kp, f3kp, dc1p, dc2p, errorsum, params);
%     
%     errorcksum   = errorsum.errorcksum;
%     errordksum   = errorsum.errordksum;
%     erroreksum   = errorsum.erroreksum;
%     errorfksum   = errorsum.errorfksum;
%     errore3ksum  = errorsum.errore3ksum;
%     errorf3ksum  = errorsum.errorf3ksum;
%  %   errordc1sum  = errorsum.errordc1sum;
% %     errordc2sum  = errorsum.errordc2sum;
%     if ( filtertap_update )
%         if ( params.type == 5 ) % RLS 
%             cko  = ckp     + errorcksum;            
%             dko  = dkp   + errordksum;            
%             eko = ekp   + erroreksum;
%             fko = fkp    ;
%             e3ko = e3kp + errore3ksum ;
%             f3ko = f3kp    ;
%             dc1o = dc1p + params.betadc1 * errordc1sum;
%             dc2o = 0 ;
%         else 
%             dc1o = dc1p ;%- params.betadc1 * errordc1sum;
%             dc2o =  dc2p; %- params.betadc2 * errordc2sum;
%             switch params.update_type
%                 case 1
%                     cko  = ckp     - params.betaf*errorcksum ;
%                     dko  = dkp     - params.betab*errordksum ;
%                     eko  = ekp     - params.betae*erroreksum ;
%                     fko  = fkp     - params.betag*errorfksum ;
%                     e3ko = e3kp     - params.betae3 * errore3ksum ;
%                     f3ko = f3kp     - params.betag3 * errorf3ksum ; 
%                 case 4
%                     cko  = ckp     - params.betaf*real(errorcksum) ;
%                     dko  = dkp     - params.betab*real(errordksum) ;
%                     eko  = ekp     - params.betae*real(erroreksum) ;
%                     fko  = fkp     - params.betag*real(errorfksum) ;
%                     e3ko = e3kp     - params.betae3 * real(errore3ksum) ;
%                     f3ko = f3kp     - params.betag3 * real(errorf3ksum) ;
%                 case 2
%                     cko = ckp     - params.betaf*errorcksum ; 
%                     dko = dkp     + params.betab*errordksum ;
%                     eko = ekp     - params.betae*erroreksum ; 
%                     fko = fkp     + params.betag*errorfksum ;
%                     pxx =  errorcksum(1,:) ;
%                     pxy =  errorcksum(2,:) ;
%                     pxx1 =  errordksum(1,:)  ;
%                     pxy1 =  errordksum(2,:)   ;
%                     cko(1,:)= ckp(1,:)     - params.betaf*pxx ;
%                     cko(2,:)= ckp(2,:)     - params.betaf*pxy ;
%                     cko(3,:)= ckp(3,:)     + params.betaf*conj(pxy) ;
%                     cko(4,:)= ckp(4,:)     - params.betaf*conj(pxx) ;
%                     dko(1,:)= dkp(1,:)     - params.betab*pxx1 ;
%                     dko(2,:)= dkp(2,:)     - params.betab*pxy1 ;
%                     dko(3,:)= dkp(3,:)     + params.betab*conj(pxy1) ;
%                     dko(4,:)= dkp(4,:)     - params.betab*conj(pxx1) ;
%                     
%                     pxx =  erroreksum(1,:) ;
%                     pxy =  erroreksum(2,:) ;
%                     pxx1 =  errorfksum(1,:)  ;
%                     pxy1 =  errorfksum(2,:)   ;
%                     eko(1,:)= ekp(1,:)     - params.betaf*pxx ;
%                     eko(2,:)= ekp(2,:)     - params.betaf*pxy ;
%                     eko(3,:)= ekp(3,:)     + params.betaf*conj(pxy) ;
%                     eko(4,:)= ekp(4,:)     - params.betaf*conj(pxx) ;
%                     fko(1,:)= fkp(1,:)     - params.betag*pxx1 ;
%                     fko(2,:)= fkp(2,:)     - params.betag*pxy1 ;
%                     fko(3,:)= fkp(3,:)     + params.betag*conj(pxy1) ;
%                     fko(4,:)= fkp(4,:)     - params.betag*conj(pxx1) ;
%                 otherwise
%                     cko  = 0 * ckp ;
%                     dko  = 0 * dkp ;
%                     eko  = 0 * ekp ;
%                     fko  = 0 * fkp ;
%                     e3ko = 0 * e3kp ;
%                     f3ko = 0 * f3kp ;
%                     sidx = [0:params.NStream-1] * ( params.NStream +1)+1;
%                     cko(sidx,:)= ckp(sidx,:)     - params.betaf*errorcksum(sidx,:) ;
%                     dko(sidx,:)= dkp(sidx,:)     - params.betab*errordksum(sidx,:) ;
%                     eko(sidx,:)= ekp(sidx,:)     - params.betae*erroreksum(sidx,:) ;
%                     fko(sidx,:)= fkp(sidx,:)     - params.betag*errorfksum(sidx,:) ;
%                     e3ko(sidx,:)= e3kp(sidx,:)   - params.betae3*errore3ksum(sidx,:) ;
%                     f3ko(sidx,:)= f3kp(sidx,:)   - params.betag3*errorf3ksum(sidx,:) ;
%             end
%         end 
%     else
%         cko = ckp   ;
%         dko = dkp    ;
%         eko = ekp   ;
%         fko = fkp    ;
%         e3ko = e3kp   ;
%         f3ko = f3kp    ;
%         dc1o = dc1p   ;
%         dc2o = dc2p    ;
%     end
%     if ( params.real_coef == 1 &&  params.type == 4 && params.skewcomp_en == 0)
%         cko = real(cko)   ;
%         dko = real(dko)    ;
%         eko = real(eko)   ;
%         fko = real(fko)    ;
%         e3ko = real(e3ko)   ;
%         f3ko = real(f3ko)    ;
%         dc1o = real(dc1o)   ;
%         dc2o = real(dc2o)    ;
%     end
% end


function [errorsum, next_P_mat]= FilterAlgorithm ( AIN, prev_decided, decided, ...
         equalized, P_mat, ck, dk,  ek, fk, e3k, f3k, dc1, dc2, params)
    next_P_mat = complex(P_mat);
    errorsum.erroreksum =complex(zeros(size(ek)));
    errorsum.errorfksum =complex(zeros(size(fk)));
    errorsum.errore3ksum =complex(zeros(size(e3k)));
    errorsum.errorf3ksum =complex(zeros(size(f3k)));
    errorsum.errordc1sum =complex(zeros(size(dc1)));
    errorsum.errordc2sum =complex(zeros(size(dc2)));
    PRL = params.PRL * params.OV;
    switch params.type
        case {1 6}
            [errorsum] = LMS ( AIN, prev_decided, decided, ...
                         equalized, ck, dk,  ek, fk, e3k, f3k, dc1, dc2, params );
%         case 2 
%             errorsum = CMA ( AIN, equalized, ck, dk, ek, fk, e3k, f3k, dc1, dc2, PRL,  params.OV );
%         case 3
%             errorsum = MMA ( AIN, equalized, ck, dk, ek, fk, e3k, f3k, dc1, dc2, PRL,  params.OV );
%         case 4
%             [errorsum ]= RDE ( AIN, prev_decided, decided, equalized, ck, dk, ek, fk, e3k, f3k, dc1, dc2, params );
%         case 5
%             [errorsum, next_P_mat] = RLS ( AIN, prev_decided, decided, ...
%                          equalized, P_mat, ck, dk,  ek, fk, e3k, f3k, dc1, dc2, params );
        otherwise
    end
    errorsum.errordc1sum = sum(errorsum.dec_error, 2)  ;
    
    
end




% function [errorsum] = LMS ( AIN, prev_decided, decided, equalized, ...
%                             ck, dk, ek, fk, e3k, f3k, dc1, dc2,  params )
% 
%     PRL     =params.PRL * params.OV;
%     OV      =params.OV;
%     errorck     = complex(zeros([size(ck), PRL/OV]));
%     errordk     = complex(zeros([size(dk), PRL/OV]));
%     errorek     = complex(zeros([size(ek,1),size(ek,2), size(ek,3), PRL/OV]));
%     errorfk     = complex(zeros([size(fk), PRL/OV]));
%     errore3k    = complex(zeros([size(e3k,1),size(e3k,2), size(e3k,3), PRL/OV]));
%     errorf3k    = complex(zeros([size(f3k), PRL/OV]));
%     errorcksum  = complex(zeros(size(ck)));
%     errordksum  = complex(zeros(size(dk)));
%     erroreksum  = complex(zeros(size(ek)));
%     errorfksum  = complex(zeros(size(fk)));
%     errore3ksum = complex(zeros(size(e3k)));
%     errorf3ksum = complex(zeros(size(f3k)));
%     errordc2sum = complex(zeros(size(dc2)));
%     dec = [prev_decided(:,end-size(dk,2)+1:end) decided(:,1:end)];
% %     if ( params.skewcomp_en == 2 )
% %         dec =[dec; conj(dec);];
% %     end 
%     dec_error = -decided + equalized;
%     decided2 = [prev_decided(:,end-params.Npbe+1:end) decided(:,1:end)];
%     decided3 = [prev_decided(:,end-params.Np3be+1:end) decided(:,1:end)];
% 
%    
%     NStream = size(decided,1);
%     for is= 1:size(AIN,1)
%         for os= 1:NStream
%             sidx = (is - 1 )* NStream + os ; % equation index 
%             for idx= 1:size(ck,2)
%                 errorck(sidx, idx,:) = dec_error(os,:) .* conj(AIN(is, idx +(0:OV:PRL-1)) + dc2(os+(is-1)*NStream));
%                 errorcksum(sidx, idx)=sum( errorck(sidx, idx,: )) ;
%             end
%             for iW= 1:params.W % W : w=0:PE ...W-1: 
%                 offset = floor(params.Npostcursor - (params.Npfe-1) /2);
%                 for idx= 1:size(ek,2)
%                     AIN1 = AIN(is, idx+offset +(0:OV:PRL-1));
%                     AIN2 = AIN(is, idx+offset +(iW-1)+0+(0:OV:PRL-1));
%                     errorek(sidx, idx, iW, :) = dec_error(os,:) .* conj(AIN1 .* AIN2 ); 
%                     erroreksum(sidx, idx, iW)=sum( errorek(sidx, idx, iW, :)) ;
%                 end
%             end
%             iW = 0;
%             for iW1= 1:params.W3
%                 offset = floor(params.Npostcursor - (params.Np3fe-1) /2);
%                 for iW2= iW1:params.W3
%                     iW = iW+1;
%                     for idx= 1:size(e3k,2) % Np3fe
%                         AIN1 = AIN(is, idx+offset +(0:OV:PRL-1));
%                         AIN2 = AIN(is, idx+offset +(iW1-1)+0+(0:OV:PRL-1));
%                         AIN3 = AIN(is, idx+offset +(iW2-1)+0+(0:OV:PRL-1));
%                         errore3k(sidx, idx, iW, :) = dec_error(os,:) .* conj(AIN1 .* AIN2 .* AIN3 );
%                         errore3ksum(sidx, idx, iW)=sum( errore3k(sidx, idx, iW, :)) ;
%                     end
%                 end
%             end
%             for idx=1:size(dk,2)
%                 idx1 = size(dk,2) - idx + 1;
%                 errordk(sidx,idx,:) = dec_error(os,:) .* conj(dec(is, idx1+(0:size(dec_error,2)-1)));
%                 errordksum(sidx,idx)  = sum( errordk(sidx, idx, :) * 1) ;
%             end
%             for idx=1:size(fk,2)
%                 idx1 = size(fk,2) - idx + 1;
%                 errorfk(sidx,idx,:) = dec_error(os,:) .* conj(decided2(is, idx1+(0:size(dec_error,2)-1)) .^2);
%                 errorfksum(sidx,idx)  = sum( errorfk(sidx, idx, :) * 1) ;
%             end
%             for idx=1:size(f3k,2)
%                 idx1 = size(f3k,2) - idx + 1;
%                 errorf3k(sidx,idx,:) = dec_error(os,:) .* conj(decided3(is, idx1+(0:size(dec_error,2)-1)) .^3);
%                 errorf3ksum(sidx,idx)  = sum( errorf3k(sidx, idx, :) * 1) ;
%             end
% %             errordc2(sidx, :) = dec_error(os,:) * sum(conj(ck(is, :)));
% %             errordc2sum(sidx)=sum( errordc2(sidx, : )) ;
%         end        
%     end
% 
%     errorsum.errorcksum   = errorcksum;
%     errorsum.errordksum   = errordksum;
%     errorsum.erroreksum   = erroreksum;
%     errorsum.errorfksum   = errorfksum;
%     errorsum.errore3ksum  = errore3ksum;
%     errorsum.errorf3ksum  = errorf3ksum;
%     errorsum.errordc2sum  = errordc2sum;
%     errorsum.dec_error    = dec_error;  
% 
% end

% function [errorsum ]= CMA ( AIN, equalized, ck, dk, ek, fk, e3k, f3k, dc1, dc2, PRL,  OV )
% 
%     errorck    = complex( zeros([size(ck), PRL/OV]));
%     errorcksum = complex( zeros(size(ck)));
%     errordksum = complex( zeros(size(dk)));
%     erroreksum  = complex(zeros(size(ek)));
%     errorfksum  = complex(zeros(size(fk)));
%     errore3ksum = complex(zeros(size(e3k)));
%     errorf3ksum = complex(zeros(size(f3k)));
%     dec_error      = 1 -  equalized .* conj ( equalized );
%     sign_err   = sign(-dec_error);
% 
%     NStream = size(equalized,1);
%     for is= 1:size(AIN,1)
%         for os= 1:NStream
%             sidx = (is - 1 )* NStream + os ; % equation index 
%             for idx= 1:size(ck,2)
%                 errorck(sidx, idx, :) = dec_error(os,:) .* equalized(os,:) .* conj(AIN(is, idx +(0:OV:PRL-1)));
%                 errorcksum(sidx, idx)  =  -sum( errorck(sidx, idx,: )) ;
%             end
%         end
%     end
%     errorsum.errorcksum   = errorcksum;
%     errorsum.errordksum   = errordksum;
%     errorsum.erroreksum   = erroreksum;
%     errorsum.errorfksum   = errorfksum;
%     errorsum.errore3ksum  = errore3ksum;
%     errorsum.errorf3ksum  = errorf3ksum;
%     errorsum.dec_error    = dec_error;  
% 
% end
  
% function [errorsum ]= MMA ( AIN, equalized, ck, dk, ek, fk, e3k, f3k, dc1, dc2, PRL,  OV )
% 
%     errorck    = complex( zeros([size(ck), PRL/OV]));
%     errorcksum = complex( zeros(size(ck)));
%     errordksum = complex( zeros(size(dk)));
%     erroreksum  = complex(zeros(size(ek)));
%     errorfksum  = complex(zeros(size(fk)));
%     errore3ksum = complex(zeros(size(e3k)));
%     errorf3ksum = complex(zeros(size(f3k)));
% 
%     R1 = 1/sqrt(10)* sqrt(1+1);
%     R2 = 1/sqrt(10)* sqrt(1+3^2);
%     R3 = 1/sqrt(10)* sqrt(3^2+3^2);
%     A1 = 0.5 * (R1+R2);
%     A2 = 0.5 * (R3-R1);
%     A3 = 0.5 * (R3-R2);
% 
%     B = abs(equalized ) -A1;
%     C = abs(B ) -A2;
%     error      = abs(C ) - A3;
%     sign_err   = sign(C) .* sign( B ) .* sign(equalized);
% 
%     NStream = size(equalized,1);
%     for is= 1:size(AIN,1)
%         for os= 1:NStream
%             sidx = (is - 1 )* NStream + os ; % equation index 
%             for idx= 1:size(ck,2)
%                 errorck(sidx, idx, :) = error(os,:) .* sign_err(os,:) .* conj(AIN(is, idx +(0:OV:PRL-1)))  ;
%                 errorcksum(sidx, idx)  =   sum( errorck(sidx, idx,: )) ;
%             end
%         end
%     end
%     errorsum.errorcksum   = errorcksum;
%     errorsum.errordksum   = errordksum;
%     errorsum.erroreksum   = erroreksum;
%     errorsum.errorfksum   = errorfksum;
%     errorsum.errore3ksum  = errore3ksum;
%     errorsum.errorf3ksum  = errorf3ksum;
%     errorsum.dec_error    = dec_error;  
% 
% end
 
% function [errorsum]= RDE_LMS ( AIN, prev_decided, decided, equalized, ck, dk, ek,fk, e3k, f3k, dc1, dc2, params )
% 
%     OV         = params.OV; 
%     PRL        = params.PRL * params.OV;
%     errorck    = complex( zeros([size(ck), PRL/OV]));
%     errordk    = complex(zeros([size(dk,1),size(dk,2), size(dk,3), PRL/OV]));
%     errorek    = complex(zeros([size(ek,1),size(ek,2), size(ek,3), PRL/OV]));
%     errore3k    = complex(zeros([size(e3k,1),size(e3k,2), size(e3k,3), PRL/OV]));
%     errorcksum = complex( zeros(size(ck)));
%     errordksum = complex( zeros(size(dk)));
%     erroreksum = complex(zeros(size(ek)));
%     errorfksum = complex(zeros(size(fk)));
%     errore3ksum = complex(zeros(size(e3k)));
%     errorf3ksum = complex(zeros(size(f3k)));
%     dec = [prev_decided(:,end-size(dk,2)+1:end) decided(:,1:end)];
%     if ( params.skewcomp_en == 2 )
%         dec =[dec; conj(dec);];
%     end 
%     if( params.skewcomp_en == 1 )
%         decided1 = complex(decided(1:2:end, :) , decided(2:2:end, :) );
%         equalized1 = complex(equalized(1:2:end, :) , equalized(2:2:end, :) );
%         abs_error1 = -decided1 + equalized1;
%         abs_error = zeros(size(abs_error1,1)*2, size(abs_error1,2));
%         abs_error(1:2:end, :) =  abs_error1;
%         abs_error(2:2:end, :) =  abs_error1;
%     else         
%         abs_error = -decided + equalized;
%     end
%     
%     NStream = size(equalized,1);
%     for is= 1:size(AIN,1)
%         for os= 1:NStream
%             sidx = (is - 1 )* NStream + os ; % equation index 
%             for idx= 1:size(ck,2)
%                 errorck(sidx, idx, :) = abs_error(os,:) .*  conj(AIN(is, idx +(0:OV:PRL-1)));
%                 errorcksum(sidx, idx) = sum( errorck(sidx, idx,: )) ;
%             end
%             for iW= 1:params.W % W : w=0:PE ...W-1: 
%                 offset = floor(params.Npostcursor - (params.Npfe-1) /2);
%                 for idx= 1:size(ek,2)
%                     AIN1 = AIN(is, idx+offset +(0:OV:PRL-1));
%                     AIN2 = AIN(is, idx+offset +(iW-1)+0+(0:OV:PRL-1));
%                     errorek(sidx, idx, iW, :) = abs_error(os,:) .* conj(AIN1 .* AIN2 ); 
%                     erroreksum(sidx, idx, iW)=sum( errorek(sidx, idx, iW, :)) ;
%                 end
%             end
%             iW = 0;
%             for iW1= 1:params.W3
%                 offset = floor(params.Npostcursor - (params.Np3fe-1) /2);
%                 for iW2= iW1:params.W3
%                     iW = iW+1;
%                     for idx= 1:size(e3k,2) % Np3fe
%                         AIN1 = AIN(is, idx+offset +(0:OV:PRL-1));
%                         AIN2 = AIN(is, idx+offset +(iW1-1)+0+(0:OV:PRL-1));
%                         AIN3 = AIN(is, idx+offset +(iW2-1)+0+(0:OV:PRL-1));
%                         errore3k(sidx, idx, iW, :) = abs_error(os,:) .* conj(AIN1 .* AIN2 .* AIN3 );
%                         errore3ksum(sidx, idx, iW)=sum( errore3k(sidx, idx, iW, :)) ;
%                     end
%                 end
%             end 
%             for idx=1:size(dk,2)
%                 idx1 = size(dk,2) - idx + 1;
%                 errordk(sidx,idx,:) = abs_error(os,:) .* conj(dec(is, idx1+(0:size(abs_error,2)-1)));
%                 errordksum(sidx,idx)  = sum( errordk(sidx, idx, :) * 1) ;
%             end
%         end
%     end     
%     errorsum.errorcksum   = errorcksum;
%     errorsum.errordksum   = errordksum;
%     errorsum.erroreksum   = erroreksum;
%     errorsum.errorfksum   = errorfksum;
%     errorsum.errore3ksum  = errore3ksum;
%     errorsum.errorf3ksum  = errorf3ksum;
%     errorsum.dec_error    = abs_error;  
% end

%% Radius directed equalizer 
% function [errorsum]= RDE ( AIN, prev_decided, decided, equalized, ck, dk, ek,fk, e3k, f3k, dc1, dc2, params )
% 
%     OV         = params.OV; 
%     PRL        = params.PRL * params.OV;
%     errorck    = complex( zeros([size(ck), PRL/OV]));
%     errordk    = complex(zeros([size(dk,1),size(dk,2), size(dk,3), PRL/OV]));
%     errorek    = complex(zeros([size(ek,1),size(ek,2), size(ek,3), PRL/OV]));
%     errore3k    = complex(zeros([size(e3k,1),size(e3k,2), size(e3k,3), PRL/OV]));
%     errorcksum = complex( zeros(size(ck)));
%     errordksum = complex( zeros(size(dk)));
%     erroreksum = complex(zeros(size(ek)));
%     errorfksum = complex(zeros(size(fk)));
%     errore3ksum = complex(zeros(size(e3k)));
%     errorf3ksum = complex(zeros(size(f3k)));
%     dec = [prev_decided(:,end-size(dk,2)+1:end) decided(:,1:end)];
% %     if ( params.skewcomp_en == 2 )
% %         dec =[dec; conj(dec);];
% %     end 
% %     if( params.skewcomp_en == 1 )
% %         decided1 = complex(decided(1:2:end, :) , decided(2:2:end, :) );
% %         equalized1 = complex(equalized(1:2:end, :) , equalized(2:2:end, :) );
% %         abs_error1 = decided1 .* conj(decided1) -  equalized1 .* conj ( equalized1 );
% %         abs_error = zeros(size(abs_error1,1)*2, size(abs_error1,2));
% %         abs_error(1:2:end, :) =  abs_error1;
% %         abs_error(2:2:end, :) =  abs_error1;
% %     else 
%         abs_error  = decided .* conj(decided) -  equalized .* conj ( equalized );
% %     end
%     W = size(ek, 3);
% 
% 
%     NStream = size(equalized,1);
%     for is= 1:size(AIN,1)
%         for os= 1:NStream
%             sidx = (is - 1 )* NStream + os ; % equation index 
%             for idx= 1:size(ck,2)
%                 errorck(sidx, idx, :) = -abs_error(os,:) .* equalized(os,:) .* conj(AIN(is, idx +(0:OV:PRL-1)));
%                 errorcksum(sidx, idx) = sum( errorck(sidx, idx,: )) ;
%             end
%             for iW= 1:params.W % W : w=0:PE ...W-1: 
%                 offset = floor(params.Npostcursor - (params.Npfe-1) /2);
%                 for idx= 1:size(ek,2)
%                     AIN1 = AIN(is, idx+offset +(0:OV:PRL-1));
%                     AIN2 = AIN(is, idx+offset +(iW-1)+0+(0:OV:PRL-1));
%                     errorek(sidx, idx, iW, :) = abs_error(os,:) .* equalized(os,:) .* conj(AIN1 .* AIN2 ); 
%                     erroreksum(sidx, idx, iW)=sum( errorek(sidx, idx, iW, :)) ;
%                 end
%             end
%             iW = 0;
%             for iW1= 1:params.W3
%                 offset = floor(params.Npostcursor - (params.Np3fe-1) /2);
%                 for iW2= iW1:params.W3
%                     iW = iW+1;
%                     for idx= 1:size(e3k,2) % Np3fe
%                         AIN1 = AIN(is, idx+offset +(0:OV:PRL-1));
%                         AIN2 = AIN(is, idx+offset +(iW1-1)+0+(0:OV:PRL-1));
%                         AIN3 = AIN(is, idx+offset +(iW2-1)+0+(0:OV:PRL-1));
%                         errore3k(sidx, idx, iW, :) = abs_error(os,:) .* equalized(os,:) .* conj(AIN1 .* AIN2 .* AIN3 );
%                         errore3ksum(sidx, idx, iW)=sum( errore3k(sidx, idx, iW, :)) ;
%                     end
%                 end
%             end 
%             for idx=1:size(dk,2)
%                 idx1 = size(dk,2) - idx + 1;
%                 errordk(sidx,idx,:) = -abs_error(os,:).* equalized(os,:) .* conj(dec(is, idx1+(0:size(abs_error,2)-1)));
%                 errordksum(sidx,idx)  = sum( errordk(sidx, idx, :) * 1) ;
%             end
%         end
%     end     
%     errorsum.errorcksum   = errorcksum;
%     errorsum.errordksum   = errordksum;
%     errorsum.erroreksum   = erroreksum;
%     errorsum.errorfksum   = errorfksum;
%     errorsum.errore3ksum  = errore3ksum;
%     errorsum.errorf3ksum  = errorf3ksum;
%     errorsum.dec_error    = abs_error;  
% end
%  

% function [errorsum, next_P_mat] = RLS ( AIN, prev_decided, decided, equalized, ...
%                             P_mat, ck, dk, ek, fk, e3k, f3k, dc1, dc2, params )
% 
%     PRL     =params.PRL * params.OV;
%     OV      =params.OV;
%     next_P_mat = P_mat;
%     
%     dec = [prev_decided(:,end-size(dk,2)+1:end) decided(:,1:end)];
% %     if ( params.skewcomp_en == 2 )
% %         dec =[dec; conj(dec);];
% %     end 
%     dec_error = decided - equalized;
%     decided2 = [prev_decided(:,end-params.Npbe+1:end) decided(:,1:end)];
%     decided3 = [prev_decided(:,end-params.Np3be+1:end) decided(:,1:end)];
% 
%     NStream = size(decided,1); 
%     RLStap = size(P_mat, 2);
%     Nffe =  size(ck,2);
%     W    =  size(ek,3);
%     Npfe =  size(ek,2);    
%     W3   =  params.W3;
%     Np3fe =  params.Np3fe;   
%     Nfbe = RLStap - Nffe - params.Ndpfe - params.Ndp3fe;
%     gn_inv   = zeros( size(ck,1), PRL/OV);  
%     gn         = zeros( size(ck,1), RLStap, PRL/OV);    
%     P0         = zeros(RLStap, RLStap,   PRL/OV,1);  
%     errorck   = complex(zeros([size(ck), PRL/OV]));
%     errorcksum  = complex(zeros(size(ck)));
%     errordk   = complex(zeros([size(dk,1), Nfbe, PRL/OV]));
%     errordksum  = complex(zeros(size(dk)));
%     errordksum1  = complex(zeros([size(dk,1), Nfbe]));
%     errorek   = complex(zeros(size(ek,1),  params.Ndpfe, PRL/OV));
%     erroreksum  = complex(zeros(size(ek)));
%     errore3k  = complex(zeros([size(e3k,1), params.Ndp3fe, PRL/OV]));
%     errore3ksum  = complex(zeros(size(e3k)));
%     NSymbol =  PRL/OV;
%     x2n = zeros(size(AIN,1), size(AIN,2), W);
%     x3n = zeros(size(AIN,1), size(AIN,2), W3*(W3-1)/2);
%     for iW= 1: W
%         x2n(:,1:size(AIN,2)-iW+1,iW) = AIN(:,1:size(AIN,2)-iW+1) .* AIN(:,iW:size(AIN,2)); 
%     end
%     iW3=0;
%     for iW1= 1:W3
%         for iW2=iW1:W3
%             iW3=iW3+1;
%             x3n(:,1:size(AIN,2)-iW2+1,iW3) = AIN(:,1:size(AIN,2)-iW2+1) .*  ...
%                                              AIN(:,(iW1-1)+(1:size(AIN,2)-iW2+1)) .*  ...
%                                              AIN(:,(iW2-1)+(1:size(AIN,2)-iW2+1));
%         end
%     end
%     offset = floor(params.Npostcursor - (params.Npfe-1) /2);
%     offset3 = floor(params.Npostcursor - (params.Np3fe-1) /2);
%     
%     for is= 1: size(AIN,1)
%         for os= 1:NStream
%             idx2 = (is-1)*NStream+os;
%             P_mat1 = reshape(P_mat(idx2,:),  RLStap, RLStap);
%             for idx=1:NSymbol
%                 xn = [AIN(is, (idx-1)*OV+1:(idx-1)*OV+params.Nffe) dec(is, idx+(Nfbe-1:-1:0))] ;
%                 for iW=1:W
%                     xn = [xn reshape(x2n(is, offset+idx+(0:Npfe-1), iW), 1, Npfe)];
%                 end
%                 iW3=0;
%                 for iW1= 1:W3
%                     for iW2=iW1:W3
%                         iW3=iW3+1;
%                         xn = [xn reshape(x3n(is, offset3+idx+(0:Np3fe-1), iW3), 1, Np3fe)];
%                     end
%                 end
%                 gn_inv(idx2, idx) = params.lambda + conj(xn)*P_mat1*transpose(xn);
%                 gn(idx2, :, idx) = 1/gn_inv(idx2, idx) * ( P_mat1*transpose(xn));
%                 P0(:,:, idx) =  transpose(gn(idx2, :, idx)) * conj(xn)*P_mat1;
%                 error_tmp =  conj(dec_error(os, idx)) *   gn(idx2, :, idx) ;
%                 errorck(idx2,:, idx)  = error_tmp(1,1:Nffe);
%                 errordk(idx2,:, idx)  = error_tmp(1,Nffe+1:Nffe+Nfbe);
%                 errorek(idx2,:, idx)  = error_tmp(1,Nffe+Nfbe+(1:params.Ndpfe));
%                 errore3k(idx2,:, idx)  = error_tmp(1,Nffe+Nfbe+(1:params.Ndp3fe));
%             end
%             errorcksum(idx2,:) = conj(sum( errorck(idx2,:,:), 3)/NSymbol);
%             erroreksum(idx2,:, :) = reshape( conj(sum( errorek(idx2,:,:), 3)/NSymbol),Npfe, W);
%             errore3ksum(idx2,:, :) = reshape( conj(sum( errore3k(idx2,:,:), 3)/NSymbol),Np3fe, W3*(W3+1)/2);
%             errordksum1(idx2,:) = conj(sum( errordk(idx2,:,:), 3)/NSymbol); 
%             next_P_mat(idx2,:,:) =   P_mat1  - sum(P0,3) /NSymbol   ;
%         end 
%     end 
% 
%     next_P_mat= params.lambda * next_P_mat;
%     errorsum.errorcksum   = errorcksum;
%     errorsum.errordksum   = errordksum;
%     if ( Nfbe ~= 0 )        
%         errorsum.errordksum   = errordksum1;
%     end
%     errorsum.erroreksum   = complex(zeros(size(ek)));
%     errorsum.erroreksum   = erroreksum;
%     errorsum.errorfksum   = complex(zeros(size(fk)));
%     errorsum.errore3ksum  = errore3ksum;
%     errorsum.errorf3ksum  = complex(zeros(size(f3k)));
%     errorsum.errordc1sum  = complex(zeros(size(dc1)));
%     errorsum.errordc2sum  = complex(zeros(size(dc2)));
%     errorsum.dec_error    = dec_error;
% 
% end
% 
% function [vffe] = volterra_fe ( in1, ek, params  )
%     PRL         = params.PRL * params.OV;
%     vffe    = complex( zeros(params.NStream, PRL));
%     if ( params.W == 0 || params.Npfe ==0 )
%         return;
%     end
% 
%     offset = floor(params.Npostcursor - (params.Npfe-1) /2);
%     in     = in1(:, offset+1:end);
%     W_1   = floor(params.W/2);
%     for os=1:params.NStream 
%         for idx=1:PRL 
%             for iW=1:params.W 
%                 vffe_mul =   in1(:,idx+offset+(0:params.Npfe -1)) .* ...
%                               in1(:,(iW-1)+0+(idx+offset)+(0:params.Npfe -1)) .* ...
%                                    ek(os:params.NStream:end, :, iW) ;
%                 vffe(os, idx) = vffe(os,idx) + sum( sum( vffe_mul, 2));
%             end
%         end
%     end
% end

% function [v3ffe] = volterra3_fe ( in1, e3k, params  )
%     PRL         = params.PRL * params.OV;
%     v3ffe    = complex( zeros(params.NStream, PRL));
%     if ( params.W3 == 0 || params.Np3fe ==0 )
%         return;
%     end
% 
%     offset = floor(params.Npostcursor - (params.Np3fe-1) /2);
%     in     = in1(:, offset+1:end);
%     for os=1:params.NStream
%         for idx=1:PRL
%             iW=0;
%             for iW1=1:params.W3
%                for iW2=iW1:params.W3
%                    iW=iW+1;
%                    v3ffe_mul =  in1(:,idx+offset+(0:params.Np3fe -1)) .* ...
%                                 in1(:,(iW1-1)+0+(idx+offset)+(0:params.Np3fe -1)) .* ...
%                                 in1(:,(iW2-1)+0+(idx+offset)+(0:params.Np3fe -1)) .* ...
%                                 e3k(os:params.NStream:end, :, iW) ;
%                    v3ffe(os, idx) = v3ffe(os,idx) + sum(sum( v3ffe_mul, 2));
%                 end
%             end
%         end
%     end
% end
% 

% function [vfbe] = volterra_be ( dec, fk, params  )
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
% end
% 
function [ck, dk, ek, fk, e3k, f3k, dc1, dc2] = coef_init(coef, params)

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
    dc1         = complex( coef(:,offidx +(params.Np3be)+1));
    dc2         = complex( coef(:,offidx +(params.Np3be)+2));
end

