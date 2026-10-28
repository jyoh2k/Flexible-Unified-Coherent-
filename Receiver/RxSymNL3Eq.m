function [AOUT, ffeout, dfeout] = RxSymNL3Eq( AIN, trainingseq, params)  

%  Usage      :  AOUT = RxDFE( AIN, params, T )   
%
%  Function   :
%     Symbol-by-Symbol Nonlinear Equalizer  ( FFE, DFE, Volterra)
%     Coefficient update algorithm LMS, CMA, MMA, RLS 
%
%  Port  :
%
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :
         
        
     
    %%  Initial value 
    [d1, d2] = size( AIN);
    DLY         = 0;
    PRL         = params.PRL; 
    OV         =  params.OV; 
    Npad        = params.Npostcursor; 
    zeropad     = ceil(d2/PRL)* PRL - d2;
   
    AIN1        = [zeros(d1, Npad), AIN, zeros(d1, params.Nffe +10 + zeropad)]; 
    zeropad1    = size(AIN1,2)-size(trainingseq, 2);
    trainingseq = [ trainingseq(1:params.NStream,:), zeros( d1, params.Nffe +10 + zeropad1)]; 
    AOUT        = zeros(params.NStream,  ceil(d2/params.OV) );
    ffeout      = zeros( size(AIN1));
    err         = zeros(params.NStream, d2);
    ffe_error    = zeros(d1*params.NStream, d2);
    
    [coef, coefp, Rinv, prev_decided] = CoefInit( AIN, trainingseq, params)  ;
        
    is_training_seq  = params.is_training_seq_init;
    filtertap_update = 0 ;   

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
             filtertap_update = params.filtertap_update ;
        else 
            if ( iSa > params.filtertap_update_size * OV )
                 filtertap_update  = 1;
            end
        end
        idx = iSa + ( 0:PRL+params.Nffe-2  );
        idx2= iSa + ( 0:1:PRL-1);
        idx3 = (iSa-1)/OV +  ( 1: PRL/OV);
        coef1 = complex(coef(:,:,iSa));     
       [AOUT(:, idx2), dfeout1, decided, coef1, coefp, Rinv] = ...
          NL3DFE ( AIN1(:,idx), trainingseq(:,idx3), ...
          is_training_seq, filtertap_update, prev_decided, coef1, coefp, Rinv, params); 
        ffe_error(:,iSa)    = dfeout1.ffe_error;
        err(:,iSa)         = dfeout1.error; 
        [coef1] = UpdateRate( (iSa-1)/PRL, coef1, params) ;
        coefp = coef1;
        coef(:,:, iSa+PRL+DLY) = coef1;
        prev_decided = decided(:, end-params.Nfbe+1:end);
%         if ( params.update_type == 2 && iSa > PRL *20 )
%             params.update_type = 1 ;
%         end
        ffeout(:, idx2) = dfeout1.ffeout;
    end 
 
    dfeout.filtercoef    = coefp;
    dfeout.filtercoeft    = coef(:,:, 1:PRL:d2);
    dfeout.error         = err(:,1:PRL:d2);
    dfeout.ffe_error     = ffe_error(:,1:PRL:d2);
    AOUT        = AOUT(:,  1:d2 );
    ffeout        = ffeout(:,  1:d2 );
    
    if ( isreal(AIN))
        AOUT = real(AOUT);
        ffeout = real(ffeout);
        dfeout.filtercoef = real(dfeout.filtercoef );
        dfeout.filtercoeft = real(dfeout.filtercoeft );        
    end
end


function [coef, coefp, Rinv, prev_decided] = CoefInit( AIN, trainingseq, params)  

    coef        = complex( zeros([size(params.filtertap), size(AIN,2)]));
    coef        = coef + 1j * coef;
    coef(:,:,1)        = complex( params.filtertap);
    coefp       = complex(params.filtertap);
    Rinv        = complex( zeros([size(params.filtertap,1), ...
                   params.Ndfe, params.Ndfe ]));
               
    Rinv(1,:,:) = complex(eye(params.Ndfe));
    Rinv = complex(Rinv); 
    if ( isreal(AIN))
        prev_decided     = real(zeros(params.NStream,max(params.Nfbe, params.Nfbe))) ;
    else
        prev_decided     = complex(zeros(params.NStream,max(params.Nfbe, params.Nfbe))) ;
    end
end
 

function [ coefp] = UpdateRate( cycle, coefp,  params)
        if ( params.update_type2 == 2 )
            if (  cycle == 500 )
                params.betab = params.betab * 1/2;
                params.betaf = params.betaf * 1/2;
            end

            if (  cycle == 1000 )
                params.betab = params.betab * 1/2;
                params.betaf = params.betaf * 1/2;
            end
        end  
end
 


