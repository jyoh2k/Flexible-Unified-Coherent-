function [out, stbcout]=  STBCDec( in, txsignal,  params )

%  Usage      : [out, stbcout]=  STBCDec( in,  params )
%  Function   :
%
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :
% Reference paper:

%     params.cpe_linear  =0;
    out = in ;
    stbcout.h = 0;
    stbcout.cpe = 0;
    if ( params.en == 0 )
        return
    end
    params.cpe_linear =1;
   OV = params.OV;
   PRL =  params.PRL/2;

   %% Initialization 
   d2 = floor(size(in,OV)/OV);
   in_dn = in(:,1:OV:OV*d2); 
   d3 = floor(size( txsignal.mapper2,2)/ PRL/2 )*(PRL ); % For STBC
   %trainseq = txsignal.mapper2;    
   
   h = zeros(4,params.Nffe, d3 );
   h(1, params.Npostcursor +1, :) = 1;
   h(4, params.Npostcursor +1, :) = -1;
   p = ones(1, d3 );
   cpe  = ones(1, d3 ); % Total phase shift ( adapted p and estimated phase using CPE)
   acc_phase_est = zeros(1, d3 ); % 
   phase_est = zeros(1, d3 ); % 
   cpe2 = ones(1, d3 ); % Just for debugging
   dec_error = zeros(2, d3 );
   dec1_error = zeros(4, d3 );
   equalized = zeros(2, d3 );
   stbc_eq = zeros(4, d3 );
   prev_cpe = cpe(1); 
   cpe1 = cpe(1);
   ecpe1 = ones(1, d3 ); % Just for debugging
   ecpe2 = ones(1, d3 ); % Just for debugging
   ecpe3 = ones(1, d3 ); % Just for debugging
   ecpe4 = ones(1, d3 ); % Just for debugging
  %% STBC in  conversion 
   rx_org  =complex(zeros(2, d3  ));
   trainseq  =complex(zeros(2, d3  ));
   decided  =complex(zeros(2, d3 ) );
   rx_org(1,:) = in_dn(1:2:d3*2 );
   rx_org(2,:) = conj( in_dn(2:2:d3*2 ));
   trainseq(1,:) = txsignal.mapper2(1,1:2:d3 *2);
   trainseq(2,:) = txsignal.mapper2(1,2:2:d3 * 2);

   %% FFE 
   if ( params.rx_in_org  == 0  || params.rx_in_org == 2)
       if ( params.Npostcursor < 2)
       
           rx1 = [ zeros(1,params.Npostcursor+params.L+params.OV) in zeros(1, params.Nffe+params.L * 2)];
           rx2 = [ zeros(1,params.Npostcursor+params.L) conj(in) zeros(1, params.Nffe+params.L * 2+params.OV)];
           rx  = [ rx1;rx2;];
           rx = rx(:, 3:end);
           in_ov = 4;

       else
           rx1 = [ zeros(1,params.Npostcursor+params.L) in zeros(1, params.Nffe+params.L * 2)];
           rx2 = [ zeros(1,params.Npostcursor+params.L-params.OV) conj(in) zeros(1, params.Nffe+params.L * 2+params.OV)];
           rx  = [ rx1;rx2;];
           in_ov = 4;
       end 
   end    
   if ( params.rx_in_org  ==  5 || params.rx_in_org  ==  6)
           rx1 = [ zeros(1,params.Npostcursor+params.L) in(:,1:2:end)  zeros(1, params.Nffe+params.L * 2)];
           rx2 = [ zeros(1,params.Npostcursor+params.L -1) conj(in(:,1:2:end) ) zeros(1, params.Nffe+params.L * 2+1)];
           rx  = [ rx1;rx2;];
           in_ov = 2;
   end 
   if ( params.rx_in_org  == 1  || params.rx_in_org == 4 )
       rx = [zeros(2,params.Npostcursor+params.L) rx_org zeros(2, params.Nffe+params.L * 2)];
       in_ov = 1;
   end
    rx1 =[ rx zeros(2,params.PRL * 5)];
    trainseq = [trainseq zeros(2,params.PRL * 5)];
   %% 
    is_trainseq = ones(1, d3) * params.is_training_seq_init;
    is_signal = ones(1, d3) * params.is_training_seq_init;
    is_trainseq([1:d3] >   params.training_seq_size / 2) = 0;
    if ( params.en_block_termination == 4 ) 
        is_trainseq(mod( [0:d3-1], params.block_size) == 0 )= 1;
    end 
    is_signal([1:d3] >   params.signal_seq_size / 2) = 0;
    is_signal([1:d3] <=  params.training_seq_size / 2) = 0;
    
   %%
   filtertap_update = ones(1, d3) ;
   if ( params.rx_in_org  == 3 ) 
       filtertap_update = filtertap_update * 0; 
   end 
   %% STBC h initial calculation  for faster adaptation 
   if ( params.h_init_en == 1 )
       [h_init] = get_stbc_H( rx_org(:,1:PRL* 8), trainseq(:,1:PRL* 8),  PRL* 8, params);
       h(:, params.Npostcursor +1, 1) =h_init; 
   end
   %% Main body
   for idx=1:PRL:d3  
        idx0 = (idx-1)*in_ov+1+(0:in_ov*(PRL)-1 + params.Nffe+params.L * 2 -1);
        idx1 = idx+(0:PRL-1);
        idx2 = idx+PRL+(0:PRL-1);
        idx3 = idx+(0:params.L * 2+PRL-1);
        idx4 = params.L + (idx-1)*in_ov+1+(0:in_ov*(PRL)-1 + params.Nffe-1);
        idx0_1 = (idx-1)*in_ov+1+(0:in_ov*(PRL*2)-1 + params.Nffe+params.L * 2 -1);
        idx1_1 = idx+(0:PRL*2-1);
        

        
