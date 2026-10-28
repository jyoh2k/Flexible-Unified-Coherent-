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

    ck  = params.ck; 
    dk  = params.dk; 
    params.PRL = size(in,2);
    params.NStream = size(in,1);

    in_pad        = [zeros(size(in,1), params.Npostcursor), in, zeros(size(in,1), params.Nffe )];

    [ffe]   = linear_fe    ( in_pad, ck,  params); 
    out = ffe;
    out= filter([1], [1 dk] , out);    
end 
 
function [ffe] = linear_fe ( in, ck, params  )
    PRL         = params.PRL;
    %% Feedforware filter
    for os=1:params.NStream 
        for idx=1:PRL 
            ffe_mul = sum( in(:,idx:idx+params.Nffe -1) .* ck(os:params.NStream:end, :),2);
            ffe(os, idx) = sum( ffe_mul ) ;        
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

