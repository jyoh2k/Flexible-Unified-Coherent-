function out = TxNLPredistortion(in, params)

%  Usage      : out = TxNLPredistortion(in, params)
%  Function   : Nonlinear predistoriton (nonlinear)
%
%
%
%  Author     : Rha, Hae Young.
    if ( params.en == 0 )
        out = in;
        return;
    end 

    ck  = fie_c(params.ck, params.T.CK);
    ek  = fie_c(params.ek, params.T.EK);
    dk  = fie_c(params.dk, params.T.DK);
    e3k = fie_c(params.e3k, params.T.E3K);
    
    params.PRL = size(in,2);
    params.NStream = size(in,1);

    in_pad        = [zeros(size(in,1), params.Npostcursor), in, zeros(size(in,1), params.Nffe )];

    [ffe]   = linear_fe( in_pad, ck,  params);
    
    [vffe]  = volterra_fe( in_pad, ek,  params);
%     [v3ffe] = volterra3_fe( in_pad, e3k, params);

    out = ffe + vffe;
%     out = ffe + vffe + v3ffe;
%     out= filter([1], [1 dk] , out);   
    out= out + params.dc; % dc term add
    out = fie_c(out, params.T.EQOut);
end 
 
function [ffe] = linear_fe ( in, ck, params  )
    PRL         = params.PRL;
    ffe    = complex( zeros(params.NStream, PRL));
    %% Feedforware filter
    for os=1:params.NStream 
        for idx=1:PRL 
            ffe_mul = sum( in(:,idx:idx+params.Nffe -1) .* ck(os:params.NStream:end, :),2);
            ffe(os, idx) = sum( ffe_mul ) ;   
        end
    end
    ffe = fie_c( ffe, params.T.FFE);
end 


function [ffe] = linear_fe_fixed ( in, ck, params  )
    PRL         = params.PRL;
    %% Feedforware filter
    for os=1:params.NStream 
        for idx=1:PRL               
            ffe_mul =  in(:,idx:idx+params.Nffe -1) .* ck(os:params.NStream:end, :);
            ffe_mul = fie_c( ffe_mul, params.T.FFEMul) ;
            ffe_sum = sum(sum(ffe_mul, 2));
            ffe(os, idx) =  ffe_sum  ;              
        end
    end
end 
 
function [vffe] = volterra_fe ( in1, ek, params  )
    PRL         = params.PRL;
    vffe    = complex( zeros(params.NStream, PRL));
    if ( params.W == 0 || params.Npfe ==0 )
        return;
    end

    offset = floor(params.Npostcursor - (params.Npbe-1) /2);
    in     = in1(:, offset+1:end);
    for os=1:params.NStream 
        for idx=1:PRL 
            for iW=1:params.W 
                vffe_mul =   in1(:,idx+offset+(0:params.Npfe -1)) .* ...
                              in1(:,(iW-1)+0+(idx+offset)+(0:params.Npfe -1)) .* ...
                                   ek(os:params.NStream:end, :, iW) ;
                vffe(os, idx) = vffe(os,idx) + sum( vffe_mul, 2);
            end
        end
    end
end


function [vffe] = volterra_fe_fixed ( in1, ek, params  )
    PRL         = params.PRL;
    vffe    = complex( zeros(params.NStream, PRL));
    if ( params.W == 0 || params.Npfe ==0 )
        return;
    end

    offset = floor(params.Npostcursor - (params.Npbe-1) /2);
    in     = in1(:, offset+1:end);
    for os=1:params.NStream 
        for idx=1:PRL 
            for iW=1:params.W 
                vffe_mul =   in1(:,idx+offset+(0:params.Npfe -1)) .* ...
                              in1(:,(iW-1)+0+(idx+offset)+(0:params.Npfe -1)) .* ...
                                   ek(os:params.NStream:end, :, iW) ;
                vffe_mul = fie_c( vffe_mul, params.T.VFEMul);
                vffe_mul_sum = sum( vffe_mul, 2);
                vffe_mul_sum = fie_c( vffe_mul_sum, params.T.VFEMulSum);
                vffe(os, idx) = vffe(os,idx) + vffe_mul_sum;
            end
        end
    end
end

function [v3ffe] = volterra3_fe ( in1, e3k, params  )
    PRL         = params.PRL;
    v3ffe    = complex( zeros(params.NStream, PRL));
    if ( params.W3 == 0 || params.Np3fe ==0 )
        return;
    end

    offset = floor(params.Npostcursor - (params.Np3be-1) /2);
    in     = in1(:, offset+1:end);
    for os=1:params.NStream
        for idx=1:PRL
            iW=0;
            for iW1=1:params.W3
               for iW2=iW1:params.W3
                   iW=iW+1;
                   v3ffe_mul =  in1(:,idx+offset+(0:params.Np3fe -1)) .* ...
                                in1(:,(iW1-1)+0+(idx+offset)+(0:params.Np3fe -1)) .* ...
                                in1(:,(iW2-1)+0+(idx+offset)+(0:params.Np3fe -1)) .* ...
                                e3k(os:params.NStream:end, :, iW) ;
                   v3ffe(os, idx) = v3ffe(os,idx) + sum( v3ffe_mul, 2);
                end
            end
        end
    end
end


function [v3ffe] = volterra3_fe_fixed ( in1, e3k, params  )
    PRL         = params.PRL;
    v3ffe    = complex( zeros(params.NStream, PRL));
    if ( params.W3 == 0 || params.Np3fe ==0 )
        return;
    end

    offset = floor(params.Npostcursor - (params.Np3be-1) /2);
    in     = in1(:, offset+1:end);
    for os=1:params.NStream
        for idx=1:PRL
            iW=0;
            for iW1=1:params.W3
               for iW2=iW1:params.W3
                   iW=iW+1;
                   v3ffe_mul =  in1(:,idx+offset+(0:params.Np3fe -1)) .* ...
                                in1(:,(iW1-1)+0+(idx+offset)+(0:params.Np3fe -1)) .* ...
                                in1(:,(iW2-1)+0+(idx+offset)+(0:params.Np3fe -1)) .* ...
                                e3k(os:params.NStream:end, :, iW) ;
                   v3ffe_mul = fie_c( v3ffe_mul, params.T.V3FEMul);
                   v3ffe_mul_sum = sum( v3ffe_mul, 2);
                   v3ffe_mul_sum = fie_c( v3ffe_mul_sum, params.T.V3FEMulSum);
                   v3ffe(os, idx) = v3ffe(os,idx) + v3ffe_mul_sum;
                end
            end
        end
    end
end