%         rx(:,idx0_1) = calculate_stbc_H( is_trainseq(idx), rx1(:,idx0_1), trainseq(:, idx1_1), in_ov, params);
        stbc_eq_tmp1= stbc_decoder( rx(:,idx0), h(:,:, idx),  in_ov*PRL + params.L*2, params.Nffe );
        stbc_eq_tmp= stbc_tpr( stbc_eq_tmp1, params.tau_frac, params, in_ov * PRL );
        stbc_eq(:, idx1)  =  stbc_eq_tmp(:, 1:in_ov:end);
        [equalized(:, idx1), cpe2(:,idx1)]    = stbc_cpr1( stbc_eq(:, idx1), trainseq(:, idx1), cpe(:, idx1), params); 

        decided(:, idx1)                       = slicer_prl(is_trainseq(idx1), is_signal(idx1),equalized(:, idx1), trainseq(:, idx1), params);

        [errorpsum]                           = stbc_phase_lms(is_trainseq(idx), stbc_eq(:,idx1), decided(:, idx1), equalized(:, idx1), params);  
        [errorhsum, dec_error(:,idx1)]         = stbc_channel_lms ( rx(:,idx4), decided(:, idx1), equalized(:, idx1), h(:,:, idx), in_ov, params);
%         [errorhsum, dec1_error(:,idx1)]         = stbc_channel_lms1 ( rx(:,idx0), decided(:, idx1), stbc_eq(:, idx1), h(:,:, idx), cpe(:, idx1(1)), in_ov);
        [p(:,idx2), cpe(:,idx2), cpe1, prev_cpe, acc_phase_est(:,idx2)] = coef_phase_update( filtertap_update(idx),  prev_cpe, p(:,idx1), acc_phase_est(:,idx1), errorpsum, params);
       
        [h(:,:, idx+PRL) ] = coef_channel_update( is_trainseq(idx1(5)), filtertap_update(idx), h(:,:, idx), cpe1, errorhsum, params);
        if (  params.rx_in_org == 2 || params.rx_in_org == 4  || params.rx_in_org == 6)
                   [equalized(:, idx1),ecpe1(:,idx), ecpe2(:,idx) ]                           = stbc_phase_correction_bps(is_trainseq(idx1), is_signal(idx1), stbc_eq(:,idx1), trainseq(:, idx1), equalized(:, idx1), cpe(:, idx1), params);  
%             [equalized(:, idx1),ecpe3(:,idx), ecpe4(:,idx) ]                           = stbc_phase_correction(is_trainseq(idx1), is_signal(idx1), stbc_eq(:,idx1), trainseq(:, idx1), equalized(:, idx1), cpe(:, idx1), params);  
      
        end
    end 
    
    %% output align 
    equalized = reshape( equalized, 1, 2*size(equalized,2)); 

    %%     
    stbcout.h = h(:, :, 1:PRL:end);    
    stbcout.p = cpe(:, 1:PRL:d3)  ; 
    stbcout.error = dec_error(1, 1:PRL:end);    
    out(:, 1:OV:OV*d3*2 ) = equalized; 
