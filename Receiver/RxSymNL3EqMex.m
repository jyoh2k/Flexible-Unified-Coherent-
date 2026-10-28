function [AOUT, ffeout, dfeout] = RxSymNL3EqMex( AIN, trainingseq, params_org)  

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
        
    Max_Ndfe = 200;
    Max_Nffe = 91;
    Max_Nfbe = 11;
        
    params = AdjustMex1( params_org) ;
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
        if ( params.Nffe < (Max_Nffe+1) & params.Ndfe < (Max_Ndfe+1) & ...
             params.Nfbe < (Max_Nfbe+1) & params.PRL == 256) 
            %  codegen DFE -args {   AIN1(:,idx), trainingseq(:,idx3),  is_training_seq, filtertap_update, prev_decided, coef1, coefp, Rinv, params }

         switch (length(params.mapper_list))
             case 4
                   [AOUT(:, idx2), dfeout1, decided, coef1, coefp, Rinv] = ...
                      NL3DFE( AIN1(:,idx), trainingseq(:,idx3), ...
                          is_training_seq, filtertap_update, prev_decided, coef1, coefp, Rinv, params);
             case 6
                   [AOUT(:, idx2), dfeout1, decided, coef1, coefp, Rinv] = ...
                      NL3DFE   ( AIN1(:,idx), trainingseq(:,idx3), ...
                          is_training_seq, filtertap_update, prev_decided, coef1, coefp, Rinv, params);
             case 8
                   [AOUT(:, idx2), dfeout1, decided, coef1, coefp, Rinv] = ...
                      NL3DFE   ( AIN1(:,idx), trainingseq(:,idx3), ...
                          is_training_seq, filtertap_update, prev_decided, coef1, coefp, Rinv, params);
             otherwise 
                   [AOUT(:, idx2), dfeout1, decided, coef1, coefp, Rinv] = ...
                      NL3DFE ( AIN1(:,idx), trainingseq(:,idx3), ...
                          is_training_seq, filtertap_update, prev_decided, coef1, coefp, Rinv, params);
          end
        else
               [AOUT(:, idx2), dfeout1, decided, coef1, coefp, Rinv] = ...
                  NL3DFE ( AIN1(:,idx), trainingseq(:,idx3), ...
                  is_training_seq, filtertap_update, prev_decided, coef1, coefp, Rinv, params);
        end
        ffe_error(:,iSa)    = dfeout1.ffe_error;
        err(:,iSa)         = dfeout1.error; 
        [coef1] = UpdateRate( (iSa-1)/PRL, coef1, params_org) ;
        coefp = coef1;
        coef(:,:, iSa+PRL+DLY) = coef1;
        prev_decided = decided(:, end-params.Nfbe+1:end);
        %[params] = UpdateRate1( (iSa-1)/PRL, params, T ) ;         
        if ( params.update_type == 2 && iSa > PRL *20 )
            params.update_type = 1 ;
        end
        ffeout(:, idx2) = dfeout1.ffeout;
    end 

  
    [coefp, coef] = AdjustMex2( params_org, coefp, coef) ;
%   dfeout.filtercoef    = [ -coefp(:, params_org.Nffe +1:end) coefp(:,1:params_org.Nffe)];
%   dfeout.filtercoeft   = [ -coef(:, params_org.Nffe +1:end,:) coef(:,1:params_org.Nffe,:)];
    dfeout.filtercoef    = coefp;
    dfeout.filtercoeft   = coef;
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
    Max_Nffe = 91;
    Max_Nfbe = 11;
    if ( isreal(AIN))
        prev_decided     = real(zeros(params.NStream,max(params.Nfbe, Max_Nfbe))) ;
    else
        prev_decided     = complex(zeros(params.NStream,max(params.Nfbe, Max_Nfbe))) ;
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
        Max_Ndfe = 200;
        Max_Nffe = 91;
        Max_Nfbe = 11;
        if ( params.Nffe < (Max_Nffe+1) & params.Ndfe < (Max_Ndfe+1) & ...
             params.Nfbe < (Max_Nfbe+1) ) 
                coefp1 = coefp ;
                coefp = 0 * coefp;
                idx1 =  ...
                  [ 1:params.Nffe ...
                  Max_Nffe+(1:params.Nfbe) ...
                  (Max_Nffe+Max_Nfbe +(1:params.W *params.Npfe)) ...
                  (Max_Nffe+Max_Nfbe +params.W *params.Npfe + (1:params.Npbe+params.Ndp3fe +params.Np3be))];
                coefp(:, idx1)= coefp1( :, idx1);
        end
        %if ( params.update_type2 == 3 )
        %    if (   params.Nffe > params.filtercoef_num *2 + 2  )
        %        coefp1 = coefp ;
        %        coefp = 0 * coefp;
        %        filtercoef_idx  = params.Npostcursor + (-params.filtercoef_num:params.filtercoef_num);
        %        coefp(:, filtercoef_idx)= coefp1( :, filtercoef_idx);
        %        return
        %    end
        %end
end

function [params] = UpdateRate1( cycle, params, T )  
%         if ( params.update_type == 2 )
            if (  cycle == 500 )
                params.betab = params.betab * 1/2;
                params.betaf = params.betaf * 1/2;
            end
                    
            if (  cycle == 1000 )
                params.betab = params.betab * 1/2;
                params.betaf = params.betaf * 1/2;
            end
            
            if (  cycle < 50  && params.type == 4 )     
                params.real_coef = 1;
            else
                params.real_coef = 0 ;
            end
end


function params1 = AdjustMex1( params)
            params1 = params;
            Max_Ndfe = 200;
            Max_Nffe = 91;
            Max_Nfbe = 11;
            if ( params.Nffe < (Max_Nffe+1) & params.Ndfe < (Max_Ndfe+1) & ...
                 params.Nfbe < (Max_Nfbe+1) ) 
                params1.filtertap = zeros(size(params.filtertap,1), Max_Ndfe);
                idx1 =  ...
                  [ 1:params.Nffe ...
                  Max_Nffe+(1:params.Nfbe) ...
                  (Max_Nffe+Max_Nfbe +(1:params.W *params.Npfe)) ...
                  (Max_Nffe+Max_Nfbe +params.W *params.Npfe + (1:params.Npbe+params.Ndp3fe +params.Np3be))];
                idx2 = 1:params.Ndfe;
                params1.filtertap(:, idx1) = params.filtertap(:, idx2);
                params1.Ndfe = Max_Ndfe;
                params1.Nffe = Max_Nffe;
                params1.Nfbe = Max_Nfbe;
                params1.filtertap = complex(params1.filtertap);
            end
end



function [coef1, coef] = AdjustMex2( params, coef1_org, coef_org)
            coef1 = coef1_org;
            coef = coef_org(:, :,1:params.PRL:end);
            Max_Ndfe = 200;
            Max_Nffe = 91;
            Max_Nfbe = 11;
            if ( params.Nffe < (Max_Nffe+1) & params.Ndfe < (Max_Ndfe+1) & ...
                 params.Nfbe < (Max_Nfbe+1) ) 
                idx1 =  ...
                  [ 1:params.Nffe ...
                  Max_Nffe+(1:params.Nfbe) ...
                  (Max_Nffe+Max_Nfbe +(1:params.W *params.Npfe)) ...
                  (Max_Nffe+Max_Nfbe +params.W *params.Npfe + (1:params.Npbe+params.Ndp3fe +params.Np3be))];
                coef1 = coef1_org(:, idx1);
                coef = coef_org(:, idx1,1:params.PRL:end);
            end
end

