function [AOUT,ffeout, dfeout, ffeout1] = RxSymEq( AIN, trainingseq, params)  

%  Usage      : [AOUT, dfeout] = RxSymEq( AIN, trainingseq, params  
%
%  Function   :
%     Symbol-by-Symbol Equalizer 
%     - Nonlinear Equalizer  ( FFE, DFE, Volterra)
%     - Skew compensation (real, widely linear )
%     - Coefficient update algorithm LMS, CMA, MMA, RLS, RDE
%     - slice function : amplitude/complex
%
%  Port  :
%
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :
        
   %%
   if ( params.en_block_termination ~=0 )
        if ( mod(params.PRL, params.block_size) ~=0 )
           error(' Parallelism should be multiples of block size');
        end 
   end
   
     
    %%  Initial value 
    [d1, d2] = size( AIN);
    DLY         = params.DLY;
    PRL         = params.PRL * params.OV; 
    OV         =  params.OV; 
    Npad        =   params.Npostcursor; 
    zeropad     = ceil(d2/PRL)* PRL - d2;
   
    AIN1        = [zeros(d1, Npad), AIN, zeros(d1, params.Nffe +10 + zeropad)]; 
    zeropad1    = size(AIN1,2)-size(trainingseq, 2);
    decided = trainingseq;
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
    if ( params.type  == 6  ) %  RDE 
       params.type = 1;
    end  
    if (params.type  == 7 ) %  RDE-RLS 
       params.type = 5;
    end 
    %%
    trainingseq = [ trainingseq(1:params.NStream,:), zeros( d1, params.Nffe +10 + zeropad1)]; 
    AOUT        = zeros(params.NStream,  ceil(d2/params.OV) );
    ffeout      = zeros(params.NStream, size(AIN1,2));
    ffeout1     = zeros(params.NStream, size(AIN1,2));
    err         = zeros(params.NStream, d2);
    ffe_error    = zeros(d1*params.NStream, d2);
     if ( params.skewcomp_en  == 2 )
         ffe_error    = zeros(d1*params.NStream*2, d2);
     end 
    [coef, coefp, P_mat, prev_decided] = CoefInit( AIN, trainingseq, params) ;
        
    is_training_seq  = params.is_training_seq_init;
    filtertap_update = 0 ;

    if ( params.en == 0 )
        dfeout.filtercoef    = params.filtertap;
        dfeout.filtercoeft    = coef;
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
        coef1 = complex(coef(:,:,(iSa-1)/PRL+1));
        [AOUT(:, idx2), dfeout1, decided1, coef1, coefp, P_mat] = ...
           DFE( AIN1(:,idx), trainingseq(:,idx3), ...
                 is_training_seq, filtertap_update, prev_decided, coef1, coefp, P_mat, params);
        ffe_error(:,iSa)    = dfeout1.ffe_error;
        err(:,iSa)         = dfeout1.error;
        [coef1] = UpdateRate( (iSa-1)/PRL, coef1, params) ;
        coefp = coef1;
        coef(:,:, (iSa-1)/PRL+2+DLY) = coef1;
        Nfbe = max(1, params.Nfbe);
        prev_decided = decided1(:, end-Nfbe+1:end);        
        ffeout(:, idx2) = dfeout1.ffeout;
        ffeout1(:, idx2) = dfeout1.ffeout1;
        decided(:, idx3) = decided1;       
    end 

    dfeout.filtercoef    = coefp;
    dfeout.filtercoeft    = coef(:,:, :);
    dfeout.P_mat         = P_mat;
    dfeout.error         = err(:,1:PRL:d2);
    dfeout.ffe_error     = ffe_error(:,1:PRL:d2);
    dfeout.decided = decided;
    AOUT        = AOUT(:,  1:d2 );
    ffeout        = ffeout(:,  1:d2 );
    ffeout1       = ffeout1(:,  1:d2 );
    
    if ( isreal(AIN))
        AOUT = real(AOUT);
        ffeout = real(ffeout);
        ffeout1= real(ffeout1);
        dfeout.filtercoef = real(dfeout.filtercoef );
        dfeout.filtercoeft = real(dfeout.filtercoeft );  
    end      
    if ( params.skewcomp_en  == 1 )
        AOUT = complex(AOUT(1:2:end,:), AOUT(2:2:end,:));
    end 
end

function [coef, coefp, Rinv, prev_decided] = CoefInit( AIN, trainingseq, params)  
   
    dc          = complex( zeros( size(params.filtertap,1), 2));
    filtertap   = [params.filtertap dc];
    filtertap   = filtertap(:, 1:(params.Ndfe+2));
    coef        = complex( zeros([size(filtertap), ceil(size(AIN,2)/params.PRL/params.OV)]));
    coef        = coef + 1j * coef;
    
     
    coef = repmat(complex(filtertap), 1, 1, size(coef,3));
    coefp       = complex(filtertap); 

    if ( params.Nfbe ~= 0 && params.betab ~=0 )
       RLStap = params.Nffe + params.Nfbe + params.Ndp3fe +  params.Ndpfe;
    else
       RLStap = params.Nffe + params.Ndp3fe +  params.Ndpfe; 
    end  
    P_mat= ones(size(params.filtertap,1),1)*reshape(complex(eye(RLStap)), 1,RLStap^2);
    Rinv  =  reshape(P_mat, size(params.filtertap,1),RLStap,RLStap);
    Rinv  =  params.delta * complex(Rinv); 
    if ( isreal(AIN))
        prev_decided     = real(ones(params.NStream,max(params.Nfbe, 1))) *   params.term_symbol;
    else
        prev_decided     = complex(zeros(params.NStream,max(params.Nfbe, 1)))  *   params.term_symbol ;
    end
end
 



function [ coefp] = UpdateRate( cycle, coefp,  params)   
        if ( params.update_type2 == 3 )
            if (   params.Nffe > params.Nffe_update_coef *2  + 2  )
                Nffe_upd_2 = ceil(params.Nffe_update_coef );
                coefp1 = coefp ;
                coefp = 0 * coefp;                 
                filtercoef_idx  = params.offset + (-Nffe_upd_2:Nffe_upd_2);
                coefp(:, filtercoef_idx)= coefp1( :, filtercoef_idx); 
                return
            end 
        end
end

 
  
