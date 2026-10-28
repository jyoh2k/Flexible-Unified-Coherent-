function [AOUT, dfeout] = RxSymEqMex( AIN, trainingseq, params_org)  

%  Usage      : [AOUT, dfeout] = RxSymEqMex( AIN, trainingseq, params_org  
%
%  Function   :
%     Symbol-by-Symbol Equalizer  ( FFE, DFE)
%     Coefficient update algorithm LMS, CMA, MMA  
%
%  Port  :
%
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :
        
    params = AdjustMex1( params_org) ;
    %%  Initial value 
    [d1, d2] = size( AIN);
    DLY         = 0;
    PRL         = params.PRL; 
    OV         =  params.OV; 
    Npad        =   params.Npostcursor;
    if ( params.Nffe < 52   & params.Nfbe < 4  &  params.PRL == 128 ) 
        Npad = 25;
    end 
    zeropad     = ceil(d2/PRL)* PRL - d2;
   
    
    AIN1        = [zeros(d1, Npad), AIN, zeros(d1, params.Nffe +10 + zeropad)]; 
    zeropad1    = size(AIN1,2)-size(trainingseq, 2);
    %%
    if ( params.skewcomp_en  == 1 )
        trainingseq1 = zeros(size(trainingseq,1) * 2, size(trainingseq,2));
        trainingseq1(1:2:end,:) = real(trainingseq); 
        trainingseq1(2:2:end,:) = imag(trainingseq);
        trainingseq = trainingseq1;
        AIN2 = zeros(size(AIN1,1) * 2, size(AIN1,2));
        AIN2(1:2:end,:) = real(AIN1); 
        AIN2(2:2:end,:) = imag(AIN1);
        AIN1 = AIN2;
        d1 = d1 *2;
    end
    if ( params.skewcomp_en  == 2 )
        AIN2 = zeros(size(AIN1,1) * 2, size(AIN1,2));
        AIN2(1:size(AIN,1),:) = (AIN1); 
        AIN2(size(AIN,1)+1:end,:) = conj(AIN1);
        AIN1 = AIN2; 
    end
    %%
    trainingseq = [ trainingseq(1:params.NStream,:), zeros( d1, params.Nffe +10 + zeropad1)]; 
    AOUT        = zeros(params.NStream,  ceil(d2/params.OV) );
    err         = zeros(params.NStream, d2);
    ffe_error    = zeros(d1*params.NStream, d2);
     if ( params.skewcomp_en  == 2 )
         ffe_error    = zeros(d1*params.NStream*2, d2);
     end 
    [coef, coefp, Rinv] = CoefInit( AIN, trainingseq, params )  ;
        
    is_training_seq  = params.is_training_seq_init;
    filtertap_update = 0 ;
    prev_decided     = complex(zeros(params.NStream,params.Nfbe)) ;

    if ( params.en == 0 )
        dfeout.filtercoef    = params.filtertap;
        dfeout.error         = err(:,1:PRL:d2);
        dfeout.ffe_error     = ffe_error(:,1:PRL:d2);
        AOUT = AIN;
        return;
    end
    for iSa  =1:PRL:d2
        if ( iSa > params.training_seq_size * OV )
             is_training_seq  = 0;
        end
        if ( iSa > params.filtertap_update_size * OV )
             filtertap_update  = 1;
        end
        idx = iSa + ( 0:PRL+params.Nffe  );
        idx2= iSa + ( 0:1:PRL-1);
        idx3 = (iSa-1)/OV +  ( 1: PRL/OV);
        coef1 = complex(coef(:,:,iSa));
        if ( params.Nffe < 52   & params.Nfbe < 4  & PRL == 128 ) 
             if ( d1 == 1 )
                 [AOUT(:, idx2), dfeout1, decided, coef1, coefp, Rinv] = ...
                   DFE( AIN1(:,idx), trainingseq(:,idx3), ...
                         is_training_seq, filtertap_update, prev_decided, coef1, coefp, Rinv, params);
             else
                 switch ( length(params.mapper_list))
                     case 16 
                [AOUT(:, idx2), dfeout1, decided, coef1, coefp, Rinv] = ...
                   DFE( AIN1(:,idx), trainingseq(:,idx3), ...
                         is_training_seq, filtertap_update, prev_decided, coef1, coefp, Rinv, params);
                     case 32  
                [AOUT(:, idx2), dfeout1, decided, coef1, coefp, Rinv] = ...
                   DFE ( AIN1(:,idx), trainingseq(:,idx3), ...
                         is_training_seq, filtertap_update, prev_decided, coef1, coefp, Rinv, params);
                     case 64
                [AOUT(:, idx2), dfeout1, decided, coef1, coefp, Rinv] = ...
                   DFE ( AIN1(:,idx), trainingseq(:,idx3), ...
                         is_training_seq, filtertap_update, prev_decided, coef1, coefp, Rinv, params);
                     otherwise  
                [AOUT(:, idx2), dfeout1, decided, coef1, coefp, Rinv] = ...
                   DFE ( AIN1(:,idx), trainingseq(:,idx3), ...
                         is_training_seq, filtertap_update, prev_decided, coef1, coefp, Rinv, params);
                 end                  
             end
        else
        [AOUT(:, idx2), dfeout1, decided, coef1, coefp, Rinv] = ...
           DFE( AIN1(:,idx), trainingseq(:,idx3), ...
                 is_training_seq, filtertap_update, prev_decided, coef1, coefp, Rinv, params);
        end
        ffe_error(:,iSa)    = dfeout1.ffe_error;
        err(:,iSa)         = dfeout1.error;
        [coef1] = UpdateRate( (iSa-1)/PRL, coef1, params_org ) ;
        coefp = coef1;
        coef(:,:, iSa+PRL+DLY) = coef1;
        prev_decided = decided(:, end-params.Nfbe+1:end);
%         if ( params.update_type == 2 && iSa > PRL *20 )
%             params.update_type = 1 ;
%         end
        
    end 

    [coefp, coef] = AdjustMex2( params_org, coefp, coef) ;
    dfeout.filtercoef    = coefp;
    dfeout.filtercoeft    = coef;
    dfeout.error         = err(:,1:PRL:d2);
    dfeout.ffe_error     = ffe_error(:,1:PRL:d2);
    AOUT        = AOUT(:,  1:d2 );
    %%
    if ( params.skewcomp_en  == 1 )
        AOUT = complex(AOUT(1:2:end,:), AOUT(2:2:end,:));
    end 
end

function [coef, coefp, Rinv] = CoefInit( AIN, trainingseq, params )   
   
    coef        = complex( zeros([size(params.filtertap), size(AIN,2)]));
    coef        = coef + 1j * coef;
    coef(:,:,1)        = complex( params.filtertap);
    coefp       = complex(params.filtertap);
    Rinv        = complex( zeros([size(params.filtertap,1), ...
                   params.Nffe, params.Nffe ]));
               
    Rinv(1,:,:) = eye(params.Nffe);
    Rinv(4,:,:) = eye(params.Nffe);
    Rinv = complex(Rinv, 0);
end
 



function [ coefp] = UpdateRate( cycle, coefp,  params)  
        if ( params.update_type2 == 2 )
            if (  cycle == 50  )
                params.betab = params.betab * 1/5;
                params.betaf = params.betaf * 1/5;
            end
                    
            if (  cycle == 100 )
                params.betab = params.betab * 1/5;
                params.betaf = params.betaf * 1/5;
            end
        end
        if ( params.Nffe < 52 & params.Nfbe < 4 &  params.PRL == 128)
                coefp1 = coefp ;
                coefp = 0 * coefp;                
                idx1 = 25 - floor(params.Nffe/2) + ( 1:params.Nffe);
                idx2 = 51 + (1:params.Nfbe);
                idx3 = 51+3+1;
                filtercoef_idx  = [idx1 idx2 idx3];
                coefp(:, filtercoef_idx)= coefp1( :, filtercoef_idx); 
                params.offset = 25;
        end
        if ( params.update_type2 == 3 )
            if (   params.Nffe > params.Nffe_update_coef *2  + 2  )
                Nffe_upd_2 = ceil(params.Nffe_update_coef );
                coefp1 = coefp ;
                coefp = 0 * coefp;                 
                filtercoef_idx  = params.offset + (-Nffe_upd_2:Nffe_upd_2);
                coefp(:, filtercoef_idx)= coefp1( :, filtercoef_idx); 
                return
            end
%                     
%             if (  cycle < 2000 && params.Nffe > 23 )
%                 coefp1 = coefp ;
%                 coefp = 0 * coefp;
%                 coefp( :, params.offset +(-10:10))= coefp1( :, params.offset +(-10:10)); 
%                 return
%             end
        end
end

 

function params1 = AdjustMex1( params) 
            params1 = params;
            if ( params.Nffe < 52   & params.Nfbe < 4  &  params.PRL == 128) 
                params1.filtertap = zeros(size(params.filtertap,1), 51 + 3 + 1);
                idx = 25 - floor(params.Nffe/2) + ( 1:params.Nffe);
                params1.filtertap(:, idx) = params.filtertap(:, 1:params.Nffe);
                idx = 51 + (1:params.Nfbe);
                params1.filtertap(:, idx) = params.filtertap(:, params.Nffe+(1:params.Nfbe));
                params1.filtertap(:, end) = 1;
                params1.Nffe = 51;
                params1.Nfbe = 3;
                params1.filtertap = complex(params1.filtertap);
                params1.offset =25;
            end
end


function [coef1, coef] = AdjustMex2( params, coef1_org, coef_org) 
            coef1 = coef1_org;
            coef = coef_org;
            if ( params.Nffe < 52   & params.Nfbe < 4  &  params.PRL == 128)  
                idx1 = 25 - floor(params.Nffe/2) + ( 1:params.Nffe); 
                idx2 = 51 + (1:params.Nfbe); 
                idx3 = [];
                if ( params.betap ~= 0 & params.type == 7 )
                    idx3 = 51 + 3 + 1;
                end
                coef1 = [coef1_org(:, idx1) coef1_org(:, idx2) coef1_org(:, idx3) ];
                coef = [coef_org(:, idx1,1:params.PRL:end) coef_org(:, idx2, 1:params.PRL:end) coef_org(:, idx3, 1:params.PRL:end) ];
            end
end
