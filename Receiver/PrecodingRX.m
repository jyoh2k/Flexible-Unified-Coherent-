function [out]=  PrecodingRX( in, dec, sim, params )

%  Usage      : [out]=  PrecodingRX( in,  sim, params )
%  Function   :
%     1.  Precoding 1/(1+D) precoding 
%
%     2.  Tomlinson-HararaShmia Coding precoding
%
%     3.  Nonlinear Trellis coded modulator 
%          v(n) = u(n) + [v(n-1)/2]
%          in case of PAM4 : u(n) =0~ 3, v(n) = 0,1,2,3,4,5
%
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :

out = dec;
if ( params.en == 0 )
    return
end

if ( params.type == 2 || params.type == 4 )
    out = mod(in-1, params.pam) + 1;
    in = out;
    dec = out;
    if ( params.type == 2)
         return;
    end
end
 
if ( params.type == 5  )
    out = mod(in-1, params.pam) + 1;
    in = out;
    dec = out; 
     return; 
end

if ( params.type == 1 || params.type == 4 )
    prev_symbol = (params.prev_symbol)-1; 
    in_sft = [ prev_symbol in-1];
    dec_sft= [ prev_symbol dec-1];
    num_block = ceil(length(in_sft) / params.block_size);
    zeropad = num_block * params.block_size - length(in_sft);
    in_sft  = reshape([ in_sft zeros(1, zeropad)], params.block_size, num_block); 
    dec_sft = reshape([dec_sft zeros(1, zeropad)], params.block_size, num_block); 
    out_sft =  [in_sft; zeros(1, num_block);] + [zeros(1, num_block); in_sft;];
    out_sft =  [in_sft; zeros(1, num_block);] + [zeros(1, num_block); dec_sft;]; 
     if ( params.en_block_termination  == 1 )
          out_sft =  [in_sft(1, :); out_sft(2:end-1, :); ];
     else
          out_sft =  [out_sft(1:end-1, :)];
     end     
     out_sft  = mod(out_sft,  params.pam)+1;
     out(1:end) =out_sft(2:1+length(in));
     return;
end


if ( params.type == 3 )    
    if ( params.en_block_termination  == 1 )
        in1 = [ 2 in]; 
        num_block = ceil(length(in1) / params.block_size);
        zeropad = num_block * params.block_size - length(in1);
        in_sft  = reshape([ in1 zeros(1, zeropad)], params.block_size, num_block);
        out_sft = in_sft;
        for isym=2:params.block_size
            prev_v = floor( in_sft(isym-1,:) /2  );
            out_sft(isym,:) =   out_sft(isym,:) - prev_v ; 
        end
        out_sft = out_sft(:);
    else
         in_sft = [ 2 in]; 
         out_sft = in_sft;
         for isym=2:length(in_sft)
            prev_v = floor( in_sft(isym-1) /2  );
            out_sft(isym ) =   out_sft(isym ) - prev_v ; 
         end 
    end 
    out_sft = out_sft(2:end)';
    out(1:end) =out_sft( 1:length(in)) + 1;
    return;
end
