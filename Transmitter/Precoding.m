function [out, training, training1]=  Precoding( in,  sims, params )

%  Usage      : [out]=  Precoding( in,  sims, params )
%
%  Function   : Precoding(1), THP precoding(2), NL TCM(3)
%     1.  Precoding 1/(1+D) precoding 
%
%     2.  Tomlinson-Harashmia Coding precoding
%
%     3.  Nonlinear Trellis coded modulator 
%          v(n) = u(n) + [v(n-1)/2]
%          in case of PAM4 : u(n) =0~ 3, v(n) = 0,1,2,3,4,5
%
%  Reference  : 
%
%   THP      Kikuchi, Nobuhiko, Riu Hirai, and Takayoshi Fukui. "Application of
%            Tomlinson-Harashima Precoding (THP) for Short-Reach Band-Limited Nyquist
%            PAM and Faster-Than-Nyquist PAM Signaling." 2018 OFC
%   TCM      Yamamoto, Shuto, et al. "92-Gbaud PAM4 transmission using 
%            spectral-shaping trellis-coded-modulation with 20-GHz bandwidth
%            limitation." Optical Fiber Communication Conference.OFC 2019
%
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :
    
    in = fie_c(in, params.T.In);

    if ( params.en == 0 )
        out = in ;
        training = in;
        training1 = in;
        return
    end
    
    
    
    if ( params.type == 1 || params.type == 4 )
        in_sft = [ in] + params.pam_offset;
        in_sft = [0 in_sft];
        num_block = ceil(length(in_sft) / params.block_size);
        zeropad = num_block * params.block_size - length(in_sft);
        in_sft = reshape([in_sft zeros(1, zeropad)], params.block_size, num_block);
        if ( params.type == 4 )
            out_sft = filter(1, [ 1 1], in_sft);
        else
            out_sft = filter(1, params.filter, in_sft);
        end
        if ( params.en_block_termination )
            out_sft(1, :) = in_sft(1, :) ;
        end
        out_sft = mod(out_sft, params.pam * 2) - params.pam_offset;
        out_sft = out_sft(:)';
        out_sft = out_sft(2:length(in)+1);
        out = out_sft;
        in  = out ;
        training = out;
    end 

    if ( params.type == 5 || params.type == 4 )
        in_sft = in;
        training = in;
        zeropad =  length(params.filter)-1 ;
        out_sft  = in_sft  ;
        out_feed = in_sft(1:zeropad);
        out = in;
         for isymbol=zeropad+1:length(in_sft)
            filtout(isymbol-1) =   sum(out_feed .* params.filter(2:end));
            if ( params.en_block_termination == 1 && mod(isymbol, params.block_size) == 0 )
                in_feed(isymbol) =  in_sft(isymbol);
            else
                in_feed(isymbol) =  in_sft(isymbol) - filtout (isymbol-1);
            end
            [out(isymbol), training(isymbol)]  = mod2M( in_feed(isymbol), params.pam);
            out_feed = [out(isymbol)   out_feed(1:end-1)];
         end 
         training = in + [0 training(2:end)];
    end 

    if ( params.type == 3  && params.en_block_termination == 1)
        in_sft = [-1 in] + params.pam_offset;
        in_sft = in_sft/2;
        num_block = ceil(length(in_sft) / params.block_size);
        zeropad = num_block * params.block_size - length(in_sft);
        in_sft = reshape([in_sft zeros(1, zeropad)], params.block_size, num_block);
        out_sft  = in_sft  ;
        out_sft(1,:) = out_sft(1,:) +1; % Termination symbol
        for isymbol=2:params.block_size
            out_mod =  out_sft(isymbol-1,:) ;
            out_sft(isymbol, :) = in_sft(isymbol, :) + floor( (out_mod)*params.filter(2) ) ; 
        end
        out_sft = out_sft * 2 - params.pam + 1  ;
        out_sft = out_sft(2:end)';
        out(1,:) = out_sft(1:length(in));
        training = out;
    end

    
    if ( params.type == 3  && params.en_block_termination == 0 )
        in_sft = [-1 in] + params.pam_offset;
        in_sft = in_sft/2; 
        out_sft  = in_sft  ; 
        for isymbol=2:length(in_sft)
            out_mod =  out_sft(isymbol-1) ;
            out_sft(isymbol) = in_sft(isymbol) + floor( (out_mod)*params.filter(2) ) ; 
        end
        out_sft = out_sft * 2 - params.pam + 1  ;
        out_sft = out_sft(2:end)';
        out(1,:) = out_sft(1:length(in));
        training = out;
    end    
    
    if ( params.type == 2  && params.en_block_termination == 1 ) % THP 
        params.filter = fie_c(params.filter, params.T.Coef); 
        zeropad =  length(params.filter)-1 ;
        out_sft  = in  ; 
        out_feed = zeros(1,zeropad);
        out_sum  = in;
        in_feed(1) = in(1);
         for isymbol=1:length(in)
            filtout1(isymbol) =   sum(out_feed .* params.filter(2:end));
            filtout(isymbol) =  fie_c(filtout1(isymbol) , params.T.Mul);
            in_feed(isymbol) =  in(isymbol) - filtout (isymbol );
            out_sum(isymbol) = mod( in_feed(isymbol) + params.pam , params.pam *2  )- params.pam   ;
            out_sum(isymbol) = fie_c(out_sum(isymbol), params.T.Sum);
            if ( params.imp_method == 2 && mod(isymbol, params.block_size) == 0 )
                out_sum(isymbol) = in(isymbol) ;
                in_feed(isymbol) = in(isymbol) ;
            end 
            out_feed = [out_sum(isymbol)   out_feed(1:end-1)];            
            if ( params.imp_method == 1  && (mod(isymbol, params.PRL) == 0) )                
                out_feed = [in(isymbol)   out_feed(1:end-1)];   
            end
         end
         training = in - in_feed + out_sum ;         
         training = round(training);     
         training1 = training;
         term_idx =params.NTrainingSymbol+ params.block_size +params.block_size:length(in);
         training(term_idx) = in(term_idx);
         out = fie_c(out_sum, params.T.Out); 
     
        if ( params.fixed_bit == 2 )             
        end 
    
    end
    
    if ( params.type == 2  && params.en_block_termination == 0) % THP 
        params.filter = fie_c(params.filter, params.T.Coef);
        in_sft = in;
        zeropad =  length(params.filter)-1 ;
        out_sft  = in_sft  ; 
        out_feed = zeros(1,zeropad);
        out = in;
         for isymbol=zeropad+1:length(in_sft)
            filtout1(isymbol-1) =   sum(out_feed .* params.filter(2:end));
            filtout(isymbol-1) =  fie_c(filtout1(isymbol-1) , params.T.Mul);
            in_feed(isymbol) =  in_sft(isymbol) - filtout (isymbol-1);
            out(isymbol) = mod( in_feed(isymbol) + params.pam , params.pam *2  )- params.pam   ;
            out_feed = fie_c(out(isymbol), params.T.Out);
            out_feed = [out(isymbol)   out_feed(1:end-1)];
         end
         training = in - in_feed + out ;
         training = round(training);         
    end
    
    if ( params.type == 6  ) %  Precoding (wo modulo)
        params.filter = fie_c(params.filter, params.T.Coef);
        in_sft = in;
        zeropad =  length(params.filter)-1 ;
        out_sft  = in_sft  ;
        out_feed = zeros(1,zeropad);
        out = in;
         for isymbol=zeropad+1:length(in_sft)
            filtout1(isymbol-1) =   sum(out_feed .* params.filter(2:end));
            filtout(isymbol-1) =  fie_c(filtout1(isymbol-1) , params.T.Mul);
            out(isymbol) =  in_sft(isymbol) - filtout (isymbol-1);
            out_feed = fie_c(out(isymbol), params.T.Out);
            out_feed = [out(isymbol)   out_feed(1:end-1)];
         end
         training = in - in_feed + out ;
         training = round(training);
    end

    if ( sims.print_tx_testvector ==  1 )
    end
end

function [out, training]=  mod2M( in,  M)
    out = in ;
    training = 0 ;
    if ( in > 2*M -1)
       out = out -  2* M;
       training = -  2* M;
       return;
    end 
    if ( in <= - (2*M -1 ))
       out = out +  2*M;
       training = +  2*M;
       return;
    end 
end