%      figure; plot(phase_est(1:PRL:end), '*');
%       figure; plot(acc_phase_est(1:PRL:end), '*');
%  figure; plot([1:PRL:length(cpe)]*2, unwrap(angle(cpe(1:PRL:end))));
end 
 
% h(1,..) : w11
% h(3,..) : w12
% h(2,..) : w21
% h(4,..) : w22

function [stbc_eq] = stbc_decoder( rx_prl, h, PRL, Nffe)
   stbc_eq = zeros(4, PRL);
   for os=1:2
       for idx=1:PRL
           stbc_eq_mul = sum(rx_prl(:, idx+(0:Nffe-1)) .* h(os:2:end,:),2); 
           stbc_eq(os:2:end,idx)= (stbc_eq_mul);
       end
   end
end 

function [decided ] = slicer_prl( is_trainseq,  is_signal,  equalized, trainseq_prl, params)
  
    PRL = size(trainseq_prl,2);   
    equalized       = reshape(equalized,1,PRL*2);
    decided   = reshape(trainseq_prl,1,PRL*2);  
     
    symbol_idx   = 1:2*PRL;
    tridx = find(is_trainseq == 1);
    tridx = sort([(2*tridx -1)  2*tridx]);
            
    sigidx = find(is_signal == 1);
    sigidx = sort([(2*sigidx -1)  2*sigidx]); 
    sigidx = setdiff(sigidx, tridx);
    dataidx = setdiff(symbol_idx, union(tridx,sigidx));
    
    for idx=dataidx
        distance = abs( equalized(1,idx) -  params.mapper_list   ).^2;
        [C, I] = min( distance  );
        decided(idx) =  params.mapper_list(I);
    end
    
    for idx=sigidx
        distance = abs( equalized(1,idx) -  params.smapper_list   ).^2;
        [C, I] = min( distance  );
        decided(idx) =  params.smapper_list(I);
    end
    
    decided = reshape( decided,2, PRL);
end 
   

function [errorpsum]= stbc_phase_lms ( is_trainseq, rx, decided, equalized, params)

    PRL = size(decided,2);
    errorp  =complex(zeros([2, PRL]));
    dec_error = -decided + equalized;
 
    errorp(1, :) = dec_error(1,:) .* conj(rx(1,:));
    errorp(2, :) = conj(dec_error(1,:) .* conj(rx(3,:)));
    errorp(3, :) = dec_error(2,:) .* conj(rx(2,:));
    errorp(4, :) = conj(dec_error(2,:) .* conj(rx(4,:)));

    errorpsum = sum(sum(errorp(1:4,:))); 
end


