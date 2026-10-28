function [AOUT,ffeout, dfeout, ffeout1] = RxUnifiedEq( AIN, trainingseq, params)  

%  Usage      : [AOUT, dfeout] = RxUnifiedEq( AIN, trainingseq, params  
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
    Npad        =   params.Npostcursor; 
    zeropad     = ceil(d2/params.PRL)* params.PRL - d2;
    training_seq_size =    params.training_seq_size * params.OV;
    signal_seq_size   =    params.signal_seq_size   * params.OV;
   
    
    if (params.PTBC == 1)
        AIN1 = [ zeros(1,params.Npostcursor) AIN zeros(1, params.Nffe+zeropad )];
        AIN2 = [ zeros(1,params.Npostcursor-params.OV) conj(AIN) zeros(1, params.Nffe +params.OV+zeropad)];
        AIN1 = [AIN1; AIN2;];   
        trainingseq = reshape(trainingseq,2,[]);
        zeropad1    = params.PRL * 5; 
        params.PTBC_factor  = 2;  
        params.OV = params.OV * params.PTBC_factor ;        
        d1 = d1 *2;
    else     
        AIN1        = [zeros(size(AIN,1), Npad), AIN, zeros(size(AIN,1), params.Nffe +10 + zeropad)]; 
        zeropad1    = size(AIN1,2)-size(trainingseq, 2);
        decided = trainingseq;
        params.PTBC_factor  =1;
    end 
    %%   Skew Comp consideration
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
    trainingseq = [ trainingseq, zeros( size(trainingseq,1), params.Nffe +10 + zeropad1)]; 
    AOUT        = zeros(params.NStream,  ceil(d2/params.OV) );
    ffeout      = zeros(params.NStream * 2, size(AIN1,2));
    ffeout1     = zeros(params.NStream, size(AIN1,2));
    err         = zeros(params.NStream, d2);
    ffe_error    = zeros(d1*params.NStream, d2);
     if ( params.skewcomp_en  == 2 )
         ffe_error    = zeros(d1*params.NStream*2, d2);
     end 
    [coef, coefp, P_mat, prev_decided] = CoefInit( AIN, trainingseq, params) ;
        
   %% 
    is_training_seq = ones(1, d2) * params.is_training_seq_init;    
    is_training_seq([1:d2] >   training_seq_size  ) = 2;
    is_training_seq([1:d2] >   signal_seq_size    ) = 0;    
 

    if ( params.en == 0 )
        dfeout.filtercoef    = params.filtertap;
        dfeout.filtercoeft    = coef;
        dfeout.error         = err(:,1:PRL:d2);
        dfeout.ffe_error     = ffe_error(:,1:PRL:d2);
        AOUT = AIN;
        return;
    end
    
    filtertap_update = 0 ;
    PRL         = params.PRL ; 
    OV         =  params.OV  ;  
    %% Main Body
    for iSa  =1:PRL:d2
        if ( iSa > training_seq_size  )
             filtertap_update = params.filtertap_update ;
        else 
            if ( iSa > params.filtertap_update_size   )
                 filtertap_update  = 1;
            end
        end
         
        idx = iSa + ( 0:PRL+params.Nffe-2  );
        idx2= iSa + ( 0:1:PRL-1);
        idx3 = (iSa-1)/OV +  ( 1: PRL/OV );
        coef1 = complex(coef(:,:,(iSa-1)/PRL+1));
        [AOUT(:, idx2), dfeout1, decided1, coef1, coefp, P_mat] = ...
           DFEUnified( AIN1(:,idx), trainingseq(:,idx3), ...
                 is_training_seq(idx2), filtertap_update, prev_decided, coef1, coefp, P_mat, params);
        ffe_error(:,iSa)    = dfeout1.ffe_error;
        err(:,iSa)         = dfeout1.error;
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
    AOUT        = align_data( AOUT(:,  1:d2 ), params);
    if ( params.PTBC == 1 )
        ffeout        =  align_data( ffeout(:,  1:d2 ), params);
    else
        ffeout        = AOUT;
    end
    ffeout1        = align_data( ffeout1(:,  1:d2 ), params); 
    
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
    if ( params.h_init_en == 1 )
        if ( size(AIN,1) == 1)
            [~, pol] = RxPTBCDemux( AIN, trainingseq, params );
            filtertap(:, params.Npostcursor+1) =reshape( pol.Hinv, 1,[]);
        else
            [~, pol] = RxPolDemux( AIN, trainingseq, params );
            filtertap(:, params.Npostcursor+1) = reshape( pol.Hinv, 1,[]);
        end         
    end 
    coef        = complex( zeros([size(filtertap), ceil(size(AIN,2)/params.PRL/params.OV)]));
    coef        = coef + 1j * coef;
    coef(:,:,1) = complex(filtertap);
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
        prev_decided     = real(zeros(params.NStream,max(params.Nfbe, 1))) ;
    else
        prev_decided     = complex(zeros(params.NStream,max(params.Nfbe, 1))) ;
    end
end
 
 
function AOUT = align_data( AIN, params)
    AOUT = AIN;
    if (params.PTBC == 1 ) 
        if ( size(AIN,1) == 2)
            AOUT(1, 3:4:end) = AOUT(2,  1:4:end);
            AOUT = AOUT(1,:); 
        else
            AOUT(1, 3:4:end) = AIN(2,  1:4:end);
            AOUT(3, 3:4:end) = AIN(4,  1:4:end);
            AOUT = AOUT([1,3],:); 
        end
    end 
end
  
