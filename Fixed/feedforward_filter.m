function [ffeout, ffe, vffe, v3ffe ] = feedforward_filter  ...
                                ( AIN, ck, ek, e3k, dc1, dc2,  params  )
    PRL         = params.PRL * params.OV;
    NStream     = params.NStream;
    ffe         = complex( zeros(params.NStream, PRL) );     
    vffe         = complex( zeros(params.NStream, PRL) );   
    v3ffe         = complex( zeros(params.NStream, PRL) );   
    %% Feedforware filter
    for os=1:params.NStream 
        for idx=1:PRL 
            ffe_mul = (AIN(:,idx:idx+params.Nffe -1) + dc2(os:NStream:end)* ones(1,params.Nffe ) ).* ck(os:NStream:end, :) ;
            ffe_mul = fie_c(ffe_mul, params.T.FFEMul);
            ffe(os, idx) = sum(sum( ffe_mul )) ;        
        end
        ffe(os, :) = ffe(os,:) + dc1(os);      
    end
    ffe = fie_c(ffe, params.T.FFE);
%     [vffe]  = volterra_fe  ( AIN,  ek, params);
%     [v3ffe] = volterra3_fe ( AIN, e3k, params);
%     ffeout = ffe + vffe + v3ffe;

    ffeout = ffe ;
    if ( params.fixed_bit == 2 )
    end

end


function [vffe] = volterra_fe ( in1, ek, params  )
    PRL         = params.PRL * params.OV;
    vffe    = complex( zeros(params.NStream, PRL));
    if ( params.W == 0 || params.Npfe ==0 )
        return;
    end

    offset = floor(params.Npostcursor - (params.Npfe-1) /2);
    in     = in1(:, offset+1:end);
    W_1   = floor(params.W/2);
    for os=1:params.NStream 
        for idx=1:PRL 
            for iW=1:params.W 
                vffe_mul =   in1(:,idx+offset+(0:params.Npfe -1)) .* ...
                              in1(:,(iW-1)+0+(idx+offset)+(0:params.Npfe -1)) .* ...
                                   ek(os:params.NStream:end, :, iW) ;
                vffe(os, idx) = vffe(os,idx) + sum( sum( vffe_mul, 2));
            end
        end
    end
end

function [v3ffe] = volterra3_fe ( in1, e3k, params  )
    PRL         = params.PRL * params.OV;
    v3ffe    = complex( zeros(params.NStream, PRL));
    if ( params.W3 == 0 || params.Np3fe ==0 )
        return;
    end

    offset = floor(params.Npostcursor - (params.Np3fe-1) /2);
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
                   v3ffe(os, idx) = v3ffe(os,idx) + sum(sum( v3ffe_mul, 2));
                end
            end
        end
    end
end