function [equalized,cpe1,cpe2 ]= stbc_phase_correction_bps ( is_trainseq, is_signal, stbc_eq, trainseq,  equalized_in, cpe_in, params)
     
    PRL1 = params.BPS_window;
    range = params.BPS_range;
    equalized_tmp = zeros(2, PRL1);
    for iblk=1:PRL1:size(stbc_eq,2) 
            dataidx = iblk:iblk+PRL1-1;
            AIN_blk = stbc_eq(:, dataidx);
            B = params.BPS_step;
            BPS_error = 100 * ones(1, B);
            for iB=0:B
                    cpe = cpe_in(1) * exp( 1j * pi/2 * ( iB/B -1/2)*range) * ones(1,size(AIN_blk,2));
                    for os=1:2 
                        equalized_tmp(os,:) = sum(AIN_blk(os:2:end, :) .* [cpe; conj(cpe);], 1);
                    end      
                    [decided ] = slicer_prl( is_trainseq(dataidx),  is_signal(dataidx), equalized_tmp, trainseq(:,dataidx), params);
                    distance_min = abs(decided - equalized_tmp) .^ 2;%             
                    BPS_error(1,iB+1) = sum(sum(distance_min));
            end
            [C, Idx] = min( BPS_error  ); 
            cpe = cpe_in(1) * exp( 1j * pi/2 * ( (Idx-1)/B -1/2)*range ) * ones(1,size(AIN_blk,2));
            %dlmwrite(['cpe_hist.txt'], (pi/2 * ( (Idx-1)/B -1/2)*range)' , '-append');  
             for os=1:2 
                equalized(os,iblk:iblk+PRL1-1) = sum(AIN_blk(os:2:end, :) .* [cpe; conj(cpe);], 1);
             end             
    end
    cpe1 =cpe(1);cpe2 =1;
     
end
    

function [equalized,cpe1,cpe2 ]= stbc_phase_correction ( is_trainseq, is_signal, stbc_eq, trainseq,  equalized_in, cpe_in, params)
 
    equalized = equalized_in;
    dataidx = 1:size(stbc_eq,2) ;
    tridx = find(is_trainseq == 1); 
    [decided ] = slicer_prl( is_trainseq(dataidx),  is_signal(dataidx), equalized_in, trainseq(:,dataidx), params);
    trainseq=decided;
    tridx = dataidx; 
    a =  stbc_eq(1,tridx) ./trainseq(1, tridx) ;
    b =  stbc_eq(3,tridx) ./trainseq(1, tridx);
    c =   stbc_eq(2,tridx) ./trainseq(2, tridx);
    d =  stbc_eq(4,tridx) ./trainseq(2, tridx);
    Z = (mean(d)-mean(b) ) /(mean(a) - mean(c));
    cpe1 = atan2( imag(Z), real(Z)) /2 ;
    cpe1 = exp( 1j * cpe1 );
    cpe = cpe_in(1) * cpe1 * ones(1,size(stbc_eq,2));
    for os=1:2 
        equalized(os,:) = sum(stbc_eq(os:2:end, :) .* [cpe; conj(cpe);], 1);
    end      
    cpe2 = cpe1;
end
       
        
 

function [errorhsum, dec_error]= stbc_channel_lms ( rx, decided, equalized, h, in_ov, params)

    PRL = size(equalized,2);
    errorh  =complex(zeros([size(h), PRL]));
    errorhsum =complex(zeros(size(h)));
    dec_error = -decided + equalized;

    NStream = size(decided,1);
    for is= 1:2
        for os= 1:2
            sidx = (is - 1 )* NStream + os ; % equation index 
            for idx= 1:size(h,2)
                 errorh(sidx, idx,:) = dec_error(os,:) .* conj(rx(is, (idx +(0:in_ov:in_ov*PRL-1))));
                 errorhsum(sidx, idx)=sum( errorh(sidx, idx,: )) ;
            end
        end
    end
end
 
% rx : stbc_decoer output
% rx(1) h(1) + rx(2) h(3) = eq(1)
function [errorhsum, dec_error]= stbc_channel_lms1 ( rx, decided, equalized, h, cpe1, in_ov)

    PRL = size(equalized,2);
    errorh  =complex(zeros([size(h), PRL]));
    errorhsum =complex(zeros(size(h))); 
    cpe1 = cpe1/abs(cpe1) ;
    decided1   = [decided(1,:) /cpe1 ; decided(2,:)/cpe1 ; decided(1,:)/conj(cpe1) ; decided(2,:)/conj(cpe1)  ;];
    dec_error =  equalized -decided1;

    NStream = size(decided,1);
    for is= 1:2
        for os= 1:2
            sidx = (is - 1 )* NStream + os ; % equation index 
            for idx= 1:size(h,2)
                 errorh(sidx, idx,:) = dec_error(sidx,:) .* conj(rx(is, (idx +(0:in_ov:in_ov*PRL-1))));
                 errorhsum(sidx, idx)=sum( errorh(sidx, idx,: )) ;
            end
        end
    end
end
 

function [equalized, cpe ] = stbc_cpr0( stbc_eq,  p_in) 
    cpe = p_in;
    equalized = zeros(2, size(stbc_eq,2)); 
        for os=1:2
            equalized(os,:) = sum(stbc_eq(os:2:end, :) .* [cpe; conj(cpe);], 1);
        end 
end 
   
function [equalized, cpe ] = stbc_cpr1( stbc_eq, trainseq_prl, p_in, params)
   % p = (p1 + conj(p2))/2p  
%     cpe =( p_in(1,:) + conj(p_in(2,:)))/2  ;
    cpe = p_in;
    equalized = zeros(2, size(stbc_eq,2));
%     if ( params.cpe_linear == 1 )
%         for os=1:2
%             for sa
%             equalized(os,:) = sum(stbc_eq(os:2:end, :) .* [cpe; conj(cpe);], 1);
%         end
%     else
        for os=1:2
            equalized(os,:) = sum(stbc_eq(os:2:end, :) .* [cpe; conj(cpe);], 1);
        end
%     end 
end 



  function [equalized, acc_cpe_blk, cpe_blk ] = stbc_cpr2( stbc_eq, trainseq_prl,  cpe_in, params)
    params.en = 0;
    params.CPEtype = 4; % Pilot 
    params.PCtype   = 1;
    params.PCtype2  = 1;
    params.fBLK = 32;
    params.fSTEP = 32;
    params.fCPEtype = 4; % BPS 
    params.fPCtype   = 1;
    params.BLK = 32;
    params.STEP =32;
    params.BPS_step    = 128;
    T = 0;
    params.OV =1;
    stbc_eq = reshape(stbc_eq, 1, size(stbc_eq,2)*2 );
    trainseq_prl = reshape(trainseq_prl, 1, size(trainseq_prl, 2)*2 );
    params.mapper2 = trainseq_prl;
    
%     cpe_blk = CPE( stbc_eq, params, T);
    cpe_blk = BPS_cpe(stbc_eq, params) ;
    cpe_blk = PhaseCorrection( cpe_blk, params, T);

    if ( isempty(find(abs(cpe_blk) > 1)) == 0 )
        disp('stop');
    end 
    if ( params.PCtype2 == 2 )
            params.BLK            = params.fBLK;
            params.CPEtype    = params.fCPEtype;
            params.PCtype       = params.fPCtype;
            params.STEP           = params.fSTEP;
            
            %cpe_blk1 = CPE( stbc_eq, params, T);
            cpe_blk1 = BPS_cpe(stbc_eq, params) ;
            if ( abs(cpe_blk1) > 0.4)
                cpe_blk1;
            end
            cpe_blk1 = PhaseCorrection( cpe_blk1, params, T);
            cpe_blk2 = PhaseCorrection2( cpe_blk1, cpe_blk, params, T);
            cpe_blk  = cpe_blk2;
    end

    equalized = stbc_eq;
    if ( params.en == 1 )
%         equalized(1:2:end)=  CPR( stbc_eq(1:2:end), cpe_blk, params, T);
%         equalized(2:2:end)=  CPR( stbc_eq(2:2:end), -cpe_blk, params, T);
    end

    equalized = reshape(equalized, 2, size(equalized,2)/2 );
    cpe_blk = cpe_blk(1:2:end);
    if ( params.en == 0 )
        cpe_blk = cpe_blk * 0;
    end
    acc_cpe_blk = cpe_blk + cpe_in; % Accumulated phase 

  end


   
function [ po, cpeo, cpe1, prev_cpe, acc_phase_est] = coef_phase_update( filtertap_update,  prev_cpe, p, acc_phase_est, errorpsum, params)
    po=p(1);cpeo = prev_cpe;acc_phase_est=acc_phase_est + errorpsum;
    if ( filtertap_update )
        po = p(:,1) - params.betab * errorpsum -  params.betab2 * acc_phase_est(1);
    end
    cpe2= po;
    cpe1 = cpe2/ abs(cpe2) ;% * exp( 1j*phase_est_in(1,1));
    po = po * ones(1, size(p,2));   
    cpeo = cpe2 * ones(1, size(p,2)) ;
    if ( params.cpe_linear == 1 )
        cpeo = prev_cpe + ( cpe2 - prev_cpe) *2*[1:size(p,2)]/size(p,2);
    end 
    prev_cpe = cpe2;
    

end 
 


function [ho ] = coef_channel_update( is_training, filtertap_update, h, cpe1, errorhsum, params)
    params.betaf(2) = params.betaf(1) * 7;
    ho = h;
    betaf = params.betaf(1);
    if ( is_training == 1 && length(params.betaf) ~= 1)
        betaf = params.betaf(2);
    end
    if ( filtertap_update )
      cpe = [conj(cpe1); conj(cpe1); cpe1; cpe1;];
      ho = h - betaf *  errorhsum .* [cpe * ones(1, size(h,2))] ;
    end
end

function [eq] = stbc_decoder1( rx_prl, h, p_in)
   % p = (p1 + conj(p2))/2p  
   p =( p_in(1,:) + conj(p_in(2,:)))/2  ;

   stbc_eq = zeros(4, size(rx_prl,2));
   eq      = zeros(2, size(rx_prl,2));
   for os=1:params.NStream
       for idx=1:size(rx_prl,2)
           stbc_eq_mul = sum(rx_prl(:, idx:idx+params.Nffe-1) .* h(os:NStream:end,:)); 
           stbc_eq(os,idx:idx+1)= (stbc_eq_mul);
       end
   end
   eq(1,:) =   stbc_eq(1,:) .* p + stbc_eq(3,:) .* conj(p) ;
   eq(2,:) =   stbc_eq(2,:) .* p + stbc_eq(4,:) .* conj(p) ;
end 


function [rxout_prl] = calculate_stbc_H( is_training, rx_prl, decided_prl,  in_ov, params)
%     if ( params.rx_in_org  == 3 ) 
         if (is_training == 1)
             PRL = size(decided_prl,2);
             rx_pilot_prl = rx_prl(:,params.Npostcursor+1:in_ov:end-params.Npostcursor);
             [H] = get_stbc_H( rx_pilot_prl, decided_prl, PRL, params);
         else
             rx_pilot_prl = rx_prl(:,[params.Npostcursor+1:params.block_size*in_ov:end-params.Npostcursor]);
             decided_pilot_prl = decided_prl(:,[1:params.block_size:end]);
             PRL = size(rx_pilot_prl,2);
             [H] = get_stbc_H( rx_pilot_prl, decided_pilot_prl, PRL, params);
         end
%     end 
    
   H =  transpose(H);
   stbc_eq = zeros(4, size(rx_prl,2));
   for os=1:2
       for idx=1:size(rx_prl,2)
           stbc_eq_mul = sum(rx_prl(:, idx) .* H(os:2:end,1),2); 
           stbc_eq(os:2:end,idx)= (stbc_eq_mul);
       end
   end
   
        for os=1:2
            rxout_prl(os,:) = sum(stbc_eq(os:2:end, :), 1);
        end
     
end

function [H] = get_stbc_H( rx_prl, decided_prl, PRL, params)
    trained_h = zeros(2, PRL); 
    for idx=1:PRL
        h= get_stbc( rx_prl(:, idx), decided_prl(:, idx), params); 
        trained_h(:, idx) = h;
    end
 
    h = mean(trained_h,2);
    H(1 ) = conj(h(1));
    H(3) = h(2);
    H(2) = conj(h(2));
    H(4) = -h(1);

end

function [h ] = get_stbc( rx, tx, params)
    h(1) = rx(1) * conj(tx(1)) - conj(rx(2)) * tx(2);
    h(2) = rx(1) * conj(tx(2)) + conj(rx(2)) * tx(1);
    norm1 = sum(abs(rx(1:2)) .^2 );
    h = h /norm1;
end


function cpeout = BPS_cpe(AIN, params)
    cpeout = zeros(1, size(AIN,2));
    for iblk=1:params.STEP:size(AIN,2)
        AIN_blk = AIN(1, iblk:iblk+params.STEP-1);
            B = params.BPS_step;
            BPS_error = zeros(1, B);
            for iB=0:B-1
                AIN_rot =  AIN_blk * exp( 1j * pi/2 * ( iB/B -1/2)/4 );
                AIN_rot(2:2:end) =  AIN_blk(2:2:end) * exp( -1j * pi/2 * ( iB/B -1/2) /4);
                [decided, distance_min] = slicer( AIN_rot, params);
                BPS_error(1,iB+1) = sum(sum(distance_min));
            end
            [C, Idx] = min( BPS_error  );
            cpeout(1,1:params.STEP)  =  - pi/2 * ((Idx-1)/B -1/2)/4;
    end
end

function [decided, distance_min] = slicer( in, params)
        distance = abs( ( ones(length(params.mapper_list),1) * in - params.mapper_list * ones(1, length(in)) )) .^2;
        [C, I] = min( distance  );
        decided =  params.mapper_list(I);
        distance_min = C;
end
 
function [out] =  stbc_tpr( in, frac_tau, params, PRL)
    if ( params.L == 0 )
        out = in;
    else
        out = zeros(4, PRL);
        out(1, :) = TPR( in(1,:), frac_tau(1), params, '');
        out(2, :) = TPR( in(2,:),  frac_tau(2), params, '');
        out(3, :) = TPR( in(3,:),  frac_tau(3), params, '');
        out(4, :) = TPR( in(4,:),  frac_tau(4), params, '');
    end
end


%         h(1, :, 1) =conv(tim_filterf, h_init(1)) ;
%         h(2, :, 1) =conv(tim_filterf1, h_init(2)) ;
%         h(3, :, 1) =conv(tim_filterf1, h_init(3)) ;
%         h(4, :, 1) =conv(tim_filterf, h_init(4)) ;
